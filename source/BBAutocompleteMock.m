#import <Cocoa/Cocoa.h>
#import <BBAddressBar.h>
#import <BBAutocompleteMock.h>

@implementation BBAutocompleteMock

-(instancetype)init {
    self = [super init];

    if(self) {
        _completions = [[NSMutableArray alloc] init];
        [_completions addObject:@"github.com"];
        [_completions addObject:@"news.ycombinator.com"];
        [_completions addObject:@"news.google.com"];
        [_completions addObject:@"http://localhost:8080"];
    }

    return self;
}

-(NSArray<NSString*>*)completionsForPartial:(NSString*)string {
    NSMutableArray<NSString*>* matches = [[NSMutableArray alloc] init];

    NSString* workingSource = string;
    if([workingSource hasPrefix:@"http://"]) {
        workingSource = [workingSource substringFromIndex:7];
    } else if([workingSource hasPrefix:@"https://"]) {
        workingSource = [workingSource substringFromIndex:8];
    }
    if([workingSource hasPrefix:@"www."]) {
        workingSource = [workingSource substringFromIndex:4];
    }
    if(workingSource.length < 1) {
        return matches;
    }

    for(NSString* completion in _completions) {
        if([completion hasPrefix:workingSource]) {
            [matches addObject:completion];
        } else if([completion hasPrefix:string]) {
            [matches addObject:completion];
        }
    }

    return matches;
}

-(void)removeCompletion:(NSString*)completion {
    [_completions removeObject:completion];
}

@end
