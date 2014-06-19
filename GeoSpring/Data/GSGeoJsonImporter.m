//
//  GSGeoJsonImporter.m
//  GeoSpring
//
//  Created by Wayne Hartman on 6/17/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import "GSGeoJsonImporter.h"
#import "GSDataController.h"
#import "GSCounty.h"
#import "GSSpringLocation.h"
#import "GSBasin+MapKit.h"

@implementation GSGeoJsonImporter

- (void)importGeoJsonDataAtURL:(NSURL *)url withCompletionHandler:(GSGeoJsonImporterCompletionHandler)completionHandler {
    GSDataController *dataController = [GSDataController sharedDataController];

    NSManagedObjectContext *backgroundContext = [dataController createManagedObjectContextForBackgroundThread];
    [backgroundContext performBlock:^{
        NSInputStream *inputStream = [[NSInputStream alloc] initWithURL:url];
        [inputStream open];
        NSError *inputStreamError = nil;

        NSDictionary *featureCollection = [NSJSONSerialization JSONObjectWithStream:inputStream options:0 error:&inputStreamError];
        [inputStream close];
        
        NSArray *featureList = featureCollection[@"features"];

        for (NSDictionary *rawFeature in featureList) {
            NSDictionary *properties = rawFeature[@"properties"];

            if (properties) {   //  Sanity check
                NSString *countyRemoteId = properties[@"county_cd"];
                GSCounty *county = [dataController countyWithRemoteId:countyRemoteId inManagedObjectContext:backgroundContext];

                void(^countyMapper)(GSCounty*) = ^(GSCounty *county){
                    county.remoteId = countyRemoteId;
                    county.name = properties[@"count_DESC"];
                };

                if (county) {
                    countyMapper(county);
                } else {
                    county = [dataController createCountyWithMapper:countyMapper inManagedObjectContext:backgroundContext];
                }

                NSString *basinRemoteId = properties[@"basin_cd"];
                GSBasin *basin = [dataController basinWithRemoteId:basinRemoteId inManagedObjectContext:backgroundContext];

                void(^basinMapper)(GSBasin *) = ^(GSBasin *basin) {
                    basin.remoteId = basinRemoteId;
                    basin.name = properties[@"basin_DESC"];
                };

                if (basin) {
                    basinMapper(basin);
                } else {
                    basin = [dataController createBasinWithMapper:basinMapper inManagedObjectContext:backgroundContext];
                }

                NSString *springRemoteId = properties[@"site_no"];
                GSSpringLocation *location = [dataController springLocationWithRemoteId:springRemoteId inManagedObjectContext:backgroundContext];

                void(^locationMapper)(GSSpringLocation *) = ^(GSSpringLocation *springLocation) {
                    springLocation.remoteId = springRemoteId;
                    springLocation.name = [self nilForNullObject:properties[@"spring_nm"]];
                    springLocation.latitude = properties[@"dec_lat_va"];
                    springLocation.longitude = properties[@"dec_long_v"];
                    springLocation.altitude = properties[@"alt_va"];
                    springLocation.remarks = [self nilForNullObject:properties[@"remarks"]];

                    springLocation.county = county;
                    springLocation.basin = basin;
                };

                if (location) {
                    locationMapper(location);
                } else {
                    location = [dataController createSpringLocationWithMapper:locationMapper inManagedObjectContext:backgroundContext];
                }
            }
        }

        NSArray *basins = [[GSDataController sharedDataController] basinsInManagedObjectContext:backgroundContext];

        for (GSBasin *basin in basins) {
            CLLocationCoordinate2D coordinate = [basin calculateCenterCoordinateFromHull];
            basin.latitude = @(coordinate.latitude);
            basin.longitude = @(coordinate.longitude);
        }

        [backgroundContext save:nil];

        //  We're done with the import
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(), completionHandler);
        }
    }];
}

- (id)nilForNullObject:(id)object {
    if ([object isKindOfClass:[NSNull class]]) {
        return nil;
    } else {
        return object;
    }
}

@end
