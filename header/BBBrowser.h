#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <BBAddressBar.h>

@interface BBBrowser : NSObject <NSWindowDelegate, NSToolbarDelegate, NSToolbarItemValidation, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler> {
    NSWindow*     window;
    WKWebView*    webview;
    NSURL*        address;
    BBAddressBar* addressBar;
}

// === Lifetime functions =========================================================================================================
-(BBBrowser*)init;
-(BBBrowser*)initWithConfiguration:(WKWebViewConfiguration*)configuration;

// === BB functions =============================================================================================================
-(void)navigateToURL:(NSURL*)url;
-(void)navigateToString:(NSString*)string;
// -(void)navigateBackward;
// -(void)navigateForward;
// -(void)navigateReload;

// === Window functions =========================================================================================================
-(NSWindow*)window;
-(BOOL)windowShouldClose:(id)sender;
-(void)windowWillClose:(NSNotification*)notification;

// === Menu functions =========================================================================================================
-(void)menuAppHandler :(NSMenuItem*)sender;
-(void)menuEditHandler:(NSMenuItem*)sender;

// === Toolbar functions =========================================================================================================
-(NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*)identifier willBeInsertedIntoToolbar:(BOOL)insert;
-(NSArray<NSToolbarItemIdentifier>*)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar;
-(NSArray<NSToolbarItemIdentifier>*)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar;
-(NSArray<NSToolbarItemIdentifier>*)toolbarSelectableItemIdentifiers:(NSToolbar*)toolbar;
-(BOOL)validateToolbarItem:(NSToolbarItem*)item;
-(void)toolbarItemClicked:(NSToolbarItem*)item;
-(void)addressEntered:(id)sender;

// === WebKit functions =========================================================================================================
-(WKWebView*)webview;
-(void)webView:(WKWebView*)webView didStartProvisionalNavigation:(WKNavigation*)navigation;
-(WKWebView*)webView:(WKWebView*)webView createWebViewWithConfiguration:(WKWebViewConfiguration*)configuration forNavigationAction:(WKNavigationAction*)navigationAction windowFeatures:(WKWindowFeatures*)windowFeatures;
-(void)userContentController:(WKUserContentController*)userContentController didReceiveScriptMessage:(WKScriptMessage*)message;

@end
