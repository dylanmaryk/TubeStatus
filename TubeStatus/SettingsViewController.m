//
//  SettingsViewController.m
//  TubeStatus
//
//  Created by Dylan Maryk on 23/07/2014.
//  Copyright (c) 2014 Dylan Maryk. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsForm.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize settingsTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settingsFormController = [[FXFormController alloc] init];
    self.settingsFormController.tableView = self.settingsTableView;
    self.settingsFormController.delegate = self;
    self.settingsFormController.form = [[SettingsForm alloc] init];
}

@end
