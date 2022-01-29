#import <Cocoa/Cocoa.h>
#import <BBApplication.h>

// TODO
// [ ] Arguments parsing?
//       NSArray *arguments = [[NSProcessInfo processInfo] arguments];
// [ ] Tell if launching from bundle or cli?
//       From cli, a ```[NSApp activateIgnoringOtherApps:YES];```, is useful.
//       Maybe just make this a command line option?

int main(int argc, char** argv) {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    [[NSApplication sharedApplication] setActivationPolicy:NSApplicationActivationPolicyRegular];

    BBApplication* application = [[BBApplication alloc] init];
    [NSApp setDelegate:application];    
    [NSApp run];

    [application release];
    [pool drain];
    return 0;
}
