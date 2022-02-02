#import <Cocoa/Cocoa.h>
#import <BBAddressBar.h>
#import <BBWebView.h>
#import <BBAddressBar.h>
#import <BBAutocompleteMock.h>

@interface BBBrowser : NSObject <NSWindowDelegate, NSToolbarDelegate, NSToolbarItemValidation, BBAddressBarCommittedDelegate> {
    BOOL _browserClosing;
}

@property NSWindow*            window;
@property BBAddressBar*        addressBar;
@property BBWebView*           webview;
@property BBAutocompleteMock*  addressCompletions;

// === Lifecycle functions ======================================================================================================
-(instancetype)init;
-(instancetype)initWithConfiguration:(WKWebViewConfiguration*)configuration NS_DESIGNATED_INITIALIZER;

// === BB functions =============================================================================================================
-(void)navigateToURL:(NSURL*)url;
-(void)navigateToString:(NSString*)string;
-(NSURL*)currentURL;

// === NSWindowDelegate =========================================================================================================
-(BOOL)windowShouldClose:(id)sender;
-(void)windowWillClose:(NSNotification*)notification;

// === Menu functions ===========================================================================================================
-(void)menuAppHandler     :(NSMenuItem*)sender;
-(void)menuEditHandler    :(NSMenuItem*)sender;
-(void)menuNavigateHandler:(NSMenuItem*)sender;
-(BOOL)validateMenuItem   :(NSMenuItem*)item;

// === Toolbar functions ========================================================================================================
-(NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*)identifier willBeInsertedIntoToolbar:(BOOL)insert;
-(NSArray<NSToolbarItemIdentifier>*)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar;
-(NSArray<NSToolbarItemIdentifier>*)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar;
-(NSArray<NSToolbarItemIdentifier>*)toolbarSelectableItemIdentifiers:(NSToolbar*)toolbar;
-(BOOL)validateToolbarItem:(NSToolbarItem*)item;
-(void)toolbarItemClicked:(NSToolbarItem*)item;

@end
