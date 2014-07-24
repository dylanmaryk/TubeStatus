//
//  SettingsForm.m
//  TubeStatus
//
//  Created by Dylan Maryk on 24/07/2014.
//  Copyright (c) 2014 Code Canopy. All rights reserved.
//

#import "SettingsForm.h"

@implementation SettingsForm

- (NSDictionary *)syncSettingsField {
    return @{FXFormFieldHeader:@"iCloud Sync",
             FXFormFieldTypeText:@"Sync Settings Over iCloud"};
}

- (NSDictionary *)dayMondayField {
    return @{FXFormFieldHeader:@"Notifications",
             FXFormFieldTypeText:@"Monday"};
}

- (NSDictionary *)dayTuesdayField {
    return @{FXFormFieldTypeText:@"Tuesday"};
}

- (NSDictionary *)dayWednesdayField {
    return @{FXFormFieldTypeText:@"Wednesday"};
}

- (NSDictionary *)dayThursdayField {
    return @{FXFormFieldTypeText:@"Thursday"};
}

- (NSDictionary *)dayFridayField {
    return @{FXFormFieldTypeText:@"Friday"};
}

- (NSDictionary *)daySaturdayField {
    return @{FXFormFieldTypeText:@"Saturday"};
}

- (NSDictionary *)daySundayField {
    return @{FXFormFieldTypeText:@"Sunday"};
}

@end
