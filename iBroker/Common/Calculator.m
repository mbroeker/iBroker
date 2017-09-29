//
//  Calculator.m
//  iBroker
//
// Created by Markus Bröker on 28.04.17.
// Copyright (c) 2017 Markus Bröker. All rights reserved.
//

#import "Calculator.h"
#import "Helper.h"
#import "KeychainWrapper.h"

#import <dispatch/dispatch.h>

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

    // Die wählbare Fiatwährung
    NSArray *fiatCurrencies;

    // Die dynamischen TickerKeys
    NSDictionary *tickerKeys;

    // Die standardmäßige Börse
    NSString *defaultExchange;

    // Mit oder ohne Abfrage
    NSNumber *tradingWithConfirmation;
}

/**
 * Der öffentliche Konstruktor mit Vorbelegung EUR/USD
 *
 * @return id
 */
+ (id)instance {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSArray *fc = [defaults objectForKey:KEY_FIAT_CURRENCIES];

    // Vorbelegung mit EUR/USD
    if (fc == nil) {
        fc = @[EUR, USD];
    }

    return [self instance:fc];
}

/**
 * Der öffentliche Konstruktor als statisches Singleton mit wählbaren Fiat-Währungen
 *
 * @param currencies
 * @return id
 */
+ (id)instance:(NSArray *)currencies {
    static Calculator *calculator = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        calculator = [[Calculator alloc] initWithFiatCurrencies:currencies];
    });

    return calculator;
}

/**
 * Der Standard Konstruktor mit Vorbelegung EUR/USD
 *
 * @return id
 */
- (id)init {
    return [self initWithFiatCurrencies:@[EUR, USD]];
}

/**
 * Der private Konstruktor der Klasse, der deswegen nicht in Calculator.h gelistet wird.
 *
 * @param currencies
 * @return id
 */
- (id)initWithFiatCurrencies:(NSArray *)currencies {

    if (self = [super init]) {

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        currentSaldo = [[defaults objectForKey:KEY_CURRENT_SALDO] mutableCopy];

        fiatCurrencies = currencies;

        if (currentSaldo == nil) {
            currentSaldo = [@{
                ASSET1: @0.0,
                ASSET2: @0.0,
                ASSET3: @0.0,
                ASSET4: @0.0,
                ASSET5: @0.0,
                ASSET6: @0.0,
                ASSET7: @0.0,
                ASSET8: @0.0,
                ASSET9: @0.0,
                ASSET10: @0.0,
            } mutableCopy];

            [defaults setObject:currentSaldo forKey:KEY_CURRENT_SALDO];
        }

        saldoUrls = [[defaults objectForKey:KEY_SALDO_URLS] mutableCopy];

        if (saldoUrls == nil) {
            saldoUrls = [@{
                DASHBOARD: [NSString stringWithFormat:@"https://coinmarketcap.com/gainers-losers/"],
                ASSET1_DESC: [NSString stringWithFormat:@"https://coinmarketcap.com/exchanges/"],
                ASSET2_DESC: [NSString stringWithFormat:@"https://chainz.cryptoid.info/%@/", ASSET2.lowercaseString],
                ASSET3_DESC: [NSString stringWithFormat:@"https://chainz.cryptoid.info/%@/", ASSET3.lowercaseString],
                ASSET4_DESC: [NSString stringWithFormat:@"https://chainz.cryptoid.info/%@/", ASSET4.lowercaseString],
                ASSET5_DESC: [NSString stringWithFormat:@"https://chainz.cryptoid.info/%@/", ASSET5.lowercaseString],
                ASSET6_DESC: [NSString stringWithFormat:@"https://chainz.cryptoid.info/%@/", ASSET6.lowercaseString],
                ASSET7_DESC: [NSString stringWithFormat:@"https://chainz.cryptoid.info/%@/", ASSET7.lowercaseString],
                ASSET8_DESC: [NSString stringWithFormat:@"https://chainz.cryptoid.info/%@/", ASSET8.lowercaseString],
                ASSET9_DESC: [NSString stringWithFormat:@"https://chainz.cryptoid.info/%@/", ASSET9.lowercaseString],
                ASSET10_DESC: [NSString stringWithFormat:@"https://chainz.cryptoid.info/%@/", ASSET10.lowercaseString],
            } mutableCopy];

            [defaults setObject:saldoUrls forKey:KEY_SALDO_URLS];
        }

        tickerKeys = @{
            ASSET1: [NSString stringWithFormat:@"%@_%@", ASSET1, fiatCurrencies[0]],
            ASSET2: [NSString stringWithFormat:@"%@_%@", ASSET1, ASSET2],
            ASSET3: [NSString stringWithFormat:@"%@_%@", ASSET1, ASSET3],
            ASSET4: [NSString stringWithFormat:@"%@_%@", ASSET1, ASSET4],
            ASSET5: [NSString stringWithFormat:@"%@_%@", ASSET1, ASSET5],
            ASSET6: [NSString stringWithFormat:@"%@_%@", ASSET1, ASSET6],
            ASSET7: [NSString stringWithFormat:@"%@_%@", ASSET1, ASSET7],
            ASSET8: [NSString stringWithFormat:@"%@_%@", ASSET1, ASSET8],
            ASSET9: [NSString stringWithFormat:@"%@_%@", ASSET1, ASSET9],
            ASSET10: [NSString stringWithFormat:@"%@_%@", ASSET1, ASSET10],
        };

        defaultExchange = [defaults objectForKey:@"defaultExchange"];

        if (defaultExchange == nil) {
            defaultExchange = EXCHANGE_BITTREX;

            [defaults setObject:defaultExchange forKey:@"defaultExchange"];
        }

        tradingWithConfirmation = [defaults objectForKey:KEY_TRADING_WITH_CONFIRMATION];

        if (tradingWithConfirmation == nil) {
            tradingWithConfirmation = [NSNumber numberWithBool:true];

            [defaults setObject:tradingWithConfirmation forKey:KEY_TRADING_WITH_CONFIRMATION];
        }

        [defaults synchronize];

        // Migration älterer Installationen
        [self upgradeAssistant];

        [self updateRatings:true];
    }

    return self;
}

/**
 * simpler Upgrade Assistent
 */
- (void)upgradeAssistant {
    BOOL mustUpdate = false;

    if (!saldoUrls[DASHBOARD]) {
        saldoUrls[DASHBOARD] = @"https://coinmarketcap.com/gainers-losers/";

        mustUpdate = true;
    }

    if (!saldoUrls[ASSET1_DESC]) {
        saldoUrls[ASSET1_DESC] = @"https://coinmarketcap.com/exchanges/";

        currentSaldo[ASSET1] = @0.0;
        initialRatings[ASSET1] = @0.0;

        mustUpdate = true;
    }

    if (!saldoUrls[ASSET2_DESC]) {
        saldoUrls[ASSET2_DESC] = [NSString stringWithFormat:@"https://chainz.cryptoid.info/%@/", ASSET2.lowercaseString];

        currentSaldo[ASSET2] = @0.0;
        initialRatings[ASSET2] = @0.0;

        mustUpdate = true;
    }

    if (!saldoUrls[ASSET3_DESC]) {
        saldoUrls[ASSET3_DESC] = [NSString stringWithFormat:@"https://chainz.cryptoid.info/%@/", ASSET3.lowercaseString];

        currentSaldo[ASSET3] = @0.0;
        initialRatings[ASSET3] = @0.0;

        mustUpdate = true;
    }

    if (!saldoUrls[ASSET4_DESC]) {
        saldoUrls[ASSET4_DESC] = [NSString stringWithFormat:@"https://chainz.cryptoid.info/%@/", ASSET4.lowercaseString];

        currentSaldo[ASSET4] = @0.0;
        initialRatings[ASSET4] = @0.0;

        mustUpdate = true;
    }

    if (!saldoUrls[ASSET5_DESC]) {
        saldoUrls[ASSET5_DESC] = [NSString stringWithFormat:@"https://chainz.cryptoid.info/%@/", ASSET5.lowercaseString];

        currentSaldo[ASSET5] = @0.0;
        initialRatings[ASSET5] = @0.0;

        mustUpdate = true;
    }

    if (!saldoUrls[ASSET6_DESC]) {
        saldoUrls[ASSET6_DESC] = [NSString stringWithFormat:@"https://chainz.cryptoid.info/%@/", ASSET6.lowercaseString];

        currentSaldo[ASSET6] = @0.0;
        initialRatings[ASSET6] = @0.0;

        mustUpdate = true;
    }

    if (!saldoUrls[ASSET7_DESC]) {
        saldoUrls[ASSET7_DESC] = [NSString stringWithFormat:@"https://chainz.cryptoid.info/%@/", ASSET7.lowercaseString];

        currentSaldo[ASSET7] = @0.0;
        initialRatings[ASSET7] = @0.0;

        mustUpdate = true;
    }

    if (!saldoUrls[ASSET8_DESC]) {
        saldoUrls[ASSET8_DESC] = [NSString stringWithFormat:@"https://chainz.cryptoid.info/%@/", ASSET8.lowercaseString];

        currentSaldo[ASSET8] = @0.0;
        initialRatings[ASSET8] = @0.0;

        mustUpdate = true;
    }

    if (!saldoUrls[ASSET9_DESC]) {
        saldoUrls[ASSET9_DESC] = [NSString stringWithFormat:@"https://chainz.cryptoid.info/%@/", ASSET9.lowercaseString];

        currentSaldo[ASSET9] = @0.0;
        initialRatings[ASSET9] = @0.0;

        mustUpdate = true;
    }

    if (!saldoUrls[ASSET10_DESC]) {
        saldoUrls[ASSET10_DESC] = [NSString stringWithFormat:@"https://chainz.cryptoid.info/%@/", ASSET10.lowercaseString];

        currentSaldo[ASSET10] = @0.0;
        initialRatings[ASSET10] = @0.0;

        mustUpdate = true;
    }

    if (mustUpdate) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        NSLog(@"Migrating Calculator settings...");

        NSMutableDictionary *tempCurrentSaldo = [currentSaldo mutableCopy];
        NSMutableDictionary *tempInitialRatings = [initialRatings mutableCopy];

        for (id key in currentSaldo) {
            if ([tickerKeys objectForKey:key] == nil) {
                [tempCurrentSaldo removeObjectForKey:key];
            }
        }

        for (id key in initialRatings) {
            if ([tickerKeys objectForKey:key] == nil) {
                [tempInitialRatings removeObjectForKey:key];
            }
        }

        // Zurückspielen nicht vergessen
        currentSaldo = tempCurrentSaldo;
        initialRatings = tempInitialRatings;

        [defaults setObject:saldoUrls forKey:KEY_SALDO_URLS];
        [defaults setObject:tempCurrentSaldo forKey:KEY_CURRENT_SALDO];
        [defaults setObject:tempInitialRatings forKey:KEY_INITIAL_RATINGS];

        [defaults synchronize];
    }
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
- (void)updateCheckpointForAsset:(NSString *)asset withBTCUpdate:(BOOL)btcUpdate {
    [self updateCheckpointForAsset:asset withBTCUpdate:btcUpdate andRate:0.0];
}

/**
 * Aktualisiere die Kurse der jeweiligen Währung
 *
 * @param asset
 * @param btcUpdate
 */
- (void)updateCheckpointForAsset:(NSString *)asset withBTCUpdate:(BOOL)btcUpdate andRate:(double)wantedRate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (currentRatings == nil || initialRatings == nil) {
        NSLog(@"updateCheckPointForAsset: NO DATA");

        return;
    }

    if ([asset isEqualToString:DASHBOARD]) {
        initialRatings = [currentRatings mutableCopy];
    } else {
        // aktualisiere den Kurs der Währung
        double priceInFiat = [self fiatPriceForAsset:ASSET1] * wantedRate;
        initialRatings[asset] = ((wantedRate == 0.0) ? currentRatings[asset] : @(1.0 / priceInFiat));

        if (![asset isEqualToString:ASSET1] && btcUpdate) {
            // aktualisiere den BTC Kurs, auf den sich die Transaktion bezog
            initialRatings[ASSET1] = currentRatings[ASSET1];
        }
    }

    [defaults setObject:initialRatings forKey:KEY_INITIAL_RATINGS];
    [defaults synchronize];
}

/**
 * Liefert NSDictionary mit den Schlüsseln "initialPrice", "currentPrice", "percent"
 *
 * @param asset
 * @return NSDictionary*
 */
- (NSDictionary *)checkpointForAsset:(NSString *)asset {
    double initialAssetRating = [initialRatings[asset] doubleValue];
    double currentAssetRating = [currentRatings[asset] doubleValue];

    if (initialAssetRating == 0 || currentAssetRating == 0) {
        return nil;
    }

    double initialPrice = 1.0 / initialAssetRating;
    double currentPrice = 1.0 / currentAssetRating;

    double percent = 100.0 * ((currentPrice / initialPrice) - 1);

    return @{
        CP_INITIAL_PRICE: @(initialPrice),
        CP_CURRENT_PRICE: @(currentPrice),
        CP_PERCENT: @(percent)
    };
}

/**
 * Berechne den BTC-Preis
 *
 * @param asset
 * @return double
 */
- (double)btcPriceForAsset:(NSString *)asset {
    double btcRating = [currentRatings[ASSET1] doubleValue];
    double assetRating = [currentRatings[asset] doubleValue];

    double btcPrice = btcRating / assetRating;
    return btcPrice;
}

/**
 * Berechne den Umrechnungsfaktor
 *
 * @param asset
 * @param baseAsset
 * @return double
 */
- (double)factorForAsset:(NSString *)asset inRelationTo:(NSString *)baseAsset {
    return [self btcPriceForAsset:baseAsset] / [self btcPriceForAsset:asset];
}

/**
 * Berechne den Fiat-Preis
 *
 * @param asset
 * @return double
 */
- (double)fiatPriceForAsset:(NSString *)asset {
    return (1 / [currentRatings[asset] doubleValue]);
}

/**
 * Liefert die aktuellen Veränderungen in Prozent
 *
 * @return NSDictionary*
 */
- (NSDictionary *)checkpointChanges {
    NSMutableDictionary *checkpointChanges = [[NSMutableDictionary alloc] init];

    for (id cAsset in currentRatings) {
        if ([cAsset isEqualToString:USD]) { continue; }

        NSDictionary *aCheckpoint = [self checkpointForAsset:cAsset];
        double cPercent = [aCheckpoint[CP_PERCENT] doubleValue];

        checkpointChanges[cAsset] = @(cPercent);
    }

    return checkpointChanges;
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
- (double)calculateWithRatings:(NSDictionary *)ratings currency:(NSString *)currency {

    for (id key in ratings) {
        if ([ratings[key] doubleValue] == 0.0) {
            NSLog(@"ERROR IN CALCULATOR: DIVISION BY ZERO");
            return 0;
        }
    }

    double asset1Rating = [ratings[ASSET1] doubleValue];
    double asset2Rating = [ratings[ASSET2] doubleValue];
    double asset3Rating = [ratings[ASSET3] doubleValue];
    double asset4Rating = [ratings[ASSET4] doubleValue];
    double asset5Rating = [ratings[ASSET5] doubleValue];

    double asset6Rating = [ratings[ASSET6] doubleValue];
    double asset7Rating = [ratings[ASSET7] doubleValue];
    double asset8Rating = [ratings[ASSET8] doubleValue];
    double asset9Rating = [ratings[ASSET9] doubleValue];
    double asset10Rating = [ratings[ASSET10] doubleValue];

    double price1 = [currentSaldo[ASSET1] doubleValue] / asset1Rating;
    double price2 = [currentSaldo[ASSET2] doubleValue] / asset2Rating;
    double price3 = [currentSaldo[ASSET3] doubleValue] / asset3Rating;
    double price4 = [currentSaldo[ASSET4] doubleValue] / asset4Rating;
    double price5 = [currentSaldo[ASSET5] doubleValue] / asset5Rating;

    double price6 = [currentSaldo[ASSET6] doubleValue] / asset6Rating;
    double price7 = [currentSaldo[ASSET7] doubleValue] / asset7Rating;
    double price8 = [currentSaldo[ASSET8] doubleValue] / asset8Rating;
    double price9 = [currentSaldo[ASSET9] doubleValue] / asset9Rating;
    double price10 = [currentSaldo[ASSET10] doubleValue] / asset10Rating;

    double sum = price1 + price2 + price3 + price4 + price5 + price6 + price7 + price8 + price9 + price10;

    if ([currency isEqualToString:fiatCurrencies[0]]) {
        return sum;
    }

    return sum * [ratings[currency] doubleValue];
}

/**
 * Berechnet die realen Preise anhand des Handelsvolumens auf Poloniex
 *
 * @return NSDictionary*
 */
- (NSDictionary *)realPrices {
    NSMutableDictionary *volumes = [[NSMutableDictionary alloc] init];

    for (id key in tickerKeys) {
        double base = [ticker[tickerKeys[key]][POLONIEX_BASE_VOLUME] doubleValue];
        double quote = [ticker[tickerKeys[key]][POLONIEX_QUOTE_VOLUME] doubleValue];

        volumes[key] = @{
            @"in": @(base),
            @"out": @(quote)
        };
    }

    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];

    for (id key in volumes) {
        if ([key isEqualToString:ASSET1]) {
            continue;
        }

        double v1 = [volumes[key][@"in"] doubleValue];
        double v2 = [volumes[key][@"out"] doubleValue];

        double realPrice = v1 / v2;
        double price = [currentRatings[ASSET1] doubleValue] / [currentRatings[key] doubleValue];
        double percentChange = ((price / realPrice) - 1) * 100.0;

        result[key] = @{
            RP_REALPRICE: @(realPrice),
            RP_PRICE: @(price),
            RP_CHANGE: @(percentChange)
        };
    }

    return result;
}

/**
 * Simple Changes
 *
 * @return NSDictionary*
 */
- (NSDictionary *)realChanges {
    NSDictionary *realPrices = [self realPrices];
    NSMutableDictionary *changes = [[NSMutableDictionary alloc] init];

    for (id key in realPrices) {
        changes[key] = [realPrices[key] objectForKey:RP_CHANGE];
    }

    return changes;
}

/**
 * Automatisches Kaufen von Assets
 *
 * @param cAsset
 * @param wantedAmount
 * @return NSString*
 */
- (NSString *)autoBuy:(NSString *)cAsset amount:(double)wantedAmount {
    return [self autoBuy:cAsset amount:wantedAmount withRate:0.0];
}

/**
 * Automatisches Kaufen von Assets
 *
 * @param cAsset
 * @param wantedAmount
 * @param wantedRate
 * @return NSString*
 */
- (NSString *)autoBuy:(NSString *)cAsset amount:(double)wantedAmount withRate:(double)wantedRate {

    NSDictionary *ak;
    NSString *sk;

    double feeAsFactor = 1.0;

    if ([defaultExchange isEqualToString:@"POLONIEX_EXCHANGE"]) {
        NSDictionary *apiKey = [KeychainWrapper keychain2ApiKeyAndSecret:@"POLONIEX"];
        ak = apiKey[@"apiKey"];
        sk = apiKey[@"secret"];
    }

    if ([defaultExchange isEqualToString:@"BITTREX_EXCHANGE"]) {
        NSDictionary *apiKey = [KeychainWrapper keychain2ApiKeyAndSecret:@"BITTREX"];
        ak = apiKey[@"apiKey"];
        sk = apiKey[@"secret"];
        feeAsFactor = 0.9975;
    }

    if (ak == nil || sk == nil) {
        return nil;
    }

    double btcPrice = [currentRatings[ASSET1] doubleValue];
    double assetPrice = [currentRatings[cAsset] doubleValue];
    double cRate = wantedRate;

    if (cRate == 0.0) {
        cRate = btcPrice / assetPrice;
    }

    // Bestimme die maximale Anzahl an ASSET1's, die verkauft werden können...
    double amountMax = feeAsFactor * ([self currentSaldo:ASSET1] / cRate);
    double amount = amountMax;

    if (wantedAmount > 0) {
        amount = wantedAmount;
    }

    if ([cAsset isEqualToString:ASSET1] || [cAsset isEqualToString:fiatCurrencies[0]] || [cAsset isEqualToString:fiatCurrencies[1]]) {
        // Illegale Kombination ASSET1_(cAsset)
        return nil;
    }

    // Es kann maximal für amountMax gekauft werden...
    if (amount > amountMax) {
        NSString *mText = NSLocalizedString(@"not_enough_btc", @"Zu wenig BTC");
        NSString *iText = NSLocalizedString(@"not_enough_btc_long", @"Sie haben zu wenig BTC zum Kauf");
        [Helper messageText:mText info:iText];
        return nil;
    }

    // Sollte einer dieser Beträge negativ sein, wird die Transaktion verhindert
    if (amount <= 0 || btcPrice <= 0 || assetPrice <= 0 || cRate <= 0) {
        NSString *mText = NSLocalizedString(@"not_enough_btc", @"Zu wenig BTC");
        NSString *iText = NSLocalizedString(@"not_enough_btc_long", @"Sie haben zu wenig BTC zum Kauf");
        [Helper messageText:mText info:iText];
        return nil;
    }

    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"buy_with_amount_asset_and_rate", @"Kaufe %.4f %@ für %.8f das Stück"), amount, cAsset, cRate];

    // Bei 0 gibts eine Kaufbestätigung, bei < 0 wird instant gekauft
    if (wantedAmount >= 0) {
        if ([Helper messageText:NSLocalizedString(@"buy_confirmation", "Kaufbestätigung") info:text] != NSAlertFirstButtonReturn) {
            // Abort Buy
            return nil;
        }
    }

    NSString *cPair = [NSString stringWithFormat:@"%@_%@", ASSET1, cAsset];
    NSDictionary *order = [Brokerage buy:ak withSecret:sk currencyPair:cPair rate:cRate amount:amount onExchange:defaultExchange];

    if (order[@"orderNumber"]) {
        [self updateCheckpointForAsset:cAsset withBTCUpdate:true andRate:cRate];

        return order[@"orderNumber"];
    }

    return nil;
}

/**
 * Automatisches Verkaufen von Assets
 *
 * @param cAsset
 * @param wantedAmount
 * @return NSString*
 */
- (NSString *)autoSell:(NSString *)cAsset amount:(double)wantedAmount {
    return [self autoSell:cAsset amount:wantedAmount withRate:0.0];
}

/**
 * Automatisches Verkaufen von Assets
 *
 * @param cAsset
 * @param wantedAmount
 * @param wantedRate
 * @return NSString*
 */
- (NSString *)autoSell:(NSString *)cAsset amount:(double)wantedAmount withRate:(double)wantedRate {

    NSDictionary *ak;
    NSString *sk;

    double feeAsFactor = 1.0;

    if ([defaultExchange isEqualToString:@"POLONIEX_EXCHANGE"]) {
        NSDictionary *apiKey = [KeychainWrapper keychain2ApiKeyAndSecret:@"POLONIEX"];
        ak = apiKey[@"apiKey"];
        sk = apiKey[@"secret"];
    }

    if ([defaultExchange isEqualToString:@"BITTREX_EXCHANGE"]) {
        NSDictionary *apiKey = [KeychainWrapper keychain2ApiKeyAndSecret:@"BITTREX"];
        ak = apiKey[@"apiKey"];
        sk = apiKey[@"secret"];
        //feeAsFactor = 0.9975;
    }

    if (ak == nil || sk == nil) {
        return nil;
    }

    // Bestimme die maximale Anzahl an Assets, die verkauft werden können...
    double amountMax = feeAsFactor * [self currentSaldo:cAsset];
    double amount = amountMax;

    double btcPrice = [currentRatings[ASSET1] doubleValue];
    double assetPrice = [currentRatings[cAsset] doubleValue];

    if (wantedAmount > 0) {
        amount = wantedAmount;
    }

    if ([cAsset isEqualToString:ASSET1] || [cAsset isEqualToString:fiatCurrencies[0]] || [cAsset isEqualToString:fiatCurrencies[1]]) {
        // Illegale Kombination ASSET1_(cAsset)
        return nil;
    }

    double cRate = wantedRate;

    if (cRate == 0.0) {
        cRate = btcPrice / assetPrice;
    }

    // Sollte einer dieser Beträge negativ sein, wird die Transaktion verhindert
    if (amount > amountMax || amount <= 0 || btcPrice <= 0 || assetPrice <= 0 || cRate <= 0) {
        NSString *mText = [NSString stringWithFormat:NSLocalizedString(@"not_enough_asset_param", @"Zu wenig %@"), cAsset];
        NSString *iText = [NSString stringWithFormat:NSLocalizedString(@"not_enough_asset_long_param", @"Zu wenig %@ zum Verkaufen"), cAsset];
        [Helper messageText:mText info:iText];
        return nil;
    }

    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"sell_with_amount_asset_and_rate", @"Verkaufe %.4f %@ für %.8f das Stück"), amount, cAsset, cRate];

    // Bei 0 gibts eine Verkaufsbestätigung, bei < 0 wird instant gekauft
    if (wantedAmount >= 0) {
        if ([Helper messageText:NSLocalizedString(@"sell_confirmation", @"Verkaufsbestätigung") info:text] != NSAlertFirstButtonReturn) {
            // Abort Sell
            return nil;
        }
    }

    NSString *cPair = [NSString stringWithFormat:@"%@_%@", ASSET1, cAsset];
    NSDictionary *order = [Brokerage sell:ak withSecret:sk currencyPair:cPair rate:cRate amount:amount onExchange:defaultExchange];

    if (order[@"orderNumber"]) {
        [self updateCheckpointForAsset:cAsset withBTCUpdate:false andRate:cRate];

        return order[@"orderNumber"];
    }

    return nil;
}

/**
 * Automatisches Kaufen...
 *
 * @param cAsset
 */
- (void)autoBuyAll:(NSString *)cAsset {
    static NSString *lastBoughtAsset = @"";

    double ask = ([tradingWithConfirmation boolValue]) ? 0 : -1;
    if ([cAsset isEqualToString:lastBoughtAsset]) {
        // ask = 0;
    }

    if ([self autoBuy:cAsset amount:ask] != nil) {
        lastBoughtAsset = cAsset;

        // Aktualisiere alle Checkpoints
        [self updateCheckpointForAsset:DASHBOARD withBTCUpdate:true];
    }
}

/**
 * Automatisches Verkaufen...
 *
 * @param cAsset
 */
- (void)autoSellAll:(NSString *)cAsset {
    double ask = ([tradingWithConfirmation boolValue]) ? 0 : -1;
    if ([self autoSell:cAsset amount:ask] != nil) {
        // Aktualisiere alle Checkpoints
        [self updateCheckpointForAsset:DASHBOARD withBTCUpdate:true];
    }
}

/**
 * Verkaufe Altcoins, die im Wert um "wantedEuros" gestiegen ist
 *
 * @param wantedEuros
 */
- (void)sellWithProfitInEuro:(double)wantedEuros {
    for (id key in currentSaldo) {
        if ([key isEqualToString:ASSET1]) { continue; }
        if ([key isEqualToString:fiatCurrencies[0]]) { continue; }
        if ([key isEqualToString:fiatCurrencies[1]]) { continue; }

        NSDictionary *checkpoint = [self checkpointForAsset:key];

        double initialPrice = [checkpoint[CP_INITIAL_PRICE] doubleValue];
        double currentPrice = [checkpoint[CP_CURRENT_PRICE] doubleValue];

        double initialBalanceInEUR = initialPrice * [self currentSaldo:key];
        double currentBalanceInEUR = currentPrice * [self currentSaldo:key];

        double gain = currentBalanceInEUR - initialBalanceInEUR;

        if (gain > wantedEuros) {
            [self autoSellAll:key];
        }
    }
}

/**
 * Verkaufe Altcoins mit mindestens 1 Euro im Bestand, deren Exchange-Rate um "wantedPercent" Prozent gestiegen ist...
 *
 * @param wantedPercent
 */
- (void)sellWithProfitInPercent:(double)wantedPercent {

    for (id key in currentSaldo) {
        if ([key isEqualToString:ASSET1]) { continue; }
        if ([key isEqualToString:fiatCurrencies[0]]) { continue; }
        if ([key isEqualToString:fiatCurrencies[1]]) { continue; }

        NSDictionary *checkpoint = [self checkpointForAsset:key];
        NSDictionary *btcCheckpoint = [self checkpointForAsset:ASSET1];

        double currentPrice = [checkpoint[CP_CURRENT_PRICE] doubleValue];
        double btcPercent = [btcCheckpoint[CP_PERCENT] doubleValue];
        double percent = [checkpoint[CP_PERCENT] doubleValue];

        double effectiveBTCPercent = percent - btcPercent;
        double balance = currentPrice * [self currentSaldo:key];

        // Security Feature: We want more, not less
        if (effectiveBTCPercent < 0) {
            continue;
        }

        if ((effectiveBTCPercent > wantedPercent) && (balance > 1.0)) {
            [self autoSellAll:key];
        }
    }
}

/**
 * Verkaufe Assets mit einer Investor-Rate von "wantedPercent"% oder mehr...
 *
 * @param wantedPercent
 */
- (void)sellByInvestors:(double)wantedPercent {
    NSDictionary *currencyUnits = [self realChanges];

    NSNumber *lowest = [[currencyUnits allValues] valueForKeyPath:@"@min.self"];

    if (lowest != nil) {
        NSString *lowestKey = [currencyUnits allKeysForObject:lowest][0];
        double investorsRate = [currencyUnits[lowestKey] doubleValue];

        double price = [currentSaldo[lowestKey] doubleValue] * [self btcPriceForAsset:lowestKey];

        // Wir verkaufen keinen Sternenstaub...
        if (price < 0.0001) { return; }

        // Verkaufe auf Grundlage der aktuellen Investoren-Rate
        if (investorsRate < wantedPercent) {
            [self autoSellAll:lowestKey];
        }
    }
}

/**
 * Kaufe Altcoins, deren Exchange-Rate um "wantedPercent" Prozent gestiegen ist...
 *
 * @param wantedPercent
 * @param wantedRate
 */
- (void)buyWithProfitInPercent:(double)wantedPercent andInvestmentRate:(double)wantedRate {
    double balance = [self currentSaldo:ASSET1];
    NSDictionary *realChanges = [self realChanges];

    if (balance < 0.0001) { return; }

    for (id key in currentSaldo) {
        if ([key isEqualToString:ASSET1]) { continue; }
        if ([key isEqualToString:fiatCurrencies[0]]) { continue; }
        if ([key isEqualToString:fiatCurrencies[1]]) { continue; }

        NSDictionary *checkpoint = [self checkpointForAsset:key];
        NSDictionary *btcCheckpoint = [self checkpointForAsset:ASSET1];

        double btcPercent = [btcCheckpoint[CP_PERCENT] doubleValue];
        double percent = [checkpoint[CP_PERCENT] doubleValue];

        double effectivePercent = btcPercent - percent;
        double realChange = [realChanges[key] doubleValue];

        // Security Feature: We want more, not less
        if (effectivePercent < 0) {
            continue;
        }

        // Trade only with a higher Price/Volume Ratio
        if (wantedRate > realChange) {
            continue;
        }

        if (effectivePercent > wantedPercent) {
            [self autoBuyAll:key];
        }
    }
}

/**
 * Kaufe Assets mit einer Investor-Rate von "rate"% oder mehr...
 *
 * @param wantedRate
 */
- (void)buyByInvestors:(double)wantedRate {
    NSDictionary *currencyUnits = [self realChanges];

    NSNumber *highest = [[currencyUnits allValues] valueForKeyPath:@"@max.self"];

    if (highest != nil) {
        NSString *highestKey = [currencyUnits allKeysForObject:highest][0];
        double investorsRate = [currencyUnits[highestKey] doubleValue];

        // Kaufe auf Grundlage der aktuellen Investoren-Rate
        if (investorsRate > wantedRate) {
            [self autoBuyAll:highestKey];
        }
    }
}

/**
 * buyTheBest: Kaufe blind die am höchsten bewertete Asset
 *
 */
- (void)buyTheBest {
    NSDictionary *currencyUnits = [self checkpointChanges];

    NSNumber *highest = [[currencyUnits allValues] valueForKeyPath:@"@max.self"];

    if (highest != nil) {
        NSString *highestKey = [currencyUnits allKeysForObject:highest][0];
        [self autoBuyAll:highestKey];
    }
}

/**
 * buyTheWorst: Kaufe blind die am niedrigsten bewertete Asset
 *
 */
- (void)buyTheWorst {
    NSMutableDictionary *currencyUnits = [[self checkpointChanges] mutableCopy];

    NSNumber *lowest = [[currencyUnits allValues] valueForKeyPath:@"@min.self"];

    if (lowest != nil) {
        NSString *lowestKey = [currencyUnits allKeysForObject:lowest][0];
        [self autoBuyAll:lowestKey];
    }
}

/**
 * Aktualsiert den Bestand (synchronisiert und thread-safe)
 *
 * falls automatedTrading an ist, wird nur der handelbare Bestand angezeigt.
 * falls automatedTrading aus ist, wird der handelbare(available) und der investierte(onOrders) Bestand angezeigt.
 *
 * @param synchronized
 */
- (void)updateBalances:(BOOL)synchronized {

    dispatch_queue_t queue = dispatch_queue_create("de.4customers.iBroker.updateBalances", NULL);

    if (synchronized) {
        dispatch_sync(queue, ^{
            [self unsynchronizedUpdateBalances];
        });
    } else {
        dispatch_async(queue, ^{
            [self unsynchronizedUpdateBalances];
        });
    }

}

/**
 * Aktualsiert den Bestand mit dem Poloniex-Key
 *
 * falls automatedTrading an ist, wird nur der handelbare Bestand angezeigt.
 * falls automatedTrading aus ist, wird der handelbare(available) und der investierte(onOrders) Bestand angezeigt.
 */
- (void)unsynchronizedUpdateBalances {

    NSDictionary *ak = nil;
    NSString *sk = nil;

    if ([defaultExchange isEqualToString:EXCHANGE_POLONIEX]) {
        NSDictionary *apiKey = [KeychainWrapper keychain2ApiKeyAndSecret:@"POLONIEX"];
        ak = apiKey[@"apiKey"];
        sk = apiKey[@"secret"];
    }

    if ([defaultExchange isEqualToString:EXCHANGE_BITTREX]) {
        NSDictionary *apiKey = [KeychainWrapper keychain2ApiKeyAndSecret:@"BITTREX"];
        ak = apiKey[@"apiKey"];
        sk = apiKey[@"secret"];
    }

    if (ak == nil || sk == nil) {
        return;
    }

    NSDictionary *currentBalance = [Brokerage balance:ak withSecret:sk forExchange:defaultExchange];

    if (currentBalance[@"error"]) {
        [Helper messageText:currentBalance[@"error"] info:@"CHECK API-KEY RESTRICTIONS"];
        return;
    }

    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    for (id key in currentSaldo) {
        double sum = [[currentBalance[key] objectForKey:@"available"] doubleValue];
        if (!self.automatedTrading) { sum += [[currentBalance[key] objectForKey:@"onOrders"] doubleValue]; }

        dictionary[key] = @(sum);
    }

    [self currentSaldoForDictionary:dictionary];
}

/**
 * synchronisierter Block, der garantiert, dass es nur ein Update gibt
 *
 * @param synchronized
 */
- (void)updateRatings:(BOOL)synchronized {

    dispatch_queue_t queue = dispatch_queue_create("de.4customers.iBroker.updateRatings", NULL);

    if (synchronized) {
        dispatch_sync(queue, ^{
            [self unsynchronizedUpdateRatings];
        });
    } else {
        dispatch_async(queue, ^{
            [self unsynchronizedUpdateRatings];
        });
    }

}

/**
 * Besorge die Kurse von der Börse per JSON-Request und speichere Sie in den App-Einstellungen
 */
- (void)unsynchronizedUpdateRatings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *tickerDictionary;

    if ([defaultExchange isEqualToString:EXCHANGE_POLONIEX]) { tickerDictionary = [Brokerage poloniexTicker:fiatCurrencies]; }
    if ([defaultExchange isEqualToString:EXCHANGE_BITTREX]) { tickerDictionary = [Brokerage bittrexTicker:fiatCurrencies forAssets:[currentSaldo allKeys]]; }

    if (tickerDictionary == nil) {

        // Kein Netzwerk, liefere gespeicherte Werte...
        initialRatings = [defaults objectForKey:KEY_INITIAL_RATINGS];

        if (initialRatings == nil) {
            NSLog(@"SERVICE UNAVAILABLE DURING INITIAL START");

            [Helper messageText:NSLocalizedString(@"no_internet_connection", @"NO INTERNET CONNECTION")
                info:NSLocalizedString(@"internet_connection_required", @"Internet Connection required")
            ];

            return;
        }

        // falls es noch keine aktuellen Ratings gibt, liefere Initiale...
        if (currentRatings == nil) {
            currentRatings = initialRatings;
        }

        return;
    }

    ticker = [tickerDictionary mutableCopy];

    NSString *btcFiat = [NSString stringWithFormat:@"%@_%@", ASSET1, fiatCurrencies[0]];
    double btcValue = 1.0 / [tickerDictionary[btcFiat][POLONIEX_LAST] doubleValue];

    currentRatings = [[NSMutableDictionary alloc] init];

    currentRatings[ASSET1] = @(btcValue);
    currentRatings[fiatCurrencies[1]] = tickerDictionary[fiatCurrencies[1]];

    for (id key in tickerKeys) {
        double assetValue = btcValue;

        if (![key isEqualToString:ASSET1]) {
            assetValue /= [tickerDictionary[tickerKeys[key]][POLONIEX_LAST] doubleValue];
        }

        currentRatings[key] = @(assetValue);
    }

    initialRatings = [[defaults objectForKey:KEY_INITIAL_RATINGS] mutableCopy];

    if (initialRatings == nil) {
        [self initialRatingsWithDictionary:currentRatings];
    }

    [defaults synchronize];
}

/**
 * Liefert den aktuellen Saldo der jeweiligen Crypto-Währung
 *
 * @param asset
 * @return double
 */
- (double)currentSaldo:(NSString *)asset {
    return [currentSaldo[asset] doubleValue];
}

/**
 * Liefert die aktuelle URL für das angegebene Label/Tab
 *
 * @param label
 * @return NSString*
 */
- (NSString *)saldoUrlForLabel:(NSString *)label {
    return saldoUrls[label];
}

/**
 * Aktualisiert den aktuellen Saldo für die CryptoWährung "asset" mit dem Wert "saldo"
 *
 * @param asset
 * @param saldo
 */
- (void)currentSaldo:(NSString *)asset withDouble:(double)saldo {
    currentSaldo[asset] = [[NSNumber alloc] initWithDouble:saldo];

    [self currentSaldoForDictionary:currentSaldo];
}

/**
 * Ersetzt die aktuellen Saldi mit den Werten aus dem Dictionary
 *
 * @param dictionary
 */
- (void)currentSaldoForDictionary:(NSMutableDictionary *)dictionary {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (dictionary == nil) { return; }
    if ([dictionary count] == 0) {
        if (!RELEASE_BUILD) {
            NSLog(@"EMPTY ARRAY - NOT INSERTING");
        }

        return;
    }

    [defaults setObject:dictionary forKey:KEY_CURRENT_SALDO];
    [defaults synchronize];

    currentSaldo = [dictionary mutableCopy];
}

/**
 * Ersetzt die aktuellen saldoUrls mit den Werten aus dem Dictionary
 *
 * @param dictionary
 */
- (void)saldoUrlsForDictionary:(NSMutableDictionary *)dictionary {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (dictionary == nil) { return; }
    if ([dictionary count] == 0) {
        if (!RELEASE_BUILD) {
            NSLog(@"EMPTY ARRAY - NOT INSERTING");
        }

        return;
    }

    [defaults setObject:dictionary forKey:KEY_SALDO_URLS];
    [defaults synchronize];

    saldoUrls = [dictionary mutableCopy];
}

/**
 * Ersetzt die aktuellen initialRatings mit den Werten aus dem Dictionary
 *
 * @param dictionary
 */
- (void)initialRatingsWithDictionary:(NSMutableDictionary *)dictionary {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (dictionary == nil) { return; }
    if ([dictionary count] == 0) {
        if (!RELEASE_BUILD) {
            NSLog(@"EMPTY ARRAY - NOT INSERTING");
        }

        return;
    }

    [defaults setObject:dictionary forKey:KEY_INITIAL_RATINGS];
    [defaults synchronize];

    initialRatings = [dictionary mutableCopy];
}

/**
 * Aktualisieren der Standardbörse ermöglichen
 *
 * @param exchange
 */
- (void)defaultExchange:(NSString *)exchange {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:exchange forKey:KEY_DEFAULT_EXCHANGE];
    [defaults synchronize];

    defaultExchange = exchange;
}

/**
 * Getter für die DefaultExchange
 *
 * @return NSString*
 */
- (NSString *)defaultExchange {
    return defaultExchange;
}

/**
 * Liefert die aktuellen Fiat-Währungen
 *
 * @return NSArray*
 */
- (NSArray *)fiatCurrencies {
    return fiatCurrencies;
}

/**
 * Getter für currentSaldo
 *
 * @return NSMutableDictionary*
 */
- (NSMutableDictionary *)currentSaldo {
    return [currentSaldo mutableCopy];
}

/**
 * Getter für das saldoUrls
 *
 * @return NSMutableDictionary*
 */
- (NSMutableDictionary *)saldoUrls {
    return [saldoUrls mutableCopy];
}

/**
 * Getter für initialRatings
 *
 * @return NSMutableDictionary*
 */
- (NSMutableDictionary *)initialRatings {
    return [initialRatings mutableCopy];
}

/**
 * Getter für currentRatings
 *
 * @return NSMutableDictionary*
 */
- (NSMutableDictionary *)currentRatings {
    return [currentRatings mutableCopy];
}

/**
 * Getter für den Ticker
 *
 * @return NSMutableDictionary*
 */
- (NSMutableDictionary *)ticker {
    return [ticker mutableCopy];
}

/**
 * Getter für die tickerKeys
 *
 * @return NSDictionary*
 */
- (NSDictionary *)tickerKeys {
    return tickerKeys;
}

@end
