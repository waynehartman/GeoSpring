//
//  GSViewController.m
//  GeoSpring
//
//  Created by Wayne Hartman on 6/17/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import "GSViewController.h"

#import "GSDataController.h"
#import <MapKit/MapKit.h>

#import "GSSpringLocation.h"
#import "GSBasin.h"
#import "GSCounty.h"

@interface GSViewController () <NSFetchedResultsControllerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSFetchedResultsController *locationsFRC;

@end

@implementation GSViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.locationsFRC performFetch:nil];
    [self.mapView addAnnotations:[self.locationsFRC fetchedObjects]];
}

- (NSFetchedResultsController *)locationsFRC {
    if (!_locationsFRC) {
        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        NSFetchedResultsController *fetchedResultsController = [[GSDataController sharedDataController] fetchedResultsControllerForClass:[GSSpringLocation class] predicate:nil sortDescriptors:sortDescriptors sectionNameKeypath:nil];
        _locationsFRC = fetchedResultsController;
        _locationsFRC.delegate = self;
    }

    return _locationsFRC;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.mapView addAnnotation:anObject];
            break;
        case NSFetchedResultsChangeDelete:
            [self.mapView removeAnnotation:anObject];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.mapView removeAnnotation:anObject];
            [self.mapView addAnnotation:anObject];
            break;
        default:
            break;
    }
}

@end
