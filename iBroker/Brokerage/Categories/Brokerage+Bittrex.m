//
//  Brokerage+Bittrex.m
//  iBroker
//
//  Created by Markus Bröker on 12.09.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "Brokerage+Bittrex.h"
#import "Brokerage+Crypto.h"
#import "Brokerage+JSON.h"
#import "Brokerage+External.h"

@implementation Brokerage (Bittrex)

/**
 * Besorge den Ticker von Bittrex
 *
 * @param fiatCurrencies
 * @param assetsArray
 * @return NSDictionary*
 */
+ (NSDictionary*)bittrexTicker:(NSArray*)fiatCurrencies forAssets:(NSArray*)assetsArray {

    NSMutableDictionary *ticker = [[NSMutableDictionary alloc] init];
    for (id key in assetsArray) {
        if ([key isEqualToString:ASSET1]) continue;

        NSString *pair = [NSString stringWithFormat:@"%@-%@", [ASSET1 lowercaseString], [key lowercaseString]];
        NSString *jsonURL = [NSString stringWithFormat:@"https://bittrex.com/api/v1.1/public/getmarketsummary?market=%@", pair];

        NSMutableDictionary *innerTicker = [[Brokerage jsonRequest:jsonURL] mutableCopy];

        if (!innerTicker[@"result"]) {
            NSLog(@"API-ERROR: Cannot retrieve ticker data from bittrex for key %@", key);

            return nil;
        }

        if ([innerTicker[@"message"] isEqualToString:@"INVALID_MARKET"]) {
            NSLog(@"Invalid Market: %@/%@", ASSET1, key);
            continue;
        }

        NSDictionary *data = innerTicker[@"result"][0];

        if (!data[@"MarketName"]) {
            return nil;
        }

        NSString *marketName = data[@"MarketName"];

        marketName = [marketName stringByReplacingOccurrencesOfString:@"-" withString:@"_"];

        double percent = ([data[@"Last"] doubleValue] / [data[@"PrevDay"] doubleValue]) -1;

        ticker[marketName] = @{
            POLONIEX_HIGH24: data[@"High"],
            POLONIEX_LOW24: data[@"Low"],
            POLONIEX_ASK: data[@"Ask"],
            POLONIEX_BID: data[@"Bid"],
            POLONIEX_LAST: data[@"Last"],
            POLONIEX_BASE_VOLUME: data[@"BaseVolume"],
            POLONIEX_QUOTE_VOLUME: data[@"Volume"],
            POLONIEX_PERCENT: @(percent)
        };
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

    return ticker;
}

/**
 * Request the balance from Bittrex via API-Key
 *
 * @param apikey
 * @param secret
 * returns NSDictionary*
 */
+ (NSDictionary*)bittrexBalance:(NSDictionary*)apikey withSecret:(NSString*)secret {

    time_t t = 1000 * time(NULL);
    NSString *nonce = [NSString stringWithFormat:@"%ld", t];

    NSString *jsonURL = [NSString stringWithFormat:@"https://bittrex.com/api/v1.1/account/getbalances?apikey=%@&nonce=%@", apikey[@"Key"], nonce];

    if ([secret isEqualToString:@""]) {
        return nil;
    }

    NSMutableDictionary *header = [[NSMutableDictionary alloc] init];
    header[@"apisign"] = [Brokerage hmac:[Brokerage urlStringEncode:jsonURL] withSecret:secret];

    NSDictionary *data = [Brokerage jsonRequest:jsonURL withPayload:nil andHeader:header];

    if (data == nil) {
        return @{
            @"error": @"API-ERROR: Cannot fetch Data from Bittrex"
        };
    }

    if ([data[@"success"] intValue] == 0) {
        return @{
            @"error": data[@"message"]
        };
    }

    NSArray *dataRows = data[@"result"];

    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];

    for (NSDictionary *row in dataRows) {
        NSString *asset = row[@"Currency"];

        double available = [row[@"Available"] doubleValue];
        double onOrders = [row[@"Pending"] doubleValue];

        result[asset] = @{
            @"available": @(available),
            @"onOrders": @(onOrders)
        };
    }

    return result;
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
+ (NSDictionary*)bittrexBuy:(NSDictionary*)apikey withSecret:(NSString*)secret currencyPair:(NSString*)currencyPair rate:(double)rate amount:(double)amount {

    if ([apikey[@"Key"] isEqualToString:@""]) {
        return nil;
    }

    NSString *bittrexCurrencyPair = [currencyPair stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
    NSString *bittrexRate = [NSString stringWithFormat:@"%.8f", rate];
    NSString *bittrexAmount = [NSString stringWithFormat:@"%.8f", amount];

    time_t t = time(NULL);
    NSString *nonce = [NSString stringWithFormat:@"%ld", t];
    NSString *jsonURL = [NSString stringWithFormat:@"https://bittrex.com/api/v1.1/market/buylimit?apikey=%@&market=%@&quantity=%@&rate=%@&nonce=%@",
        apikey[@"Key"],
        bittrexCurrencyPair,
        bittrexAmount,
        bittrexRate,
        nonce
    ];

    NSMutableDictionary *header = [[NSMutableDictionary alloc] init];
    header[@"apisign"] = [Brokerage hmac:[Brokerage urlStringEncode:jsonURL] withSecret:secret];

    NSDictionary *response = [Brokerage jsonRequest:jsonURL withPayload:nil andHeader:header];

    if ([response[@"success"] integerValue] == 1) {
        NSDictionary *result = response[@"result"];

        return @{
            @"orderNumber": result[@"uuid"]
        };
    } else {
        NSLog(@"BUY-LIMIT: %@/%@/%@: %@", bittrexCurrencyPair, bittrexAmount, bittrexRate, response[@"message"]);
    }

    return nil;
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
+ (NSDictionary*)bittrexSell:(NSDictionary*)apikey withSecret:(NSString*)secret currencyPair:(NSString*)currencyPair rate:(double)rate amount:(double)amount {

    if ([apikey[@"Key"] isEqualToString:@""]) {
        return nil;
    }

    NSString *bittrexCurrencyPair = [currencyPair stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
    NSString *bittrexRate = [NSString stringWithFormat:@"%.8f", rate];
    NSString *bittrexAmount = [NSString stringWithFormat:@"%.8f", amount];

    time_t t = time(NULL);
    NSString *nonce = [NSString stringWithFormat:@"%ld", t];
    NSString *jsonURL = [NSString stringWithFormat:@"https://bittrex.com/api/v1.1/market/selllimit?apikey=%@&market=%@&quantity=%@&rate=%@&nonce=%@",
        apikey[@"Key"],
        bittrexCurrencyPair,
        bittrexAmount,
        bittrexRate,
        nonce
    ];

    NSMutableDictionary *header = [[NSMutableDictionary alloc] init];
    header[@"apisign"] = [Brokerage hmac:[Brokerage urlStringEncode:jsonURL] withSecret:secret];

    NSDictionary *response = [Brokerage jsonRequest:jsonURL withPayload:nil andHeader:header];

    if ([response[@"success"] integerValue] == 1) {
        NSDictionary *result = response[@"result"];

        return @{
            @"orderNumber": result[@"uuid"]
        };
    } else {
        NSLog(@"SELL-LIMIT: %@/%@/%@: %@", bittrexCurrencyPair, bittrexAmount, bittrexRate, response[@"message"]);
    }

    return nil;
}

@end