//
// Created by Markus Bröker on 28.04.17.
// Copyright (c) 2017 Markus Bröker. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Calculator : NSObject

+ (id)instance;

// Umrechnungsmethoden für Crypto-Währungen
- (NSDictionary*)unitsAndPercent:(NSString*)unit;
- (double)calculate:(NSString*)currency;
- (double)calculateWithRatings:(NSDictionary*)ratings currency:(NSString *)currency;

// Methoden fürs Aktualisieren der Wechselkurse und zum Updaten dieser
- (void)updateRatings;
- (void)checkPointForKey:(NSString*)key;
- (void)waitForUpdateRatings;

- (NSMutableDictionary*)currentSaldo;
- (double)currentSaldo:(NSString*)unit;
- (void)currentSaldoForUnit:(NSString*)cUnit withDouble:(double) saldo;
- (NSString*)saldoUrlForLabel:(NSString*)label;

- (NSMutableDictionary*)initialRatings;
- (NSMutableDictionary*)currentRatings;
@end