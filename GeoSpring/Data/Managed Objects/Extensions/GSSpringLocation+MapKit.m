//
//  GSSpringLocation+MapKit.m
//  GeoSpring
//
//  Created by Wayne Hartman on 6/17/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import "GSSpringLocation+MapKit.h"
#import "GSBasin.h"

@implementation GSSpringLocation (MapKit)

- (CLLocationCoordinate2D) coordinate {
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (NSString *)title {
    return self.name;
}

- (NSString *)subtitle {
    return self.basin.name;
}

@end
