/**
 * ScanTableViewController.m
 * HeartRate
 *
 * Created by Stephen Schiffli on 10/16/14.
 * Copyright 2014-2015 MbientLab Inc. All rights reserved.
 *
 * IMPORTANT: Your use of this Software is limited to those specific rights
 * granted under the terms of a software license agreement between the user who
 * downloaded the software, his/her employer (which must be your employer) and
 * MbientLab Inc, (the "License").  You may not use this Software unless you
 * agree to abide by the terms of the License which can be found at
 * www.mbientlab.com/terms.  The License limits your use, and you acknowledge,
 * that the Software may be modified, copied, and distributed when used in
 * conjunction with an MbientLab Inc, product.  Other than for the foregoing
 * purpose, you may not use, reproduce, copy, prepare derivative works of,
 * modify, distribute, perform, display or sell this Software and/or its
 * documentation for any purpose.
 *
 * YOU FURTHER ACKNOWLEDGE AND AGREE THAT THE SOFTWARE AND DOCUMENTATION ARE
 * PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY, TITLE,
 * NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL
 * MBIENTLAB OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER CONTRACT, NEGLIGENCE,
 * STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR OTHER LEGAL EQUITABLE
 * THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES INCLUDING BUT NOT LIMITED
 * TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR CONSEQUENTIAL DAMAGES, LOST
 * PROFITS OR LOST DATA, COST OF PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY,
 * SERVICES, OR ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY
 * DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
 *
 * Should you have any questions regarding your right to use this Software,
 * contact MbientLab via email: hello@mbientlab.com
 */

#import "ScanTableViewController.h"
#import <MetaWear/MetaWear.h>
#import "MBProgressHUD.h"

@interface ScanTableViewController ()
@property (nonatomic, strong) NSArray *devices;
@property (nonatomic, strong) MBLMetaWear *selected;
@end

@implementation ScanTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[MBLMetaWearManager sharedManager] startScanForMetaWearsAllowDuplicates:YES handler:^(NSArray *array) {
        self.devices = array;
        [self.tableView reloadData];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[MBLMetaWearManager sharedManager] stopScanForMetaWears];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MetaWearCell" forIndexPath:indexPath];
   
    MBLMetaWear *cur = self.devices[indexPath.row];
    
    UILabel *uuid = (UILabel *)[cell viewWithTag:1];
    uuid.text = cur.identifier.UUIDString;
    
    UILabel *rssi = (UILabel *)[cell viewWithTag:2];
    rssi.text = [cur.discoveryTimeRSSI stringValue];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Connecting...";
    
    self.selected = self.devices[indexPath.row];
    [self.selected connectWithHandler:^(NSError *error) {
        if (!error) {
            [self.selected.led flashLEDColor:[UIColor greenColor] withIntensity:0.75];
            [hud hide:YES];
            [[[UIAlertView alloc] initWithTitle:@"Pair Device"
                                        message:@"Do you see a blinking green LED on the MetaWear?"
                                       delegate:self
                              cancelButtonTitle:@"No"
                              otherButtonTitles:@"Yes!", nil] show];
        } else {
            hud.labelText = error.localizedDescription;
            [hud hide:YES afterDelay:2];
        }
    }];
}

#pragma mark - Alert View delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.selected.led setLEDOn:NO withOptions:1];
    if (buttonIndex == 1) {
        [self.selected rememberDevice];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
