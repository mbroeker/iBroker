//
// Created by Markus Bröker on 28.04.17.
// Copyright (c) 2017 Markus Bröker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Brokerage.h"
#import "CalculatorConstants.h"

@interface Calculator : NSObject

+ (id)instance;
+ (id)instance:(NSArray*)currencies;

+ (void)reset;

// Umrechnungsmethoden für Crypto-Währungen
- (double)calculate:(NSString*)currency;
- (double)calculateWithRatings:(NSDictionary*)ratings currency:(NSString *)currency;
- (NSDictionary*)realPrices;

// Methoden fürs Aktualisieren der Wechselkurse und zum Updaten dieser
- (void)updateRatings;
- (void)updateCheckpointForAsset:(NSString *)asset withBTCUpdate:(BOOL) btcUpdate;

// Methoden für das Aktualisieren des Saldos
- (double)currentSaldo:(NSString*)asset;
- (void)currentSaldo:(NSString*)asset withDouble:(double) saldo;

// Getter für einen spezifischen Saldo
- (NSString*)saldoUrlForLabel:(NSString*)label;

// Setter für die jeweiligen Dictionaries
- (NSDictionary*)checkpointForAsset:(NSString*)asset;
- (NSDictionary*)checkpointChanges;
- (void)currentSaldoForDictionary:(NSMutableDictionary*)dictionary;
- (void)saldoUrlsForDictionary:(NSMutableDictionary*)dictionary;
- (void)initialRatingsWithDictionary:(NSMutableDictionary*)dictionary;

// die aktuellen Fiat-Währungen
- (NSArray*)fiatCurrencies;

// Getter für die Dictionaries
- (NSMutableDictionary*)currentSaldo;
- (NSMutableDictionary*)saldoUrls;
- (NSMutableDictionary*)initialRatings;
- (NSMutableDictionary*)currentRatings;
- (NSMutableDictionary*)ticker;
- (NSDictionary*)tickerKeys;
@end