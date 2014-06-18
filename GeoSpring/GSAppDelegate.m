//
//  GSAppDelegate.m
//  GeoSpring
//
//  Created by Wayne Hartman on 6/17/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import "GSAppDelegate.h"
#import "GSGeoJsonImporter.h"

@interface GSAppDelegate ()

@property (nonatomic, strong) GSGeoJsonImporter *dataImporter;

@end

@implementation GSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //  Data obtained from http://www.tpwd.state.tx.us/gis/data/
    //  Converted from ArcGIS to GeoJSON at http://ogre.adc4gis.com/
    //  Open data should be in open formats... >_<
    NSString *path = [[NSBundle mainBundle] pathForResource:@"springdata" ofType:@"json"];
    self.dataImporter = [[GSGeoJsonImporter alloc] init];

    __weak typeof(self) weakSelf = self;
    [self.dataImporter importGeoJsonDataAtURL:[NSURL fileURLWithPath:path] withCompletionHandler:^{
        weakSelf.dataImporter = nil;
    }];

    return YES;
}

@end
