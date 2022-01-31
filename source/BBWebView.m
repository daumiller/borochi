#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <BBApplication.h>
#import <BBBrowser.h>
#import <BBWebView.h>

@implementation BBWebView

// === Lifecycle functions ======================================================================================================
-(instancetype)init {
    // *could* be called since we inherit NSObject;
    // but an invalid case for us
    @throw nil;
}

-(instancetype)initWithBrowser:(BBBrowser*)browser andConfiguration:(WKWebViewConfiguration*)configuration {
    self = [super init];
    if(self) {
        self.browser = browser;

        if(configuration == nil) {
            configuration = [[WKWebViewConfiguration alloc] init];
        }

        [[configuration preferences] setValue:@YES forKey:@"developerExtrasEnabled"];
        [[configuration preferences] setValue:@YES forKey:@"fullScreenEnabled"];
        [[configuration preferences] setValue:@YES forKey:@"javaScriptCanAccessClipboard"];
        [[configuration preferences] setValue:@YES forKey:@"DOMPasteAllowed"];
        // WKUserContentController* content_controller = [config userContentController];
        // [content_controller addScriptMessageHandler:self name:@"nativeAlert"];

        _webkit = [[WKWebView alloc] initWithFrame:CGRectMake(0,0,0,0) configuration:configuration];
        [self.webkit setNavigationDelegate:self];
        [self.webkit setUIDelegate:self];

        [self.browser.window setContentView:self.webkit];

        // observers for properties that will update the UI
        [self.webkit addObserver:self forKeyPath:@"title"             options:NSKeyValueObservingOptionNew context:NULL];
        [self.webkit addObserver:self forKeyPath:@"loading"           options:NSKeyValueObservingOptionNew context:NULL];
        [self.webkit addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];

        // set user agent
        [self buildUserAgent];
    }

    return self;
}

-(void)buildUserAgent {
    NSBundle* webkitBundle  = [NSBundle bundleWithIdentifier:@"com.apple.WebKit"];
    NSString* webkitVersion = [[webkitBundle infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString* userAgent     = [NSString stringWithFormat:@"Borochi/1.0 (AppleWebKit/%@)", webkitVersion];
    self.webkit.customUserAgent = userAgent;
}

-(void)cleanup {
    // remove our Observers
    [self.webkit removeObserver:self forKeyPath:@"title"             context:NULL];
    [self.webkit removeObserver:self forKeyPath:@"loading"           context:NULL];
    [self.webkit removeObserver:self forKeyPath:@"estimatedProgress" context:NULL];
}

// === BB functions =============================================================================================================
-(void)navigateBackward    {        [self.webkit goBack          ]; }
-(void)navigateForward     {        [self.webkit goForward       ]; }
-(void)navigateReload      {        [self.webkit reloadFromOrigin]; }
-(BOOL)canNavigateBackward { return [self.webkit canGoBack       ]; }
-(BOOL)canNavigateForward  { return [self.webkit canGoForward    ]; }

-(void)navigateToURL:(NSURL*)url {
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url];
    [self.webkit loadRequest:request];
    request = nil;

    if(self.browser.addressBar != nil) {
        [self.browser.addressBar setStringValue:[url absoluteString]];
    }
}

// === WKNavigationDelegate =====================================================================================================
-(void)webView:(WKWebView*)webkit didStartProvisionalNavigation:(WKNavigation*)navigation {
    if(self.browser.addressBar != nil) {
        [self.browser.addressBar setStringValue:[[self.webkit URL] absoluteString]];
    }
}

-(void)webView:(WKWebView*)webkit didFinishNavigation:(WKNavigation*)navigation {
    // TODO : useful to keep this?
}

-(void)webView:(WKWebView*)webkit decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // TODO : added this as prep for storing cookies (https://stackoverflow.com/questions/39772007/wkwebview-persistent-storage-of-cookies) ,
    // but they seem have started "just work"ing? (as long as the app isn't rebuilt)

    // TODO : load any stored cookies here

    decisionHandler(WKNavigationActionPolicyAllow);
}

-(void)webView:(WKWebView*)webkit decidePolicyForNavigationResponse:(WKNavigationResponse*)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    // TODO: save any stored cookies here

    decisionHandler(WKNavigationResponsePolicyAllow);
}

// === WKUIDelegate =============================================================================================================
-(WKWebView*)webView:(WKWebView*)webkit createWebViewWithConfiguration:(WKWebViewConfiguration*)configuration forNavigationAction:(WKNavigationAction*)navigationAction windowFeatures:(WKWindowFeatures*)windowFeatures {
    if([navigationAction targetFrame] && [[navigationAction targetFrame] isMainFrame]) {
        return nil;
    }

    BBApplication* application = [NSApp delegate];
    BBBrowser* browser = [application newTabWithURL:[[navigationAction request] URL] andConfiguration:configuration];
    application = nil;

    return browser.webview.webkit;
}

// === WKScriptMessageHandler ===================================================================================================
-(void)userContentController:(WKUserContentController*)userContentController didReceiveScriptMessage:(WKScriptMessage*)message {
    // JS integration interface
}

// === KVO ======================================================================================================================
-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id>*)change context:(void*)context {
    if([keyPath isEqual:@"title"]) {
        [self.browser.window setTitle:self.webkit.title];
        return;
    }

    if([keyPath isEqual:@"loading"]) {
        [self.browser.addressBar setProgressBarActive:[self.webkit isLoading]];
        return;
    }

    if([keyPath isEqual:@"estimatedProgress"]) {
        [self.browser.addressBar setProgressBarValue:[self.webkit estimatedProgress]];
        return;
    }
}

@end
