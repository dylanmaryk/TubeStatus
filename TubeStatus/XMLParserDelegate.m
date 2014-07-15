//
//  XMLParserDelegate.m
//  TubeStatus
//
//  Created by Dylan Maryk on 28/06/2014.
//  Copyright (c) 2014 Dylan Maryk. All rights reserved.
//

#import "XMLParserDelegate.h"

@implementation XMLParserDelegate {
    NSMutableDictionary *lineColours;
    NSMutableDictionary *lineDict;
    
    NSMutableArray *cachedSettings;
    NSMutableArray *newCachedData;
}

- (id)init {
    self = [super init];
    
    if (self) {
        lineColours = [[NSMutableDictionary alloc] init];
        
        NSDictionary *lineRGBs = [[NSDictionary alloc] initWithObjectsAndKeys:@"#AE6118", @"Bakerloo", @"#E41F1F", @"Central", @"#F8D42D", @"Circle", @"#007229", @"District", @"#00BBB4", @"DLR", @"#E899A8", @"Hammersmith and City", @"#686E72", @"Jubilee", @"#893267", @"Metropolitan", @"#000000", @"Northern", @"#F86C00", @"Overground", @"#0450A1", @"Piccadilly", @"#009FE0", @"Victoria", @"#70C3CE", @"Waterloo and City", nil];
        
        for (id line in lineRGBs) {
            NSString *colourForLineString = [lineRGBs valueForKey:line];
            
            unsigned int red, green, blue;
            
            sscanf([colourForLineString UTF8String], "#%02X%02X%02X", &red, &green, &blue);
            
            UIColor *colourForLineColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
            
            NSData *colourForLineData = [NSKeyedArchiver archivedDataWithRootObject:colourForLineColor];
            
            [lineColours setValue:colourForLineData forKey:line];
        }
    }
    
    return self;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    cachedSettings = [NSMutableArray array];
    newCachedData = [NSMutableArray array];
    
    NSArray *cachedData = [[[NSUserDefaults alloc] initWithSuiteName:@"group.com.dylanmaryk.TubeStatus"] objectForKey:@"cachedData"];
    
    if (cachedData) {
        for (NSDictionary *line in cachedData) {
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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dylanmaryk.TubeStatus"];
    [userDefaults setObject:newCachedData forKey:@"cachedData"];
    [userDefaults setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"lastUpdated"];
    [userDefaults synchronize];
}

@end
