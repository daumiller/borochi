#import <Cocoa/Cocoa.h>
#import <BBAddressBar_TableRowView.h>

@implementation BBAddressBar_TableRowView

-(void)drawSelectionInRect:(NSRect)dirtyRect {
    [super drawSelectionInRect:dirtyRect];

    NSRect selectionRect = NSInsetRect(self.bounds, 0.5, 0.5);
    [[NSColor keyboardFocusIndicatorColor] set];
    NSRectFillUsingOperation(selectionRect, NSCompositingOperationSourceOver);
}

@end
