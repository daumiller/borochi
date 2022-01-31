#import <Cocoa/Cocoa.h>
#import <BBAddressBar.h>
#import <BBAddressBar_TableRowView.h>

@implementation BBAddressBar

// === Lifecycle functions ======================================================================================================
+(instancetype)textFieldWithString:(NSString*)string {
    BBAddressBar* addressBar = [super textFieldWithString:string];
    [addressBar setup];
    return addressBar;
}
-(void)setup {
    self.delegate = self;
    [self setAlignment:NSTextAlignmentCenter];
    [[self cell] setSendsActionOnEndEditing:NO]; // ensure we ONLY fire committed actions for ENTER key presses

    _addressCommittedDelegate = nil;

    _progressBarActive = false;
    _progressBarValue  = 0.0;

    _keyDownMonitor         = nil;
    _autocompleteSource     = nil;
    _autocompleteEnabled    = NO;
    _autocompleteMaxResults = 10;
    _autocompletions        = [[NSArray alloc] init];

    _autocompletePopover          = [[NSPopover        alloc] init];
    _autocompletePopoverHideArrow = [[NSView           alloc] init];
    _autocompleteViewController   = [[NSViewController alloc] init];
    _autocompleteTable            = [[NSTableView      alloc] init];

    [_autocompleteViewController setView:_autocompleteTable];
    [_autocompletePopover setContentViewController:_autocompleteViewController];
    _autocompletePopover.behavior = NSPopoverBehaviorTransient; // NSPopoverBehaviorApplicationDefined;
    _autocompletePopover.animates = NO;

    NSTableColumn* column = [[NSTableColumn alloc] initWithIdentifier:@"Completions"];
    column.editable = false;
    [_autocompleteTable addTableColumn:column];
    column = nil;

    _autocompleteTable.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;
    _autocompleteTable.backgroundColor         = [NSColor clearColor];  // [NSColor purpleColor]
    _autocompleteTable.rowSizeStyle            = NSTableViewRowSizeStyleSmall;
    _autocompleteTable.intercellSpacing        = NSMakeSize(10.0f, 0.0f);
    _autocompleteTable.headerView              = nil;
    _autocompleteTable.refusesFirstResponder   = YES;
    _autocompleteTable.target                  = self;
    _autocompleteTable.doubleAction            = @selector(autocompleteChosen:);
    _autocompleteTable.delegate                = self;
    _autocompleteTable.dataSource              = self;
    _autocompleteTable.columnAutoresizingStyle = NSTableViewNoColumnAutoresizing;
}

// === BB functions =============================================================================================================
-(void)setProgressBarActive:(BOOL)active {
    _progressBarActive = active;
    [self setNeedsDisplay:YES];
}

-(void)setProgressBarValue:(double)value {
    _progressBarValue = value;
    [self setNeedsDisplay:YES];
}

// === NSTextFieldDelegate (and related) ========================================================================================
#define KEYCODE_RETURN  36
#define KEYCODE_ENTER   76
#define KEYCODE_TAB     48
#define KEYCODE_DELETE  51
#define KEYCODE_ESCAPE  53
#define KEYCODE_DOWN   125
#define KEYCODE_UP     126

-(void)textDidBeginEditing:(NSNotification*)notification {
    [self.currentEditor setNextKeyView:self.nextKeyView];
    [(NSTextView*)(self.currentEditor) setInsertionPointColor:[NSColor textColor]];

    // simply implementing keyDown: doesn't work...; we need something more aggressive
    if(!_keyDownMonitor) {
        _keyDownMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^(NSEvent* event) {

            if((self.autocompleteEnabled == YES) && (_autocompletePopover.shown == YES)) {
                switch(event.keyCode) {
                    case KEYCODE_ESCAPE: [self autocompleteHide       ]; event = nil; break;
                    case KEYCODE_UP    : [self autocompleteScrollUp   ]; event = nil; break;
                    case KEYCODE_DOWN  : [self autocompleteScrollDown ]; event = nil; break;
                    case KEYCODE_ENTER : [self autocompleteChosen:self]; /*not nil*/  break;
                    case KEYCODE_RETURN: [self autocompleteChosen:self]; /*not nil*/  break;
                    // TODO : on KEYCODE_DELETE, tell autocompleter to delete that item, and remove it from our list of completions
                    //        but, how do we differentiate from actually deleting text? maybe we use SHITFT+DELETE?
                }
            }
            if((event.keyCode == KEYCODE_ENTER) || (event.keyCode == KEYCODE_RETURN)) {
                if(self.addressCommittedDelegate != nil) {
                    [self.addressCommittedDelegate addressBarCommitted:[self stringValue]];
                }
                event = nil;
            }

            return event;
        }];
    }
}

-(void)textDidChange:(NSNotification*)notification {
    if(self.autocompleteEnabled == NO) { return; }

    if(self.autocompleteSource) {
        _autocompletions = [self.autocompleteSource completionsForPartial:[self stringValue]];
    } else if(_autocompletions.count > 0) {
        _autocompletions = [NSArray array];
    }

    [self autocompleteDeselect];
    if(_autocompletions.count == 0) {
        [self autocompleteHide];
    } else {
        [_autocompleteTable reloadData];
        [self autocompleteShow];
    }
}

-(void)textDidEndEditing:(NSNotification*)notification {
    [(NSTextView*)(self.currentEditor) setInsertionPointColor:[NSColor clearColor]];
    [self.currentEditor setSelectedRange:NSMakeRange([self stringValue].length, 0)];

    if(!_keyDownMonitor) { return; }
    [NSEvent removeMonitor:_keyDownMonitor];
    _keyDownMonitor = nil;
}

// === NSTextField Overrides ====================================================================================================
-(BOOL)becomeFirstResponder {
    BOOL result = [super becomeFirstResponder];
    if(!result) { return NO; }
    [(NSTextView*)(self.currentEditor) setInsertionPointColor:[NSColor textColor]];

    // when activated, always select-all, so new addresses can be more easily typed
    // delay here is so the contained cell can finish setup before we select-all
    [self performSelector:@selector(selectText:) withObject:self afterDelay:0];

    return YES;
}

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    if(_progressBarActive) {
        NSRect progressRect = [self bounds];
        progressRect.size.width *= _progressBarValue;

        [[NSColor keyboardFocusIndicatorColor] set];
        NSRectFillUsingOperation(progressRect, NSCompositingOperationSourceOver);
    }
}

// === Autocomplete Helpers =====================================================================================================
-(void)autocompleteShow {
    [self autocompleteResize];

    // resize even if we're currently shown, otherwise ignore
    if(_autocompletePopover.shown == YES) { return; }
    [self autocompleteDeselect];

    [self addSubview:_autocompletePopoverHideArrow positioned:NSWindowBelow relativeTo:nil];
    NSRect hideRect = self.frame;
    hideRect.size.height -= 16.0;
    _autocompletePopoverHideArrow.frame = hideRect;
    // this really should be NSRectEdgeMaxY instead of NSRectEdgeMinY; but, this works and that doesn't...
    [_autocompletePopover showRelativeToRect:[self visibleRect] ofView:_autocompletePopoverHideArrow preferredEdge:NSRectEdgeMinY];
    _autocompletePopoverHideArrow.frame = NSMakeRect(0, -200, 10, 10);
}

-(void)autocompleteHide {
    if(_autocompletePopover.shown == NO) { return; }
    [_autocompletePopover close];
    [_autocompletePopoverHideArrow removeFromSuperview];
}

-(void)autocompleteDeselect {
    [_autocompleteTable deselectAll:self];
}

-(void)autocompleteScrollTop {
    [_autocompleteTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

-(void)autocompleteScrollUp {
    NSInteger selectedRowIndex = _autocompleteTable.selectedRow;
    --selectedRowIndex;
    if(selectedRowIndex < 0) {
        [_autocompleteTable deselectAll:self];
        return;
    }

    [_autocompleteTable selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRowIndex] byExtendingSelection:NO];
}

-(void)autocompleteScrollDown {
    NSInteger selectedRowIndex = _autocompleteTable.selectedRow;
    ++selectedRowIndex;
    if(selectedRowIndex >= _autocompleteTable.numberOfRows) {
        selectedRowIndex = 0;
    }

    [_autocompleteTable selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRowIndex] byExtendingSelection:NO];
}

-(void)autocompleteResize {
    NSInteger resizeWidth  = self.bounds.size.width;
    NSInteger resizeHeight = _autocompleteTable.intrinsicContentSize.height;
    if(resizeHeight < 24.0f) { resizeHeight = 24.0f; } // TODO : actual size of a single row
    
    NSTableColumn* column = [_autocompleteTable.tableColumns objectAtIndex:0];
    column.width = column.minWidth = resizeWidth;

    NSRect atBounds = _autocompleteTable.bounds;
    atBounds.size.width  = resizeWidth;
    atBounds.size.height = resizeHeight;
    _autocompleteTable.bounds = atBounds;

    [_autocompletePopover setContentSize:NSMakeSize(resizeWidth, resizeHeight)];
}

-(NSString*)autocompleteSelectedValue {
    NSInteger selectedRowIndex = _autocompleteTable.selectedRow;
    if(selectedRowIndex >= [_autocompletions count]) {
        return nil;
    }
    return [_autocompletions objectAtIndex:selectedRowIndex];
}

-(void)autocompleteChosen:(id)sender {
    [self autocompleteHide];
    NSString* completedString = [self autocompleteSelectedValue];
    if(completedString == nil) { return; }
    [self setStringValue:completedString];
}

// === NSTableViewDelegate ======================================================================================================
-(NSTableRowView*)tableView:(NSTableView*)table rowViewForRow:(NSInteger)row {
    return [[BBAddressBar_TableRowView alloc] init];
}

-(NSView*)tableView:(NSTableView*)table viewForTableColumn:(NSTableColumn*)column row:(NSInteger)row {
    NSString* stringAtRow = (row >= _autocompletions.count) ? @"" : [_autocompletions objectAtIndex:row];

    NSTableCellView* cell = [[NSTableCellView alloc] init];
    NSTextField* cellText = [[NSTextField alloc] init];
    cellText.bezeled         = NO;
    cellText.drawsBackground = NO;
    cellText.editable        = NO;
    cellText.selectable      = NO;
    [cell addSubview:cellText];
    [cell setTextField:cellText];
    [cell setIdentifier:@"BBAutocompleteTableCellView"];

    NSDictionary<NSAttributedStringKey, id>* attributeStringValues = @{ NSForegroundColorAttributeName:[NSColor whiteColor], NSFontAttributeName:[NSFont systemFontOfSize:14.0] };
    NSMutableAttributedString* attributesString = [[NSMutableAttributedString alloc] initWithString:stringAtRow attributes:attributeStringValues];
    cellText.attributedStringValue = attributesString;

    return cell;
}

// === NSTableViewDataSource ====================================================================================================
-(NSInteger)numberOfRowsInTableView:(NSTableView*)view {
    NSInteger rows = _autocompletions.count;
    if(rows > _autocompleteMaxResults) {
        rows = _autocompleteMaxResults;
    }
    return rows;
}

-(id)tableView:(NSTableView*)view objectValueForTableColumn:(NSTableColumn*)column row:(NSInteger)row {
    if(row >= _autocompletions.count) { return nil; }
    return [_autocompletions objectAtIndex:row];
}

@end
