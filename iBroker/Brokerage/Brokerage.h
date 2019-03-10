//
//  Brokerage.h
//  iBroker
//
//  Created by Markus Bröker on 11.05.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "Calculator.h"

/**
 * Rudimentary Trading Functions
 *
 * @author      Markus Bröker<broeker.markus@googlemail.com>
 * @copyright   Copyright (C) 2017 4customers UG
 */
@interface Brokerage : NSObject

/**
 * Retrieve the current balance from the crypto exchange of choice
 *
 * @param apikey NSDictionary*
 * @param secret NSString*
 * @param exchange NSString*
 * @return NSDictionary*
 */
+ (NSDictionary *)balance:(NSDictionary *)apikey withSecret:(NSString *)secret forExchange:(NSString *)exchange;

/**
 * Buy an ASSET with the MASTER-ASSET (BTC) via API-KEY
 *
 * @param apikey NSDictionary*
 * @param secret NSString*
 * @param currencyPair NSSstring*
 * @param rate double
 * @param amount double
 * @param exchange NSString*
 * @return NSDictionary*
 */
+ (NSDictionary *)buy:(NSDictionary *)apikey withSecret:(NSString *)secret currencyPair:(NSString *)currencyPair rate:(double)rate amount:(double)amount onExchange:(NSString *)exchange;

/**
 * Sell an ASSET back into the MASTER-ASSET (BTC) via API-KEY
 *
 * @param apikey NSDictionary*
 * @param secret NSString*
 * @param currencyPair NSSstring*
 * @param rate double
 * @param amount double
 * @param exchange NSString*
 * @return NSDictionary*
 */
+ (NSDictionary *)sell:(NSDictionary *)apikey withSecret:(NSString *)secret currencyPair:(NSString *)currencyPair rate:(double)rate amount:(double)amount onExchange:(NSString *)exchange;

/**
 * Get Open Orders from the given exchange via API-KEY
 *
 * @param apikey NSDictionary*
 * @param secret NSString*
 * @param exchange NSString*
 * @return NSArray*
 */
+ (NSArray *)openOrders:(NSDictionary *)apikey withSecret:(NSString *)secret onExchange:(NSString *)exchange;

/**
 * Cancel Order from the given exchange via API-KEY
 *
 * @param apikey NSDictionary*
 * @param secret NSString*
 * @param exchange NSString*
 * @return BOOL
 */
+ (BOOL)cancelOrder:(NSDictionary *)apikey withSecret:(NSString *)secret orderId:(NSString *)orderId onExchange:(NSString *)exchange;

@end

#import "Categories/Brokerage+Bittrex.h"
#import "Categories/Brokerage+Poloniex.h"
