#import <Cocoa/Cocoa.h>
#import <BBPreferenceDefinitions.h>

@interface BBPreferences : NSObject {
    BBPreferenceDefinitions*           _definitions;
    NSMutableDictionary<NSString*,id>* _preferenceValues;
    NSDictionary<NSString*,id>*        _defaultValues;
}

// === Lifecycle ================================================================================================================
+(instancetype)sharedPreferences;

// === Values ===================================================================================================================
-(id)getPreference:(NSString*)preferenceID;
-(id)getPreference:(NSString*)preferenceID isDefault:(BOOL*)isDefault;
-(id)getDefault:(NSString*)preferenceID;
-(BOOL)setPreference:(NSString*)preferenceID withObject:(id)preferenceValue;

// === Load/Save ================================================================================================================
-(BOOL)loadPreferences;
-(BOOL)loadPreferencesFromFile:(NSString*)path;

-(BOOL)savePreferences;
-(BOOL)savePreferencesToFile:(NSString*)path;

// === Preferences Window =======================================================================================================
-(void)showPreferencesWindow;

@end
