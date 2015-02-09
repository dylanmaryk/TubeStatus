//
//  SettingTableViewCell.h
//  TubeStatus
//
//  Created by Dylan Maryk on 25/08/2014.
//  Copyright (c) 2014 Dylan Maryk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *settingIdentifier;

@property (nonatomic, retain) IBOutlet UIView *separatorViewTop;

@property (nonatomic, retain) IBOutlet UILabel *settingNameLabel;

@property (nonatomic, retain) IBOutlet UISwitch *settingSettingSwitch;

@end
