#import <Cocoa/Cocoa.h>
#import <BBApplication.h>
#import <BBBrowser.h>
#import <BBPreferences.h>
#import <BBHelpers.h>

@implementation BBApplication

// === Lifecycle functions =====================================================================================================
+(instancetype)sharedApplication {
    static BBApplication* sharedApplication = nil;
    static dispatch_once_t sharedApplicationToken;

    dispatch_once(&sharedApplicationToken, ^{
        sharedApplication = [[BBApplication alloc] init];
    });

    return sharedApplication;
}

-(instancetype)init {
    self = [super init];
    if(self) {
        // init with an empty list; we'll add a starting window in applicationDidFinishLaunching
        self.browserList = [[NSMutableArray alloc] init];
    }
    return self;
}

// === BB functions =============================================================================================================
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

// === NSApplicationDelegate ====================================================================================================
-(void)applicationDidFinishLaunching:(NSNotification*)notification {
    BOOL restoreState = [(NSNumber*)[[BBPreferences sharedPreferences] getPreference:@"restoreState"] boolValue];
    if(restoreState) {
        // restore state (open urls @ last terminate)
        NSString* loadPath = bbFilePathFromLibrary(@"restore-pages.json");
        NSArray<NSString*>* urlStrings = bbJsonLoadPath(loadPath, nil, NO, NO);
        if((urlStrings != nil) && (urlStrings.count > 0)) {
            for(NSString* urlString in urlStrings) {
                [self newTabWithURL:[NSURL URLWithString:urlString]];
            }
            return;
        }
    }

    [self newTabWithURL:nil];
}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender {
    [[BBPreferences sharedPreferences] savePreferences];

    BOOL restoreState = [(NSNumber*)[[BBPreferences sharedPreferences] getPreference:@"restoreState"] boolValue];
    if(restoreState) {
        // save state (all open browsers' urls)
        NSMutableArray<NSString*>* savedURLS = [[NSMutableArray alloc] initWithCapacity:self.browserList.count];
        for(BBBrowser* browser in self.browserList) {
            [savedURLS addObject:[[browser currentURL] absoluteString]];
        }

        NSString* savePath = bbFilePathFromLibrary(@"restore-pages.json");
        bbJsonSavePath(savePath, savedURLS, nil, YES, YES);
    }

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

@end
