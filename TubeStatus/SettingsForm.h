//
//  SettingsForm.h
//  TubeStatus
//
//  Created by Dylan Maryk on 24/07/2014.
//  Copyright (c) 2014 Code Canopy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FXForms.h"

@interface SettingsForm : NSObject <FXForm>

@property (nonatomic, assign) bool syncSettings;
@property (nonatomic, assign) bool dayMonday;
@property (nonatomic, assign) bool dayTuesday;
@property (nonatomic, assign) bool dayWednesday;
@property (nonatomic, assign) bool dayThursday;
@property (nonatomic, assign) bool dayFriday;
@property (nonatomic, assign) bool daySaturday;
@property (nonatomic, assign) bool daySunday;

@end
