#import <Cocoa/Cocoa.h>

@protocol BBAddressCompletionSource
-(NSArray<NSString*>*)completionsForPartial:(NSString*)string;
-(void)removeCompletion:(NSString*)completion;
@end

@protocol BBAddressBarCommittedDelegate
-(void)addressBarCommitted:(NSString*)address;
@end

@interface BBAddressBar : NSTextField <NSTextFieldDelegate, NSTableViewDelegate, NSTableViewDataSource> {
    BOOL   _progressBarActive;
    double _progressBarValue; // 0.0 - 1.0

    id                _keyDownMonitor;
    NSPopover*        _autocompletePopover;
    NSView*           _autocompletePopoverHideArrow;
    NSViewController* _autocompleteViewController;
    NSTableView*      _autocompleteTable;

    NSArray<NSString*>* _autocompletions;
}

@property (weak) id <BBAddressCompletionSource> autocompleteSource;
@property BOOL                                  autocompleteEnabled;
@property NSInteger                             autocompleteMaxResults;

@property (weak) id <BBAddressBarCommittedDelegate> addressCommittedDelegate;

// === Lifecycle functions ======================================================================================================
+(instancetype)textFieldWithString:(NSString*)string;

// === BB functions =============================================================================================================
-(void)setProgressBarActive:(BOOL)active;
-(void)setProgressBarValue :(double)value;

@end
