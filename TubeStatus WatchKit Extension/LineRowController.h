//
//  LineRowController.h
//  TubeStatus
//
//  Created by Dylan Maryk on 09/02/2015.
//  Copyright (c) 2015 Dylan Maryk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface LineRowController : NSObject

@property (nonatomic, retain) IBOutlet WKInterfaceGroup *lineColourGroup;

@property (nonatomic, retain) IBOutlet WKInterfaceLabel *lineNameLabel;
@property (nonatomic, retain) IBOutlet WKInterfaceLabel *lineStatusLabel;

@end
