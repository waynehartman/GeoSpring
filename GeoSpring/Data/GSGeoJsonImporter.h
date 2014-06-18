//
//  GSGeoJsonImporter.h
//  GeoSpring
//
//  Created by Wayne Hartman on 6/17/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GSGeoJsonImporterCompletionHandler)(void);

@interface GSGeoJsonImporter : NSObject

- (void)importGeoJsonDataAtURL:(NSURL *)url withCompletionHandler:(GSGeoJsonImporterCompletionHandler)completionHandler;

@end
