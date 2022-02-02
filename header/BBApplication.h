#import <Cocoa/Cocoa.h>
#import <BBBrowser.h>

// TODO
// [ ] State Restoration
//       https://stackoverflow.com/questions/50331083/ui-save-restoration-mechanism-in-cocoa-via-swift/55665698
//       https://developer.apple.com/documentation/appkit/nsapplicationdelegate?language=objc  @ "Restoring Application State"


@interface BBApplication : NSObject <NSApplicationDelegate>

@property NSMutableArray<BBBrowser*>* browserList;

// === Lifecycle functions =====================================================================================================
+(instancetype)sharedApplication;

// === BB functions =============================================================================================================
-(BBBrowser*)newTabWithURL:(NSURL*)url;
-(BBBrowser*)newTabWithURL:(NSURL*)url andConfiguration:(WKWebViewConfiguration*)configuration;
-(void)browserClosed:(BBBrowser*)browser;

// === NSApplicationDelegate ====================================================================================================
-(void)applicationDidFinishLaunching:(NSNotification*)notification;
-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender;
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender;
-(void)application:(NSApplication*)application openURLs:(NSArray<NSURL*>*)urls;
-(void)newWindowForTab:(id)sender;

@end
