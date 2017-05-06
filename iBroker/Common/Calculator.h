//
// Created by Markus Bröker on 28.04.17.
// Copyright (c) 2017 Markus Bröker. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BTC @"BTC"
#define ETH @"ETH"
#define XMR @"XMR"
#define LTC @"LTC"
#define DOGE @"DOGE"

#define ZEC @"ZEC"
#define DASH @"DASH"
#define XRP @"XRP"

#define EUR @"EUR"
#define USD @"USD"

#define KEY_INITIAL_RATINGS @"initialRatings"
#define KEY_CURRENT_SALDO @"currentSaldo"
#define KEY_SALDO_URLS @"saldoUrls"

#define KEY_INITIAL_PRICE @"initialPrice"
#define KEY_CURRENT_PRICE @"currentPrice"
#define KEY_EFFECTIVE_PRICE @"effectivePrice"
#define KEY_PERCENT @"percent"

@interface Calculator : NSObject

+ (id)instance;
+ (id)instance:(NSArray*)currencies;

+ (void)reset;

// Umrechnungsmethoden für Crypto-Währungen
- (double)calculate:(NSString*)currency;
- (double)calculateWithRatings:(NSDictionary*)ratings currency:(NSString *)currency;

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
@end