//
//  Brokerage.h
//  iBroker
//
//  Created by Markus Bröker on 11.05.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define RELEASE_BUILD 1

#define POLONIEX_ASK @"lowestAsk"
#define POLONIEX_BID @"highestBid"
#define POLONIEX_LOW24 @"low24hr"
#define POLONIEX_HIGH24 @"high24hr"
#define POLONIEX_QUOTE_VOLUME @"quoteVolume"
#define POLONIEX_BASE_VOLUME @"baseVolume"
#define POLONIEX_PERCENT @"percentChange"
#define POLONIEX_LAST @"last"

@interface Brokerage : NSObject
+ (NSDictionary*)jsonRequest:(NSString*)jsonURL;
+ (NSDictionary*)poloniexTicker:(NSArray*)fiatCurrencies;

+ (void)safeSleep:(NSTimeInterval)timeout;
@end
