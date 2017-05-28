//
//  Poloniex.m
//  iBroker
//
//  Created by Markus Bröker on 11.05.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "Brokerage.h"
#import <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#include <SystemConfiguration/SystemConfiguration.h>

@implementation Brokerage

/**
 * Allgemeiner jsonRequest Handler
 *
 * @param jsonURL
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
 * Allgemeiner jsonRequest Handler mit Payload
 *
 * @param jsonURL
 * @param payload
 * @return NSDictionary*
 */
+ (NSDictionary*)jsonRequest:(NSString*)jsonURL withPayload:(NSDictionary*)payload {
    return [Brokerage jsonRequest:jsonURL withPayload:payload andHeader:nil];
}

/**
 * Allgemeiner jsonRequest Handler mit Payload und Header
 *
 * @param jsonURL
 * @param payload
 * @param header
 *
 * @return NSDictionary*
 */
+ (NSDictionary*)jsonRequest:(NSString*)jsonURL withPayload:(NSDictionary*)payload andHeader:(NSDictionary*)header {

    if (![Brokerage isInternetConnection]) {
        return nil;
    }

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    [request setHTTPMethod:@"POST"];
    [request setURL:[NSURL URLWithString:jsonURL]];

    for (id field in header) {
        [request setValue:header[field] forHTTPHeaderField:field];
    }

    NSString *payloadAsString = [Brokerage urlEncode:payload];
    NSData *data = [payloadAsString dataUsingEncoding:NSASCIIStringEncoding];

    [request setHTTPBody:data];

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
 * Request the balance from poloniex via API-Key
 *
 * @param apikey
 * @param secret
 * returns NSDictionary*
 */
+ (NSDictionary*)balance:(NSDictionary*)apikey withSecret:(NSString*)secret {
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

    return [Brokerage jsonRequest:jsonURL withPayload:payload andHeader:header];
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
+ (NSDictionary*)buy:(NSDictionary*)apikey withSecret:(NSString*)secret currencyPair:(NSString*)currencyPair rate:(double)rate amount:(double)amount {
    NSString *jsonURL = @"https://poloniex.com/tradingApi";

    if ([secret isEqualToString:@""]) {
        return nil;
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
+ (NSDictionary*)sell:(NSDictionary*)apikey withSecret:(NSString*)secret currencyPair:(NSString*)currencyPair rate:(double)rate amount:(double)amount {
    NSString *jsonURL = @"https://poloniex.com/tradingApi";

    if ([secret isEqualToString:@""]) {
        return nil;
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

/**
 * HMAC SHA512
 */
+ (NSString *)hmac:(NSString *)plainText withSecret:(NSString*)secret {
    const char *cKey  = [secret cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [plainText cStringUsingEncoding:NSASCIIStringEncoding];

    unsigned char cHMAC[CC_SHA512_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA512, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    NSData *HMACData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];

    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    NSString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];

    for (int i = 0; i < HMACData.length; ++i)
        HMAC = [HMAC stringByAppendingFormat:@"%02lx", (unsigned long)buffer[i]];

    return HMAC;
}

/**
 * SHA512
 *
 * @param input
 * @return NSString*
 */
+ (NSString *)sha512:(NSString *)input {
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];

    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);

    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];

    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }

    return output;
}

/**
 * Simpler URL-Encoder
 *
 * @param payload
 * @return NSString*
 */
+ (NSString*)urlEncode:(NSDictionary*)payload {
    NSMutableString *str = [@"" mutableCopy];

    for (id key in payload) {
        if (![str isEqualToString:@""]) {
            [str appendString:@"&"];
        }

        [str appendString:[NSString stringWithFormat:@"%@=%@", key, payload[key]]];
    }

    return str;
}

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
        NSLog(@"API-ERROR: Cannot retrieve ticker data");

        return nil;
    }

    NSDictionary *btcTicker = [Brokerage bitstampBTCTicker:fiatCurrencies[0]];

    if (!btcTicker) {
        return nil;
    }

    NSNumber *exchangeRate = [Brokerage fiatExchangeRate:fiatCurrencies];

    if (!exchangeRate) {
        return nil;
    }

    ticker[@"BTC_EUR"] = btcTicker;
    ticker[fiatCurrencies[1]] = @([exchangeRate doubleValue]);

    return ticker;
}

/**
 * Besorge den Umrechnungsfaktor EUR/USD
 * 
 * @param fiatCurrencies
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
