//
//  Brokerage+External.h
//  iBroker
//
//  Created by Markus Bröker on 12.09.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "Brokerage.h"

/**
 * Category for External Services
 *
 * @author      Markus Bröker<broeker.markus@googlemail.com>
 * @copyright   Copyright (C) 2017 4customers UG
 */
@interface Brokerage (External)

/**
 *
 * @param fiatCurrencies NSArray*
 * @return NSNumber*
 */
+ (NSNumber *)fiatExchangeRate:(NSArray *)fiatCurrencies;

/**
 *
 * @param asset NSString*
 * @return NSDictionary*
 */
+ (NSDictionary *)bitstampAsset1Ticker:(NSString *)asset;

@end
