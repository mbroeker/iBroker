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
 * 
 * WICHTIG: LAST = OPEN, LOW = OPEN, HIGH = CLOSE - das ist definitiv eine temporäre Lösung
 */
+ (NSDictionary*)cryptoCompareBTCTicker:(double)usdFactor {
    NSString *jsonURL =
        [NSString stringWithFormat:@"https://min-api.cryptocompare.com/data/histoday?fsym=BTC&tsym=USD&limit=1&e=Poloniex&extraParams=de.4customers.iBroker"];

    NSDictionary *theirData = [Brokerage jsonRequest:jsonURL];

    NSDictionary *data = theirData[@"Data"][0];

    double high24 = [data[@"high"] doubleValue] / usdFactor;
    double low24 = [data[@"low"] doubleValue] / usdFactor;
    double open = [data[@"open"] doubleValue] / usdFactor;
    double close = [data[@"close"] doubleValue] / usdFactor;

    NSMutableDictionary *poloniexData = [[NSMutableDictionary alloc] init];

    poloniexData[POLONIEX_HIGH24] = [NSNumber numberWithDouble:high24];
    poloniexData[POLONIEX_LOW24] = [NSNumber numberWithDouble:low24];
    poloniexData[POLONIEX_HIGH] = [NSNumber numberWithDouble:close];
    poloniexData[POLONIEX_LOW] = [NSNumber numberWithDouble:open];
    poloniexData[POLONIEX_LAST] = [NSNumber numberWithDouble:open];

    // Poloniex liefert ausgerechnete Werte (50% sind halt 50 / 100 = 0.5)
    poloniexData[POLONIEX_PERCENT] = [NSNumber numberWithDouble:(high24 / low24) - 1];

    // BASE ist BTC / Quote ist irgendeine Asset :)
    poloniexData[POLONIEX_BASE_VOLUME] = data[@"volumeto"];
    poloniexData[POLONIEX_QUOTE_VOLUME] = data[@"volumefrom"];

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
