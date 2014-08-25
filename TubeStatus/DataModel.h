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
+ (NSMutableArray *)getSettings;

+ (NSUserDefaults *)getUserDefaults;

+ (void)setUserDefaultsObject:(id)object forKey:(NSString *)key;

@end
