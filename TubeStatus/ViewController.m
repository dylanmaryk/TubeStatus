//
//  ViewController.m
//  TubeStatus
//
//  Created by Dylan Maryk on 28/06/2014.
//  Copyright (c) 2014 Dylan Maryk. All rights reserved.
//

#import "ViewController.h"
#import "DataModel.h"

@interface ViewController ()

@end

@implementation ViewController {
    NSMutableArray *cachedData;
}

@synthesize lineTableView;
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadDataRefreshed:NO tryLoadingRefreshedDataIfFails:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cachedData count];
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
    
    if (indexPath.row > 0) {
        UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(cell.lineColourView.frame.size.width, 0, cellFrame.size.width - cell.lineColourView.frame.size.width, 1)];
        [separatorLineView setBackgroundColor:[UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1]];
        
        [cell.contentView addSubview:separatorLineView];
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
    
    [DataModel setSettingObject:cachedData forKey:@"cachedData"];
    
    // Refresh data using code below? May impact performance, but otherwise cached data not updated until viewDidLoad called again or widget displayed. Not refreshing data here results in cached data being "reset" to when viewDidLoad was called.
    
    // [self loadDataRefreshed:YES tryLoadingRefreshedDataIfFails:nil];
}

- (void)loadDataRefreshed:(bool)refreshedData tryLoadingRefreshedDataIfFails:(bool)tryLoadingRefreshedDataIfFails {
    cachedData = [DataModel getDataForSelectedLinesOnly:NO refreshedData:refreshedData];
    
    if (cachedData) {
        [lineTableView reloadData];
    } else if (refreshedData) {
        [self loadDataRefreshed:NO tryLoadingRefreshedDataIfFails:NO];
    } else if (tryLoadingRefreshedDataIfFails) {
        [self loadDataRefreshed:YES tryLoadingRefreshedDataIfFails:nil];
    } else {
        // Handle no cached data.
    }
}

@end
