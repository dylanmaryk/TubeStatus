//
//  GlanceInterfaceController.m
//  TubeStatus
//
//  Created by Dylan Maryk on 05/04/2015.
//  Copyright (c) 2015 Code Canopy. All rights reserved.
//

#import "GlanceInterfaceController.h"
#import "DataModel.h"
#import "Reachability.h"

@interface GlanceInterfaceController()

@end

@implementation GlanceInterfaceController {
    Reachability *reachability;
    
    NSMutableArray *cachedData;
}

@synthesize statusLabel;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged) name:kReachabilityChangedNotification object:nil];
    
    [DataModel registerForSettingsSync];
    
    [self loadDataRefreshed:NO];
}

- (void)willActivate {
    [super willActivate];
    
    [self loadDataRefreshed:YES];
}

- (void)reachabilityChanged {
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    if (networkStatus ==  ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
        [self loadDataRefreshed:YES];
    }
}

- (void)loadDataRefreshed:(bool)refreshedData {
    cachedData = [DataModel getDataForDisruptedLinesRefreshed:refreshedData];
    
    if ([cachedData count]) {
        
    } else if (refreshedData) {
        [self loadDataRefreshed:NO];
    } else {
        [statusLabel setText:@"Currently no disruptions on your selected lines."];
    }
}

@end
