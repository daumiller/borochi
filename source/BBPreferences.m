#import <Cocoa/Cocoa.h>
#import <BBPreferences.h>
#import <BBHelpers.h>

@implementation BBPreferences

// === Lifecycle ================================================================================================================
+(instancetype)sharedPreferences {
    static BBPreferences* sharedPreferences = nil;
    static dispatch_once_t sharedPreferencesToken;

    dispatch_once(&sharedPreferencesToken, ^{
        sharedPreferences = [[BBPreferences alloc] init];
    });

    return sharedPreferences;
}

-(instancetype)init {
    self = [super init];
    if(self == nil) { return nil; }

    BBPreferenceDefinitions* defs = [[BBPreferenceDefinitions alloc] init];
    if([defs validatePreferenceDefinitionsCode] == YES) {
        _definitions = defs;
        [self buildDefaults];
        [self loadPreferences];
    } else {
        _definitions      = nil;
        _preferenceValues = nil;
        _defaultValues    = nil;
    }

    return self;
}

-(void)buildDefaults {
    if(_definitions == nil) { return; }

    NSMutableDictionary<NSString*,BBPreferenceValue*>* buildDefs = [[NSMutableDictionary alloc] init];

    for(BBPreferenceValue* pref in _definitions.values) {
        [buildDefs setObject:pref forKey:pref.id];
    }

    _defaultValues = [NSDictionary dictionaryWithDictionary:buildDefs];
}

// === Values ===================================================================================================================
-(id)getPreference:(NSString*)preferenceID {
    return [self getPreference:preferenceID isDefault:nil];
}

-(id)getPreference:(NSString*)preferenceID isDefault:(BOOL*)isDefault {
    if(_definitions == nil) { return nil; }

    if(_preferenceValues != nil) {
        id setValue = [_preferenceValues objectForKey:preferenceID];
        if(setValue != nil) {
            if(isDefault != nil) { *isDefault = NO; }
            return setValue;
        }
    }

    if(_defaultValues != nil) {
        BBPreferenceValue* prefVal = [_defaultValues objectForKey:preferenceID];
        if(prefVal != nil) {
            if(isDefault != nil) { *isDefault = YES; }
            return prefVal.defaultValue;
        }
    }

    return nil;
}

-(id)getDefault:(NSString*)preferenceID {
    if(_definitions == nil) { return nil; }
    if(_defaultValues == nil) { return nil; }
    return [_defaultValues objectForKey:preferenceID];
}

-(BOOL)setPreference:(NSString*)preferenceID withObject:(id)preferenceValue {
    if(_definitions == nil) { return NO; }
    if(_preferenceValues == nil) { return NO; }

    [_preferenceValues setObject:preferenceValue forKey:preferenceID];
    return YES;
}

// === Load/Save ================================================================================================================
-(NSString*)defaultPreferencesLocation {
    return bbFilePathFromLibrary(@"preferences.json");
}

-(BOOL)loadPreferences {
    return [self loadPreferencesFromFile:[self defaultPreferencesLocation]];
}

-(BOOL)loadPreferencesFromFile:(NSString*)path {
    if(_definitions == nil) { return NO; }

    // create empty preferences dict
    // even if file loading fails (no prefs exist), we can still set prefs to save later
    _preferenceValues = [[NSMutableDictionary alloc] init];

    // load preferences file
    // don't show file errors (may be first run, or reset prefs), but do show parse errors
    id json = bbJsonLoadPath(path, nil, NO, YES);
    if(json == nil) { return NO; }

    // copy to our preferences
    NSDictionary<NSString*, id>* jsonRoot = (NSDictionary<NSString*, id>*)json;
    for(NSString* key in jsonRoot) {
        [_preferenceValues setObject:[jsonRoot objectForKey:key] forKey:key];
    }

    return YES;
}

-(BOOL)savePreferences {
    return [self savePreferencesToFile:[self defaultPreferencesLocation]];
}

-(BOOL)savePreferencesToFile:(NSString*)path {
    if(_definitions == nil) { return NO; }
    if(_preferenceValues == nil) { return NO; }

    // save JSON; let it handle any error messages
    return bbJsonSavePath(path, _preferenceValues, nil, YES, YES);
}

// === Preferences Window =======================================================================================================
-(void)showPreferencesWindow {
    if(_definitions == nil) { return; }
}

@end
