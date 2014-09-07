//
//  SettingsViewController.m
//  TubeStatus
//
//  Created by Dylan Maryk on 23/07/2014.
//  Copyright (c) 2014 Dylan Maryk. All rights reserved.
//

#import "SettingsViewController.h"
#import "DataModelAppOnly.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController {
    NSArray *appSettings;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appSettings = [DataModelAppOnly getSettings];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return appSettings.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SettingTableViewCell";
    
    SettingTableViewCell *cell = (SettingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SettingTableViewCell" owner:self options:nil];
        
        cell = settingTableViewCell;
    }
    
    CGRect cellFrame = cell.frame;
    cellFrame.size.width = tableView.frame.size.width;
    
    [cell setFrame:cellFrame];
    
    if (indexPath.row == 0) {
        [cell.separatorViewTop setHidden:NO];
    } else {
        [cell.separatorViewTop setHidden:YES];
    }
    
    cell.settingIdentifier = [appSettings[indexPath.row] valueForKey:@"identifier"];
    [cell.settingNameLabel setText:[appSettings[indexPath.row] valueForKey:@"name"]];
    [cell.settingSettingSwitch setOn:[[appSettings[indexPath.row] valueForKey:@"setting"] boolValue]];
    
    return cell;
}

- (IBAction)settingSwitchTapped:(id)sender {
    NSString *settingIdentifier = ((SettingTableViewCell *)((UISwitch *)sender).superview.superview).settingIdentifier;
    
    bool settingOn = ((UISwitch *)sender).isOn;
    
    [DataModelAppOnly setCachedSetting:settingOn forIdentifier:settingIdentifier];
    [DataModelAppOnly updateRemoteSettings];
}

@end
