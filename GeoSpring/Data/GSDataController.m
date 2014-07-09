//
//  GSDataController.m
//  GeoSpring
//
//  Created by Wayne Hartman on 6/17/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import "GSDataController.h"
#import "GSSpringLocation.h"
#import "GSCounty.h"
#import "GSBasin.h"

@interface GSDataController ()

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;

@end

@implementation GSDataController

#pragma mark - Public Methods

static GSDataController *singleton;

+ (instancetype)sharedDataController {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[GSDataController alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver:singleton selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
    });

    return singleton;
}

#pragma mark - Public Methods

- (GSSpringLocation *)createSpringLocationWithMapper:(SpringLocationMapper)mapper inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self createInstanceForEntityClass:[GSSpringLocation class] withMapping:mapper inManagedObjectContext:context];
}

- (GSCounty *)createCountyWithMapper:(CountyMapper)mapper inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self createInstanceForEntityClass:[GSCounty class] withMapping:mapper inManagedObjectContext:context];
}

- (GSBasin *)createBasinWithMapper:(BasinMapper)mapper inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self createInstanceForEntityClass:[GSBasin class] withMapping:mapper inManagedObjectContext:context];
}

- (GSSpringLocation *)springLocationWithRemoteId:(NSString *)remoteId inManagedObjectContext:(NSManagedObjectContext *)context {
    NSArray *results = [self fetchEntitiesWithEntityClass:[GSSpringLocation class]
                                                predicate:[NSPredicate predicateWithFormat:@"remoteId == %@", remoteId]
                                   inManagedObjectContext:context];
    return [results firstObject];
}

- (GSCounty *)countyWithRemoteId:(NSString *)remoteId inManagedObjectContext:(NSManagedObjectContext *)context {
    NSArray *results = [self fetchEntitiesWithEntityClass:[GSCounty class]
                                                predicate:[NSPredicate predicateWithFormat:@"remoteId == %@", remoteId]
                                   inManagedObjectContext:context];
    return [results firstObject];
}

- (GSBasin *)basinWithRemoteId:(NSString *)remoteId inManagedObjectContext:(NSManagedObjectContext *)context {
    NSArray *results = [self fetchEntitiesWithEntityClass:[GSBasin class]
                                                predicate:[NSPredicate predicateWithFormat:@"remoteId == %@", remoteId]
                                   inManagedObjectContext:context];
    return [results firstObject];
}

- (NSArray *)basinsInManagedObjectContext:(NSManagedObjectContext *)context {
    return [self fetchEntitiesWithEntityClass:[GSBasin class] predicate:nil inManagedObjectContext:context];
}

#pragma mark - Reusable CRUD

- (NSFetchedResultsController *)fetchedResultsControllerForClass:(Class)clazz predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors sectionNameKeypath:(NSString *)keypath {
    NSString * entityName = NSStringFromClass(clazz);

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    request.predicate = predicate;
    request.sortDescriptors = sortDescriptors;
    
    NSFetchedResultsController *resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                        managedObjectContext:self.managedObjectContext
                                                                                          sectionNameKeyPath:keypath
                                                                                                   cacheName:nil];
    return resultsController;
}

- (NSArray *)fetchEntitiesWithEntityClass:(Class)clazz predicate:(NSPredicate *)predicate inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self fetchEntitiesWithEntityClass:clazz
                                   predicate:predicate
                             sortDescriptors:nil
                      inManagedObjectContext:context];
}

- (NSArray *)fetchEntitiesWithEntityClass:(Class)clazz predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inManagedObjectContext:(NSManagedObjectContext *)context {
    if (context == nil) {
        context = self.managedObjectContext;
    }

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(clazz)];
    request.predicate = predicate;
    request.sortDescriptors = sortDescriptors;
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (results == nil) {
        NSLog(@"error fetching! %@", error);
    }
    
    return results;
}

- (id)managedObjectForEntityClass:(Class)clazz withPredicate:(NSPredicate *)predicate inManagedObjectContext:(NSManagedObjectContext *)context {
    if (context == nil) {
        context = self.managedObjectContext;
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(clazz)];
    request.predicate = predicate;

    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (results == nil) {
        NSLog(@"error fetching!!!\n\n%@", error);
        return nil;
    } else if (results.count > 0) {
        return results[0];
    } else {
        return nil;
    }
}

- (id)createInstanceForEntityClass:(Class)clazz withMapping:(void(^__strong)(id))mapping inManagedObjectContext:(NSManagedObjectContext *)context {
    if (context == nil) {
        context = self.managedObjectContext;
    }
    
    NSManagedObject *item = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(clazz)
                                                          inManagedObjectContext:context];

    if (mapping) {
        mapping(item);
    }
    
    return item;
}

#pragma mark - Core Data Boilerplate Code

/*
 *  There really isn't anything interesting in this section because this is standard boilerplate Core Data code
 */

- (NSManagedObjectContext *)createManagedObjectContextForBackgroundThread {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = self.persistentStoreCoordinator;
    context.mergePolicy = [[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType];
    
    return context;
}

- (NSURL *)persistentStoreUrl {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [NSString stringWithFormat:@"%@/datastore.sqlite", libraryPath];
    NSURL * url = [NSURL fileURLWithPath:path];

    return url;
}

- (NSURL *)managedObjectModelUrl {
    return nil;
}

- (void)contextDidSave:(NSNotification *)notification {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self contextDidSave:notification];
        });
    } else {
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    }
}

- (NSManagedObjectModel*) managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *momURL = [self managedObjectModelUrl];
    
    if (momURL) {
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    } else {
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator*) persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSURL* storeURL = [self persistentStoreUrl];
    NSError* error = nil;

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext*) managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator* coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

@end
