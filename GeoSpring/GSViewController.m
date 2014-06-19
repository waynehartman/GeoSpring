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
#import "GSBasin+MapKit.h"
#import "GSCounty.h"

@interface GSViewController () <NSFetchedResultsControllerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSFetchedResultsController *basinsFRC;
@property (nonatomic, strong) NSFetchedResultsController *locationsFRC;
@property (nonatomic, strong) NSPredicate *predicate;

@end

@implementation GSViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.basinsFRC performFetch:nil];
    
    for (GSBasin *basin in [self.basinsFRC fetchedObjects]) {
        MKPolygon *polygon = basin.convexHullOfSpringLocations;
        if (polygon) {
            [self.mapView addOverlay:polygon];
        }
    }

    [self.mapView addAnnotations:[self.basinsFRC fetchedObjects]];
}

- (NSFetchedResultsController *)basinsFRC {
    if (!_basinsFRC) {
        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        NSFetchedResultsController *fetchedResultsController = [[GSDataController sharedDataController] fetchedResultsControllerForClass:[GSBasin class] predicate:nil sortDescriptors:sortDescriptors sectionNameKeypath:nil];
        _basinsFRC = fetchedResultsController;
        _basinsFRC.delegate = self;
    }

    return _basinsFRC;
}

- (NSFetchedResultsController *)locationsFRC {
    if (!_locationsFRC  ) {
        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        NSFetchedResultsController *fetchedResultsController = [[GSDataController sharedDataController] fetchedResultsControllerForClass:[GSSpringLocation class] predicate:[self predicate] sortDescriptors:sortDescriptors sectionNameKeypath:nil];
        _locationsFRC = fetchedResultsController;
        _locationsFRC.delegate = self;
    }
    
    return _locationsFRC;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[GSBasin class]]) {
        [self.mapView removeAnnotations:self.locationsFRC.fetchedObjects];

        self.predicate = [NSPredicate predicateWithFormat:@"basin == %@", view.annotation];

        self.locationsFRC.fetchRequest.predicate = self.predicate;
        NSError *fetchError = nil;
        BOOL didFetch = [self.locationsFRC performFetch:&fetchError];

        if (didFetch) {
            NSArray *newAnnotations = self.locationsFRC.fetchedObjects;

            [self.mapView addAnnotations:newAnnotations];
        } else {
            NSLog(@"Unable to fetch spring locations!!! %@", fetchError);
        }
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:overlay];
    polygonView.lineWidth = 1.0;
    polygonView.strokeColor = [UIColor blueColor];
    polygonView.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.05];
    return polygonView;
}

- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"Pin";

    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];

    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }

    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.annotation = annotation;

    if([annotation isKindOfClass:[GSBasin class]]) {
        annotationView.pinColor = MKPinAnnotationColorRed;
    } else {
        annotationView.pinColor = MKPinAnnotationColorGreen;
    }

    return annotationView;
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
