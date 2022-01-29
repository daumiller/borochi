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

-(BBBrowser*)newTabWithURL:(NSURL*)url andConfiguration:(WKWebViewConfiguration*)configuration {
    BBBrowser* bbb = [[BBBrowser alloc] initWithConfiguration:configuration];

    if(url != nil) {
        [bbb navigateToURL:url];
    } else {
        [bbb navigateToString:@"about:blank"];
    }

    if([self.browserList count] > 0) {
        [[self.browserList lastObject].window addTabbedWindow:bbb.window ordered:NSWindowAbove];
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
