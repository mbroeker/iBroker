//
//  Poloniex.m
//  iBroker
//
//  Created by Markus Bröker on 11.05.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "Brokerage.h"

@implementation Brokerage

/**
 * Allgemeiner jsonRequest Handler
 */
+ (NSDictionary*)jsonRequest:(NSString*)jsonURL {

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:jsonURL]];
    [request setHTTPMethod:@"GET"];
    
    __block NSMutableDictionary *result;
    __block BOOL hasFinished = false;

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

        NSData *jsonData = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError;

        result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&jsonError];
        if (jsonError) {
            // Fehlermeldung wird angezeigt
            NSLog(@"%@", [jsonError description]);
        }

        hasFinished = true;

    }] resume];

    while(!hasFinished) {
        [Brokerage safeSleep:0.1];
    }
    
    return result;
}

/**
 * Besorge den Ticker von Poloniex
 */
+ (NSDictionary*)poloniexTicker {
    NSString *jsonURL = @"https://poloniex.com/public?command=returnTicker";

    return [Brokerage jsonRequest:jsonURL];
}

/**
 * Besorge die Kurse von cryptocompare per JSON-Request
 */
+ (NSDictionary*)cryptoCompareRatings:(NSArray*)fiatCurrencies {
    NSString *jsonURL =
        [NSString stringWithFormat:@"https://min-api.cryptocompare.com/data/pricemulti?fsyms=%@&tsyms=%@,BTC&extraParams=de.4customers.iBroker", fiatCurrencies[0], fiatCurrencies[1]];
    
    return [Brokerage jsonRequest:jsonURL];
}

/**
 * Besorge den fehlenden BTC-Ticker von cryptoCompare und fake diesen ins Poloniex-Format
 */
+ (NSDictionary*)cryptoCompareBTCTicker:(double)usdFactor {
    NSString *jsonURL =
        [NSString stringWithFormat:@"https://min-api.cryptocompare.com/data/histoday?fsym=BTC&tsym=USD&limit=1&e=Poloniex&extraParams=de.4customers.iBroker"];

    NSDictionary *theirData = [Brokerage jsonRequest:jsonURL];

    NSMutableDictionary *poloniexData = [[NSMutableDictionary alloc] init];

    NSDictionary *data = theirData[@"Data"][0];
    poloniexData[POLONIEX_HIGH24] = [NSNumber numberWithDouble:[data[@"high"] doubleValue] / usdFactor];
    poloniexData[POLONIEX_LOW24] = [NSNumber numberWithDouble:[data[@"low"] doubleValue] / usdFactor];
    poloniexData[POLONIEX_HIGH] = [NSNumber numberWithDouble:[data[@"close"] doubleValue] / usdFactor];
    poloniexData[POLONIEX_LOW] = [NSNumber numberWithDouble:[data[@"open"] doubleValue] / usdFactor];
    poloniexData[POLONIEX_LAST] = [NSNumber numberWithDouble:[data[@"open"] doubleValue] / usdFactor];

    poloniexData[POLONIEX_BASE_VOLUME] = data[@"volumefrom"];
    poloniexData[POLONIEX_QUOTE_VOLUME] = data[@"volumeto"];
    poloniexData[POLONIEX_PERCENT] = [NSNumber numberWithDouble:100 * ([data[@"volumefrom"] doubleValue] / [data[@"volumeto"] doubleValue])];

    return poloniexData;
}

/**
 * Warte timeout Sekunden
 *
 * @param timeout
 */
+ (void)safeSleep:(NSTimeInterval)timeout {
    [NSThread sleepForTimeInterval:timeout];
}

@end
