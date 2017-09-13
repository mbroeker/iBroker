//
//  iBrokerTests.m
//  iBrokerTests
//
//  Created by Markus Bröker on 12.09.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../iBroker/Common/Calculator.h"
#import "../iBroker/Common/KeychainWrapper.h"

@interface iBrokerTests : XCTestCase
    @property Calculator *calculator;
@end

@implementation iBrokerTests

- (void)setUp {
    [super setUp];

    self.calculator = [Calculator instance];
}

- (void)tearDown {
    [super tearDown];

    [Calculator reset];
}

/**
 * Check TickerStatus and Key Mappings on Poloniex
 *
 */
- (void)testPoloniexTicker {
    NSDictionary *result = [Brokerage poloniexTicker:@[EUR, USD]];
    NSArray *tickerKeys = [self.calculator.tickerKeys allValues];

    NSLog(@"Testing all Ticker Keys on Poloniex");
    for (id key in tickerKeys) {
        if ([key isEqualToString:[NSString stringWithFormat:@"%@_%@", ASSET1, EUR]]) {
            continue;
        }

        XCTAssertNotNil(result[key], @"Key %@ is missing", key);
    }
}

/**
 * Check TickerStatus and Key Mappings on Bittrex
 *
 */
- (void)testBittrexTicker {
    NSDictionary *result = [Brokerage bittrexTicker:@[EUR, USD] forAssets:[self.calculator.tickerKeys allKeys]];
    NSArray *tickerKeys = [self.calculator.tickerKeys allValues];

    NSLog(@"Testing all Ticker Keys on Bittrex");
    for (id key in tickerKeys) {
        if ([key isEqualToString:[NSString stringWithFormat:@"%@_%@", ASSET1, EUR]]) {
            continue;
        }

        XCTAssertNotNil(result[key], @"Key %@ is missing", key);
    }
}

/**
 * Check Keychain Management
 *
 */
- (void)testKeychain {
    // Create a TEST API-KEY AND CHECK the presence
    [KeychainWrapper createKeychainValue:@"key:secret" forIdentifier:@"TEST"];
    NSDictionary *test = [KeychainWrapper keychain2ApiKeyAndSecret:@"TEST"];
    XCTAssertNotNil(test, @"INVALID API-KEY");

    // Delete the Test API-KEY AND CHECK the removal
    [KeychainWrapper deleteItemFromKeychainWithIdentifier:@"TEST"];
    test = [KeychainWrapper keychain2ApiKeyAndSecret:@"TEST"];
    XCTAssertNil(test, @"API-KEY WAS NOT DELETED");
}

/**
 * Check Balances and Number of ASSETS
 */
- (void)testCurrentBalance {
    [self.calculator updateBalances:true];

    XCTAssert([[self.calculator currentSaldo] count] == 10, @"NUMBER OF ASSETS != 10");
}

@end
