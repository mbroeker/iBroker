//
//  Poloniex.m
//  iBroker
//
//  Created by Markus Bröker on 11.05.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "Brokerage.h"
#import "Helper.h"

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

        id allkeys = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&jsonError];
        if (jsonError) {
            // Fehlermeldung wird angezeigt
            NSLog(@"%@", [jsonError description]);

            // Deadlocks vermeiden
            hasFinished = true;

            return;
        }
        
        result = allkeys;

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
 * Besorge die Kurse von cryptocompare per JSON-Request und speichere Sie in den App-Einstellungen
 */
+ (NSDictionary*)cryptoCompareRatings:(NSArray*)fiatCurrencies {
    NSString *jsonURL =
        [NSString stringWithFormat:@"https://min-api.cryptocompare.com/data/pricemulti?fsyms=%@&tsyms=%@,BTC,ETH,LTC,XMR,DOGE,ZEC,DASH,XRP", fiatCurrencies[0], fiatCurrencies[1]];
    
    return [Brokerage jsonRequest:jsonURL];
}

/**
 * Hilfsmethode, da der Kurs bei Cryptocompare ewig falsch ist.
 *
 * @return double
 */
+ (double) cryptonatorsDogUpdate:(NSArray*)fiatCurrencies {
    NSString *jsonURL =
        [NSString stringWithFormat:@"https://api.cryptonator.com/api/ticker/doge-%@", [fiatCurrencies[0] lowercaseString]];
    
    NSDictionary *result = [Brokerage jsonRequest:jsonURL];
    double dogePrice = 1 / [result[@"ticker"][@"price"] doubleValue];
    
    return dogePrice;
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
