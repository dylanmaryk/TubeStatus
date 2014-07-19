//
//  TodayViewController.m
//  TubeStatusWidget
//
//  Created by Dylan Maryk on 28/06/2014.
//  Copyright (c) 2014 Dylan Maryk. All rights reserved.
//

#import <NotificationCenter/NotificationCenter.h>

#import "TodayViewController.h"
#import "DataModel.h"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController {
    DataModel *dataModel;
    
    NSMutableArray *cachedData;
    
    bool widgetNotUpdated;
}

@synthesize todayLineTableView, lastUpdatedLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataModel = [[DataModel alloc] init];
    
    [self loadDataRefreshed:NO];
    
    widgetNotUpdated = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (widgetNotUpdated) {
        [self loadDataRefreshed:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cachedData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TodayLineTableViewCell";
    
    TodayLineTableViewCell *cell = (TodayLineTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"TodayLineTableViewCell" owner:self options:nil];
        
        cell = todayLineTableViewCell;
    }
    
    CGRect cellFrame = cell.frame;
    cellFrame.size.width = tableView.frame.size.width;
    
    NSData *lineColourData = [cachedData[indexPath.row] valueForKey:@"colour"];
    
    UIColor *lineColourColor = [NSKeyedUnarchiver unarchiveObjectWithData:lineColourData];
    
    [cell setFrame:cellFrame];
    [cell.lineColour setBackgroundColor:lineColourColor];
    
    return cell;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [self loadDataRefreshed:YES];
    
    // Handle completionHandler correctly.
    
    completionHandler(NCUpdateResultNewData);
    
    widgetNotUpdated = NO;
}

- (void)loadDataRefreshed:(bool)refreshedData {
    cachedData = [dataModel getDataWithSelectedLinesOnly:YES refreshedData:refreshedData];
    
    if (cachedData) {
        [lastUpdatedLabel setText:[NSString stringWithFormat:@"Last updated: %@", [[[NSUserDefaults alloc] initWithSuiteName:@"group.com.dylanmaryk.TubeStatus"] valueForKey:@"lastUpdated"]]];
        
        CGRect tableFrame = todayLineTableView.frame;
        
        unsigned long preferredTableHeight = [cachedData count] * 44;
        
        tableFrame.size.height = preferredTableHeight;
        
        [todayLineTableView setFrame:tableFrame];
        [todayLineTableView reloadData];
        
        [self setPreferredContentSize:CGSizeMake(self.preferredContentSize.width, tableFrame.origin.y + preferredTableHeight)];
    } else if (refreshedData) {
        [self loadDataRefreshed:NO];
    } else {
        // Handle zero lines, whether due to none selected or no cached data (set preferred content size accordingly).
    }
}

@end
