//
//  DataModel.m
//  TubeStatus
//
//  Created by Dylan Maryk on 29/06/2014.
//  Copyright (c) 2014 Dylan Maryk. All rights reserved.
//

#import "DataModel.h"
#import "XMLParserDelegate.h"
#import "AFHTTPSessionManager.h"
#import "SDCloudUserDefaults.h"

@implementation DataModel

static NSString *suiteName = @"group.com.dylanmaryk.TubeStatus";

+ (NSMutableArray *)getDataForSelectedLinesOnly:(bool)selectedLinesOnly refreshedData:(bool)refreshedData {
    bool dataAvailable;
    
    if (refreshedData) {
        dataAvailable = [self getRefreshedData];
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

+ (bool)getRefreshedData {
    XMLParserDelegate *xmlParserDelegate = [[XMLParserDelegate alloc] init];
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://cloud.tfl.gov.uk/TrackerNet/LineStatus"]];
    [xmlParser setDelegate:xmlParserDelegate];
    
    return [xmlParser parse];
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
        
        [self setUserDefaultsObject:cachedAppSettings forKey:@"appSettings" andSync:NO];
    }
    
    NSNumber *cachedAppSetting = [cachedAppSettings valueForKey:settingIdentifier];
    
    if (cachedAppSetting) {
        return cachedAppSetting;
    } else {
        [self setCachedSetting:onByDefault forIdentifier:settingIdentifier];
        
        return [NSNumber numberWithBool:onByDefault];
    }
}

+ (void)setCachedSetting:(bool)settingValue forIdentifier:(NSString *)settingIdentifier {
    NSMutableDictionary *cachedAppSettings = [[[self getUserDefaults] valueForKey:@"appSettings"] mutableCopy];
    [cachedAppSettings setValue:[NSNumber numberWithBool:settingValue] forKey:settingIdentifier];
    
    [self setUserDefaultsObject:cachedAppSettings forKey:@"appSettings" andSync:YES];
}

+ (void)updateRemoteSettings {
    [self registerForSettingsSync];
    
    NSString *deviceToken = [[self getUserDefaults] valueForKey:@"deviceToken"];
    
    if (deviceToken) {
        NSArray *cachedData = [self getDataForSelectedLinesOnly:YES refreshedData:NO];
        NSArray *linesSelected = [cachedData valueForKey:@"name"];
        
        NSString *linesPref = [linesSelected componentsJoinedByString:@", "];
        
        if (!linesPref) {
            linesPref = @"";
        }
        
        NSArray *daysOfWeek = [NSArray arrayWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday", nil];
        
        NSMutableArray *daysSelected = [NSMutableArray array];
        
        for (NSDictionary *setting in [self getSettings]) {
            NSString *settingName = [setting valueForKey:@"name"];
            
            if ([daysOfWeek containsObject:settingName] && [[setting valueForKey:@"setting"] boolValue]) {
                [daysSelected addObject:settingName];
            }
        }
        
        NSString *daysPref = [daysSelected componentsJoinedByString:@", "];
        
        if (!daysPref) {
            daysPref = @"";
        }
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager POST:@"http://api.tubestatus.dylanmaryk.com/prefs" parameters:@{ @"devicetoken":deviceToken, @"linespref":linesPref, @"dayspref":daysPref } progress:nil success:nil failure:nil];
    }
}

+ (void)registerForSettingsSync {
    [SDCloudUserDefaults setSuiteName:suiteName];
    [SDCloudUserDefaults registerForNotifications];
}

+ (NSUserDefaults *)getUserDefaults {
    return [[NSUserDefaults alloc] initWithSuiteName:suiteName];
}

+ (void)setUserDefaultsObject:(id)object forKey:(NSString *)key andSync:(bool)syncObject {
    [[self getUserDefaults] setObject:object forKey:key];
    [[self getUserDefaults] synchronize];
    
    if (syncObject) {
        [SDCloudUserDefaults setObject:object forKey:key];
        [SDCloudUserDefaults synchronize];
    }
}

@end
