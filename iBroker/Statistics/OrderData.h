//
//  OrderData.h
//  iBroker
//
//  Created by Markus Bröker on 26.09.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Entity for openOrders Table
 *
 * @author      Markus Bröker<broeker.markus@googlemail.com>
 * @copyright   Copyright (C) 2017 4customers UG
 */
@interface OrderData : NSObject
@property(nonatomic, copy) NSString *orderId;
@property(nonatomic, copy) NSString *date;
@property(nonatomic, copy) NSString *pair;
@property(nonatomic, copy) NSString *amount;
@property(nonatomic, copy) NSString *rate;

/**
 *
 * @param data NSArray*
 * @return id
 */
- (id)initWithArray:(NSArray *)data;

/**
 *
 * @return NSArray*
 */
+ (NSArray *)fetchOrderData;

/**
 *
 * @return BOOL
 */
- (BOOL)cancelOrder;

@end
