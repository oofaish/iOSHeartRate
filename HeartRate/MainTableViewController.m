//
//  MainTableViewController.m
//  TempLogger
//
//  Created by Stephen Schiffli on 10/16/14.
//  Copyright (c) 2014 MbientLab Inc. All rights reserved.
//

#import "MainTableViewController.h"
#import "HRViewController.h"
#import <MetaWear/MetaWear.h>
#import "ColorConstants.h"

@interface MainTableViewController ()
@property (nonatomic, strong) NSArray *devices;
@end

@implementation MainTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[MBLMetaWearManager sharedManager] retrieveSavedMetaWearsWithHandler:^(NSArray *array) {
        self.devices = array;
        [self.tableView reloadData];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = ColorNavigationTint;
    self.navigationController.navigationBar.barTintColor = ColorNavigationBarTint;
    self.navigationController.navigationBar.translucent = TRUE;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ColorNavigationTitle,NSForegroundColorAttributeName, FontNavigationTitle, NSFontAttributeName, nil]];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[HRViewController class]]) {
        HRViewController *controller = segue.destinationViewController;
        controller.device = sender;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MAX(1, self.devices.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = self.devices.count ? @"MetaWearCell" : @"NoDeviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if (self.devices.count) {
        MBLMetaWear *cur = self.devices[indexPath.row];
        UILabel *uuid = (UILabel *)[cell viewWithTag:1];
        uuid.text = cur.identifier.UUIDString;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.devices.count) {
        MBLMetaWear *selected = self.devices[indexPath.row];
        [self performSegueWithIdentifier:@"ViewLog" sender:selected];
    } else {
        [self performSegueWithIdentifier:@"AddNewDevice" sender:nil];
    }
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.devices.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MBLMetaWear *cur = self.devices[indexPath.row];
        [cur forgetDevice];
        
        NSMutableArray *tmp = [self.devices mutableCopy];
        [tmp removeObjectAtIndex:indexPath.row];
        self.devices = tmp;
        
        if (self.devices.count) {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}


@end
