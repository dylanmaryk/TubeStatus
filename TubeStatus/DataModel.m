//
//  DataModel.m
//  TubeStatus
//
//  Created by Dylan Maryk on 29/06/2014.
//  Copyright (c) 2014 Code Canopy. All rights reserved.
//

#import "DataModel.h"
#import "XMLParserDelegate.h"

@implementation DataModel {
    XMLParserDelegate *xmlParserDelegate;
}

- (id)init {
    self = [super init];
    
    if (self) {
        xmlParserDelegate = [[XMLParserDelegate alloc] init];
    }
    
    return self;
}

- (NSMutableArray *)getRefreshedDataWithSelectedLinesOnly:(bool)selectedLinesOnly {
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://cloud.tfl.gov.uk/TrackerNet/LineStatus"]];
    [xmlParser setDelegate:xmlParserDelegate];
    
    if ([xmlParser parse] || [[NSUserDefaults standardUserDefaults] objectForKey:@"cachedData"]) {
        NSMutableArray *cachedData = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cachedData"] mutableCopy];
        
        // Test "selectedLinesOnly" after implementing shared data
        
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
        // No cached data, show error message.
        
        return nil;
    }
}

@end
