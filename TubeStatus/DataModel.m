//
//  DataModel.m
//  TubeStatus
//
//  Created by Dylan Maryk on 29/06/2014.
//  Copyright (c) 2014 Dylan Maryk. All rights reserved.
//

#import "DataModel.h"
#import "XMLParserDelegate.h"

@implementation DataModel

+ (NSMutableArray *)getDataForSelectedLinesOnly:(bool)selectedLinesOnly refreshedData:(bool)refreshedData {
    bool dataAvailable;
    
    if (refreshedData) {
        XMLParserDelegate *xmlParserDelegate = [[XMLParserDelegate alloc] init];
        
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://cloud.tfl.gov.uk/TrackerNet/LineStatus"]];
        [xmlParser setDelegate:xmlParserDelegate];
        
        dataAvailable = [xmlParser parse];
    } else {
        dataAvailable = [[self getUserDefaults] objectForKey:@"cachedData"];
    }
    
    if (dataAvailable) {
        NSMutableArray *cachedData = [[[self getUserDefaults] objectForKey:@"cachedData"] mutableCopy];
        
        if (selectedLinesOnly) {
            NSMutableArray *cachedDataSelectedLinesOnly = [NSMutableArray array];
            
            for (NSDictionary *lineDict in cachedData) {
                if ([[lineDict valueForKey:@"setting"] boolValue]) {
                    [cachedDataSelectedLinesOnly addObject:lineDict];
                }
            }
            
            cachedData = cachedDataSelectedLinesOnly;
        }
        
        for (int i = 0; i < cachedData.count; i++) {
            NSMutableDictionary *lineDict = [cachedData[i] mutableCopy];
            
            cachedData[i] = lineDict;
        }
        
        return cachedData;
    } else {
        return nil;
    }
}

+ (NSArray *)getSettings {
    NSArray *daysOfWeek = [NSArray arrayWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday", nil];
    
    NSMutableArray *appSettings = [NSMutableArray array];
    
    for (NSString *dayOfWeek in daysOfWeek) {
        NSString *appSettingIdentifier = dayOfWeek.lowercaseString;
        
        [appSettings addObject:[NSDictionary dictionaryWithObjectsAndKeys:appSettingIdentifier, @"identifier", dayOfWeek, @"name", [self getCachedSettingByIdentifier:appSettingIdentifier onByDefault:NO], @"setting", nil]];
    }
    
    return appSettings;
}

+ (NSNumber *)getCachedSettingByIdentifier:(NSString *)settingIdentifier onByDefault:(bool)onByDefault {
    NSMutableDictionary *cachedAppSettings = [[[self getUserDefaults] valueForKey:@"appSettings"] mutableCopy];
    
    if (!cachedAppSettings) {
        cachedAppSettings = [NSMutableDictionary dictionary];
        
        [self setUserDefaultsObject:cachedAppSettings forKey:@"appSettings"];
    }
    
    NSNumber *cachedAppSetting = [cachedAppSettings valueForKey:settingIdentifier];
    
    if (cachedAppSetting) {
        return cachedAppSetting;
    } else {
        NSNumber *newCachedAppSetting = [NSNumber numberWithBool:onByDefault];
        
        [cachedAppSettings setValue:newCachedAppSetting forKey:settingIdentifier];
        
        [self setUserDefaultsObject:cachedAppSettings forKey:@"appSettings"];
        
        return newCachedAppSetting;
    }
}

+ (void)setCachedSetting:(bool)settingValue forIdentifier:(NSString *)settingIdentifier {
    NSMutableDictionary *cachedAppSettings = [[[self getUserDefaults] valueForKey:@"appSettings"] mutableCopy];
    
    [cachedAppSettings setValue:[NSNumber numberWithBool:settingValue] forKey:settingIdentifier];
    
    [self setUserDefaultsObject:cachedAppSettings forKey:@"appSettings"];
}

+ (NSUserDefaults *)getUserDefaults {
    return [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dylanmaryk.TubeStatus"];
}

+ (void)setUserDefaultsObject:(id)object forKey:(NSString *)key {
    [[self getUserDefaults] setObject:object forKey:key];
    [[self getUserDefaults] synchronize];
}

@end
