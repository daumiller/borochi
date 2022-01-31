#import <Cocoa/Cocoa.h>
#import <BBApplication.h>
#import <BBBrowser.h>

@implementation BBApplication

-(instancetype)init {
    self = [super init];
    if(self) {
        // init with an empty list; we'll add a starting window in applicationDidFinishLaunching
        self.browserList = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)applicationDidFinishLaunching:(NSNotification*)notification {
    // TODO : restore state (previous pages) at startup
    [self newTabWithURL:nil];
}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender {
    // TODO : check if we might want to save anything before exit, if so, prompt,
    //        and return NSTerminateCancel if we decide to stay open.
    //        actually, we should probably ask each browser/window/tab if it wants to save before deciding...
    return NSTerminateNow;
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender {
    // we'll handle this ourselves; in browserClosed
    return NO;
}

-(void)application:(NSApplication*)application openURLs:(NSArray<NSURL*>*)urls {
    for(NSURL* url in urls) {
        [self newTabWithURL:url];
    }
}

-(void)newWindowForTab:(id)sender {
    [self newTabWithURL:nil];
}

-(BBBrowser*)newTabWithURL:(NSURL*)url {
    return [self newTabWithURL:url andConfiguration:nil];
}

// TODO : we need options to create tabs without activating them (ex: preference for opening new tab without deactivating current one)

-(BBBrowser*)newTabWithURL:(NSURL*)url andConfiguration:(WKWebViewConfiguration*)configuration {
    // capture currently active window, before we create a new one
    NSWindow* activeWindow = [NSApp keyWindow];

    BBBrowser* bbb = [[BBBrowser alloc] initWithConfiguration:configuration];

    if(url != nil) {
        [bbb navigateToURL:url];
    } else {
        [bbb navigateToString:@"about:blank"];
    }

    // add to existing window tab-group, if we have any
    if([self.browserList count] > 0) {
        // if we have multiple windows (each with multiple tabs), we want to make sure this routes to the correct (active) group
        if(activeWindow != nil) {
            id activeWindowDelegate = activeWindow.delegate;
            if(activeWindowDelegate != nil) {
                if([activeWindowDelegate isKindOfClass:[BBBrowser class]]) {
                    [activeWindow addTabbedWindow:bbb.window ordered:NSWindowAbove];
                }
            }
        }
    }

    [self.browserList addObject:bbb];

    return bbb;
}

-(void)browserClosed:(BBBrowser*)browser {
    NSUInteger index = [self.browserList indexOfObject:browser];
    if(index == NSNotFound) { return; } // shouldn't ever happen

    [self.browserList removeObjectAtIndex:index];

    if([self.browserList count] == 0) {
        [NSApp terminate:self];
    }
}

@end
