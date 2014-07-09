//
//  GSBasinDetailsViewController.m
//  GeoSpring
//
//  Created by Wayne Hartman on 6/19/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import "GSBasinDetailsViewController.h"
#import "GSBasin.h"
#import "GSSpringLocation.h"
#import "GSSpringLocationDetailsViewController.h"

@interface GSBasinDetailsViewController ()

@property (nonatomic, strong) NSArray *springs;

@end

#define SEGUE_SPRING @"SEGUE_SPRING"

@implementation GSBasinDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.basin.name;
    self.springs = [[self.basin.springs allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_SPRING]) {
        GSSpringLocationDetailsViewController *springVC = segue.destinationViewController;
        springVC.springLocation = sender;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.springs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSSpringLocation *spring = self.springs[indexPath.row];

    static NSString *cellID = @"SpringCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.textLabel.text = spring.name ?: @"<Unnamed Spring>";
    cell.detailTextLabel.text = spring.remarks ?: @"";

    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:SEGUE_SPRING sender:self.springs[indexPath.row]];
}

@end
