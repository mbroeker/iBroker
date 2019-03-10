//
//  Calculator.h
//  iBroker
//
// Created by Markus Bröker on 28.04.17.
// Copyright (c) 2017 Markus Bröker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Brokerage.h"
#import "CalculatorConstants.h"

/**
 * Calculator for Crypto Currencies
 *
 * @author      Markus Bröker<broeker.markus@googlemail.com>
 * @copyright   Copyright (C) 2017 4customers UG
 */
@interface Calculator : NSObject

/**
 *
 * @param row unsigned int
 * @param index unsigned int
 * @return NSString*
 */
+ (NSString *)assetString:(unsigned int)row withIndex:(unsigned int)index;

/**
 * Static Constructor implemented as singleton
 *
 * @return id
 */
+ (id)instance;

/**
 * Static Constructor implemented as singleton
 *
 * @param currencies NSArray*
 * @return id
 */
+ (id)instance:(NSArray *)currencies;

/**
 * INTERNAL SWITCH FOR AUTOMATED TRADING
 */
@property BOOL automatedTrading;

/**
 * SELL the current amount of ASSETs back into the MASTER-ASSET (BTC) IF the PROFIT is higher than "wantedEuros"
 *
 * @param wantedEuros double
 */
- (void)sellWithProfitInEuro:(double)wantedEuros;

/**
 * SELL the current amount of ASSETs back into the MASTER-ASSET (BTC) IF the EXCHANGE-RATE is higher than "wantedPercent"
 *
 * @param wantedPercent double
 */
- (void)sellWithProfitInPercent:(double)wantedPercent;

/**
 * SELL the current amount of ASSET's back into the MASTER-ASSET (BTC) IF the INVESTMENT-RATE is higher than "wantedPercent"
 *
 * @param wantedPercent double
 */
- (void)sellByInvestors:(double)wantedPercent;

/**
 * Sell at a daily high
 */
- (void)sellHigh;

/**
 * BUY with the current amount of MASTER-ASSET (BTC) ANY ASSET WITH an EXCHANGE-RATE of "wantedPercent" and an INVESTMENT-RATE greater than "wantedRate"
 *
 * @param wantedPercent double
 * @param wantedRate double
 */
- (void)buyWithProfitInPercent:(double)wantedPercent andInvestmentRate:(double)wantedRate;

/**
 * BUY with the current amount of MASTER-ASSET (BTC) ANY ASSET WITH an investmentRate greater than "wantedRate"
 *
 * @param wantedRate double
 */
- (void)buyByInvestors:(double)wantedRate;

/**
 * BUY with the current amount of MASTER-ASSET (BTC) the ASSET the highest INVESTMENT-RATE
 */
- (void)buyTheBest;

/**
 * BUY with the current amount of MASTER-ASSET (BTC) the ASSET the lowest INVESTMENT-RATE
 */
- (void)buyTheWorst;

/**
 * Buy at a daily low
 */
- (void)buyLow;

- (NSString *)autoBuy:(NSString *)cAsset amount:(double)wantedAmount;

/**
 * BUY a specific ASSET with given parameters and rate and return the orderNumber
 *
 * @param cAsset NSString*
 * @param wantedAmount double
 * @param wantedRate double
 * @return NSString*
 */
- (NSString *)autoBuy:(NSString *)cAsset amount:(double)wantedAmount withRate:(double)wantedRate;

/**
 * SELL a specific ASSET with the given parameters and return the orderNumber
 *
 * @param cAsset NSString*
 * @param wantedAmount double
 * @return NSString*
 */
- (NSString *)autoSell:(NSString *)cAsset amount:(double)wantedAmount;

/**
 * SELL a specific ASSET with the given parameters and "wantedRate" and return the orderNumber
 *
 * @param cAsset NSString*
 * @param wantedAmount double
 * @param wantedRate double
 * @return NSString*
 */
- (NSString *)autoSell:(NSString *)cAsset amount:(double)wantedAmount withRate:(double)wantedRate;

/**
 * BUY the given ASSET with the current amount of MASTER ASSET (BTC) to the current conditions
 *
 * @param cAsset NSString*
 */
- (void)autoBuyAll:(NSString *)cAsset;

/**
 * SELL the current amount of ASSET to the current conditions back into the MASTER-ASSET (BTC)
 *
 * @param cAsset NSString*
 */
- (void)autoSellAll:(NSString *)cAsset;

/**
 * Updates the balances automatically via API-KEY
 *
 * @param synchronized BOOL
 */
- (void)updateBalances:(BOOL)synchronized;

/**
 * Sums up the current balances of all cryptos in Fiat-Money (EUR, USD, GBP, JPY, CNY)
 *
 * @param currency NSString*
 * @return double
 */
- (double)calculate:(NSString *)currency;

/**
 * Sums up the current balances of all cryptos in Fiat-Money (EUR, USD, GBP, JPY, CNY) with specific ratings
 *
 * @param ratings
 * @param currency NSString*
 * @return double
 */
- (double)calculateWithRatings:(NSDictionary *)ratings currency:(NSString *)currency;

/**
 * Calculation of the Price/Volume/Ratio
 *
 * @return NSDictionary*
 */
- (NSDictionary *)realPrices;

/**
 * Calculate the BTC Price for the given ASSET
 *
 * @param asset NSString*
 * @return double
 */
- (double)btcPriceForAsset:(NSString *)asset;

/**
 * Calculate the FIAT Price for the given ASSET with current settings(EUR, USD, GBP, CNY, JPY)
 *
 * @param asset NSString*
 * @return double
 */
- (double)fiatPriceForAsset:(NSString *)asset;

/**
 * Calculate the current exchange factor for the given ASSET in relation to another asset
 *
 * @param asset NSString*
 * @param baseAsset NSString*
 * @return double
 */
- (double)factorForAsset:(NSString *)asset inRelationTo:(NSString *)baseAsset;

/**
 * Update the internal ticker
 *
 * @param synchronized BOOL
 */
- (void)updateRatings:(BOOL)synchronized;

/**
 * SET the current Checkpoint for the given ASSET or all ASSETS(DASHBOARD)
 *
 * @param asset NSString*
 * @param btcUpdate BOOL BOOL
 */
- (void)updateCheckpointForAsset:(NSString *)asset withBTCUpdate:(BOOL)btcUpdate;

/**
 * SET a new Checkpoint for the given ASSET and a specific rate in MASTER-ASSET (BTC)
 *
 * @param asset NSString*
 * @param btcUpdate BOOL BOOL
 * @param wantedRate double
 */
- (void)updateCheckpointForAsset:(NSString *)asset withBTCUpdate:(BOOL)btcUpdate andRate:(double)wantedRate;

/**
 * Get the current amount of an specific ASSET
 *
 * @param asset NSString*
 * @return double
 */
- (double)currentSaldo:(NSString *)asset;

/**
 * SET the current amount of an ASSET to "saldo"
 *
 * @param asset NSString*
 * @param saldo double
 */
- (void)currentSaldo:(NSString *)asset withDouble:(double)saldo;

/**
 * GETTER for an specific ASSET
 *
 * @param label NSString*
 * @return NSString*
 */
- (NSString *)saldoUrlForLabel:(NSString *)label;

/**
 * GET the current CHECKPOINT for an specific ASSET
 *
 * @param asset NSString*
 * @return NSDictionary*
 */
- (NSDictionary *)checkpointForAsset:(NSString *)asset;

/**
 * Retrieve the current checkpoint changes
 *
 * @return NSDictionary*
 */
- (NSDictionary *)checkpointChanges;

/**
 * Replaces internal SALDO Dictionary with "dictionary"
 *
 * @param dictionary
 */
- (void)currentSaldoForDictionary:(NSMutableDictionary *)dictionary;

/**
 * Replaces the internal saldoUrls (ADDRESSES) with "dictionary"
 *
 * @param dictionary
 */
- (void)saldoUrlsForDictionary:(NSMutableDictionary *)dictionary;

/**
 * Replaces the internal "initialRatings" with "dictionary"
 *
 * @param dictionary
 */
- (void)initialRatingsWithDictionary:(NSMutableDictionary *)dictionary;

/**
 * Get the current used exchange
 *
 * @return NSString*
 */
- (NSString *)defaultExchange;

/**
 * SET the exchange to use for further operations
 *
 * @param exchange NSString*
 */
- (void)defaultExchange:(NSString *)exchange;

/**
 * Retrieve the currently active Fiat-Currency-Pair (EUR/USD) or (USD/EUR) ...
 *
 * @return NSArray*
 */
- (NSArray *)fiatCurrencies;

/**
 * Get an editable copy of the currentSaldo
 *
 * @return NSMutableDictionary*
 */
- (NSMutableDictionary *)currentSaldo;

/**
 * Get an editable copy of the current saldoUrls
 *
 * @return NSMutableDictionary*
 */
- (NSMutableDictionary *)saldoUrls;

/**
 * Get an editable copy of the initalRatings
 *
 * @return NSMutableDictionary*
 */
- (NSMutableDictionary *)initialRatings;

/**
 * Get an editable copy of the currentRatings
 *
 * @return NSMutableDictionary*
 */
- (NSMutableDictionary *)currentRatings;

/**
 * Get an editable copy of the current ticker
 *
 * @return NSMutableDictionary*
 */
- (NSMutableDictionary *)ticker;

/**
 * Get a dictionary with the 10 tickerKeys
 *
 * @return NSDictionary*
 */
- (NSDictionary *)tickerKeys;

/**
 * Get a dictionary with the 10 tickerKeysDesc
 *
 * @return NSDictionary*
 */
- (NSDictionary *)tickerKeysDescription;

/**
 * Get the ApiKey
 */
- (NSDictionary *)apiKey;
@end

#import "Calculator+Migration.h"
