//
//  GSSpringLocation.h
//  GeoSpring
//
//  Created by Wayne Hartman on 6/17/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GSBasin, GSCounty;

@interface GSSpringLocation : NSManagedObject

@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * remarks;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) GSCounty *county;
@property (nonatomic, retain) GSBasin *basin;

@end
