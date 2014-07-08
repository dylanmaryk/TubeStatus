//
//  LineTableViewCell.h
//  TubeStatus
//
//  Created by Dylan Maryk on 28/06/2014.
//  Copyright (c) 2014 Code Canopy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIView *lineColour;
@property (nonatomic, retain) IBOutlet UILabel *lineName;
@property (nonatomic, retain) IBOutlet UISwitch *lineSetting;

@end
