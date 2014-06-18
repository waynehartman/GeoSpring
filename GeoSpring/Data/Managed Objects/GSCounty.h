//
//  GSCounty.h
//  GeoSpring
//
//  Created by Wayne Hartman on 6/17/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GSSpringLocation;

@interface GSCounty : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) NSSet *springs;
@end

@interface GSCounty (CoreDataGeneratedAccessors)

- (void)addSpringsObject:(GSSpringLocation *)value;
- (void)removeSpringsObject:(GSSpringLocation *)value;
- (void)addSprings:(NSSet *)values;
- (void)removeSprings:(NSSet *)values;

@end
