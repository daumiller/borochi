#import <Cocoa/Cocoa.h>
#import <BBHelpers.h>

// === Simple Alerts ============================================================================================================
void bbAlertError(NSString* message) {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle : @"Okay"];
    [alert setMessageText     : message];
    [alert setAlertStyle      : NSAlertStyleCritical];
    [alert runModal];
}

BOOL bbAlertYesNo(NSString* message) {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle : @"Yes"];
    [alert addButtonWithTitle : @"No" ];
    [alert setMessageText     : message];
    [alert setAlertStyle      : NSAlertStyleInformational];
    [alert runModal];

    return ([alert runModal] == NSAlertFirstButtonReturn);
}

// === File Paths ===============================================================================================================
// ~/Library/Application Support/com.cherrybomb.borochi/${filename}
NSString* bbFilePathFromLibrary(NSString* filename) {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray<NSURL*>* applicationSupportURLs = [fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    if(applicationSupportURLs.count < 1) { return nil; }

    NSURL* applicationSupport = [applicationSupportURLs objectAtIndex:0];
    applicationSupportURLs = nil;

    applicationSupport = [applicationSupport URLByAppendingPathComponent:@"cherrybomb.technology"];
    applicationSupport = [applicationSupport URLByAppendingPathComponent:@"borochi"];
    BOOL success = [fileManager createDirectoryAtURL:applicationSupport withIntermediateDirectories:YES attributes:nil error:nil];
    if(success == NO) { return nil; }

    NSURL* fileURL = [applicationSupport URLByAppendingPathComponent:filename];
    return [fileURL path];
}

NSString* bbFilePathFromLibraryComponents(NSArray<NSString*>* components) {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray<NSURL*>* applicationSupportURLs = [fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    if(applicationSupportURLs.count < 1) { return nil; }

    NSURL* applicationSupport = [applicationSupportURLs objectAtIndex:0];
    applicationSupportURLs = nil;

    applicationSupport = [applicationSupport URLByAppendingPathComponent:@"cherrybomb.technology"];
    applicationSupport = [applicationSupport URLByAppendingPathComponent:@"borochi"];
    BOOL success = [fileManager createDirectoryAtURL:applicationSupport withIntermediateDirectories:YES attributes:nil error:nil];
    if(success == NO) { return nil; }

    NSURL* fileURL = applicationSupport;
    for(NSString* component in components) {
        fileURL = [fileURL URLByAppendingPathComponent:component];
    }
    return [fileURL path];
}

// /Applications/borochi.app/Contents/Resources/${filename}
NSString* bbFilePathFromBundle (NSString* filename) {
    return [NSString pathWithComponents:@[ [[NSBundle mainBundle] resourcePath], filename ]];
}

NSString* bbFilePathFromBundleComponents(NSArray<NSString*>* components) {
    NSMutableArray<NSString*>* fullComponents = [NSMutableArray arrayWithArray:components];
    [fullComponents insertObject:[[NSBundle mainBundle] resourcePath] atIndex:0];
    return [NSString pathWithComponents:fullComponents];
}

// === (De)serializing JSON, to/from files ======================================================================================
id bbJsonLoadPath(NSString* path, NSError** error, BOOL showFileErrors, BOOL showJsonErrors) {
    NSInputStream* fileStream = [NSInputStream inputStreamWithFileAtPath:path];
    if(fileStream == nil) {
        if(error != nil) {
            *error = [NSError errorWithDomain:@"technology.cherrybomb.borochi" code:0xF1 userInfo:@{ NSLocalizedDescriptionKey:@"Error opening/reading file." }];
        }
        if(showFileErrors) { bbAlertError([NSString stringWithFormat:@"Error opening/reading file \"%@\"", path]); }
        return nil;
    }

    [fileStream open];
    if(fileStream.streamStatus == NSStreamStatusError) {
        if(error != nil) {
            *error = [NSError errorWithDomain:@"technology.cherrybomb.borochi" code:0xF2 userInfo:@{ NSLocalizedDescriptionKey:@"Error opening/reading file." }];
        }
        if(showFileErrors) { bbAlertError([NSString stringWithFormat:@"Error opening/reading file \"%@\"", path]); }
        return nil;
    }

    NSError* jsonError = nil;
    id json = [NSJSONSerialization JSONObjectWithStream:fileStream options:0 error:(&jsonError)];
    [fileStream close];
    if(jsonError != nil) {
        if(error != nil) { *error = [jsonError copy]; }
        if(showJsonErrors) {
            NSString* errorMessage = [NSString stringWithFormat:@"Error parsing JSON file \"%@\"\n\n%@", path, jsonError.localizedDescription];
            bbAlertError(errorMessage);
        }
        return nil;
    }

    return json;
}

BOOL bbJsonSavePath(NSString* path, id object, NSError** error, BOOL showFileErrors, BOOL showJsonErrors) {
    NSOutputStream* fileStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    if(fileStream == nil) {
        if(error != nil) {
            *error = [NSError errorWithDomain:@"technology.cherrybomb.borochi" code:0xF3 userInfo:@{ NSLocalizedDescriptionKey:@"Error creating/writing file." }];
        }
        if(showFileErrors) { bbAlertError([NSString stringWithFormat:@"Error creating/writing file \"%@\"", path]); }
        return NO;
    }

    [fileStream open];
    if(fileStream.streamStatus == NSStreamStatusError) {
        if(error != nil) {
            *error = [NSError errorWithDomain:@"technology.cherrybomb.borochi" code:0xF4 userInfo:@{ NSLocalizedDescriptionKey:@"Error creating/writing file." }];
        }
        if(showFileErrors) { bbAlertError([NSString stringWithFormat:@"Error creating/writing file \"%@\"", path]); }
        return NO;
    }

    NSError* jsonError = nil;
    [NSJSONSerialization writeJSONObject:object toStream:fileStream options:(NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys) error:(&jsonError)];
    if(jsonError != nil) {
        if(error != nil) { *error = [jsonError copy]; }
        if(showJsonErrors) {
            NSString* errorMessage = [NSString stringWithFormat:@"Error parsing JSON object for file \"%@\"\n\n%@", path, jsonError.localizedDescription];
            bbAlertError(errorMessage);
        }
        return NO;
    }

    return YES;
}
