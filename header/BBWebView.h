#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

// forward declared to resolve circular import dependency
@class BBBrowser;

@interface BBWebView : NSObject <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (readonly) WKWebView* webkit;
@property (weak)     BBBrowser* browser;

// === Lifecycle functions ======================================================================================================
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithBrowser:(BBBrowser*)browser andConfiguration:(WKWebViewConfiguration*)configuration NS_DESIGNATED_INITIALIZER;
-(void)cleanup;

// === BB functions =============================================================================================================
-(void)navigateBackward;
-(void)navigateForward;
-(void)navigateReload;
-(void)navigateToURL:(NSURL*)url;
-(BOOL)canNavigateBackward;
-(BOOL)canNavigateForward;

// === WKNavigationDelegate =====================================================================================================
-(void)webView:(WKWebView*)webkit didStartProvisionalNavigation:(WKNavigation*)navigation;
-(void)webView:(WKWebView*)webkit didFinishNavigation:(WKNavigation*)navigation;
-(void)webView:(WKWebView*)webkit decidePolicyForNavigationAction  :(WKNavigationAction*)navigationAction     decisionHandler:(void (^)(WKNavigationActionPolicy  ))decisionHandler;
-(void)webView:(WKWebView*)webkit decidePolicyForNavigationResponse:(WKNavigationResponse*)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;

// === WKUIDelegate =============================================================================================================
-(WKWebView*)webView:(WKWebView*)webkit createWebViewWithConfiguration:(WKWebViewConfiguration*)configuration forNavigationAction:(WKNavigationAction*)navigationAction windowFeatures:(WKWindowFeatures*)windowFeatures;

// === WKScriptMessageHandler ===================================================================================================
-(void)userContentController:(WKUserContentController*)userContentController didReceiveScriptMessage:(WKScriptMessage*)message;

// === KVO ======================================================================================================================
-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id>*)change context:(void*)context;

@end
