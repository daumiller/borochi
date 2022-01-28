#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#include <stdio.h>

void QuickAlert(NSString* message) {
     NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle : @"Okay"];
    [alert setMessageText     : message];
    [alert setAlertStyle      : NSAlertStyleWarning];
    [alert runModal];
    [alert release];
    return;
}

#define TOOLBAR_IDENTIFIER_MAIN          @"CBB.Toolbar.Main"
#define TOOLBAR_IDENTIFIER_MAIN_BACKWARD @"CBB.Toolbar.Main.Backward"
#define TOOLBAR_IDENTIFIER_MAIN_FORWARD  @"CBB.Toolbar.Main.Forward"
#define TOOLBAR_IDENTIFIER_MAIN_ADDRESS  @"CBB.Toolbar.MainAddress"

@interface ShinyAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, WKScriptMessageHandler, NSToolbarDelegate, NSToolbarItemValidation> {
    NSWindow* window;
    WKWebView* webview;
    // NSImage* toolbar_image_backward;
    // NSImage* toolbar_image_forward;
}
-(void)applicationDidFinishLaunching:(NSNotification*)notification;
-(BOOL)windowShouldClose:(id)sender;
-(void)windowWillClose:(NSNotification*)notification;
-(void)clipboardCopy:(NSMenuItem*)sender;
-(void)clipboardCut:(NSMenuItem*)sender;
-(void)clipboardPaste:(NSMenuItem*)sender;
-(void)menuSelectAll:(NSMenuItem*)sender;
-(void)menuUndo:(NSMenuItem*)sender;
-(void)menuRedo:(NSMenuItem*)sender;
-(void)userContentController:(WKUserContentController*)userContentController didReceiveScriptMessage:(WKScriptMessage*)message;
-(void)createWindow;
-(NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*)identifier willBeInsertedIntoToolbar:(BOOL)insert;
-(NSArray<NSToolbarItemIdentifier>*)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar;
-(NSArray<NSToolbarItemIdentifier>*)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar;
-(NSArray<NSToolbarItemIdentifier>*)toolbarSelectableItemIdentifiers:(NSToolbar*)toolbar;
-(BOOL)validateToolbarItem:(NSToolbarItem*)item;
-(void)ToolbarItemClicked:(NSToolbarItem*)sender;
-(void)newWindowForTab:(id)sender;
@end

@implementation ShinyAppDelegate
-(void)applicationDidFinishLaunching:(NSNotification*)notification {
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"NSQuitAlwaysKeepsWindows"];
}

-(BOOL)windowShouldClose:(id)sender {
    /*
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle : @"Okay"];
    [alert addButtonWithTitle : @"Cancel"];
    [alert setMessageText     : @"Really Close?"];
    [alert setAlertStyle      : NSAlertStyleWarning];

    BOOL result = ([alert runModal] == NSAlertFirstButtonReturn);
    [alert release];
    return result;
    */
    return YES;
}

-(void)windowWillClose:(NSNotification*)notification {
    [NSApp terminate:self];
}

-(void)clipboardCopy:(NSMenuItem*)sender {
    [NSApp sendAction:@selector(copy:) to:nil from:self];
}

-(void)clipboardCut:(NSMenuItem*)sender {
    [NSApp sendAction:@selector(cut:) to:nil from:self];
}

-(void)clipboardPaste:(NSMenuItem*)sender {
    [NSApp sendAction:@selector(paste:) to:nil from:self];
}

-(void)menuSelectAll:(NSMenuItem*)sender {
    [NSApp sendAction:@selector(selectAll:) to:nil from:self];
}

-(void)menuUndo:(NSMenuItem*)sender {
    [NSApp sendAction:@selector(undo:) to:nil from:self];
}

-(void)menuRedo:(NSMenuItem*)sender {
    [NSApp sendAction:@selector(redo:) to:nil from:self];
}

-(void)userContentController:(WKUserContentController*)userContentController didReceiveScriptMessage:(WKScriptMessage*)message {
    id body = [message body];
    if(body && [body isKindOfClass:[NSString class]]) {
        QuickAlert(body);
    }
}

-(NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*)identifier willBeInsertedIntoToolbar:(BOOL)insert {\
    if([identifier isEqual:TOOLBAR_IDENTIFIER_MAIN_BACKWARD]) {
        NSToolbarItem* item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        [item setLabel:@"Backward"];
        [item setToolTip:@"Navigate to Previous Page"];
        [item setTag:0];
        [item setTarget:self];
        [item setAction: @selector(ToolbarItemClicked:)];
        [item setImage:[NSImage imageNamed:NSImageNameTouchBarGoBackTemplate]];
        [item setBordered:YES];
        return [item autorelease];
    }

    if([identifier isEqual:TOOLBAR_IDENTIFIER_MAIN_FORWARD]) {
        NSToolbarItem* item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        [item setLabel:@"Forward"];
        [item setToolTip:@"Navigate to Next Page"];
        [item setTag:1];
        [item setTarget:self];
        [item setAction: @selector(ToolbarItemClicked:)];
        // [item setImage:toolbar_image_forward];
        // https://developer.apple.com/design/human-interface-guidelines/macos/touch-bar/touch-bar-glyphs-and-images/
        [item setImage:[NSImage imageNamed:NSImageNameTouchBarGoForwardTemplate]];
        [item setBordered:YES];
        return [item autorelease];
    }

    if([identifier isEqual:TOOLBAR_IDENTIFIER_MAIN_ADDRESS]) {
        NSTextField* text_address = [NSTextField textFieldWithString:@"https://mail.google.com"];
        [text_address setAlignment:NSTextAlignmentCenter];
        NSToolbarItem* item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        [item setLabel:@"Address"];
        [item setBordered:YES];
        NSSize minSize = [item minSize];
        minSize.width = 128;
        [item setMinSize:minSize];
        NSSize maxSize = [item maxSize];
        maxSize.width = 4096;
        [item setMaxSize:maxSize];
        [item setView:text_address];
        [text_address release];
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
    // return [self toolbarAllowedItemIdentifiers:toolbar];
    return @[];
}

-(BOOL)validateToolbarItem:(NSToolbarItem*)item {
    if([item tag] == 1) {
        return NO;
    }
    return YES;
}

-(void)ToolbarItemClicked:(NSToolbarItem*)sender {
    int tag = [sender tag];
    switch(tag) {
        case 0:
            QuickAlert(@"Pressed Backward");
            break;
        case 1:
            QuickAlert(@"Pressed Forward");
            break;
    }
    // [[sender toolbar] setSelectedItemIdentifier:nil];
}

-(void)createWindow {
    NSString* appName = [[NSProcessInfo processInfo] processName];

    /*
    NSString* path_image_backward = [NSString pathWithComponents:@[ [[NSBundle mainBundle] resourcePath], @"icons", @"backward.png"] ];
    toolbar_image_backward = [[NSImage alloc] initByReferencingFile:path_image_backward];
    [path_image_backward release];
    NSString* path_image_forward = [NSString pathWithComponents:@[ [[NSBundle mainBundle] resourcePath], @"icons", @"forward.png"] ];
    toolbar_image_forward = [[NSImage alloc] initByReferencingFile:path_image_forward];
    [path_image_forward release];
    */

    NSMenu* menu = [[NSMenu alloc] init];
    [NSApp setMainMenu:menu];
    [menu setAutoenablesItems:YES];

    NSMenuItem* menu_appItem = [menu addItemWithTitle:@"" action:NULL keyEquivalent:@""];
    NSMenu* menu_appGroup = [[NSMenu alloc] init];
    [menu_appItem setSubmenu:menu_appGroup];
    [menu_appGroup addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
    [menu_appGroup release];

    NSMenuItem* menu_editItem = [menu addItemWithTitle:@"" action:NULL keyEquivalent:@""];
    NSMenu* menu_editGroup = [[NSMenu alloc] initWithTitle:@"Edit"];
    [menu_editItem setSubmenu:menu_editGroup];
    [menu_editGroup addItemWithTitle:@"Copy"       action:@selector(clipboardCopy:)  keyEquivalent:@"c"];
    [menu_editGroup addItemWithTitle:@"Cut"        action:@selector(clipboardCut:)   keyEquivalent:@"x"];
    [menu_editGroup addItemWithTitle:@"Paste"      action:@selector(clipboardPaste:) keyEquivalent:@"v"];
    [menu_editGroup addItemWithTitle:@"Select All" action:@selector(menuSelectAll:)  keyEquivalent:@"a"];
    [menu_editGroup addItemWithTitle:@"Undo"       action:@selector(menuUndo:)       keyEquivalent:@"z"];
    NSMenuItem* redo = [menu_editGroup addItemWithTitle:@"Redo" action:@selector(menuRedo:) keyEquivalent:@"z"];
    [redo setKeyEquivalentModifierMask:NSEventModifierFlagShift|NSEventModifierFlagCommand];
    [menu_editGroup release];

    [menu release];

    window = [[NSWindow alloc] initWithContentRect: NSMakeRect(0, 0, 800, 480)
                                              styleMask: NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
                                                backing: NSBackingStoreBuffered
                                                  defer: NO];

    [window setDelegate:self];
    [[window windowController] setShouldCascadeWindows:NO]; 
    [window setFrameAutosaveName:appName];
    [window setTitle:appName];
    [window makeKeyAndOrderFront:window];
    [window setTitleVisibility:NSWindowTitleHidden];
    [window setTabbingMode:NSWindowTabbingModePreferred];

    NSToolbar* toolbar = [[NSToolbar alloc] initWithIdentifier:TOOLBAR_IDENTIFIER_MAIN];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeDefault]; // [ NSToolbarDisplayModeDefault, NSToolbarDisplayModeIconAndLabel, NSToolbarDisplayModeIconOnly, NSToolbarDisplayModeLabelOnl ]
    [window setToolbar:toolbar];
    [toolbar release];
  
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    [[config preferences] setValue:@YES forKey:@"developerExtrasEnabled"];
    [[config preferences] setValue:@YES forKey:@"fullScreenEnabled"];
    [[config preferences] setValue:@YES forKey:@"javaScriptCanAccessClipboard"];
    [[config preferences] setValue:@YES forKey:@"DOMPasteAllowed"];
    WKUserContentController* content_controller = [config userContentController];
    [content_controller addScriptMessageHandler:self name:@"nativeAlert"];
    webview = [[WKWebView alloc] initWithFrame:CGRectMake(0,0,0,0) configuration:config];
    [config release];
    // window.webkit.messageHandlers.nativeAlert.postMessage("Testing JS->C...");

    /*
    NSString* path_html_directory = [NSString pathWithComponents:@[ @"file://", [[NSBundle mainBundle] resourcePath], @"html"]];
    NSString* path_html_index     = [NSString pathWithComponents:@[ @"file://", [[NSBundle mainBundle] resourcePath], @"html", @"index.html" ]];
    NSURL* url_html_directory = [[NSURL alloc] initWithString:path_html_directory];
    NSURL* url_html_index     = [[NSURL alloc] initWithString:path_html_index];
    [webview loadFileURL:url_html_index allowingReadAccessToURL:url_html_directory];
    [url_html_directory  release];
    [url_html_index      release];
    [path_html_directory release];
    [path_html_index     release];
    */

    NSURL* url_mail = [[NSURL alloc] initWithString:@"https://mail.google.com"];
    NSURLRequest* request_mail = [[NSURLRequest alloc] initWithURL:url_mail];
    [webview loadRequest:request_mail];
    [request_mail release];
    [url_mail release];

    /*
    [webview callAsyncJavaScript: @"var prom = new Promise(function(resolve, reject) { window.addEventListener('DOMContentLoaded', function(event){ document.body.appendChild(document.createTextNode('Hello Shiny Worlds!!!')); window.setTimeout(resolve, 3000); }); }); await prom; return 4331;"
                       arguments: @{}
                         inFrame: nil
                  inContentWorld: [WKContentWorld pageWorld]
               completionHandler: ^void(NSString* result, NSError* error) {
                   NSString* result_string = @"callAsyncJavaScript errored out";
                   if(error) {
                       result_string = [error localizedDescription];
                   }
                   if([error isKindOfClass:[NSNull class]]) {
                       result_string = @"callAsyncJavaScript returned null";
                   } else if(error == nil) {
                       result_string = @"callAsyncJavaScript returned no value";
                       if(result != nil) {
                        result_string = [NSString stringWithFormat:@"%@", result];
                       }
                   }

                   QuickAlert(result_string);
               }
    ];

    [webview evaluateJavaScript: @"window.addEventListener('DOMContentLoaded', function(event){ document.body.appendChild(document.createTextNode('Hello Shiny Worldz!!!')); });" completionHandler:^void(NSString* result, NSError* error) {}];
    */
    [window setContentView:webview];
    [window makeFirstResponder:webview];

    NSWindow* window2 = [[NSWindow alloc] initWithContentRect: NSMakeRect(0, 0, 800, 480)
                                              styleMask: NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
                                                backing: NSBackingStoreBuffered
                                                  defer: NO];

    [[window2 windowController] setShouldCascadeWindows:NO]; 
    [window2 setFrameAutosaveName:appName];
    [window2 setTitle:appName];
    // [window2 makeKeyAndOrderFront:window2];
    [window2 setTitleVisibility:NSWindowTitleHidden];
    [window2 setTabbingMode:NSWindowTabbingModePreferred];
    [window addTabbedWindow:window2 ordered:NSWindowAbove];
}

-(void)newWindowForTab:(id)sender {
    // newWindow = [ShinyAppDelegate createWindow]
    // [self.window addTabbedWindow:newWindow ordered:NSWindowAbove];
}

-(void)dealloc {
    window = nil;
    [webview release];
    // [toolbar_image_backward release];
    // [toolbar_image_forward release];
    [super dealloc];
}
@end

int main() {
    // NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    [[NSApplication sharedApplication] setActivationPolicy:NSApplicationActivationPolicyRegular];
    ShinyAppDelegate* appDelegate = [[ShinyAppDelegate alloc] init];
    [NSApp setDelegate:appDelegate];

    [appDelegate createWindow];
    // [NSApp activateIgnoringOtherApps:YES];
    [NSApp run];

    [appDelegate release];
    [pool drain];
    return 0;
}
