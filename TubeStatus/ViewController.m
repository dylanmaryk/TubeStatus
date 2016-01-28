//
//  ViewController.m
//  TubeStatus
//
//  Created by Dylan Maryk on 28/06/2014.
//  Copyright (c) 2014 Dylan Maryk. All rights reserved.
//

#import "ViewController.h"
#import "DataModel.h"
#import "Reachability.h"

@interface ViewController ()

@end

@implementation ViewController {
    Reachability *reachability;
    
    NSMutableArray *cachedData;
}

@synthesize lineTableView;
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self loadDataRefreshed:NO tryLoadingRefreshedDataIfFails:YES];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self loadDataRefreshed:NO tryLoadingRefreshedDataIfFails:YES];
}

- (void)reachabilityChanged:(NSNotification *)notification {
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    if (networkStatus ==  ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
        [self loadDataRefreshed:NO tryLoadingRefreshedDataIfFails:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return cachedData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"LineTableViewCell";
    
    LineTableViewCell *cell = (LineTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"LineTableViewCell" owner:self options:nil];
        
        cell = lineTableViewCell;
    }
    
    CGRect cellFrame = cell.frame;
    cellFrame.size.width = tableView.frame.size.width;
    
    [cell setFrame:cellFrame];
    
    if (indexPath.row == 0) {
        [cell.separatorViewTop setHidden:NO];
    } else {
        [cell.separatorViewTop setHidden:YES];
    }
    
    NSData *lineColourData = [cachedData[indexPath.row] valueForKey:@"colour"];
    
    UIColor *lineColourColor = [NSKeyedUnarchiver unarchiveObjectWithData:lineColourData];
    
    [cell.lineColourView setBackgroundColor:lineColourColor];
    [cell.lineNameLabel setText:[cachedData[indexPath.row] valueForKey:@"name"]];
    [cell.lineSettingSwitch setOn:[[cachedData[indexPath.row] valueForKey:@"setting"] boolValue]];
    [cell.lineSettingSwitch setTag:indexPath.row];
    
    return cell;
}

- (IBAction)settingSwitchTapped:(id)sender {
    cachedData = [DataModel getDataForSelectedLinesOnly:NO refreshedData:NO];
    
    NSInteger settingTag = ((UISwitch *)sender).tag;
    
    bool settingOn = ((UISwitch *)sender).isOn;
    
    [cachedData[settingTag] setValue:[NSNumber numberWithBool:settingOn] forKey:@"setting"];
    
    [DataModel setUserDefaultsObject:cachedData forKey:@"cachedData" andSync:YES];
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        [session updateApplicationContext:[NSDictionary dictionaryWithObjectsAndKeys:cachedData, @"cachedData", nil] error:nil];
    }
    
    // Refresh data using code below? May impact performance, but otherwise cached data not updated until viewDidLoad called again or widget displayed. Not refreshing data here results in cached data being "reset" to when viewDidLoad was called.
    
    // [self loadDataRefreshed:YES tryLoadingRefreshedDataIfFails:NO];
}

- (void)loadDataRefreshed:(bool)refreshedData tryLoadingRefreshedDataIfFails:(bool)tryLoadingRefreshedDataIfFails {
    cachedData = [DataModel getDataForSelectedLinesOnly:NO refreshedData:refreshedData];
    
    if (cachedData) {
        [lineTableView reloadData];
    } else if (refreshedData) {
        [self loadDataRefreshed:NO tryLoadingRefreshedDataIfFails:NO];
    } else if (tryLoadingRefreshedDataIfFails) {
        [self loadDataRefreshed:YES tryLoadingRefreshedDataIfFails:NO];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please connect to the Internet to use TubeStatus for the first time." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

@end
