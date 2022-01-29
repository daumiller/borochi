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

// === Lifecycle functions ======================================================================================================
-(instancetype)init {
    return [self initWithConfiguration:nil];
}

-(instancetype)initWithConfiguration:(WKWebViewConfiguration*)configuration {
    self = [super init];
    if(self) {
        [self initWindow];
        [self initMenu];
        [self initToolbar];
        [self initWebkitWithConfiguration:configuration];

        // auto-active the address bar,
        // so we can CMD+T & immediately type a new address
        [self.window makeFirstResponder:self.addressBar];
    }
    return self;
}

// === BB functions =============================================================================================================
-(void)navigateToURL:(NSURL*)url {
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url];
    [self.webview loadRequest:request];
    request = nil;

    if(self.addressBar != nil) {
        [self.addressBar setStringValue:[url absoluteString]];
    }
}

-(void)navigateToString:(NSString*)string {
    @autoreleasepool {
        // TODO : test if keyword search

        // check for protocol
        NSString* lowerCase = [string lowercaseString];
        bool hasProtocol = NO;
        if(!hasProtocol) { if([lowerCase hasPrefix:@"about:"  ]) { hasProtocol = YES; } }
        if(!hasProtocol) { if([lowerCase hasPrefix:@"http://" ]) { hasProtocol = YES; } }
        if(!hasProtocol) { if([lowerCase hasPrefix:@"https://"]) { hasProtocol = YES; } }
        lowerCase = nil;

        NSURL* url;
        if(hasProtocol == NO) {
            NSString* protocolled = [NSString stringWithFormat:@"https://%@", string];
            url = [[NSURL alloc] initWithString:protocolled];
            protocolled = nil;
        } else {
            url = [[NSURL alloc] initWithString:string];
        }

        [self navigateToURL:url];
        url = nil;
    }
}

// -(void)navigateBackward;
// -(void)navigateForward;
// -(void)navigateReload;

// === NSWindowDelegate =========================================================================================================
-(void)initWindow {
    NSString* appName = [[NSProcessInfo processInfo] processName];

    self.window = [[NSWindow alloc] initWithContentRect: NSMakeRect(0, 0, 800, 480)
                                              styleMask: NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
                                                backing: NSBackingStoreBuffered
                                                  defer: NO];

    [self.window setReleasedWhenClosed:NO];
    [self.window setDelegate:self];
    [[self.window windowController] setShouldCascadeWindows:NO]; 
    [self.window setFrameAutosaveName:appName];
    [self.window setTitle:appName];
    [self.window makeKeyAndOrderFront:self.window];
    [self.window setTitleVisibility:NSWindowTitleHidden];
    [self.window setTabbingMode:NSWindowTabbingModePreferred];
}

-(BOOL)windowShouldClose:(id)sender {
    // TODO : actual checking of this method
    return YES;
}

-(void)windowWillClose:(NSNotification*)notification {
    // remove our Observer on self.webview.title
    [self.webview removeObserver:self forKeyPath:@"title" context:NULL];

    BBApplication* app = [NSApp delegate];
    [app browserClosed:self];
    app = nil;
}

// === Menu functions ===========================================================================================================
typedef NS_ENUM(NSInteger, BBMenuTag) {
    BBMenuTagNewTab,
    BBMenuTagEditCopy,
    BBMenuTagEditCut,
    BBMenuTagEditPaste,
    BBMenuTagEditSelectAll,
    BBMenuTagEditSelectNone,
    BBMenuTagEditUndo,
    BBMenuTagEditRedo
};

-(void)initMenu {
    @autoreleasepool {
        NSMenuItem* item;
        
        NSMenu* menu = [[NSMenu alloc] init];
        [NSApp setMainMenu:menu];
        [menu setAutoenablesItems:YES];

        // App Menu
        NSMenuItem* menu_appItem = [menu addItemWithTitle:@"" action:NULL keyEquivalent:@""];
        NSMenu* menu_appGroup = [[NSMenu alloc] init];
        [menu_appItem setSubmenu:menu_appGroup];
        item = [menu_appGroup addItemWithTitle:@"New Tab" action:@selector(menuAppHandler:) keyEquivalent:@"t"]; [item setTag:BBMenuTagNewTab];
               [menu_appGroup addItem:[NSMenuItem separatorItem]];
        item = [menu_appGroup addItemWithTitle:@"Quit"    action:@selector(terminate:)      keyEquivalent:@"q"];
        menu_appGroup = nil;
        menu_appItem = nil;

        // Edit Menu
        NSMenuItem* menu_editItem = [menu addItemWithTitle:@"" action:NULL keyEquivalent:@""];
        NSMenu* menu_editGroup = [[NSMenu alloc] initWithTitle:@"Edit"];
        [menu_editItem setSubmenu:menu_editGroup];
        item = [menu_editGroup addItemWithTitle:@"Copy"        action:@selector(menuEditHandler:) keyEquivalent:@"c"]; [item setTag:BBMenuTagEditCopy      ];
        item = [menu_editGroup addItemWithTitle:@"Cut"         action:@selector(menuEditHandler:) keyEquivalent:@"x"]; [item setTag:BBMenuTagEditCut       ];
        item = [menu_editGroup addItemWithTitle:@"Paste"       action:@selector(menuEditHandler:) keyEquivalent:@"v"]; [item setTag:BBMenuTagEditPaste     ];
               [menu_editGroup addItem:[NSMenuItem separatorItem]];
        item = [menu_editGroup addItemWithTitle:@"Select All"  action:@selector(menuEditHandler:) keyEquivalent:@"a"]; [item setTag:BBMenuTagEditSelectAll ];
        item = [menu_editGroup addItemWithTitle:@"Select None" action:@selector(menuEditHandler:) keyEquivalent:@"d"]; [item setTag:BBMenuTagEditSelectNone];
               [menu_editGroup addItem:[NSMenuItem separatorItem]];
        item = [menu_editGroup addItemWithTitle:@"Undo"        action:@selector(menuEditHandler:) keyEquivalent:@"z"]; [item setTag:BBMenuTagEditUndo      ];
        item = [menu_editGroup addItemWithTitle:@"Redo"        action:@selector(menuEditHandler:) keyEquivalent:@"z"]; [item setTag:BBMenuTagEditRedo      ]; [item setKeyEquivalentModifierMask:(NSEventModifierFlagShift|NSEventModifierFlagCommand)];
        menu_editGroup = nil;
        menu_editItem = nil;

        menu = nil;
    }
}

-(void)menuAppHandler:(NSMenuItem*)sender {
    switch([sender tag]) {
        case BBMenuTagNewTab: {
            BBApplication* app = [NSApp delegate];
            [app newTabWithURL:nil];
        }
        break;
    }
}

-(void)menuEditHandler:(NSMenuItem*)sender {
    switch([sender tag]) {
        case BBMenuTagEditCopy:       [NSApp sendAction:@selector(copy:)       to:nil from:self]; break;
        case BBMenuTagEditCut:        [NSApp sendAction:@selector(cut:)        to:nil from:self]; break;
        case BBMenuTagEditPaste:      [NSApp sendAction:@selector(paste:)      to:nil from:self]; break;
        case BBMenuTagEditSelectAll:  [NSApp sendAction:@selector(selectAll:)  to:nil from:self]; break;
        case BBMenuTagEditSelectNone: [NSApp sendAction:@selector(selectNone:) to:nil from:self]; break;
        case BBMenuTagEditUndo:       [NSApp sendAction:@selector(undo:)       to:nil from:self]; break;
        case BBMenuTagEditRedo:       [NSApp sendAction:@selector(redo:)       to:nil from:self]; break;
    }
}

// === Toolbar functions ========================================================================================================
#define TOOLBAR_IDENTIFIER_MAIN          @"BB.Toolbar.Main"
#define TOOLBAR_IDENTIFIER_MAIN_ADDRESS  @"BB.Toolbar.Main.Address"
#define TOOLBAR_IDENTIFIER_MAIN_BACKWARD @"BB.Toolbar.Main.Backward"
#define TOOLBAR_IDENTIFIER_MAIN_FORWARD  @"BB.Toolbar.Main.Forward"

typedef NS_ENUM(NSInteger, BBToolbarTag) {
    BBToolbarTagMainAddress,
    BBToolbarTagMainBackward,
    BBToolbarTagMainForward
};

-(void)initToolbar {
    NSToolbar* toolbar = [[NSToolbar alloc] initWithIdentifier:TOOLBAR_IDENTIFIER_MAIN];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeDefault]; // [ NSToolbarDisplayModeDefault, NSToolbarDisplayModeIconAndLabel, NSToolbarDisplayModeIconOnly, NSToolbarDisplayModeLabelOnl ]
    [self.window setToolbar:toolbar];
    toolbar = nil;
}

-(NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*)identifier willBeInsertedIntoToolbar:(BOOL)insert {
if([identifier isEqual:TOOLBAR_IDENTIFIER_MAIN_BACKWARD]) {
        NSToolbarItem* item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        [item setLabel:@"Backward"];
        [item setToolTip:@"Navigate to Previous Page"];
        [item setTag:BBToolbarTagMainBackward];
        [item setBordered:YES];
        [item setTarget:self];
        [item setAction:@selector(toolbarItemClicked:)];
        [item setImage:[NSImage imageNamed:NSImageNameTouchBarGoBackTemplate]];
        return item;
    }

    if([identifier isEqual:TOOLBAR_IDENTIFIER_MAIN_FORWARD]) {
        NSToolbarItem* item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        [item setLabel:@"Forward"];
        [item setToolTip:@"Navigate to Next Page"];
        [item setTag:BBToolbarTagMainForward];
        [item setBordered:YES];
        [item setTarget:self];
        [item setAction:@selector(toolbarItemClicked:)];
        // https://developer.apple.com/design/human-interface-guidelines/macos/touch-bar/touch-bar-glyphs-and-images/
        [item setImage:[NSImage imageNamed:NSImageNameTouchBarGoForwardTemplate]];
        return item;
    }

    if([identifier isEqual:TOOLBAR_IDENTIFIER_MAIN_ADDRESS]) {
        self.addressBar = [BBAddressBar textFieldWithString:@""];
        [self.addressBar  setAlignment:NSTextAlignmentCenter];
        [[self.addressBar cell] setSendsActionOnEndEditing:NO]; // ensure we ONLY fire actions for ENTER key presses
        [self.addressBar  setTarget:self];
        [self.addressBar  setAction:@selector(addressEntered:)];

        NSToolbarItem* item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        [item setLabel:@"Address"];
        [item setToolTip:@"Enter a web address or search term."];
        [item setTag:BBToolbarTagMainAddress];
        [item setBordered:YES];
        // TODO : use "constraints" instead???
        NSSize minSize=[item minSize]; minSize.width= 128; [item setMinSize:minSize];
        NSSize maxSize=[item maxSize]; maxSize.width=4096; [item setMaxSize:maxSize];
        [item setView:self.addressBar];
        return item;
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
    if(self.webview == nil) { return NO; }

    switch([item tag]) {
        case BBToolbarTagMainBackward: return [self.webview canGoBack   ]; break;
        case BBToolbarTagMainForward : return [self.webview canGoForward]; break;
    }

    return NO;
}

-(void)toolbarItemClicked:(NSToolbarItem*)item {
    switch([item tag]) {
        case BBToolbarTagMainBackward: [self.webview goBack   ]; break;
        case BBToolbarTagMainForward : [self.webview goForward]; break;
    }
}

-(void)addressEntered:(id)sender {
    [self navigateToString:[self.addressBar stringValue]];
}

// === WebKit functions =========================================================================================================
-(void)initWebkitWithConfiguration:(WKWebViewConfiguration*)configuration {
    if(configuration == nil) {
        configuration = [[WKWebViewConfiguration alloc] init];
    }

    [[configuration preferences] setValue:@YES forKey:@"developerExtrasEnabled"];
    [[configuration preferences] setValue:@YES forKey:@"fullScreenEnabled"];
    [[configuration preferences] setValue:@YES forKey:@"javaScriptCanAccessClipboard"];
    [[configuration preferences] setValue:@YES forKey:@"DOMPasteAllowed"];
    // WKUserContentController* content_controller = [config userContentController];
    // [content_controller addScriptMessageHandler:self name:@"nativeAlert"];

    self.webview = [[WKWebView alloc] initWithFrame:CGRectMake(0,0,0,0) configuration:configuration];
    [self.webview setNavigationDelegate:self];
    [self.webview setUIDelegate:self];

    [self.window setContentView:self.webview];

    // observe changes to [self.webview title], and set our window/tab title on any change
    [self.webview addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
}

-(void)webView:(WKWebView*)webview didStartProvisionalNavigation:(WKNavigation*)navigation {
    if(self.addressBar != nil) {
        [self.addressBar setStringValue:[[self.webview URL] absoluteString]];
    }
}

-(void)webView:(WKWebView*)webview didFinishNavigation:(WKNavigation*)navigation {
    // we were setting title here, but just KVO-observing it now
}

-(WKWebView*)webView:(WKWebView*)webview createWebViewWithConfiguration:(WKWebViewConfiguration*)configuration forNavigationAction:(WKNavigationAction*)navigationAction windowFeatures:(WKWindowFeatures*)windowFeatures {
    if([navigationAction targetFrame] && [[navigationAction targetFrame] isMainFrame]) {
        return nil;
    }

    BBApplication* application = [NSApp delegate];
    BBBrowser* browser = [application newTabWithURL:[[navigationAction request] URL] andConfiguration:configuration];
    application = nil;

    return browser.webview;
}

-(void)userContentController:(WKUserContentController*)userContentController didReceiveScriptMessage:(WKScriptMessage*)message {
}

-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id>*)change context:(void*)context {
    if([keyPath isEqual:@"title"]) {
        [self.window setTitle:self.webview.title];
    }
}

@end
