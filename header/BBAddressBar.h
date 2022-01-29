#import <Cocoa/Cocoa.h>

@interface BBAddressBar : NSTextField {
    BOOL _loading;
    double _progress;
}

-(BOOL)becomeFirstResponder;

-(void)setLoading:(BOOL)loading;
-(void)setProgress:(double)progress;

@end
