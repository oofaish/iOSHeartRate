//
//  StartViewController.m
//  TempLogger
//
//  Created by Yu Suo on 11/13/14.
//  Copyright (c) 2014 MbientLab Inc. All rights reserved.
//

#import "StartViewController.h"

@interface StartViewController ()

@end

@implementation StartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
}

@end
