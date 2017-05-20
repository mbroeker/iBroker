//
//  Poloniex.m
//  iBroker
//
//  Created by Markus Bröker on 11.05.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "Brokerage.h"
#include <SystemConfiguration/SystemConfiguration.h>

@implementation Brokerage

/**
 * Allgemeiner jsonRequest Handler
 *
 * @param jsonURL
 *
 * @return NSDictionary*
 */
+ (NSDictionary*)jsonRequest:(NSString*)jsonURL {

    if (![Brokerage isInternetConnection]) {
        return nil;
    }

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
        if (jsonError && !RELEASE_BUILD) {
            // Fehlermeldung wird angezeigt
            NSLog(@"JSON-ERROR for URL %@\n%@", jsonURL, [jsonError description]);
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
+ (NSDictionary*)poloniexTicker:(NSArray*)fiatCurrencies {
    NSString *jsonURL = @"https://poloniex.com/public?command=returnTicker";

    NSMutableDictionary *ticker = [[Brokerage jsonRequest:jsonURL] mutableCopy];

    if (!ticker[@"BTC_XMR"]) {
        NSLog(@"API-ERROR: Cannot retrieve ticker data");

        return nil;
    }

    ticker[@"BTC_EUR"] = [Brokerage bitstampBTCTicker:fiatCurrencies[0]];
    ticker[fiatCurrencies[1]] = @([[Brokerage fiatExchangeRate:fiatCurrencies] doubleValue]);

    return ticker;
}

/**
 * Besorge den Umrechnungsfaktor EUR/USD
 * 
 * @param fiatCurrencies
 *
 * @return NSNumber*
 */
+ (NSNumber*)fiatExchangeRate:(NSArray*)fiatCurrencies {
    NSString *jsonURL =
        [NSString stringWithFormat:@"https://min-api.cryptocompare.com/data/pricemulti?fsyms=%@&tsyms=%@&extraParams=de.4customers.iBroker", fiatCurrencies[0], fiatCurrencies[1]];

    NSDictionary *data = [Brokerage jsonRequest:jsonURL];

    if (!data[fiatCurrencies[0]]) {
        NSLog(@"API-ERROR: Cannot retrieve exchange rates for %@/%@", fiatCurrencies[0], fiatCurrencies[1]);

        return nil;
    }

    return @([data[fiatCurrencies[0]][fiatCurrencies[1]] doubleValue]);
}

/**
 * Besorge den fehlenden BTC-Ticker von bitstamp und fake diesen ins Poloniex-Format
 *
 * @param asset
 *
 * @return NSDictionary*
 */
+ (NSDictionary*)bitstampBTCTicker:(NSString*)asset {
    NSString *jsonURL = [NSString stringWithFormat:@"https://www.bitstamp.net/api/v2/ticker/btc%@/", [asset lowercaseString]];

    NSDictionary *theirData = [Brokerage jsonRequest:jsonURL];

    if (!theirData[@"last"]) {
        NSLog(@"API-ERROR: Cannot retrieve exchange rates for BTC/%@", asset);

        return nil;
    }

    // aktuelle Anfragen und Käufe
    double ask = [theirData[@"ask"] doubleValue];
    double bid = [theirData[@"bid"] doubleValue];

    // 24h Change
    double high24 = [theirData[@"high"] doubleValue];
    double low24 = [theirData[@"low"] doubleValue];

    // aktueller Kurs
    double last = [theirData[@"last"] doubleValue];

    // Heutiger Eröffnungskurs
    double open= [theirData[@"open"] doubleValue];
    double percent = (last / open) - 1;

    NSMutableDictionary *poloniexData = [[NSMutableDictionary alloc] init];

    poloniexData[POLONIEX_HIGH24] = @(high24);
    poloniexData[POLONIEX_LOW24] = @(low24);
    poloniexData[POLONIEX_ASK] = @(ask);
    poloniexData[POLONIEX_BID] = @(bid);
    poloniexData[POLONIEX_LAST] = @(last);

    // Poloniex liefert ausgerechnete Werte (50% sind halt 50 / 100 = 0.5)
    poloniexData[POLONIEX_PERCENT] = @(percent);

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

/**
 * Prüfe, ob es überhaupt eine Netzwerkverbindung gibt
 *
 * @return BOOL
 */
+ (BOOL) isInternetConnection {
    BOOL returnValue = NO;

    struct sockaddr zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sa_len = sizeof(zeroAddress);
    zeroAddress.sa_family = AF_INET;

    SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithAddress(NULL, (const struct sockaddr*)&zeroAddress);

    if (reachabilityRef != NULL) {
        SCNetworkReachabilityFlags flags;

        if(SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
            BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
            BOOL connectionRequired = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
            returnValue = isReachable && !connectionRequired;
        }

        CFRelease(reachabilityRef);
    }

    return returnValue;
}

@end
