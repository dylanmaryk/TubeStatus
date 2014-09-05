//
//  DataModelAppOnly.m
//  TubeStatus
//
//  Created by Dylan Maryk on 02/09/2014.
//  Copyright (c) 2014 Code Canopy. All rights reserved.
//

#import "DataModelAppOnly.h"
#import "DataModel.h"
#import "AFHTTPRequestOperationManager.h"

@implementation DataModelAppOnly

+ (void)updateRemoteSettings {
    NSString *deviceToken = [[DataModel getUserDefaults] valueForKey:@"deviceToken"];
    
    if (deviceToken) {
        NSArray *cachedData = [DataModel getDataForSelectedLinesOnly:YES refreshedData:NO];
        NSArray *linesSelected = [cachedData valueForKey:@"name"];
        
        NSString *linesPref = [linesSelected componentsJoinedByString:@", "];
        
        if (!linesPref) {
            linesPref = @"";
        }
        
        NSArray *daysOfWeek = [NSArray arrayWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday", nil];
        
        NSMutableArray *daysSelected = [NSMutableArray array];
        
        for (NSDictionary *setting in [DataModel getSettings]) {
            NSString *settingName = [setting valueForKey:@"name"];
            
            if ([daysOfWeek containsObject:settingName] && [[setting valueForKey:@"setting"] boolValue]) {
                [daysSelected addObject:settingName];
            }
        }
        
        NSString *daysPref = [daysSelected componentsJoinedByString:@", "];
        
        if (!daysPref) {
            daysPref = @"";
        }
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:@"http://api.tubestatus.dylanmaryk.com/prefs" parameters:@{ @"devicetoken": deviceToken, @"linespref": linesPref, @"dayspref": daysPref } success:nil failure:nil];
    }
}

@end
