//
//  GSBasin.h
//  GeoSpring
//
//  Created by Wayne Hartman on 6/19/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GSSpringLocation;

@interface GSBasin : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSSet *springs;
@end

@interface GSBasin (CoreDataGeneratedAccessors)

- (void)addSpringsObject:(GSSpringLocation *)value;
- (void)removeSpringsObject:(GSSpringLocation *)value;
- (void)addSprings:(NSSet *)values;
- (void)removeSprings:(NSSet *)values;

@end
