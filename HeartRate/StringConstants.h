//
//  StringConstants.h
//  TempLogger
//
//  Created by Yu Suo on 11/5/14.
//  Copyright (c) 2014 MbientLab Inc. All rights reserved.
//

#ifndef TempLogger_StringConstants_h
#define TempLogger_StringConstants_h


#endif

#define localize(key, default) NSLocalizedStringWithDefaultValue(key, nil, [NSBundle mainBundle], default, nil)

#define StringLabelDegreesFahrenheit localize(@"label.degrees.fahrenheit", @"%d%@F")
#define StringLabelDegreeSymbol localize(@"label.degree.symbol", @"\u00B0")