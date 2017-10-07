//
//  Helper.h
//  iBroker
//
//  Created by Markus Bröker on 06.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface Helper : NSObject

/**
 * Returns a Localized doubleValue as String
 *
 * @param value
 * @param min
 * @param max
 * @return NSString*
 */
+ (NSString *)double2German:(double)value min:(NSUInteger)min max:(NSUInteger)max;

/**
 * Returns a Localized doubleValue as String formatted as percent
 *
 * @param value
 * @param fractions
 * @return NSString*
 */
+ (NSString *)double2GermanPercent:(double)value fractions:(NSUInteger)fractions;

/**
 * Opens a modal dialog and prompts for input
 *
 * @param message
 * @param info
 * @return NSModalResponse
 */
+ (NSModalResponse)messageText:(NSString *)message info:(NSString *)info;

/**
 * Restart the Application after "seconds"s
 *
 * @param seconds
 */
+ (void)relaunchAfterDelay:(float)seconds;

@end
