//
//  HRViewController.h
//  HeartRate
//
//  Created by Laura Kassovic on 12/16/14.
//  Copyright (c) 2014 MbientLab Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MetaWear/MetaWear.h>

@interface HRViewController : UIViewController

@property (nonatomic, strong) MBLMetaWear *device;

@end
