//
//  Helper.h
//  iBroker
//
//  Created by Markus Bröker on 06.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject
+ (NSString*) double2German:(double) value min:(int) min max:(int) max;
+ (NSString*) double2GermanPercent:(double) value fractions:(int) fractions;
@end
