#import <Cocoa/Cocoa.h>

// === Preference Value =========================================================================================================
typedef NS_ENUM(NSInteger, BBPreferenceType) {
    BBPreferenceType_String,
    BBPreferenceType_Bool,
    BBPreferenceType_Integer,
    BBPreferenceType_StringStringDictionary
};

@interface BBPreferenceValue : NSObject
@property (copy) NSString*    id;
@property (copy) NSString*    name;
@property (copy) NSString*    desc;         // can't use "description" (read-write, anyway)
@property BBPreferenceType    type;
@property (copy) id           defaultValue; // can't use "default"
@property NSArray<NSString*>* enablesIDs;

+(instancetype)valueID:(NSString*)id withName:(NSString*)name description:(NSString*)description type:(BBPreferenceType)type defaultValue:(id)defaultValue enablesIDs:(NSArray<NSString*>*)enablesIDs;
@end

// === Preference Category ======================================================================================================
@interface BBPreferenceCategory : NSObject
@property (copy) NSString*    id;
@property (copy) NSString*    name;
@property (copy) NSString*    desc; // horrible abbreviation...
@property NSArray<NSString*>* valueIDs;

+(instancetype)categoryID:(NSString*)id withName:(NSString*)name description:(NSString*)description values:(NSArray<NSString*>*)values;
@end

// === Preference Definition ====================================================================================================
@interface BBPreferenceDefinitions : NSObject
@property NSArray<BBPreferenceValue*>*    values;
@property NSArray<BBPreferenceCategory*>* categories;

-(instancetype)init;
-(BOOL)validatePreferenceDefinitionsCode;
@end
