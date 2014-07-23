//
//  DataModel.m
//  TubeStatus
//
//  Created by Dylan Maryk on 29/06/2014.
//  Copyright (c) 2014 Dylan Maryk. All rights reserved.
//

#import "DataModel.h"
#import "XMLParserDelegate.h"

@implementation DataModel

+ (NSMutableArray *)getDataForSelectedLinesOnly:(bool)selectedLinesOnly refreshedData:(bool)refreshedData {
    bool dataAvailable;
    
    if (refreshedData) {
        XMLParserDelegate *xmlParserDelegate = [[XMLParserDelegate alloc] init];
        
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://cloud.tfl.gov.uk/TrackerNet/LineStatus"]];
        [xmlParser setDelegate:xmlParserDelegate];
        
        dataAvailable = [xmlParser parse];
    } else {
        dataAvailable = [[[NSUserDefaults alloc] initWithSuiteName:@"group.com.dylanmaryk.TubeStatus"] objectForKey:@"cachedData"];
    }
    
    if (dataAvailable) {
        NSMutableArray *cachedData = [[[[NSUserDefaults alloc] initWithSuiteName:@"group.com.dylanmaryk.TubeStatus"] objectForKey:@"cachedData"] mutableCopy];
        
        if (selectedLinesOnly) {
            NSMutableArray *cachedDataSelectedLinesOnly = [NSMutableArray array];
            
            for (NSDictionary *lineDict in cachedData) {
                if ([[lineDict valueForKey:@"setting"] boolValue]) {
                    [cachedDataSelectedLinesOnly addObject:lineDict];
                }
            }
            
            cachedData = cachedDataSelectedLinesOnly;
        }
        
        for (int i = 0; i < cachedData.count; i++) {
            NSMutableDictionary *lineDict = [cachedData[i] mutableCopy];
            
            cachedData[i] = lineDict;
        }
        
        return cachedData;
    } else {
        return nil;
    }
}

@end
