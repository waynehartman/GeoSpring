//
//  GSDataController.h
//  GeoSpring
//
//  Created by Wayne Hartman on 6/17/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GSCounty;
@class GSSpringLocation;
@class GSBasin;

typedef void(^CountyMapper)(GSCounty *county);
typedef void(^SpringLocationMapper)(GSSpringLocation *springLocation);
typedef void(^BasinMapper)(GSBasin *county);

@interface GSDataController : NSObject

+ (instancetype)sharedDataController;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

- (NSFetchedResultsController *)fetchedResultsControllerForClass:(Class)clazz predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors sectionNameKeypath:(NSString *)keypath;
- (NSManagedObjectContext *)createManagedObjectContextForBackgroundThread;

//  Create
- (GSSpringLocation *)createSpringLocationWithMapper:(SpringLocationMapper)mapper inManagedObjectContext:(NSManagedObjectContext *)context;
- (GSCounty *)createCountyWithMapper:(CountyMapper)mapper inManagedObjectContext:(NSManagedObjectContext *)context;
- (GSBasin *)createBasinWithMapper:(BasinMapper)mapper inManagedObjectContext:(NSManagedObjectContext *)context;

//  Fetch
- (GSSpringLocation *)springLocationWithRemoteId:(NSString *)remoteId inManagedObjectContext:(NSManagedObjectContext *)context;
- (GSCounty *)countyWithRemoteId:(NSString *)remoteId inManagedObjectContext:(NSManagedObjectContext *)context;
- (GSBasin *)basinWithRemoteId:(NSString *)remoteId inManagedObjectContext:(NSManagedObjectContext *)context;

- (NSArray *)basinsInManagedObjectContext:(NSManagedObjectContext *)context;

@end
