//
//  LineTableViewCell.h
//  TubeStatus
//
//  Created by Dylan Maryk on 28/06/2014.
//  Copyright (c) 2014 Dylan Maryk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIView *separatorViewTop;
@property (nonatomic, retain) IBOutlet UIView *lineColourView;

@property (nonatomic, retain) IBOutlet UILabel *lineNameLabel;

@property (nonatomic, retain) IBOutlet UISwitch *lineSettingSwitch;

@end
