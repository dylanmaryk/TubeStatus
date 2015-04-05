//
//  GlanceInterfaceController.h
//  TubeStatus
//
//  Created by Dylan Maryk on 05/04/2015.
//  Copyright (c) 2015 Code Canopy. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface GlanceInterfaceController : WKInterfaceController

@property (nonatomic, retain) IBOutlet WKInterfaceLabel *statusLabel;

@end
