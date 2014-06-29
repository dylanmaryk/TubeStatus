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

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    DataModel *dataModel = [[DataModel alloc] init];
    
    cachedData = [dataModel getRefreshedData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cachedData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return todayLineTableViewCell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TodayLineTableViewCell";
    
    TodayLineTableViewCell *cell = (TodayLineTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"TodayLineTableViewCell" owner:self options:nil];
        
        cell = todayLineTableViewCell;
    }
    
    return cell;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    completionHandler(NCUpdateResultNewData);
}

@end
