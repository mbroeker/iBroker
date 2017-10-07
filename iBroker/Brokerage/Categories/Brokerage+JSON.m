//
//  Brokerage+JSON.m
//  iBroker
//
//  Created by Markus Bröker on 12.09.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "Brokerage+JSON.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation Brokerage (JSON)

/**
 * Allgemeiner jsonRequest Handler
 *
 * @param jsonURL
 * @return NSDictionary*
 */
+ (NSDictionary *)jsonRequest:(NSString *)jsonURL {
    return [Brokerage jsonRequest:jsonURL withPayload:nil andHeader:nil];
}

/**
 * Allgemeiner jsonRequest Handler mit Payload
 *
 * @param jsonURL
 * @param payload
 * @return NSDictionary*
 */
+ (NSDictionary *)jsonRequest:(NSString *)jsonURL withPayload:(NSDictionary *)payload {
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
+ (NSDictionary *)jsonRequest:(NSString *)jsonURL withPayload:(NSDictionary *)payload andHeader:(NSDictionary *)header {
    NSDebug(@"Brokerage::jsonRequest:%@ withPayload:... andHeader:...", jsonURL);

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    [request setHTTPMethod:(payload == nil) ? @"GET" : @"POST"];
    [request setURL:[NSURL URLWithString:jsonURL]];

    if (header != nil) {
        for (id field in header) {
            [request setValue:header[field] forHTTPHeaderField:field];
        }
    }

    if (payload != nil) {
        NSString *payloadAsString = [Brokerage urlEncode:payload];
        NSData *data = [payloadAsString dataUsingEncoding:NSASCIIStringEncoding];

        [request setHTTPBody:data];
    }

    __block NSMutableDictionary *result;
    __block dispatch_semaphore_t lock = dispatch_semaphore_create(0);

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

        dispatch_semaphore_signal(lock);

    }] resume];

    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    return result;
}

/**
 * Simpler Text Encoder
 *
 * @param string
 */
+ (NSString *)urlStringEncode:(NSString *)string {
    NSDebug(@"Brokerage::urlStringEncode:%@", string);

    return [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

/**
 * Simpler URL-Encoder
 *
 * @param payload
 * @return NSString*
 */
+ (NSString *)urlEncode:(NSDictionary *)payload {
    NSDebug(@"Brokerage::urlEncode:%@", payload);

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
 * Prüfe, ob es überhaupt eine Netzwerkverbindung gibt
 *
 * @return BOOL
 */
+ (BOOL)isInternetConnection {
    NSDebug(@"Brokerage::isInternetConnection");

    BOOL returnValue = NO;

    struct sockaddr zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sa_len = sizeof(zeroAddress);
    zeroAddress.sa_family = AF_INET;

    SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithAddress(NULL, (const struct sockaddr *) &zeroAddress);

    if (reachabilityRef != NULL) {
        SCNetworkReachabilityFlags flags;

        if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
            BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
            BOOL connectionRequired = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
            returnValue = isReachable && !connectionRequired;
        }

        CFRelease(reachabilityRef);
    }

    return returnValue;
}

@end
