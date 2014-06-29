//
//  XMLParserDelegate.m
//  TubeStatus
//
//  Created by Dylan Maryk on 28/06/2014.
//  Copyright (c) 2014 Code Canopy. All rights reserved.
//

#import "XMLParserDelegate.h"

@implementation XMLParserDelegate {
    NSXMLParser *xmlParser;
    
    NSDictionary *lineColours;
    
    NSMutableArray *cachedSettings;
    NSMutableArray *newCachedData;
    
    NSMutableDictionary *lineDict;
}

- (id)init {
    self = [super init];
    
    if (self) {
        lineColours = [[NSDictionary alloc] initWithObjectsAndKeys:@"#AE6118", @"Bakerloo", @"#E41F1F", @"Central", @"#F8D42D", @"Circle", @"#007229", @"District", @"#00BBB4", @"DLR", @"#E899A8", @"Hammersmith and City", @"#686E72", @"Jubilee", @"#893267", @"Metropolitan", @"#000000", @"Northern", @"#F86C00", @"Overground", @"#0450A1", @"Piccadilly", @"#009FE0", @"Victoria", @"#70C3CE", @"Waterloo and City", nil];
    }
    
    return self;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    cachedSettings = [NSMutableArray array];
    newCachedData = [NSMutableArray array];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"cachedData"]) {
        for (NSDictionary *line in [[NSUserDefaults standardUserDefaults] objectForKey:@"cachedData"]) {
            [cachedSettings addObject:[line objectForKey:@"setting"]];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"LineStatus"]) {
        lineDict = [NSMutableDictionary dictionary];
        [lineDict setValue:[attributeDict valueForKey:@"StatusDetails"] forKey:@"statusDetails"];
    } else if ([elementName isEqualToString:@"Line"]) {
        [lineDict setValue:[attributeDict valueForKey:@"Name"] forKey:@"name"];
        [lineDict setValue:[lineColours valueForKey:[attributeDict valueForKey:@"Name"]] forKey:@"colour"];
    } else if ([elementName isEqualToString:@"Status"] && [lineDict objectForKey:@"name"]) {
        [lineDict setValue:[attributeDict valueForKey:@"Description"] forKey:@"description"];
        
        [newCachedData addObject:lineDict];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    if ([cachedSettings count]) {
        int i = 0;
        
        for (NSNumber *setting in cachedSettings) {
            [newCachedData[i] setValue:setting forKey:@"setting"];
            
            i++;
        }
    } else {
        for (NSDictionary *line in newCachedData) {
            [line setValue:[NSNumber numberWithBool:NO] forKey:@"setting"];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:newCachedData forKey:@"cachedData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
