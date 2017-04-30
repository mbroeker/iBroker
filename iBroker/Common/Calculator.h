//
// Created by Markus Bröker on 28.04.17.
// Copyright (c) 2017 Markus Bröker. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Calculator : NSObject

+ (id)instance;
+ (id)instance:(NSArray*)currencies;

// Umrechnungsmethoden für Crypto-Währungen
- (NSDictionary*)checkpointForUnit:(NSString*)unit;
- (double)calculate:(NSString*)currency;
- (double)calculateWithRatings:(NSDictionary*)ratings currency:(NSString *)currency;

// Methoden fürs Aktualisieren der Wechselkurse und zum Updaten dieser
- (void)updateRatings;
- (void)checkPointForKey:(NSString*)key withBTCUpdate:(BOOL) btcUpdate;

// Methoden für das Aktualisieren des Saldos
- (double)currentSaldo:(NSString*)cUnit;
- (void)currentSaldo:(NSString*)cUnit withDouble:(double) saldo;

// Getter für einen spezifischen Saldo
- (NSString*)saldoUrlForLabel:(NSString*)label;

// Setter für die jeweiligen Dictionaries
- (void)currentSaldoForDictionary:(NSMutableDictionary*)dictionary withUpdate:(BOOL)update;
- (void)saldoUrlsForDictionary:(NSMutableDictionary*)dictionary withUpdate:(BOOL)update;
- (void)initialRatingsWithDictionary:(NSMutableDictionary*)dictionary withUpdate:(BOOL)update;

// die aktuellen Fiat-Währungen
- (NSArray*)fiatCurrencies;

// Getter für die Dictionaries
- (NSMutableDictionary*)currentSaldo;
- (NSMutableDictionary*)saldoUrls;
- (NSMutableDictionary*)initialRatings;
- (NSMutableDictionary*)currentRatings;
@end