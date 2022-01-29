#import <Cocoa/Cocoa.h>
#import <BBApplication.h>
#import <BBBrowser.h>

@implementation BBApplication

-(BBApplication*)init {
    self = [super init];
    browser_list = [[NSMutableArray alloc] init];
    return self;
}

-(void)applicationDidFinishLaunching:(NSNotification*)notification {
    [self newTabWithURL:nil];
}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender {
    // TODO : check if we might want to save anything before exit, if so, prompt,
    //        and return NSTerminateCancel if we decide to stay open.
    //        actually, we should probably ask each browser/window/tab if it wants to save before deciding...
    return NSTerminateNow;
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender {
    // we'll handle this ourselves
    return NO;
}

-(void)applicationWillTerminate {
    // this never gets called...
    // ( https://developer.apple.com/forums/thread/126418 )
    while([browser_list count] > 0) {
        BBBrowser* bbb = [browser_list lastObject];
        [browser_list removeLastObject];
        [bbb release];
    }

    [browser_list release];
    browser_list = nil;
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
    BBBrowser* bbb = [[BBBrowser alloc] init];
    if(url != nil) {
        [bbb navigateToURL:url];
    } else {
        [bbb navigateToString:@"about:blank"];
    }

    if([browser_list count] > 0) {
        [[[browser_list lastObject] window] addTabbedWindow:[bbb window] ordered:NSWindowAbove];
    }
    [browser_list addObject:bbb];

    return bbb;
}

-(BBBrowser*)newTabWithURL:(NSURL*)url andConfiguration:(WKWebViewConfiguration*)configuration {
    BBBrowser* bbb = [[BBBrowser alloc] initWithConfiguration:configuration];
    if(url != nil) {
        [bbb navigateToURL:url];
    } else {
        [bbb navigateToString:@"about:blank"];
    }

    if([browser_list count] > 0) {
        [[[browser_list lastObject] window] addTabbedWindow:[bbb window] ordered:NSWindowAbove];
    }
    [browser_list addObject:bbb];

    return bbb;
}

-(void)browserClosed:(BBBrowser*)browser {
    NSUInteger index = [browser_list indexOfObject:browser];
    if(index == NSNotFound) { return; } // shouldn't ever happen

    [browser_list removeObjectAtIndex:index];

    // TODO : track down how/when these can be released without crashing
    //        current solution will become resource hog (maybe that's what happens to safar? 😅)
    // [browser release];

    if([browser_list count] == 0) {
        [NSApp terminate:self];
    }
}

@end
