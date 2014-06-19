//
//  GSBasin+MapKit.m
//  GeoSpring
//
//  Created by Wayne Hartman on 6/18/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import "GSBasin+MapKit.h"
#import "GSSpringLocation+MapKit.h"
#import "GSConvexHull.h"

@implementation GSBasin (MapKit)

- (MKPolygon *)convexHullOfSpringLocations {
    NSArray *locations = [self.springs allObjects];
    NSInteger count = locations.count;
    
    if (count > 2) {
        NSMutableArray *points = [NSMutableArray arrayWithCapacity:count];

        for (int i = 0; i < locations.count; i++) {
            GSSpringLocation *location = locations[i];
            CGPoint point = CGPointMake([location.latitude doubleValue], [location.longitude doubleValue]);

            [points addObject:[NSValue valueWithCGPoint:point]];
        }

        GSConvexHull *hull = [[GSConvexHull alloc] init];
        NSArray *hullPoints = [hull convexHullOfLocationPointsForPoints:points];

//        NSLog(@"%@", hullPoints);
        
        CLLocationCoordinate2D *coords = malloc(sizeof(CLLocationCoordinate2D) * hullPoints.count);
        for (int i=0; i < hullPoints.count; i++) {
            CGPoint point = [hullPoints[i] CGPointValue];

            coords[i] = CLLocationCoordinate2DMake(point.x, point.y);
        }

        MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coords count:hullPoints.count];
        free(coords);
        return polygon;
    } else if (count > 0) {
        NSArray *sortedLocations = [locations sortedArrayUsingComparator:^NSComparisonResult(GSSpringLocation *obj1, GSSpringLocation *obj2) {
            return [obj1.longitude compare:obj2.longitude];
        }];

        CLLocationCoordinate2D *coords = malloc(sizeof(CLLocationCoordinate2D) * sortedLocations.count);
        for (int i=0; i < sortedLocations.count; i++) {
            GSSpringLocation *location = sortedLocations[i];
            coords[i] = location.coordinate;
        }

        MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coords count:sortedLocations.count];

        return polygon;
    } else {
        return nil;
    }
}

- (CLLocationCoordinate2D)calculateCenterCoordinateFromHull {
    MKPolygon *hull = [self convexHullOfSpringLocations];

    CLLocationCoordinate2D coordinate = [self centerCoordinateForPoints:hull.points pointCount:hull.pointCount];
    return coordinate;
}

double Deg_to_Rad(double degrees) {
    return (M_PI / 180) * degrees;
}

double Rad_to_Deg(double radians) {
    return (180 / M_PI) * radians;
}

- (CLLocationCoordinate2D)centerCoordinateForPoints:(MKMapPoint *)points pointCount:(NSInteger)count {
    double x = 0;
    double y = 0;
    double z = 0;
    
    for (int i = 0; i < count; i++) {
        CLLocationCoordinate2D coordinate = MKCoordinateForMapPoint(points[i]);

        double lat = Deg_to_Rad(coordinate.latitude);
        double lon = Deg_to_Rad(coordinate.longitude);
        x += cos(lat) * cos(lon);
        y += cos(lat) * sin(lon);
        z += sin(lat);
    }
    
    x = x / (double)count;
    y = y / (double)count;
    z = z / (double)count;
    
    double resultLon = atan2(y, x);
    double resultHyp = sqrt(x * x + y * y);
    double resultLat = atan2(z, resultHyp);
    
    CLLocationCoordinate2D result = CLLocationCoordinate2DMake(Rad_to_Deg(resultLat), Rad_to_Deg(resultLon));
    return result;
}

#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (NSString *)title {
    return self.name;
}

- (NSString *)subtitle {
    return [NSString stringWithFormat:@"Springs: %li", (long)self.springs.count];
}


@end
