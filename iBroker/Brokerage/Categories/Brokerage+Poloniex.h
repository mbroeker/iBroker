//
//  Brokerage+Poloniex.h
//  iBroker
//
//  Created by Markus Bröker on 12.09.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "Brokerage.h"

/**
 * Category for Poloniex
 *
 * @author      Markus Bröker<broeker.markus@googlemail.com>
 * @copyright   Copyright (C) 2017 4customers UG
 */
@interface Brokerage (Poloniex)

/**
 * Retrieve the Ticker from Poloniex
 *
 * @param fiatCurrencies NSArray*
 * @return NSDictionary*
 */
+ (NSDictionary *)poloniexTicker:(NSArray *)fiatCurrencies;

/**
 * Retrieve the balance from Poloniex via API-KEY
 *
 * @param apikey NSDictionary*
 * @param secret NSString*
 * @return NSDictionary*
 */
+ (NSDictionary *)poloniexBalance:(NSDictionary *)apikey withSecret:(NSString *)secret;

/**
 * Buy an ASSET with the MASTER ASSET (BTC) via API-KEY
 *
 * @param apikey NSDictionary*
 * @param secret NSString*
 * @param currencyPair NSSstring*
 * @param rate double
 * @param amount double
 * @return NSDictionary*
 */
+ (NSDictionary *)poloniexBuy:(NSDictionary *)apikey withSecret:(NSString *)secret currencyPair:(NSString *)currencyPair rate:(double)rate amount:(double)amount;

/**
 * Sell an ASSET back into the master ASSET (BTC) via API-KEY
 *
 * @param apikey NSDictionary*
 * @param secret NSString*
 * @param currencyPair NSSstring*
 * @param rate double
 * @param amount double
 * @return NSDictionary*
 */
+ (NSDictionary *)poloniexSell:(NSDictionary *)apikey withSecret:(NSString *)secret currencyPair:(NSString *)currencyPair rate:(double)rate amount:(double)amount;

/**
 * Get Open Orders from Poloniex via API-KEY
 *
 * @param apikey NSDictionary*
 * @param secret NSString*
 * @return NSArray*
 */
+ (NSArray *)poloniexOpenOrders:(NSDictionary *)apikey withSecret:(NSString *)secret;

/**
 *
 * @param apikey NSDictionary*
 * @param secret NSString*
 * @param orderId NSString*
 * @return BOOL
 */
+ (BOOL)poloniexCancelOrder:(NSDictionary *)apikey withSecret:(NSString *)secret orderId:(NSString *)orderId;

@end
