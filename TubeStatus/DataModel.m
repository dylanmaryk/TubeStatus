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
    NSXMLParser *xmlParser;
}

- (id)init {
    self = [super init];
    
    if (self) {
        XMLParserDelegate *xmlParserDelegate = [[XMLParserDelegate alloc] init];
        
        xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://cloud.tfl.gov.uk/TrackerNet/LineStatus"]];
        [xmlParser setDelegate:xmlParserDelegate];
    }
    
    return self;
}

- (NSMutableArray *)getRefreshedData {
    if ([xmlParser parse] || [[NSUserDefaults standardUserDefaults] objectForKey:@"cachedData"]) {
        NSMutableArray *cachedData = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cachedData"] mutableCopy];
        
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
