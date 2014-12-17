//
//  ColorConstants.h
//  TempLogger
//
//  Created by Yu Suo on 11/5/14.
//  Copyright (c) 2014 MbientLab Inc. All rights reserved.
//

#ifndef HRLogger_ColorConstants_h
#define HRLogger_ColorConstants_h

#endif

#define UIColorFromHex(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]

#pragma mark - Navigation

#define ColorNavigationBarTint UIColorFromHex(0x0D0D0D)
#define ColorNavigationTint UIColorFromHex(0xFF3B30)
#define ColorNavigationTitle UIColorFromHex(0xFF3B30)

#pragma mark - Tooltips

#define ColorTooltipColor [UIColor colorWithWhite:1.0 alpha:0.9]
#define ColorTooltipTextColor UIColorFromHex(0x313131)