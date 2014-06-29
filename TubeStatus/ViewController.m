//
//  ViewController.m
//  TubeStatus
//
//  Created by Dylan Maryk on 28/06/2014.
//  Copyright (c) 2014 Code Canopy. All rights reserved.
//

#import "ViewController.h"
#import "XMLParserDelegate.h"

@interface ViewController ()

@end

@implementation ViewController {
    NSXMLParser *xmlParser;
    NSMutableArray *cachedData;
}

@synthesize lineTableView;
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    XMLParserDelegate *xmlParserDelegate = [[XMLParserDelegate alloc] init];
    
    xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://cloud.tfl.gov.uk/TrackerNet/LineStatus"]];
    [xmlParser setDelegate:xmlParserDelegate];
    
    if ([xmlParser parse] || [[NSUserDefaults standardUserDefaults] objectForKey:@"cachedData"]) {
        cachedData = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cachedData"] mutableCopy];
    } else {
        // No cached data, show error message
    }
    
    for (int i = 0; i < cachedData.count; i++) {
        NSMutableDictionary *lineDict = [cachedData[i] mutableCopy];
        
        cachedData[i] = lineDict;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cachedData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return lineTableViewCell.frame.size.height;
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
    
    NSString *colourForLineString = [cachedData[indexPath.row] valueForKey:@"colour"];
    
    unsigned int red, green, blue;
    
    sscanf([colourForLineString UTF8String], "#%02X%02X%02X", &red, &green, &blue);
    
    UIColor *colourForLine = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    
    [cell setFrame:cellFrame];
    [cell.lineColour setBackgroundColor:colourForLine];
    [cell.lineColourExtended setBackgroundColor:colourForLine];
    [cell.lineName setText:[cachedData[indexPath.row] valueForKey:@"name"]];
    [cell.lineSetting setOn:[[cachedData[indexPath.row] valueForKey:@"setting"] boolValue]];
    [cell.lineSetting setTag:indexPath.row];
    
    return cell;
}

- (IBAction)settingSwitchTapped:(id)sender {
    NSInteger settingTag = ((UISwitch *)sender).tag;
    
    bool settingOn = ((UISwitch *)sender).isOn;
    
    [cachedData[settingTag] setValue:[NSNumber numberWithBool:settingOn] forKey:@"setting"];
    
    [[NSUserDefaults standardUserDefaults] setObject:cachedData forKey:@"cachedData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
