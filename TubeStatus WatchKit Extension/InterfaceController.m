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
        
        [lastUpdatedLabel setText:[NSString stringWithFormat:@"Last updated %@", [[DataModel getUserDefaults] valueForKey:@"lastUpdated"]]];
    } else if (refreshedData) {
        [self loadDataRefreshed:NO];
    } else {
        [lastUpdatedLabel setText:@"Please select lines in the TubeStatus app on your iPhone to see their status."];
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

@end
