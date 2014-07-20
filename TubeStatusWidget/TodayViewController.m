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
    
    NSMutableArray *cachedData;
}

@synthesize todayLineTableView, lastUpdatedLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataModel = [[DataModel alloc] init];
    
    widgetNotUpdated = YES;
    
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
    CGRect statusLabelRect = [[[NSAttributedString alloc] initWithString:[self lineStatusLabelTextForRow:indexPath.row] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}] boundingRectWithSize:CGSizeMake(todayLineTableView.frame.size.width - 48, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    return 28 + statusLabelRect.size.height + 2;
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
    [cell.lineStatusLabel setText:[self lineStatusLabelTextForRow:indexPath.row]];
    [cell.lineStatusLabel sizeToFit];
    
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
        CGRect tableFrame = todayLineTableView.frame;
        
//        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dylanmaryk.TubeStatus"];
        
        CGFloat tableHeight = 0;
//        CGFloat tableHeightOld = [[userDefaults valueForKey:@"widgetTableHeight"] floatValue];
        
        for (int i = 0; i < [todayLineTableView numberOfRowsInSection:0]; i++) {
            tableHeight += [self tableView:todayLineTableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        tableFrame.size.height = tableHeight;
        
        [todayLineTableView setFrame:tableFrame];
        [todayLineTableView reloadData];
        
//        [lastUpdatedLabel setText:[NSString stringWithFormat:@"Last updated: %@", [userDefaults valueForKey:@"lastUpdated"]]];
        [lastUpdatedLabel setText:[NSString stringWithFormat:@"Last updated: %@", [[[NSUserDefaults alloc] initWithSuiteName:@"group.com.dylanmaryk.TubeStatus"] valueForKey:@"lastUpdated"]]];
        
//        if ((int)tableHeight != (int)tableHeightOld && refreshedData) {
            int preferredWidgetHeight = tableFrame.origin.y + tableHeight;
            
            [self setPreferredContentSize:CGSizeMake(self.preferredContentSize.width, preferredWidgetHeight)];
            
//            [userDefaults setValue:[NSNumber numberWithFloat:tableHeight] forKey:@"widgetTableHeight"];
//            [userDefaults synchronize];
//        }
    } else if (refreshedData) {
        [self loadDataRefreshed:NO];
    } else {
        // Handle zero lines, whether due to none selected or no cached data (set preferred content size accordingly).
    }
}

- (NSString *)lineStatusLabelTextForRow:(NSInteger)row {
    NSString *lineDescription = [cachedData[row] valueForKey:@"description"];
    NSString *lineStatusDetails = [cachedData[row] valueForKey:@"statusDetails"];
    
    if (![lineStatusDetails isEqualToString:@""]) {
        return [NSString stringWithFormat:@"%@: %@", lineDescription, lineStatusDetails];
    } else {
        return [NSString stringWithFormat:@"%@", lineDescription];
    }
}

@end
