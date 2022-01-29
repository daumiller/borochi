#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <BBApplication.h>
#import <BBBrowser.h>
#import <BBAddressBar.h>

/*
void bbInformation(NSString* message) {
  NSAlert *alert = [[NSAlert alloc] init];
  [alert addButtonWithTitle : @"Okay"];
  [alert setMessageText     : message];
  [alert setAlertStyle      : NSAlertStyleInformational];

  [alert runModal];
  [alert release];
}
*/

@implementation BBBrowser

// === Lifetime functions =========================================================================================================
-(BBBrowser*)init {
    self = [super init];
    window     = nil;
    webview    = nil;
    address    = nil;
    addressBar = nil;

    [self initWindow];
    [self initMenu];
    [self initToolbar];
    [self initWebkit];

    // auto-active the address bar,
    // so we can CMD+T & immediately type a new address
    [window makeFirstResponder:addressBar];

    return self;
}

-(BBBrowser*)initWithConfiguration:(WKWebViewConfiguration*)configuration {
    self = [super init];
    window     = nil;
    webview    = nil;
    address    = nil;
    addressBar = nil;

    [self initWindow];
    [self initMenu];
    [self initToolbar];
    [self initWebkitWithConfiguration:configuration];

    return self;
}

// === BB functions =============================================================================================================
-(void)navigateToURL:(NSURL*)url {
    NSURL* address_old = address;
    address = [[NSURL alloc] initWithString:[url absoluteString]];
    if(address_old) { [address_old release]; }

    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:address];
    [webview loadRequest:request];
    [request release];

    if(addressBar != nil) {
        [addressBar setStringValue:[url absoluteString]];
    }
}

-(void)navigateToString:(NSString*)string {
    // TODO : test if keyword search

    // check for protocol
    NSString* lowerCase = [string lowercaseString];
    bool hasProtocol = NO;
    if(!hasProtocol) { if([lowerCase hasPrefix:@"about:"  ]) { hasProtocol = YES; } }
    if(!hasProtocol) { if([lowerCase hasPrefix:@"http://" ]) { hasProtocol = YES; } }
    if(!hasProtocol) { if([lowerCase hasPrefix:@"https://"]) { hasProtocol = YES; } }

    NSURL* url = nil;
    if(hasProtocol == NO) {
        NSString* protocolled = [NSString stringWithFormat:@"https://%@", string];
        url = [[NSURL alloc] initWithString:protocolled];
        [protocolled release];
    } else {
        url = [[NSURL alloc] initWithString:string];
    }

    [self navigateToURL:url];
    [url release];
}

// -(void)navigateBackward;
// -(void)navigateForward;
// -(void)navigateReload;

// === Window functions =========================================================================================================
-(void)initWindow {
    NSString* appName = [[NSProcessInfo processInfo] processName];

    window = [[NSWindow alloc] initWithContentRect: NSMakeRect(0, 0, 800, 480)
                                              styleMask: NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
                                                backing: NSBackingStoreBuffered
                                                  defer: NO];

    [window setDelegate:self];
    [window setReleasedWhenClosed:NO];
    [[window windowController] setShouldCascadeWindows:NO]; 
    [window setFrameAutosaveName:appName];
    [window setTitle:appName];
    [window makeKeyAndOrderFront:window];
    [window setTitleVisibility:NSWindowTitleHidden];
    [window setTabbingMode:NSWindowTabbingModePreferred];
}

-(NSWindow*)window {
    return window;
}

-(BOOL)windowShouldClose:(id)sender {
    // TODO : actual checking of this method
    return YES;
}

-(void)windowWillClose:(NSNotification*)notification {
    [self cleanupWebkit];
    [self cleanupToolbar];
    [self cleanupMenu];

    if(address) { [address release]; }
    address = nil;

    BBApplication* app = [NSApp delegate];
    [app browserClosed:self];
}

-(void)dealloc {
    if(window) {
        [window release];
        window = nil;
    }
    [super dealloc];
}

// === Menu functions =========================================================================================================
#define MENU_TAG_APP_NEW_TAB      0x0101
#define MENU_TAG_EDIT_COPY        0x0201
#define MENU_TAG_EDIT_CUT         0x0202
#define MENU_TAG_EDIT_PASTE       0x0203
#define MENU_TAG_EDIT_SELECT_ALL  0x0204
#define MENU_TAG_EDIT_SELECT_NONE 0x0205
#define MENU_TAG_EDIT_UNDO        0x0206
#define MENU_TAG_EDIT_REDO        0x0207

-(void)initMenu {
    NSMenuItem* item;
    
    NSMenu* menu = [[NSMenu alloc] init];
    [NSApp setMainMenu:menu];
    [menu setAutoenablesItems:YES];

    NSMenuItem* menu_appItem = [menu addItemWithTitle:@"" action:NULL keyEquivalent:@""];
    NSMenu* menu_appGroup = [[NSMenu alloc] init];
    [menu_appItem setSubmenu:menu_appGroup];
    item = [menu_appGroup addItemWithTitle:@"New Tab" action:@selector(menuAppHandler:) keyEquivalent:@"t"]; [item setTag:MENU_TAG_APP_NEW_TAB];
           [menu_appGroup addItem:[NSMenuItem separatorItem]];
    item = [menu_appGroup addItemWithTitle:@"Quit"    action:@selector(terminate:)      keyEquivalent:@"q"];
    [menu_appGroup release];

    NSMenuItem* menu_editItem = [menu addItemWithTitle:@"" action:NULL keyEquivalent:@""];
    NSMenu* menu_editGroup = [[NSMenu alloc] initWithTitle:@"Edit"];
    [menu_editItem setSubmenu:menu_editGroup];
    item = [menu_editGroup addItemWithTitle:@"Copy"        action:@selector(menuEditHandler:) keyEquivalent:@"c"]; [item setTag:MENU_TAG_EDIT_COPY       ];
    item = [menu_editGroup addItemWithTitle:@"Cut"         action:@selector(menuEditHandler:) keyEquivalent:@"x"]; [item setTag:MENU_TAG_EDIT_CUT        ];
    item = [menu_editGroup addItemWithTitle:@"Paste"       action:@selector(menuEditHandler:) keyEquivalent:@"v"]; [item setTag:MENU_TAG_EDIT_PASTE      ];
           [menu_editGroup addItem:[NSMenuItem separatorItem]];
    item = [menu_editGroup addItemWithTitle:@"Select All"  action:@selector(menuEditHandler:) keyEquivalent:@"a"]; [item setTag:MENU_TAG_EDIT_SELECT_ALL ];
    item = [menu_editGroup addItemWithTitle:@"Select None" action:@selector(menuEditHandler:) keyEquivalent:@"d"]; [item setTag:MENU_TAG_EDIT_SELECT_NONE];
           [menu_editGroup addItem:[NSMenuItem separatorItem]];
    item = [menu_editGroup addItemWithTitle:@"Undo"        action:@selector(menuEditHandler:) keyEquivalent:@"z"]; [item setTag:MENU_TAG_EDIT_UNDO       ];
    item = [menu_editGroup addItemWithTitle:@"Redo"        action:@selector(menuEditHandler:) keyEquivalent:@"z"]; [item setTag:MENU_TAG_EDIT_REDO       ]; [item setKeyEquivalentModifierMask:(NSEventModifierFlagShift|NSEventModifierFlagCommand)];
    [menu_editGroup release];

    [menu release];
}

-(void)cleanupMenu {
}

-(void)menuAppHandler:(NSMenuItem*)sender {
    switch([sender tag]) {
        case MENU_TAG_APP_NEW_TAB: {
            BBApplication* app = [NSApp delegate];
            [app newTabWithURL:nil];
        }
        break;
    }
}

-(void)menuEditHandler:(NSMenuItem*)sender {
    switch([sender tag]) {
        case MENU_TAG_EDIT_COPY:        [NSApp sendAction:@selector(copy:)       to:nil from:self]; break;
        case MENU_TAG_EDIT_CUT:         [NSApp sendAction:@selector(cut:)        to:nil from:self]; break;
        case MENU_TAG_EDIT_PASTE:       [NSApp sendAction:@selector(paste:)      to:nil from:self]; break;
        case MENU_TAG_EDIT_SELECT_ALL:  [NSApp sendAction:@selector(selectAll:)  to:nil from:self]; break;
        case MENU_TAG_EDIT_SELECT_NONE: [NSApp sendAction:@selector(selectNone:) to:nil from:self]; break;
        case MENU_TAG_EDIT_UNDO:        [NSApp sendAction:@selector(undo:)       to:nil from:self]; break;
        case MENU_TAG_EDIT_REDO:        [NSApp sendAction:@selector(redo:)       to:nil from:self]; break;
    }
}

// === Toolbar functions =========================================================================================================
#define TOOLBAR_IDENTIFIER_MAIN          @"BB.Toolbar.Main"
#define TOOLBAR_IDENTIFIER_MAIN_ADDRESS  @"BB.Toolbar.Main.Address"
#define TOOLBAR_IDENTIFIER_MAIN_BACKWARD @"BB.Toolbar.Main.Backward"
#define TOOLBAR_IDENTIFIER_MAIN_FORWARD  @"BB.Toolbar.Main.Forward"

#define TOOLBAR_TAG_MAIN_ADDRESS  0x0000
#define TOOLBAR_TAG_MAIN_BACKWARD 0x0001
#define TOOLBAR_TAG_MAIN_FORWARD  0x0002

-(void)initToolbar {
    NSToolbar* toolbar = [[NSToolbar alloc] initWithIdentifier:TOOLBAR_IDENTIFIER_MAIN];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeDefault]; // [ NSToolbarDisplayModeDefault, NSToolbarDisplayModeIconAndLabel, NSToolbarDisplayModeIconOnly, NSToolbarDisplayModeLabelOnl ]
    [window setToolbar:toolbar];
    [toolbar release];
}

-(void)cleanupToolbar {
}

-(NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*)identifier willBeInsertedIntoToolbar:(BOOL)insert {
if([identifier isEqual:TOOLBAR_IDENTIFIER_MAIN_BACKWARD]) {
        NSToolbarItem* item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        [item setLabel:@"Backward"];
        [item setToolTip:@"Navigate to Previous Page"];
        [item setTag:TOOLBAR_TAG_MAIN_BACKWARD];
        [item setBordered:YES];
        [item setTarget:self];
        [item setAction:@selector(toolbarItemClicked:)];
        [item setImage:[NSImage imageNamed:NSImageNameTouchBarGoBackTemplate]];
        return [item autorelease];
    }

    if([identifier isEqual:TOOLBAR_IDENTIFIER_MAIN_FORWARD]) {
        NSToolbarItem* item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        [item setLabel:@"Forward"];
        [item setToolTip:@"Navigate to Next Page"];
        [item setTag:TOOLBAR_TAG_MAIN_FORWARD];
        [item setBordered:YES];
        [item setTarget:self];
        [item setAction:@selector(toolbarItemClicked:)];
        // https://developer.apple.com/design/human-interface-guidelines/macos/touch-bar/touch-bar-glyphs-and-images/
        [item setImage:[NSImage imageNamed:NSImageNameTouchBarGoForwardTemplate]];
        return [item autorelease];
    }

    if([identifier isEqual:TOOLBAR_IDENTIFIER_MAIN_ADDRESS]) {
        addressBar = [BBAddressBar textFieldWithString:@""];
        [addressBar setAlignment:NSTextAlignmentCenter];
        [[addressBar cell] setSendsActionOnEndEditing:NO]; // ensure we ONLY fire actions for ENTER key presses
        [addressBar setTarget:self];
        [addressBar setAction:@selector(addressEntered:)];

        NSToolbarItem* item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        [item setLabel:@"Address"];
        [item setToolTip:@"Enter a web address or search term."];
        [item setTag:TOOLBAR_TAG_MAIN_ADDRESS];
        [item setBordered:YES];
        NSSize minSize=[item minSize]; minSize.width= 128; [item setMinSize:minSize];
        NSSize maxSize=[item maxSize]; maxSize.width=4096; [item setMaxSize:maxSize];
        [item setView:addressBar];
        [addressBar release];
        return [item autorelease];
    }

    return nil;
}

-(NSArray<NSToolbarItemIdentifier>*)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
    return @[ TOOLBAR_IDENTIFIER_MAIN_BACKWARD, TOOLBAR_IDENTIFIER_MAIN_FORWARD, TOOLBAR_IDENTIFIER_MAIN_ADDRESS ];
}

-(NSArray<NSToolbarItemIdentifier>*)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
    return [self toolbarAllowedItemIdentifiers:toolbar];
}

-(NSArray<NSToolbarItemIdentifier>*)toolbarSelectableItemIdentifiers:(NSToolbar*)toolbar {
    return @[];
}

-(BOOL)validateToolbarItem:(NSToolbarItem*)item {
    if(webview == nil) { return NO; }

    switch([item tag]) {
        case TOOLBAR_TAG_MAIN_BACKWARD: return [webview canGoBack   ]; break;
        case TOOLBAR_TAG_MAIN_FORWARD : return [webview canGoForward]; break;
    }

    return NO;
}

-(void)toolbarItemClicked:(NSToolbarItem*)item {
    switch([item tag]) {
        case TOOLBAR_TAG_MAIN_BACKWARD: [webview goBack   ]; break;
        case TOOLBAR_TAG_MAIN_FORWARD : [webview goForward]; break;
    }
}

-(void)addressEntered:(id)sender {
    [self navigateToString:[addressBar stringValue]];
}

// === WebKit functions =========================================================================================================
-(void)initWebkit {
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    [self initWebkitWithConfiguration:config];
    [config release];
}

-(void)initWebkitWithConfiguration:(WKWebViewConfiguration*)configuration {
    [[configuration preferences] setValue:@YES forKey:@"developerExtrasEnabled"];
    [[configuration preferences] setValue:@YES forKey:@"fullScreenEnabled"];
    [[configuration preferences] setValue:@YES forKey:@"javaScriptCanAccessClipboard"];
    [[configuration preferences] setValue:@YES forKey:@"DOMPasteAllowed"];
    // WKUserContentController* content_controller = [config userContentController];
    // [content_controller addScriptMessageHandler:self name:@"nativeAlert"];

    webview = [[WKWebView alloc] initWithFrame:CGRectMake(0,0,0,0) configuration:configuration];
    [webview setNavigationDelegate:self];
    [webview setUIDelegate:self];

    [window setContentView:webview];
    [window makeFirstResponder:webview];

    // observe changes to [webview title], and set our window/tab title on any change
    [webview addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
}

-(WKWebView*)webview {
    return webview;
}

-(void)cleanupWebkit {
    [webview release];
    webview = nil;
}

-(void)webView:(WKWebView*)sourceWebview didStartProvisionalNavigation:(WKNavigation*)navigation {
    NSURL* address_old = address;
    address = [[NSURL alloc] initWithString:[[sourceWebview URL] absoluteString]];
    if(address_old) { [address_old release]; }

    if(addressBar != nil) {
        [addressBar setStringValue:[address absoluteString]];
    }
}

-(void)webView:(WKWebView*)sourceWebview didFinishNavigation:(WKNavigation*)navigation {
    // was setting title here, but just KVO-observing it now
}

-(WKWebView*)webView:(WKWebView*)sourceWebview createWebViewWithConfiguration:(WKWebViewConfiguration*)configuration forNavigationAction:(WKNavigationAction*)navigationAction windowFeatures:(WKWindowFeatures*)windowFeatures {
    if([navigationAction targetFrame] && [[navigationAction targetFrame] isMainFrame]) {
        return nil;
    }

    NSURL* url = [[navigationAction request] URL];
    BBApplication* app = (BBApplication*)[NSApp delegate];
    BBBrowser* new_browser = [app newTabWithURL:url andConfiguration:configuration];
    return [new_browser webview];
}

-(void)userContentController:(WKUserContentController*)userContentController didReceiveScriptMessage:(WKScriptMessage*)message {
}

-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id>*)change context:(void*)context {
    if([keyPath isEqual:@"title"]) {
        [window setTitle:[webview title]];
    }
}

@end
