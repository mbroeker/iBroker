//
//  Brokerage+JSON.h
//  iBroker
//
//  Created by Markus Bröker on 12.09.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "Brokerage.h"

/**
 * Category for JSON-Interface
 *
 * @author      Markus Bröker<broeker.markus@googlemail.com>
 * @copyright   Copyright (C) 2017 4customers UG
 */
@interface Brokerage (JSON)

/**
 *
 * @param jsonURL NSString*
 * @return NSDictionary*
 */
+ (NSDictionary *)jsonRequest:(NSString *)jsonURL;

/**
 *
 * @param jsonURL NSString*
 * @param payload NSDictionary*
 * @return NSDictionary*
 */
+ (NSDictionary *)jsonRequest:(NSString *)jsonURL withPayload:(NSDictionary *)payload;

/**
 *
 * @param jsonURL NSString*
 * @param payload NSDictionary*
 * @param header NSDictionary*
 * @return NSDictionary*
 */
+ (NSDictionary *)jsonRequest:(NSString *)jsonURL withPayload:(NSDictionary *)payload andHeader:(NSDictionary *)header;

/**
 *
 * @param string NSString*
 * @return NSDictionary*
 */
+ (NSString *)urlStringEncode:(NSString *)string;

/**
 *
 * @param payload NSDictionary*
 * @return NSString*
 */
+ (NSString *)urlEncode:(NSDictionary *)payload;

/**
 * Check for valid internet connection
 *
 * @return BOOL
 */
+ (BOOL)isInternetConnection;

@end
