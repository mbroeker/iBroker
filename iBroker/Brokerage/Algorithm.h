//
//  Algorithm.h
//  iBroker
//
//  Created by Markus Bröker on 12.05.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Algorithms in Objective C
 *
 * @author      Markus Bröker<broeker.markus@googlemail.com>
 * @copyright   Copyright (C) 2017 4customers UG
 */
@interface Algorithm : NSObject

/**
 *
 * @param matrix NSArray*
 * @return NSDictionary*
 */
+ (NSArray *)gaussAlgorithm:(NSArray *)matrix;

/**
 *
 * @param A double**
 * @param equations int
 */
+ (void)gaussAlgorithm:(double **)A withEquations:(int)equations;

/**
 *
 * @param value double
 * @param accuracy double
 * @return double
 */
+ (double)nearest:(double)value withAccuracy:(double)accuracy;

@end
