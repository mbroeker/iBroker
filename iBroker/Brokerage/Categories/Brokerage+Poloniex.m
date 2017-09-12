//
//  Brokerage+Poloniex.m
//  iBroker

//
//  Created by Markus Bröker on 12.09.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "Brokerage+Poloniex.h"
#import "Brokerage+Crypto.h"
#import "Brokerage+JSON.h"
#import "Brokerage+External.h"

@implementation Brokerage (Poloniex)

/**
 * Besorge den Ticker von Poloniex
 *
 * @param fiatCurrencies
 * @return NSDictionary*
 */
+ (NSDictionary*)poloniexTicker:(NSArray*)fiatCurrencies {
    NSString *jsonURL = @"https://poloniex.com/public?command=returnTicker";

    NSMutableDictionary *ticker = [[Brokerage jsonRequest:jsonURL] mutableCopy];

    if (!ticker[@"BTC_XMR"]) {
        NSLog(@"API-ERROR: Cannot retrieve ticker data from poloniex");

        return nil;
    }

    NSDictionary *asset1Ticker = [Brokerage bitstampAsset1Ticker:fiatCurrencies[0]];

    if (!asset1Ticker) {
        return nil;
    }

    NSNumber *exchangeRate = [Brokerage fiatExchangeRate:fiatCurrencies];

    if (!exchangeRate) {
        return nil;
    }

    NSString *asset1Fiat = [NSString stringWithFormat:@"%@_%@", ASSET1, fiatCurrencies[0]];
    ticker[asset1Fiat] = asset1Ticker;
    ticker[fiatCurrencies[1]] = @([exchangeRate doubleValue]);

    // BCC ist BCH auf Poloniex
    NSString *asset1BCC = [NSString stringWithFormat:@"%@_BCC", ASSET1];
    NSString *asset1BCH = [NSString stringWithFormat:@"%@_BCH", ASSET1];
    ticker[asset1BCC] = ticker[asset1BCH];

    return ticker;
}

/**
 * Request the balance from poloniex via API-Key
 *
 * @param apikey
 * @param secret
 * returns NSDictionary*
 */
+ (NSDictionary*)poloniexBalance:(NSDictionary*)apikey withSecret:(NSString*)secret {
    NSString *jsonURL = @"https://poloniex.com/tradingApi";

    if ([secret isEqualToString:@""]) {
        return nil;
    }

    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *header = [apikey mutableCopy];

    time_t t = 1975.0 * time(NULL);

    payload[@"command"] = @"returnCompleteBalances";
    payload[@"nonce"] = [NSString stringWithFormat:@"%ld", t];

    header[@"Sign"] = [Brokerage hmac:[Brokerage urlEncode:payload] withSecret:secret];

    NSDictionary *data = [Brokerage jsonRequest:jsonURL withPayload:payload andHeader:header];

    if (data == nil) {
        return @{
            @"error": @"API-ERROR: Cannot fetch Data from Poloniex"
        };
    }

    return data;
}

/**
 * BUY via API-KEY
 *
 * @param apikey
 * @param secret
 * @param currencyPair
 * @param rate
 * @param amount
 * returns NSDictionary*
 */
+ (NSDictionary*)poloniexBuy:(NSDictionary*)apikey withSecret:(NSString*)secret currencyPair:(NSString*)currencyPair rate:(double)rate amount:(double)amount {
    NSString *jsonURL = @"https://poloniex.com/tradingApi";

    if ([secret isEqualToString:@""]) {
        return nil;
    }

    // Bitcoin Cash heißt BCH auf Poloniex
    NSString *asset1BCC = [NSString stringWithFormat:@"%@_BCC", ASSET1];
    NSString *asset1BCH = [NSString stringWithFormat:@"%@_BCH", ASSET1];
    if ([currencyPair isEqualToString:asset1BCC]) {
        currencyPair = asset1BCH;
    }

    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *header = [apikey mutableCopy];

    time_t t = 1975.0 * time(NULL);

    payload[@"command"] = @"buy";
    payload[@"currencyPair"] = currencyPair;
    payload[@"rate"] = [NSNumber numberWithDouble:rate];
    payload[@"amount"] = [NSNumber numberWithDouble:amount];
    payload[@"nonce"] = [NSString stringWithFormat:@"%ld", t];

    header[@"Sign"] = [Brokerage hmac:[Brokerage urlEncode:payload] withSecret:secret];

    return [Brokerage jsonRequest:jsonURL withPayload:payload andHeader:header];
}

/**
 * SELL via API-KEY
 *
 * @param apikey
 * @param secret
 * @param currencyPair
 * @param rate
 * @param amount
 * returns NSDictionary*
 */
+ (NSDictionary*)poloniexSell:(NSDictionary*)apikey withSecret:(NSString*)secret currencyPair:(NSString*)currencyPair rate:(double)rate amount:(double)amount {
    NSString *jsonURL = @"https://poloniex.com/tradingApi";

    if ([secret isEqualToString:@""]) {
        return nil;
    }

    // Bitcoin Cash heißt BCH auf Poloniex
    NSString *asset1BCC = [NSString stringWithFormat:@"%@_BCC", ASSET1];
    NSString *asset1BCH = [NSString stringWithFormat:@"%@_BCH", ASSET1];
    if ([currencyPair isEqualToString:asset1BCC]) {
        currencyPair = asset1BCH;
    }

    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *header = [apikey mutableCopy];

    time_t t = 1975.0 * time(NULL);

    payload[@"command"] = @"sell";
    payload[@"currencyPair"] = currencyPair;
    payload[@"rate"] = [NSNumber numberWithDouble:rate];
    payload[@"amount"] = [NSNumber numberWithDouble:amount];
    payload[@"nonce"] = [NSString stringWithFormat:@"%ld", t];

    header[@"Sign"] = [Brokerage hmac:[Brokerage urlEncode:payload] withSecret:secret];

    return [Brokerage jsonRequest:jsonURL withPayload:payload andHeader:header];
}

@end
