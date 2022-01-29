#import <Cocoa/Cocoa.h>
#import <BBAddressBar.h>

@implementation BBAddressBar

-(BOOL)becomeFirstResponder {
    BOOL result = [super becomeFirstResponder];
    if(!result) { return NO; }

    // when activated, always select-all, so new addresses can be more easily typed
    // delay here is so the contained cell can finish setup before we select-all
    [self performSelector:@selector(selectText:) withObject:self afterDelay:0];
    return YES;
}

@end
