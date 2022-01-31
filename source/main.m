#import <Cocoa/Cocoa.h>
#import <BBApplication.h>
#include <stdio.h>

// TODO
// [ ] Arguments parsing?
//       NSArray *arguments = [[NSProcessInfo processInfo] arguments];
// [ ] Tell if launching from bundle or cli?
//       From cli, a ```[NSApp activateIgnoringOtherApps:YES];```, is useful.
//       Maybe just make this a command line option?

int main(int argc, char** argv) {
    @autoreleasepool {
        [[NSApplication sharedApplication] setActivationPolicy:NSApplicationActivationPolicyRegular];
        BBApplication* application = [[BBApplication alloc] init];
        [NSApp setDelegate:application];    
        [NSApp run];
    }

    return 0;
}
