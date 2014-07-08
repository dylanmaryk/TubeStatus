//
//  TodayViewController.m
//  TubeStatusWidget
//
//  Created by Dylan Maryk on 28/06/2014.
//  Copyright (c) 2014 Code Canopy. All rights reserved.
//

#import <NotificationCenter/NotificationCenter.h>

#import "TodayViewController.h"
#import "DataModel.h"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController {
    NSMutableArray *cachedData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DataModel *dataModel = [[DataModel alloc] init];
    
    cachedData = [dataModel getRefreshedData];
    
    [self setPreferredContentSize:CGSizeMake(self.preferredContentSize.width, [cachedData count] * 44)];
    
    // Above code should also be called when widget performs update.
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
    completionHandler(NCUpdateResultNewData);
    
    // Handle update success/failure.
}

@end
