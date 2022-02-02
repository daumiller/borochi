#import <Cocoa/Cocoa.h>
#import <BBPreferenceDefinitions.h>

// === Preference Value =========================================================================================================
@implementation BBPreferenceValue

+(instancetype)valueID:(NSString*)id withName:(NSString*)name description:(NSString*)description type:(BBPreferenceType)type defaultValue:(id)defaultValue enablesIDs:(NSArray<NSString*>*)enablesIDs {
    BBPreferenceValue* preferenceValue = [[BBPreferenceValue alloc] init];
    if(preferenceValue == nil) { return nil; }

    preferenceValue.id           = id;
    preferenceValue.name         = name;
    preferenceValue.desc         = description;
    preferenceValue.type         = type;
    preferenceValue.defaultValue = defaultValue;
    preferenceValue.enablesIDs   = [[NSArray alloc] initWithArray:enablesIDs copyItems:YES];

    return preferenceValue;
}

@end

// === Preference Category ======================================================================================================
@implementation BBPreferenceCategory

+(instancetype)categoryID:(NSString*)id withName:(NSString*)name description:(NSString*)description values:(NSArray<NSString*>*)values {
    BBPreferenceCategory* preferenceCategory = [[BBPreferenceCategory alloc] init];
    if(preferenceCategory == nil) { return nil; }

    preferenceCategory.id       = id;
    preferenceCategory.name     = name;
    preferenceCategory.desc     = description;
    preferenceCategory.valueIDs = [[NSArray alloc] initWithArray:values copyItems:YES];

    return preferenceCategory;
}

@end

// === Preference Definition ====================================================================================================
@implementation BBPreferenceDefinitions

-(instancetype)init {
    self = [super init];
    if(self == nil) { return nil; }

    // - - Values - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    NSMutableArray* buildValues = [[NSMutableArray alloc] init];
    [buildValues addObject:[BBPreferenceValue valueID: @"homePage"
                                             withName: @"Home Page"
                                          description: @"Page to load when home button clicked, or launching a new browser."
                                                 type: BBPreferenceType_String
                                         defaultValue: @"about:blank"
                                           enablesIDs: @[]
    ]];
    [buildValues addObject:[BBPreferenceValue valueID: @"restoreState"
                                             withName: @"Restore Pages"
                                          description: @"When existing the browser, save open pages, and restore those pages when restarted."
                                                 type: BBPreferenceType_Bool
                                         defaultValue: [NSNumber numberWithBool:YES]
                                           enablesIDs: @[]
    ]];
    [buildValues addObject:[BBPreferenceValue valueID: @"middleClickTab"
                                             withName: @"Middle Click for New Tab"
                                          description: @"Set middle-clicked links to open in a new tab."
                                                 type: BBPreferenceType_Bool
                                         defaultValue: [NSNumber numberWithBool:YES]
                                           enablesIDs: @[ @"activateMiddleClickTab" ]
    ]];
    [buildValues addObject:[BBPreferenceValue valueID: @"activateMiddleClickTab"
                                             withName: @"Activate New Tabs"
                                          description: @"Activate new tabs opened with a middle-click."
                                                 type: BBPreferenceType_Bool
                                         defaultValue: [NSNumber numberWithBool:NO]
                                           enablesIDs: @[]
    ]];
    [buildValues addObject:[BBPreferenceValue valueID: @"historyPreserve"
                                             withName: @"Save History"
                                          description: @"Preserve browser history across sessions."
                                                 type: BBPreferenceType_Bool
                                         defaultValue: [NSNumber numberWithBool:YES]
                                           enablesIDs: @[ @"historyMaxAge" ]
    ]];
    [buildValues addObject:[BBPreferenceValue valueID: @"historyMaxAge"
                                             withName: @"History Length"
                                          description: @"How many days to store history (0 for indefinite)."
                                                 type: BBPreferenceType_Integer
                                         defaultValue: [NSNumber numberWithInteger:7]
                                           enablesIDs: @[]
    ]];
    [buildValues addObject:[BBPreferenceValue valueID: @"addressBarAutocompleteEnabled"
                                             withName: @"Autocomplete Enabled"
                                          description: @"Enable autocomplete in the address bar."
                                                 type: BBPreferenceType_Bool
                                         defaultValue: [NSNumber numberWithBool:YES]
                                           enablesIDs: @[
                                               @"addressBarAutocompleteBookmarks",
                                               @"addressBarAutocompleteEnteredAddresses",
                                               @"addressBarAutocompleteLinksFollowed",
                                               @"addressBarAutocompleteMaxResults"
                                           ]
    ]];
    [buildValues addObject:[BBPreferenceValue valueID: @"addressBarAutocompleteBookmarks"
                                             withName: @"Autocomplete Bookmarks"
                                          description: @"Enable bookmarks as a source of autocompletions in the address bar."
                                                 type: BBPreferenceType_Bool
                                         defaultValue: [NSNumber numberWithBool:YES]
                                           enablesIDs: @[]
    ]];
    [buildValues addObject:[BBPreferenceValue valueID: @"addressBarAutocompleteEnteredAddresses"
                                             withName: @"Autocomplete Entered Addresses"
                                          description: @"Enable previously entered addresses as a source of autocompletions in the address bar."
                                                 type: BBPreferenceType_Bool
                                         defaultValue: [NSNumber numberWithBool:YES]
                                           enablesIDs: @[]
    ]];
    [buildValues addObject:[BBPreferenceValue valueID: @"addressBarAutocompleteLinksFollowed"
                                             withName: @"Autocomplete Followed Links"
                                          description: @"Enable previously followed links as a source of autocompletions in the address bar."
                                                 type: BBPreferenceType_Bool
                                         defaultValue: [NSNumber numberWithBool:NO]
                                           enablesIDs: @[]
    ]];
    [buildValues addObject:[BBPreferenceValue valueID: @"addressBarAutocompleteMaxResults"
                                             withName: @"Autocomplete Suggestion Limit"
                                          description: @"Maximum number of autocomplete values to show for the address bar (0 for unlimited)."
                                                 type: BBPreferenceType_Integer
                                         defaultValue: [NSNumber numberWithInteger:10]
                                           enablesIDs: @[]
    ]];
    [buildValues addObject:[BBPreferenceValue valueID: @"addressBarSearchEnabled"
                                             withName: @"Search Enabled"
                                          description: @"Enable searching from the address bar."
                                                 type: BBPreferenceType_Bool
                                         defaultValue: [NSNumber numberWithBool:YES]
                                           enablesIDs: @[
                                               @"addressBarSearchTemplates",
                                               @"addressBarSearchDefault"
                                           ]
    ]];
    [buildValues addObject:[BBPreferenceValue valueID: @"addressBarSearchTemplates"
                                             withName: @"Search Templates"
                                          description: @"Search templates to use in the Address Bar."
                                                 type: BBPreferenceType_StringStringDictionary
                                         defaultValue: @{
                                                  @"ddg "    : @"https://duckduckgo.com/?q=${search}",
                                                  @"usps "   : @"https://tools.usps.com/go/TrackConfirmAction?qtc_tLabels1=${search}",
                                                  @"ups "    : @"https://www.ups.com/track?loc=null&tracknum=${search}",
                                                  @"github " : @"https://github.com/search?q=${search}",
                                                  @"google " : @"https://www.google.com/search?client=borochi&rls=en&q=${search}&ie=UTF-8&oe=UTF-8",
                                              }
                                           enablesIDs: @[]
    ]];
    [buildValues addObject:[BBPreferenceValue valueID: @"addressBarSearchDefault"
                                             withName: @"Default Search"
                                          description: @"Search template to use for non-keyword searches."
                                                 type: BBPreferenceType_String
                                         defaultValue: @"ddg"
                                           enablesIDs: @[]
    ]];
    [buildValues addObject:[BBPreferenceValue valueID: @"loginGenerate"
                                             withName: @"Generate Passwords"
                                          description: @"Offer to generate passwords for new logins."
                                                 type: BBPreferenceType_Bool
                                         defaultValue: [NSNumber numberWithBool:YES]
                                           enablesIDs: @[]
    ]];
    [buildValues addObject:[BBPreferenceValue valueID: @"loginSave"
                                             withName: @"Save Logins"
                                          description: @"Offer to save login information."
                                                 type: BBPreferenceType_Bool
                                         defaultValue: [NSNumber numberWithBool:YES]
                                           enablesIDs: @[ @"loginAutofill" ]
    ]];
    [buildValues addObject:[BBPreferenceValue valueID: @"loginAutofill"
                                             withName: @"Autofill Logins"
                                          description: @"Autofill saved login information."
                                                 type: BBPreferenceType_Bool
                                         defaultValue: [NSNumber numberWithBool:YES]
                                           enablesIDs: @[]
    ]];

    self.values = buildValues;

    // - - Categories - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    NSMutableArray* buildCategories = [[NSMutableArray alloc] init];
    [buildCategories addObject:[BBPreferenceCategory categoryID: @"general"
                                                       withName: @"General"
                                                    description: @"General Preferences"
                                                         values: @[
                                                             @"homePage",
                                                             @"restoreState",
                                                             @"middleClickTab",
                                                             @"activateMiddleClickTab"
                                                         ]
    ]];
    [buildCategories addObject:[BBPreferenceCategory categoryID: @"history"
                                                       withName: @"History"
                                                    description: @"Preferences for browser history."
                                                         values: @[
                                                             @"historyPreserve",
                                                             @"historyMaxAge"
                                                         ]
    ]];
    [buildCategories addObject:[BBPreferenceCategory categoryID: @"addressBarAutocopmlete"
                                                       withName: @"Autocomplete"
                                                    description: @"Preferences for autocomplete in the Address Bar."
                                                         values: @[
                                                             @"addressBarAutocompleteEnabled",
                                                             @"addressBarAutocompleteBookmarks",
                                                             @"addressBarAutocompleteEnteredAddresses",
                                                             @"addressBarAutocompleteLinksFollowed",
                                                             @"addressBarAutocompleteMaxResults"
                                                         ]
    ]];
    [buildCategories addObject:[BBPreferenceCategory categoryID: @"addressBarSearch"
                                                       withName: @"Search"
                                                    description: @"Preferences for searching from the Address Bar."
                                                         values: @[
                                                             @"addressBarSearchEnabled",
                                                             @"addressBarSearchTemplates",
                                                             @"addressBarSearchDefault"
                                                         ]
    ]];
    [buildCategories addObject:[BBPreferenceCategory categoryID: @"login"
                                                       withName: @"Logins"
                                                    description: @"Preferences for saving login information."
                                                         values: @[
                                                             @"loginGenerate",
                                                             @"loginSave",
                                                             @"loginAutofill"
                                                         ]
    ]];
    self.categories = buildCategories;

    return self;
}

-(BOOL)validatePreferenceDefinitionsCode {
    NSMutableDictionary<NSString*, NSString*>* valueCategory  = [[NSMutableDictionary alloc] init];
    NSMutableDictionary<NSString*, NSString*>* categoryLookup = [[NSMutableDictionary alloc] init];
    NSMutableArray<NSString*>*                 errors         = [[NSMutableArray alloc] init];

    // lookup of valueID:categoryID
    for(BBPreferenceValue* value in self.values) {
        // basic field validation
        if((value.id == nil) || (value.id.length == 0)) {
            [errors addObject:[NSString stringWithFormat:@"Found value with a missing id."]];
            continue;
        }
        if((value.name == nil) || (value.name.length == 0)) {
            [errors addObject:[NSString stringWithFormat:@"Value \"%@\" is missing a name.", value.id]];
        }
        if((value.desc == nil) || (value.desc.length == 0)) {
            [errors addObject:[NSString stringWithFormat:@"Value \"%@\" is missing a description.", value.id]];
        }

        // no duplicate IDs
        if([valueCategory objectForKey:value.id] != nil) {
            [errors addObject:[NSString stringWithFormat:@"Value ID \"%@\" is used more than once.", value.id]];
            continue;
        }

        [valueCategory setObject:@"" forKey:value.id];
    }

    // validate categories
    for(BBPreferenceCategory* category in self.categories) {
        // basic field validation
        if((category.id == nil) || (category.id.length == 0)) {
            [errors addObject:[NSString stringWithFormat:@"Found category with a missing id."]];
            continue;
        }
        if((category.name == nil) || (category.name.length == 0)) {
            [errors addObject:[NSString stringWithFormat:@"Category \"%@\" is missing a name.", category.id]];
        }
        if((category.desc == nil) || (category.desc.length == 0)) {
            [errors addObject:[NSString stringWithFormat:@"Category \"%@\" is missing a description.", category.id]];
        }
        if((category.valueIDs == nil) || (category.valueIDs.count == 0)) {
            [errors addObject:[NSString stringWithFormat:@"Category \"%@\" has no value IDs.", category.id]];
            continue;
        }

        // no duplicate IDs
        if([categoryLookup objectForKey:category.id] != nil) {
            [errors addObject:[NSString stringWithFormat:@"Category ID \"%@\" is used more than once.", category.id]];
            continue;
        }
        [categoryLookup setObject:@"" forKey:category.id];

        for(NSString* valueID in category.valueIDs) {
            // all values[] are valid Value IDs
            if([valueCategory objectForKey:valueID] == nil) {
                [errors addObject:[NSString stringWithFormat:@"Category \"%@\" lists unregistered Value ID \"%@\".", category.id, valueID]];
                continue;
            }
            // no Values listed in multiple Categories (maybe allow this later)
            if([valueCategory objectForKey:valueID].length > 0) {
                [errors addObject:[NSString stringWithFormat:@"Category \"%@\" lists Value ID \"%@\", that is already in category \"%@\".", category.id, valueID, (NSString*)([valueCategory objectForKey:valueID])]];
                continue;
            }
            [valueCategory setObject:category.id forKey:valueID];
        }
    }

    // finally, iterate through valueCategories, to esnure that
    // - all values appear in a category
    for(NSString* key in valueCategory) {
        if([valueCategory objectForKey:key].length == 0) {
            [errors addObject:[NSString stringWithFormat:@"Value \"%@\" is never used in a category.", key]];
        }
    }

    BOOL success = (errors.count == 0);

    if(success == NO) {
        [errors insertObject:@""                                            atIndex:0];
        [errors insertObject:@"Users should never see this message."        atIndex:0];
        [errors insertObject:@"borochi preference definitions are invalid." atIndex:0];
        NSString* errorString = [errors componentsJoinedByString:@"\r\n"];

        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle : @"Okay"];
        [alert setMessageText     : errorString];
        [alert setAlertStyle      : NSAlertStyleCritical];
        [alert runModal];
    }

    return success;
}

@end
