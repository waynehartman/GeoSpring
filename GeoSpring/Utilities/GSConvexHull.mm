//
//  GSConvexHull.m
//  GeoSpring
//
//  Created by Wayne Hartman on 6/18/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import "GSConvexHull.h"
#import "ConvexHull2.cpp"

@implementation GSConvexHull

- (NSArray *)convexHullOfLocationPointsForPoints:(NSArray *)points {
    vector<CXPoint> inPoints;

    for (int i = 0; i < points.count; i++) {
        NSValue *value = points[i];
        CGPoint point = value.CGPointValue;
        CXPoint chPoint = { point.x, point.y };
        inPoints.push_back(chPoint);
    }
    
    inPoints.end();

    vector<CXPoint> answer = convex_hull(inPoints);
    NSMutableArray *answerPoints = [NSMutableArray array];

    for (unsigned i = 0; i< answer.size(); i++) {
        CXPoint chPoint = answer.at(i);
        CGPoint point = CGPointMake(chPoint.x, chPoint.y);
        [answerPoints addObject:[NSValue valueWithCGPoint:point]];
    }

    return answerPoints;
}

@end
