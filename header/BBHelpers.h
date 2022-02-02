// Little Helper Library
// mostly simplifying objc/cocoa boilerplate

// === Simple Alerts ============================================================================================================
void bbAlertError(NSString* message);
BOOL bbAlertYesNo(NSString* message);

// === File Paths ===============================================================================================================
// ~/Library/Application Support/com.cherrybomb.borochi/${filename}
NSString* bbFilePathFromLibrary(NSString* filename);
NSString* bbFilePathFromLibraryComponents(NSArray<NSString*>* components);

// /Applications/borochi.app/Contents/Resources/${filename}
NSString* bbFilePathFromBundle(NSString* filename);
NSString* bbFilePathFromBundleComponents(NSArray<NSString*>* components);

// === (De)serializing JSON, to/from files ======================================================================================
id   bbJsonLoadPath(NSString* path, NSError** error, BOOL showFileErrors, BOOL showJsonErrors);
BOOL bbJsonSavePath(NSString* path, id object, NSError** error, BOOL showFileErrors, BOOL showJsonErrors);
