//
//  TodayViewController.h
//  TubeStatusWidget
//
//  Created by Dylan Maryk on 28/06/2014.
//  Copyright (c) 2014 Code Canopy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TodayLineTableViewCell.h"

@interface TodayViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet TodayLineTableViewCell *todayLineTableViewCell;
}

@property (nonatomic, retain) IBOutlet UITableView *todayLineTableView;
@property (nonatomic, retain) IBOutlet UILabel *lastUpdatedLabel;

@end
