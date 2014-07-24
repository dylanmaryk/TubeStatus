//
//  SettingsViewController.h
//  TubeStatus
//
//  Created by Dylan Maryk on 23/07/2014.
//  Copyright (c) 2014 Dylan Maryk. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FXForms.h"

@interface SettingsViewController : UIViewController <FXFormControllerDelegate>

@property (nonatomic, strong) FXFormController *settingsFormController;

@property (nonatomic, strong) IBOutlet UITableView *settingsTableView;

@end
