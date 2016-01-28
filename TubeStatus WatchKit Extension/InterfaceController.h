//
//  InterfaceController.h
//  TubeStatus WatchKit Extension
//
//  Created by Dylan Maryk on 09/02/2015.
//  Copyright (c) 2015 Dylan Maryk. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@import WatchConnectivity;

@interface InterfaceController : WKInterfaceController <WCSessionDelegate>

@property (nonatomic, retain) IBOutlet WKInterfaceLabel *lastUpdatedLabel;

@property (nonatomic, retain) IBOutlet WKInterfaceTable *tableView;

@end
