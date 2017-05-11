//
//  Poloniex.m
//  iBroker
//
//  Created by Markus Bröker on 11.05.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "Brokerage.h"

@implementation Brokerage

+ (NSDictionary*)poloniexTicker {
    NSString *jsonURL = @"https://poloniex.com/public?command=returnTicker";

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:jsonURL]];
    [request setHTTPMethod:@"GET"];

    __block NSDictionary *result;
    __block BOOL hasFinished = false;

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

        NSData *jsonData = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError;

        id allkeys = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&jsonError];
        if (jsonError) {
            return;
        }

        result = allkeys;

        hasFinished = true;
    }] resume];

    while (!hasFinished) {
        usleep(1000);
    }

    return result;
}

@end
