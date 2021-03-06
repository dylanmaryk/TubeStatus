//
//  ViewController.h
//  TubeStatus
//
//  Created by Dylan Maryk on 28/06/2014.
//  Copyright (c) 2014 Dylan Maryk. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LineTableViewCell.h"

@import WatchConnectivity;

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, WCSessionDelegate> {
    IBOutlet LineTableViewCell *lineTableViewCell;
}

@property (nonatomic, retain) IBOutlet UITableView *lineTableView;

- (IBAction)settingSwitchTapped:(id)sender;

@end
