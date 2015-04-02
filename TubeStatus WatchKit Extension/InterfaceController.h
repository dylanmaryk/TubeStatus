//
//  InterfaceController.h
//  TubeStatus WatchKit Extension
//
//  Created by Dylan Maryk on 09/02/2015.
//  Copyright (c) 2015 Dylan Maryk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface InterfaceController : WKInterfaceController

@property (nonatomic, retain) IBOutlet WKInterfaceLabel *lastUpdatedLabel;

@property (nonatomic, retain) IBOutlet WKInterfaceTable *tableView;

@end
