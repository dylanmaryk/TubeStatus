//
//  InterfaceController.m
//  TubeStatus WatchKit Extension
//
//  Created by Dylan Maryk on 09/02/2015.
//  Copyright (c) 2015 Dylan Maryk. All rights reserved.
//

#import "InterfaceController.h"
#import "LineRowController.h"
#import "DataModel.h"

@interface InterfaceController()

@end

@implementation InterfaceController {
    NSMutableArray *cachedData;
}

@synthesize lastUpdatedLabel, tableView;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [DataModel registerForSettingsSync];
    
    [self loadDataRefreshed:NO];
}

- (void)willActivate {
    [super willActivate];
    
    [self loadDataRefreshed:YES];
}

- (void)loadDataRefreshed:(bool)refreshedData {
    cachedData = [DataModel getDataForSelectedLinesOnly:YES refreshedData:refreshedData];
    
    if ([cachedData count]) {
        [tableView setNumberOfRows:[cachedData count] withRowType:@"default"];
        
        for (int i = 0; i < tableView.numberOfRows; i++) {
            NSData *lineColourData = [cachedData[i] valueForKey:@"colour"];
            
            UIColor *lineColourColor = [NSKeyedUnarchiver unarchiveObjectWithData:lineColourData];
            
            LineRowController *lineRow = [tableView rowControllerAtIndex:i];
            [lineRow.lineColourGroup setBackgroundColor:lineColourColor];
            [lineRow.lineNameLabel setText:[cachedData[i] valueForKey:@"name"]];
            [lineRow.lineStatusLabel setText:[self lineStatusLabelTextForRow:i]];
        }
        
        NSString *lastUpdated = [[DataModel getUserDefaults] valueForKey:@"lastUpdated"];
        
        if (lastUpdated) {
            [lastUpdatedLabel setText:[NSString stringWithFormat:@"Last updated %@", lastUpdated]];
        } else {
            [lastUpdatedLabel setText:@""];
        }
    } else if (refreshedData) {
        [self loadDataRefreshed:NO];
    } else {
        [tableView setNumberOfRows:0 withRowType:@"default"];
        
        [lastUpdatedLabel setText:@"Please select lines in the TubeStatus app on your iPhone to see their status."];
    }
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    [self loadDataRefreshed:YES];
}

- (NSString *)lineStatusLabelTextForRow:(int)row {
    NSString *lineDescription = [cachedData[row] valueForKey:@"description"];
    NSString *lineStatusDetails = [cachedData[row] valueForKey:@"statusDetails"];
    
    if (![lineStatusDetails isEqualToString:@""]) {
        return [NSString stringWithFormat:@"%@: %@", lineDescription, lineStatusDetails];
    } else {
        return lineDescription;
    }
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(nonnull NSDictionary<NSString *,id> *)applicationContext {
    [DataModel setUserDefaultsObject:[applicationContext valueForKey:@"cachedData"] forKey:@"cachedData" andSync:YES];
    
    [self loadDataRefreshed:YES];
}

@end
