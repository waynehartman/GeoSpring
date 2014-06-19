//
//  GSConvexHull.h
//  GeoSpring
//
//  Created by Wayne Hartman on 6/18/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSConvexHull : NSObject

- (NSArray *)convexHullOfLocationPointsForPoints:(NSArray *)points;

@end
