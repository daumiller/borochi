#import <Cocoa/Cocoa.h>
#import <BBAddressBar.h>

@interface BBAutocompleteMock : NSObject <BBAddressCompletionSource> {
    NSMutableArray<NSString*>* _completions;
}
-(NSArray<NSString*>*)completionsForPartial:(NSString*)string;
-(void)removeCompletion:(NSString*)completion;
@end
