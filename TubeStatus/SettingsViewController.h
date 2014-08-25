//
//  SettingsViewController.h
//  TubeStatus
//
//  Created by Dylan Maryk on 23/07/2014.
//  Copyright (c) 2014 Dylan Maryk. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SettingTableViewCell.h"

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet SettingTableViewCell *settingTableViewCell;
}

@property (nonatomic, retain) IBOutlet UITableView *settingTableView;

- (IBAction)settingSwitchTapped:(id)sender;

@end
