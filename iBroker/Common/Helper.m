//
//  Helper.m
//  iBroker
//
//  Created by Markus Bröker on 06.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "Helper.h"

@implementation Helper

/**
 * Umwandlung von double Werten in das Format des jeweiligen Landes(Deutschland)
 *
 * @param double
 * @param min
 * @param max
 * @return NSString*
 */
+ (NSString*) double2German:(double) value min:(int) min max:(int) max {
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMinimumFractionDigits:min];
    [formatter setMaximumFractionDigits:max];
        
    return [formatter stringFromNumber:[NSNumber numberWithDouble:value]];
}

/**
 * Umwandlung von double Werten in das Prozent-Format des jeweiligen Landes(Deutschland)
 *
 * @param double
 * @param fractions
 * @return NSString*
 */
+ (NSString*) double2GermanPercent:(double) value fractions:(int) fractions {

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMinimumFractionDigits:2];
    [formatter setMaximumFractionDigits:fractions];
    
    NSString *signs = @"";
    
    if (value > 0.0) {
        signs = @"+";
    } else if (value == 0.0) {
        return @"+/- 0";
    }
    
    return [NSString stringWithFormat:@"%@%@ %%", signs, [formatter stringFromNumber:[NSNumber numberWithDouble:value]]];
}

/**
 * Anzeige eines modalen Dialogs
 *
 * @param message
 * @param info
 * @return NSModalResponse*
 *
 */
+ (NSModalResponse)messageText:(NSString*) message info:(NSString*) info {
    
    NSAlert *msg = [[NSAlert alloc] init];
    
    [msg setAlertStyle:NSInformationalAlertStyle];
    [msg addButtonWithTitle:@"Anwenden"];
    [msg addButtonWithTitle:@"Verwerfen"];
    
    msg.messageText = message;
    msg.informativeText = info;
    
    return [msg runModal];
    
}

@end
