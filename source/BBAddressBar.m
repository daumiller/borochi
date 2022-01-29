#import <Cocoa/Cocoa.h>
#import <BBAddressBar.h>

@implementation BBAddressBar

-(BOOL)becomeFirstResponder {
    BOOL result = [super becomeFirstResponder];
    if(!result) { return NO; }

    [self performSelector:@selector(selectText:) withObject:self afterDelay:0];
    return YES;
}

@end
