#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <BBAddressBar.h>

@interface BBBrowser : NSObject <NSWindowDelegate, NSToolbarDelegate, NSToolbarItemValidation, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property NSWindow*     window;
@property WKWebView*    webview;
@property BBAddressBar* addressBar;

// === Lifecycle functions ======================================================================================================
-(instancetype)init;
-(instancetype)initWithConfiguration:(WKWebViewConfiguration*)configuration NS_DESIGNATED_INITIALIZER;

// === BB functions =============================================================================================================
-(void)navigateToURL:(NSURL*)url;
-(void)navigateToString:(NSString*)string;
// -(void)navigateBackward;
// -(void)navigateForward;
// -(void)navigateReload;

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
-(void)addressEntered:(id)sender;

// === WebKit functions =========================================================================================================
-(void)webView:(WKWebView*)webView didStartProvisionalNavigation:(WKNavigation*)navigation;
-(void)webView:(WKWebView*)webView didFinishNavigation:(WKNavigation*)navigation;
-(WKWebView*)webView:(WKWebView*)webView createWebViewWithConfiguration:(WKWebViewConfiguration*)configuration forNavigationAction:(WKNavigationAction*)navigationAction windowFeatures:(WKWindowFeatures*)windowFeatures;
-(void)userContentController:(WKUserContentController*)userContentController didReceiveScriptMessage:(WKScriptMessage*)message;
-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id>*)change context:(void*)context;

@end
