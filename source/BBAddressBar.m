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

-(void)setLoading:(BOOL)loading {
    _loading = loading;
    [self setNeedsDisplay:YES];
}

-(void)setProgress:(double)progress {
    _progress = progress;
    [self setNeedsDisplay:YES];
}

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    if(_loading) {
        NSRect progressRect = [self bounds];
        progressRect.size.width *= _progress;

        [[NSColor keyboardFocusIndicatorColor] set];
        NSRectFillUsingOperation(progressRect, NSCompositingOperationSourceOver);
    }
}

@end
