//
// Created by Markus Bröker on 28.04.17.
// Copyright (c) 2017 Markus Bröker. All rights reserved.
//

#import "Calculator.h"
#import "Algorithm.h"

/**
 * Berechnungklasse für Crypto-Währungen
 */
@implementation Calculator {
    // Synchronisierte Einstellungen und Eigenschaften
    NSMutableDictionary *initialRatings;
    NSMutableDictionary *currentSaldo;
    NSMutableDictionary *saldoUrls;

    // Normale Eigenschaften
    NSMutableDictionary *currentRatings;
    NSMutableDictionary *ticker;

    NSArray *fiatCurrencies;
}

/**
 * Der öffentliche Konstruktor mit Vorbelegung EUR/USD
 */
+ (id)instance {
    return [self instance:@[EUR, USD]];
}

/**
 * Der öffentliche Konstruktor als statisches Singleton mit wählbaren Fiat-Währungen
 */
+ (id)instance:(NSArray*)currencies {
    static Calculator *calculator = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        calculator = [[Calculator alloc] initWithFiatCurrencies:currencies];
    });

    return calculator;
}

/**
 * Der Standard Konstruktor
 */
- (id)init {
    return [self initWithFiatCurrencies:@[EUR, USD]];
}

/**
 * Der private Konstruktor der Klasse, der deswegen nicht in Calculator.h gelistet wird.
 *
 */
- (id)initWithFiatCurrencies:(NSArray*)currencies {

    if (self = [super init]) {

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        currentSaldo = [[defaults objectForKey:KEY_CURRENT_SALDO] mutableCopy];

        fiatCurrencies = currencies;

        if (currentSaldo == NULL) {
            currentSaldo = [@{
                BTC: @0.0,
                ETH: @0.0,
                LTC: @0.0,
                XMR: @0.0,
                DOGE: @0.0,
            } mutableCopy];

            [defaults setObject:currentSaldo forKey:KEY_CURRENT_SALDO];
        }

        saldoUrls = [defaults objectForKey:KEY_SALDO_URLS];

        if (saldoUrls == NULL) {
            saldoUrls = [@{
                @"Dashboard": @"https://poloniex.com/exchange#btc_xmr",
                @"Bitcoin": @"https://blockchain.info/",
                @"Ethereum": @"https://etherscan.io/",
                @"Litecoin": @"https://chainz.cryptoid.info/ltc/",
                @"Monero": @"https://moneroblocks.info",
                @"Dogecoin": @"http://dogechain.info/",
            } mutableCopy];

            [defaults setObject:saldoUrls forKey:KEY_SALDO_URLS];
        }

        [defaults synchronize];
        [self updateRatings];
    }

    return self;
}

/**
 * Statische Reset-Methode zum Abräumen
 *
 */
+ (void)reset {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults removeObjectForKey:KEY_SALDO_URLS];
    [defaults removeObjectForKey:KEY_CURRENT_SALDO];
    [defaults removeObjectForKey:KEY_INITIAL_RATINGS];

    [defaults synchronize];
}

/**
 * Aktualisiere die Kurse der jeweiligen Währung
 *
 * @param asset
 * @param btcUpdate
 */
- (void)updateCheckpointForAsset:(NSString *)asset withBTCUpdate:(BOOL) btcUpdate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([asset isEqualToString:@"ALL"]) {
        initialRatings = [currentRatings mutableCopy];
    } else {
        // aktualisiere den Kurs der Währung
        initialRatings[asset] = currentRatings[asset];

        if (![asset isEqualToString:BTC] && btcUpdate) {
            // aktualisiere den BTC Kurs, auf den sich die Transaktion bezog
            initialRatings[BTC] = currentRatings[BTC];
        }
    }

    [defaults setObject:initialRatings forKey:KEY_INITIAL_RATINGS];
    [defaults synchronize];
}

/**
 * Liefert NSDictionary mit den Schlüsseln "initialPrice", "currentPrice", "percent", "effectivePrice"
 *
 * @param asset
 * @return NSDictionary*
 */
- (NSDictionary*)checkpointForAsset:(NSString*)asset {
    double initialPrice = 1.0 / [initialRatings[asset] doubleValue];
    double currentPrice = 1.0 / [currentRatings[asset] doubleValue];

    double percent = 100.0 * ((currentPrice / initialPrice) - 1);

    return @{
        KEY_INITIAL_PRICE: @(initialPrice),
        KEY_CURRENT_PRICE: @(currentPrice),
        KEY_PERCENT: @(percent),
        KEY_EFFECTIVE_PRICE: @((1 + percent / 100.0) * currentPrice)
    };
}

/**
 * Berechne den Gesamtwert der Geldbörsen in Euro oder Dollar...
 *
 * @param currency
 * @return double
 */
- (double)calculate:(NSString *)currency {
    return [self calculateWithRatings:currentRatings currency:currency];
}

/**
 * Berechne den Gesamtwert der Geldbörsen in Euro oder Dollar mit den übergebenen Ratings
 *
 * @param ratings
 * @param currency
 * @return double
 */
- (double)calculateWithRatings:(NSDictionary*)ratings currency:(NSString *)currency {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    currentSaldo = [[defaults objectForKey:KEY_CURRENT_SALDO] mutableCopy];

    double btc = [currentSaldo[BTC] doubleValue] / [ratings[BTC] doubleValue];
    double eth = [currentSaldo[ETH] doubleValue] / [ratings[ETH] doubleValue];
    double ltc = [currentSaldo[LTC] doubleValue] / [ratings[LTC] doubleValue];
    double xmr = [currentSaldo[XMR] doubleValue] / [ratings[XMR] doubleValue];
    double doge = [currentSaldo[DOGE] doubleValue] / [ratings[DOGE] doubleValue];

    double sum = btc + eth + ltc + xmr + doge;

    if ([currency isEqualToString:fiatCurrencies[0]]) {
        return sum;
    }

    return sum * [ratings[currency] doubleValue];
}

/**
 * synchronisierter Block, der garantiert, dass es nur ein Update gibt
 */
- (void)updateRatings {

    @synchronized (self) {
        [self unsynchronizedUpdateRatings];
    }
}

/**
 * Besorge die Kurse von cryptocompare per JSON-Request und speichere Sie in den App-Einstellungen
 */
- (void)unsynchronizedUpdateRatings {

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *allkeys = [Brokerage cryptoCompareRatings:fiatCurrencies];

        if (allkeys != NULL) {
            currentRatings = [allkeys[fiatCurrencies[0]] mutableCopy];
            initialRatings = [[defaults objectForKey:KEY_INITIAL_RATINGS] mutableCopy];

            // DOGE RATINGS aktualisieren, da dieser WS das nicht kann.
            double dogeValue = [Brokerage cryptonatorsDogUpdate:fiatCurrencies];
            currentRatings[DOGE] = [NSString stringWithFormat:@"%.8f", dogeValue];

            if (initialRatings == NULL) {
                [self initialRatingsWithDictionary:currentRatings];
            }

            NSDictionary *poloniexTicker = [Brokerage poloniexTicker];
            if (poloniexTicker != NULL) {
                ticker = [poloniexTicker mutableCopy];
            }
        }

        [defaults synchronize];
}

/**
 * Liefert den aktuellen Saldo der jeweiligen Crypto-Währung
 *
 * @param asset
 * @return double
 */
- (double)currentSaldo:(NSString*)asset {
    return [currentSaldo[asset] doubleValue];
}

/**
 * Liefert die aktuelle URL für das angegebene Label/Tab
 *
 * @param label
 * @return NSString*
 */
- (NSString*)saldoUrlForLabel:(NSString*)label {
    return saldoUrls[label];
}

/**
 * Aktualisiert den aktuellen Saldo für die CryptoWährung "asset" mit dem Wert "saldo"
 *
 * @param asset
 * @param saldo
 */
- (void)currentSaldo:(NSString*)asset withDouble: (double) saldo {
    currentSaldo[asset] = [[NSNumber alloc] initWithDouble:saldo];

    [self currentSaldoForDictionary:currentSaldo];
}

/**
 * Ersetzt die aktuellen Saldo mit den Werten aus dem Dictionary
 *
 * @param dictionary
 */
- (void)currentSaldoForDictionary:(NSMutableDictionary*)dictionary {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:dictionary forKey:KEY_CURRENT_SALDO];
    [defaults synchronize];

    currentSaldo = [dictionary mutableCopy];
}

/**
 * Ersetzt die aktuellen saldoUrls mit den Werten aus dem Dictionary
 *
 * @param dictionary
 */
- (void)saldoUrlsForDictionary:(NSMutableDictionary*)dictionary {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:dictionary forKey:KEY_SALDO_URLS];
    [defaults synchronize];

    saldoUrls = [dictionary mutableCopy];
}

/**
 * Ersetzt die aktuellen initialRatings mit den Werten aus dem Dictionary
 *
 * @param dictionary
 */
- (void)initialRatingsWithDictionary:(NSMutableDictionary*)dictionary {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:dictionary forKey:KEY_INITIAL_RATINGS];
    [defaults synchronize];

    initialRatings = [dictionary mutableCopy];
}

/**
 * Liefert die aktuellen Fiat-Währungen
 *
 * @return NSString*
 */
- (NSArray*)fiatCurrencies {
    return fiatCurrencies;
}

/**
 * Getter für currentSaldo
 *
 * @return NSMutableDictionary*
 */
- (NSMutableDictionary*)currentSaldo {
    return [currentSaldo mutableCopy];
}

/**
 * Getter für das saldoUrls
 *
 * @return NSMutableDictionary*
 */
- (NSMutableDictionary*)saldoUrls {
    return [saldoUrls mutableCopy];
}

/**
 * Getter für initialRatings
 *
 * @return NSMutableDictionary*
 */
- (NSMutableDictionary*)initialRatings {
    return [initialRatings mutableCopy];
}

/**
 * Getter für currentRatings
 *
 * @return NSMutableDictionary*
 */
- (NSMutableDictionary*)currentRatings {
    return [currentRatings mutableCopy];
}

- (NSMutableDictionary*)ticker {
    return [ticker mutableCopy];
}

@end
