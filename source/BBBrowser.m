#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <BBApplication.h>
#import <BBBrowser.h>
#import <BBAddressBar.h>
#import <BBAutocompleteMock.h>

@implementation BBBrowser

// === Lifecycle functions ======================================================================================================
-(instancetype)init {
    return [self initWithConfiguration:nil];
}

-(instancetype)initWithConfiguration:(WKWebViewConfiguration*)configuration {
    self = [super init];
    if(self) {
        _browserClosing = NO;

        [self initWindow];
        [self initMenu];
        [self initToolbar];
        self.webview = [[BBWebView alloc] initWithBrowser:self andConfiguration:configuration];

        // TODO : bookmarks
        //        - either a NSTitlebarAccessoryViewController,
        //        - or, a sidebar (https://developer.apple.com/design/human-interface-guidelines/macos/windows-and-views/sidebars/)

        // auto-activate the address bar,
        // so we can CMD+T & immediately type a new address
        [self.window makeFirstResponder:self.addressBar];

        self.addressBar.nextKeyView = self.webview.webkit;
        self.webview.webkit.nextKeyView = self.addressBar;
    }
    return self;
}

// === BB functions =============================================================================================================
-(void)navigateToURL:(NSURL*)url {
    [self.window makeFirstResponder:self.webview.webkit];
    [self.webview navigateToURL:url];
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
    [self.window setTabbingIdentifier:@"BorochiBrowserWindow"];
}

-(BOOL)windowShouldClose:(id)sender {
    // TODO : actual checking of this method
    return YES;
}

-(void)windowWillClose:(NSNotification*)notification {
    // okay... we get called when BBBrowser window is closing, but,
    // if we're the last window, BBApplication will terminate, and, i guess,
    // since the window isn't fully closed yet (we're still inside of our call to browserClosed:),
    // it starts another close attempt, leading us back here, and throwing exceptions (mostly in [webview cleanup])
    if(_browserClosing == YES) { return; }
    _browserClosing = YES;
    
    // let webview remove its KVOs
    [self.webview cleanup];

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
    BBMenuTagEditRedo,
    BBMenuTagNavigateHome,
    BBMenuTagNavigateBackward,
    BBMenuTagNavigateForward,
    BBMenuTagNavigateReload
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

        // Navigate Menu
        NSMenuItem* menu_navigateItem = [menu addItemWithTitle:@"" action:NULL keyEquivalent:@""];
        NSMenu* menu_navigateGroup = [[NSMenu alloc] initWithTitle:@"Navigate"];
        [menu_navigateItem setSubmenu:menu_navigateGroup];
        item = [menu_navigateGroup addItemWithTitle:@"Home"     action:@selector(menuNavigateHandler:) keyEquivalent:@"h"]; [item setTag:BBMenuTagNavigateHome]; [item setKeyEquivalentModifierMask:(NSEventModifierFlagShift|NSEventModifierFlagCommand)];
               [menu_navigateGroup addItem:[NSMenuItem separatorItem]];
        item = [menu_navigateGroup addItemWithTitle:@"Backward" action:@selector(menuNavigateHandler:) keyEquivalent:@"["]; [item setTag:BBMenuTagNavigateBackward];
        item = [menu_navigateGroup addItemWithTitle:@"Forward"  action:@selector(menuNavigateHandler:) keyEquivalent:@"]"]; [item setTag:BBMenuTagNavigateForward];
               [menu_navigateGroup addItem:[NSMenuItem separatorItem]];
        item = [menu_navigateGroup addItemWithTitle:@"Reload"   action:@selector(menuNavigateHandler:) keyEquivalent:@"r"]; [item setTag:BBMenuTagNavigateReload];

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

-(void)menuNavigateHandler:(NSMenuItem*)sender {
    if(!self.webview) { return; }

    switch([sender tag]) {
        case BBMenuTagNavigateHome:     /* TODO */                       break;
        case BBMenuTagNavigateBackward: [self.webview navigateBackward]; break;
        case BBMenuTagNavigateForward:  [self.webview navigateForward ]; break;
        case BBMenuTagNavigateReload:   [self.webview navigateReload  ]; break;
    }
}

-(BOOL)validateMenuItem:(NSMenuItem*)item {
    switch([item tag]) {
        case BBMenuTagNavigateBackward: return (self.webview == nil) ? NO : [self.webview canNavigateBackward];
        case BBMenuTagNavigateForward : return (self.webview == nil) ? NO : [self.webview canNavigateForward ];
    }

    return YES;
}

// === Toolbar functions ========================================================================================================
#define TOOLBAR_IDENTIFIER_MAIN             @"BB.Toolbar.Main"
#define TOOLBAR_IDENTIFIER_MAIN_ADDRESS     @"BB.Toolbar.Main.Address"
#define TOOLBAR_IDENTIFIER_MAIN_BACKWARD    @"BB.Toolbar.Main.Backward"
#define TOOLBAR_IDENTIFIER_MAIN_FORWARD     @"BB.Toolbar.Main.Forward"
#define TOOLBAR_IDENTIFIER_MAIN_RELOAD      @"BB.Toolbar.Main.Reload"
#define TOOLBAR_IDENTIFIER_MAIN_HOME        @"BB.Toolbar.Main.Home"
#define TOOLBAR_IDENTIFIER_MAIN_PREFERENCES @"BB.Toolbar.Main.Preferences"

typedef NS_ENUM(NSInteger, BBToolbarTag) {
    BBToolbarTagMainAddress,
    BBToolbarTagMainBackward,
    BBToolbarTagMainForward,
    BBToolbarTagMainReload,
    BBToolbarTagMainHome,
    BBToolbarTagMainPreferences
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
        [item setImage:[NSImage imageNamed:NSImageNameGoBackTemplate]];
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
        [item setImage:[NSImage imageNamed:NSImageNameGoForwardTemplate]];
        return item;
    }

    if([identifier isEqual:TOOLBAR_IDENTIFIER_MAIN_RELOAD]) {
        NSToolbarItem* item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        [item setLabel:@"Reload"];
        [item setToolTip:@"Reload the Current Page"];
        [item setTag:BBToolbarTagMainReload];
        [item setBordered:YES];
        [item setTarget:self];
        [item setAction:@selector(toolbarItemClicked:)];
        [item setImage:[NSImage imageNamed:NSImageNameTouchBarRefreshTemplate]];
        return item;
    }

    if([identifier isEqual:TOOLBAR_IDENTIFIER_MAIN_HOME]) {
        NSToolbarItem* item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        [item setLabel:@"Home"];
        [item setToolTip:@"Navigate to your Home Page"];
        [item setTag:BBToolbarTagMainHome];
        [item setBordered:YES];
        [item setTarget:self];
        [item setAction:@selector(toolbarItemClicked:)];
        [item setImage:[NSImage imageNamed:NSImageNameHomeTemplate]];
        return item;
    }

    if([identifier isEqual:TOOLBAR_IDENTIFIER_MAIN_PREFERENCES]) {
        NSToolbarItem* item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        [item setLabel:@"Preferences"];
        [item setToolTip:@"Edit your Preferences"];
        [item setTag:BBToolbarTagMainPreferences];
        [item setBordered:YES];
        [item setTarget:self];
        [item setAction:@selector(toolbarItemClicked:)];
        [item setImage:[NSImage imageNamed:NSImageNameSmartBadgeTemplate]];
        return item;
    }

    if([identifier isEqual:TOOLBAR_IDENTIFIER_MAIN_ADDRESS]) {
        self.addressCompletions = [[BBAutocompleteMock alloc] init];

        self.addressBar = [BBAddressBar textFieldWithString:@""];
        self.addressBar.autocompleteSource       = self.addressCompletions;
        self.addressBar.autocompleteEnabled      = YES;
        self.addressBar.autocompleteMaxResults   = 10;
        self.addressBar.addressCommittedDelegate = self;

        NSToolbarItem* item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        [item setLabel:@"Address"];
        [item setToolTip:@"Enter a web address or search term."];
        [item setTag:BBToolbarTagMainAddress];
        [item setBordered:YES];
        // TODO : minSize/maxSize are going away; but i haven't found how to auto-expand this field without them
        NSSize minSize=[item minSize]; minSize.width= 128; [item setMinSize:minSize];
        NSSize maxSize=[item maxSize]; maxSize.width=4096; [item setMaxSize:maxSize];
        [item setView:self.addressBar];
        return item;
    }

    return nil;
}

-(NSArray<NSToolbarItemIdentifier>*)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
    return @[
        TOOLBAR_IDENTIFIER_MAIN_BACKWARD,
        TOOLBAR_IDENTIFIER_MAIN_FORWARD,
        TOOLBAR_IDENTIFIER_MAIN_ADDRESS,
        TOOLBAR_IDENTIFIER_MAIN_RELOAD,
        TOOLBAR_IDENTIFIER_MAIN_HOME,
        TOOLBAR_IDENTIFIER_MAIN_PREFERENCES
    ];
}

-(NSArray<NSToolbarItemIdentifier>*)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
    return @[
        TOOLBAR_IDENTIFIER_MAIN_BACKWARD,
        TOOLBAR_IDENTIFIER_MAIN_FORWARD,
        TOOLBAR_IDENTIFIER_MAIN_ADDRESS,
        TOOLBAR_IDENTIFIER_MAIN_PREFERENCES
    ];
}

-(NSArray<NSToolbarItemIdentifier>*)toolbarSelectableItemIdentifiers:(NSToolbar*)toolbar {
    return @[];
}

-(BOOL)validateToolbarItem:(NSToolbarItem*)item {
    if(self.webview == nil) { return NO; }

    switch([item tag]) {
        case BBToolbarTagMainBackward: return [self.webview canNavigateBackward];
        case BBToolbarTagMainForward : return [self.webview canNavigateForward ];
    }

    return YES;
}

-(void)toolbarItemClicked:(NSToolbarItem*)item {
    switch([item tag]) {
        case BBToolbarTagMainBackward    : [self.webview navigateBackward]; break;
        case BBToolbarTagMainForward     : [self.webview navigateForward ]; break;
        case BBToolbarTagMainReload      : [self.webview navigateReload  ]; break;
        case BBToolbarTagMainHome        : /* TODO */ break;
        case BBToolbarTagMainPreferences : /* TODO */ break;
    }
}

-(void)addressBarCommitted:(NSString*)address {
    [self navigateToString:address];
}

@end
