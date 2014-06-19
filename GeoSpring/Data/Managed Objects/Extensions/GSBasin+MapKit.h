//
//  GSBasin+MapKit.h
//  GeoSpring
//
//  Created by Wayne Hartman on 6/18/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import "GSBasin.h"
#import <MapKit/MapKit.h>

@interface GSBasin (MapKit) <MKAnnotation>

- (MKPolygon *)convexHullOfSpringLocations;
- (CLLocationCoordinate2D)calculateCenterCoordinateFromHull;

@end
