//
//  DataModel.h
//  TubeStatus
//
//  Created by Dylan Maryk on 29/06/2014.
//  Copyright (c) 2014 Dylan Maryk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

+ (NSMutableArray *)getDataForSelectedLinesOnly:(bool)selectedLinesOnly refreshedData:(bool)refreshedData;

+ (bool)getRefreshedData;

+ (NSMutableArray *)getSettings;

+ (void)setCachedSetting:(bool)settingValue forIdentifier:(NSString *)settingIdentifier;
+ (void)updateRemoteSettings;
+ (void)registerForSettingsSync;

+ (NSUserDefaults *)getUserDefaults;

+ (void)setUserDefaultsObject:(id)object forKey:(NSString *)key andSync:(bool)syncObject;

@end
