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
#import "Reachability.h"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController {
    Reachability *reachability;
    
    bool tableViewScrollingDown;
    
    NSMutableArray *cachedData;
    
    NSTimer *scrollTableViewTimer;
}

@synthesize todayLineTableView, lastUpdatedLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged) name:kReachabilityChangedNotification object:nil];
    
    UITapGestureRecognizer *tableViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTableViewTap)];
    
    [todayLineTableView addGestureRecognizer:tableViewTapGestureRecognizer];
    
    tableViewScrollingDown = YES;
    
    [DataModel registerForSettingsSync];
    
    [self loadDataRefreshed:NO];
}

- (void)reachabilityChanged {
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    if (networkStatus ==  ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
        [self loadDataRefreshed:YES];
    }
}

- (void)handleTableViewTap {
    if (scrollTableViewTimer.isValid) {
        [todayLineTableView setContentOffset:CGPointMake(todayLineTableView.contentOffset.x, todayLineTableView.contentOffset.y) animated:NO];
        
        [scrollTableViewTimer invalidate];
    } else if (tableViewScrollingDown) {
        [self scrollTableViewDown];
    } else {
        [self scrollTableViewUp];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return cachedData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 31 + CGRectIntegral([self lineStatusLabelFrameForRow:indexPath.row]).size.height;
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
    
    CGRect lineStatusLabelFrame = cell.lineStatusLabel.frame;
    
    CGFloat lineStatusLabelFrameX = lineStatusLabelFrame.origin.x;
    CGFloat lineStatusLabelFrameY = lineStatusLabelFrame.origin.y;
    
    lineStatusLabelFrame = [self lineStatusLabelFrameForRow:indexPath.row];
    lineStatusLabelFrame.origin.x = lineStatusLabelFrameX;
    lineStatusLabelFrame.origin.y = lineStatusLabelFrameY;
    
    [cell.lineStatusLabel setFrame:lineStatusLabelFrame];
    
    return cell;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [self loadDataRefreshed:YES];
    
    completionHandler(NCUpdateResultNewData);
}

- (void)loadDataRefreshed:(bool)refreshedData {
    cachedData = [DataModel getDataForSelectedLinesOnly:YES refreshedData:refreshedData];
    
    if (cachedData.count) {
        CGFloat tableHeight = 0;
        
        CGRect tableFrame = todayLineTableView.frame;
        
        NSMutableArray *totalWidgetHeights = [NSMutableArray array];
        
        for (int i = 0; i < [todayLineTableView numberOfRowsInSection:0]; i++) {
            CGFloat cellHeightFloat = [self tableView:todayLineTableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            
            tableHeight += cellHeightFloat;
            
            [totalWidgetHeights addObject:[NSNumber numberWithFloat:tableFrame.origin.y + tableHeight]];
        }
        
        tableFrame.size.height = tableHeight;
        
        [todayLineTableView setFrame:tableFrame];
        [todayLineTableView reloadData];
        
        [lastUpdatedLabel setText:[NSString stringWithFormat:@"Last updated: %@", [[DataModel getUserDefaults] valueForKey:@"lastUpdated"]]];
        
        int preferredWidgetHeight = tableFrame.origin.y + tableHeight;
        
        [self setPreferredContentSize:CGSizeMake(self.preferredContentSize.width, preferredWidgetHeight)];
        
        if (preferredWidgetHeight > self.view.frame.size.height) {
            NSArray *totalWidgetHeightsReversed = [[totalWidgetHeights reverseObjectEnumerator] allObjects];
            
            for (NSNumber *cellHeightNumber in totalWidgetHeightsReversed) {
                if ([cellHeightNumber floatValue] < self.view.frame.size.height) {
                    [self setPreferredContentSize:CGSizeMake(self.preferredContentSize.width, [cellHeightNumber floatValue])];
                    
                    break;
                }
            }
            
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(scrollTableViewDown) userInfo:nil repeats:NO];
        }
    } else if (refreshedData) {
        [self loadDataRefreshed:NO];
    } else {
        CGRect labelFrame = lastUpdatedLabel.frame;
        labelFrame.size.height = 42;
        
        [lastUpdatedLabel setFrame:labelFrame];
        [lastUpdatedLabel setText:@"Please select lines in the TubeStatus app to see their status."];
        
        [self setPreferredContentSize:CGSizeMake(self.preferredContentSize.width, 54)];
    }
}

- (void)scrollTableViewDown {
    [todayLineTableView setContentOffset:CGPointMake(todayLineTableView.contentOffset.x, todayLineTableView.contentOffset.y + 50) animated:YES];
    
    if (todayLineTableView.contentOffset.y <= todayLineTableView.contentSize.height - todayLineTableView.frame.size.height) {
        scrollTableViewTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(scrollTableViewDown) userInfo:nil repeats:NO];
    } else {
        [todayLineTableView setContentOffset:CGPointMake(todayLineTableView.contentOffset.x, todayLineTableView.contentSize.height - todayLineTableView.frame.size.height) animated:YES];
        
        tableViewScrollingDown = NO;
        
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(scrollTableViewUp) userInfo:nil repeats:NO];
    }
}

- (void)scrollTableViewUp {
    [todayLineTableView setContentOffset:CGPointMake(todayLineTableView.contentOffset.x, todayLineTableView.contentOffset.y - 50) animated:YES];
    
    if (todayLineTableView.contentOffset.y >= 0) {
        scrollTableViewTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(scrollTableViewUp) userInfo:nil repeats:NO];
    } else {
        [todayLineTableView setContentOffset:CGPointMake(todayLineTableView.contentOffset.x, 0) animated:YES];
        
        tableViewScrollingDown = YES;
        
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(scrollTableViewDown) userInfo:nil repeats:NO];
    }
}

- (CGRect)lineStatusLabelFrameForRow:(NSInteger)row {
    return [[[NSAttributedString alloc] initWithString:[self lineStatusLabelTextForRow:row] attributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:17] }] boundingRectWithSize:CGSizeMake(todayLineTableView.frame.size.width - 24, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil]; // Dynamic table width causes "bouncing" of widget height. iPad hard-coded: "545".
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

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsZero;
}

@end
