//
//  Brokerage.h
//  iBroker
//
//  Created by Markus Bröker on 11.05.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define POLONIEX_LOW @"lowestAsk"
#define POLONIEX_HIGH @"highestBid"
#define POLONIEX_LOW24 @"low24hr"
#define POLONIEX_HIGH24 @"high24hr"
#define POLONIEX_QUOTE_VOLUME @"quoteVolume"
#define POLONIEX_BASE_VOLUME @"baseVolume"
#define POLONIEX_PERCENT @"percentChange"
#define POLONIEX_LAST @"last"

@interface Brokerage : NSObject
+ (NSDictionary*)jsonRequest:(NSString*)jsonURL;
+ (NSDictionary*)cryptoCompareRatings:(NSArray*)fiatCurrencies;
+ (NSDictionary*)poloniexTicker;
+ (NSDictionary*)cryptoCompareBTCTicker:(double)euroFactor;

+ (void)safeSleep:(NSTimeInterval)timeout;
@end
