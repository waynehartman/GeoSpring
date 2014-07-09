//
//  GSSpringLocationDetailsViewController.m
//  GeoSpring
//
//  Created by Wayne Hartman on 6/19/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import "GSSpringLocationDetailsViewController.h"
#import "GSSpringLocation.h"
#import "GSCounty.h"

typedef NS_ENUM(NSInteger, SpringDetailsRow) {
    SpringDetailsRowRemarks = 0,
    SpringDetailsRowAltitude,
    SpringDetailsRowLocation,
    SpringDetailsRowCount
};

@interface GSSpringLocationDetailsViewController ()

@end

@implementation GSSpringLocationDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.title = self.springLocation.name ?: @"<Unnamed Spring>";
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return SpringDetailsRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = [self cellIDForRowAtIndexPath:indexPath];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];

    SpringDetailsRow row = indexPath.row;
    switch (row) {
        case SpringDetailsRowAltitude: {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lift.", [self.springLocation.altitude longValue]];
        }
            break;
        case SpringDetailsRowLocation: {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ County", self.springLocation.county.name];
        }
            break;
        case SpringDetailsRowRemarks: {
            cell.textLabel.text = self.springLocation.remarks ?: @"<No remarks>";
        }
            break;
        default: {
            //  DO NOTHING
        }
    }

    return cell;
}

- (NSString *)cellIDForRowAtIndexPath:(NSIndexPath *)indexPath {
    SpringDetailsRow row = indexPath.row;
    switch (row) {
        case SpringDetailsRowAltitude:
            return @"AltitudeCell";
        case SpringDetailsRowLocation:
            return @"LocationCell";
        case SpringDetailsRowRemarks:
            return @"RemarksCell";
        default:
            return nil;
    }
}

@end
