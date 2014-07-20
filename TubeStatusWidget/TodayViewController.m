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
    
    bool widgetNotUpdated;
    
//    int tableHeight;
    
    NSMutableArray *cachedData;
}

@synthesize todayLineTableView, lastUpdatedLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataModel = [[DataModel alloc] init];
    
    widgetNotUpdated = YES;
    
//    tableHeight = 0;
    
    [self loadDataRefreshed:NO];
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
    UILabel *lineStatusLabelTemp = [[UILabel alloc] initWithFrame:CGRectMake(28, 21, tableView.frame.size.width - 48, 21)];
    [lineStatusLabelTemp setNumberOfLines:0];
    [lineStatusLabelTemp setLineBreakMode:NSLineBreakByWordWrapping];
    
    [self setStatusLabel:lineStatusLabelTemp forRow:indexPath.row];
    
    return lineStatusLabelTemp.frame.origin.y + lineStatusLabelTemp.frame.size.height + 2;
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
    
    [cell setFrame:cellFrame];
    
    NSData *lineColourData = [cachedData[indexPath.row] valueForKey:@"colour"];
    
    UIColor *lineColourColor = [NSKeyedUnarchiver unarchiveObjectWithData:lineColourData];
    
    [cell.lineColourView setBackgroundColor:lineColourColor];
    [cell.lineNameLabel setText:[cachedData[indexPath.row] valueForKey:@"name"]];
    
    [self setStatusLabel:cell.lineStatusLabel forRow:indexPath.row];
    
    return cell;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [self loadDataRefreshed:YES];
    
    widgetNotUpdated = NO;
    
    // Handle completionHandler correctly.
    
    completionHandler(NCUpdateResultNewData);
}

- (void)loadDataRefreshed:(bool)refreshedData {
    cachedData = [dataModel getDataWithSelectedLinesOnly:YES refreshedData:refreshedData];
    
    if (cachedData) {
        CGFloat tableHeight = 0;
        
        for (int i = 0; i < [todayLineTableView numberOfRowsInSection:0]; i++) {
            tableHeight += [self tableView:todayLineTableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        CGRect tableFrame = todayLineTableView.frame;
        tableFrame.size.height = tableHeight;
        
        [todayLineTableView setFrame:tableFrame];
        [todayLineTableView reloadData];
        
        [lastUpdatedLabel setText:[NSString stringWithFormat:@"Last updated: %@", [[[NSUserDefaults alloc] initWithSuiteName:@"group.com.dylanmaryk.TubeStatus"] valueForKey:@"lastUpdated"]]];
        
        int preferredWidgetHeight = tableFrame.origin.y + tableHeight;
        
        [self setPreferredContentSize:CGSizeMake(self.preferredContentSize.width, preferredWidgetHeight)];
    } else if (refreshedData) {
        [self loadDataRefreshed:NO];
    } else {
        // Handle zero lines, whether due to none selected or no cached data (set preferred content size accordingly).
    }
}

- (void)setStatusLabel:(UILabel *)statusLabel forRow:(NSInteger)row {
    NSString *lineDescription = [cachedData[row] valueForKey:@"description"];
    NSString *lineStatusDetails = [cachedData[row] valueForKey:@"statusDetails"];
    
    if (![lineStatusDetails isEqualToString:@""]) {
        [statusLabel setText:[NSString stringWithFormat:@"%@: %@", lineDescription, lineStatusDetails]];
    } else {
        [statusLabel setText:[NSString stringWithFormat:@"%@", lineDescription]];
    }
    
    [statusLabel sizeToFit];
}

@end
