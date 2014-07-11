//
//  DataModel.h
//  TubeStatus
//
//  Created by Dylan Maryk on 29/06/2014.
//  Copyright (c) 2014 Code Canopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

- (NSMutableArray *)getRefreshedDataWithSelectedLinesOnly:(bool)selectedLinesOnly;

@end
