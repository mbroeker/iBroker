//
// Created by Markus Bröker on 28.04.17.
// Copyright (c) 2017 Markus Bröker. All rights reserved.
//

#import "Calculator.h"
#import "Helper.h"

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
}

/**
 * Der öffentliche Konstruktor mit Vorbelegung EUR/USD
 */
+ (id)instance {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSArray *fc = [defaults objectForKey:KEY_FIAT_CURRENCIES];
    return [self instance:fc];
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
 * Der Standard Konstruktor mit Vorbelegung EUR/USD
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

        if (currentSaldo == nil) {
            currentSaldo = [@{
                BTC: @0.0,
                ZEC: @0.0,
                ETH: @0.0,
                LTC: @0.0,
                XMR: @0.0,
                GAME: @0.0,
                EMC2: @0.0,
                MAID: @0.0,
                SC: @0.0,
                DOGE: @0.0,
            } mutableCopy];

            [defaults setObject:currentSaldo forKey:KEY_CURRENT_SALDO];
        }

        saldoUrls = [[defaults objectForKey:KEY_SALDO_URLS] mutableCopy];

        if (saldoUrls == nil) {
            saldoUrls = [@{
                DASHBOARD: @"https://poloniex.com/exchange#btc_xmr",
                BITCOIN: @"https://blockchain.info/",
                ZCASH: @"https://explorer.zcha.in",
                ETHEREUM: @"https://etherscan.io/",
                LITECOIN: @"https://chainz.cryptoid.info/ltc/",
                MONERO: @"https://moneroblocks.info",
                GAMECREDITS: @"https://blockexplorer.gamecredits.com",
                EINSTEINIUM: @"https://prohashing.com/explorer/Einsteinium/",
                SAFEMAID: @"https://maidsafe.net/features.html",
                SIACOIN: @"https://explore.sia.tech",
                DOGECOIN: @"https://dogechain.info"
            } mutableCopy];

            [defaults setObject:saldoUrls forKey:KEY_SALDO_URLS];
        }

        tickerKeys = @{
            BTC: @"BTC_EUR",
            ZEC: @"BTC_ZEC",
            ETH: @"BTC_ETH",
            XMR: @"BTC_XMR",
            LTC: @"BTC_LTC",
            GAME: @"BTC_GAME",
            EMC2: @"BTC_EMC2",
            MAID: @"BTC_MAID",
            SC: @"BTC_SC",
            DOGE: @"BTC_DOGE"
        };

        defaultExchange = [defaults objectForKey:@"defaultExchange"];

        if (defaultExchange == nil) {
            defaultExchange = EXCHANGE_POLONIEX;

            [defaults setObject:defaultExchange forKey:@"defaultExchange"];
        }

        [defaults synchronize];

        // Migration älterer Installationen
        [self upgradeAssistant];

        [self updateRatings];
    }

    return self;
}

/**
 * simpler Upgrade Assistent
 */
- (void)upgradeAssistant {
    BOOL mustUpdate = false;

    if (!saldoUrls[BITCOIN]) {
        saldoUrls[BITCOIN] = @"https://blockchain.info/";

        currentSaldo[BTC] = @0.0;
        initialRatings[BTC] = @0.0;

        mustUpdate = true;
    }

    if (!saldoUrls[ZCASH]) {
        saldoUrls[ZCASH] = @"https://explorer.zcha.in";

        currentSaldo[ZEC] = @0.0;
        initialRatings[ZEC] = @0.0;

        mustUpdate = true;
    }

    if (!saldoUrls[ETHEREUM]) {
        saldoUrls[ETHEREUM] = @"https://etherscan.io/";

        currentSaldo[ETH] = @0.0;
        initialRatings[ETH] = @0.0;

        mustUpdate = true;
    }

    if (!saldoUrls[MONERO]) {
        saldoUrls[MONERO] = @"https://moneroblocks.info";

        currentSaldo[XMR] = @0.0;
        initialRatings[XMR] = @0.0;

        mustUpdate = true;
    }

    if (!saldoUrls[LITECOIN]) {
        saldoUrls[LITECOIN] = @"https://chainz.cryptoid.info/ltc/";

        currentSaldo[LTC] = @0.0;
        initialRatings[LTC] = @0.0;

        mustUpdate = true;
    }

    if (!saldoUrls[GAMECREDITS]) {
        saldoUrls[GAMECREDITS] = @"https://blockexplorer.gamecredits.com";

        currentSaldo[GAME] = @0.0;
        initialRatings[GAME] = @0.0;

        mustUpdate = true;
    }

    if (!saldoUrls[SAFEMAID]) {
        saldoUrls[SAFEMAID] = @"https://maidsafe.net/features.html";

        currentSaldo[MAID] = @0.0;
        initialRatings[MAID] = @0.0;

        mustUpdate = true;
    }

    if (!saldoUrls[EINSTEINIUM]) {
        saldoUrls[EINSTEINIUM] = @"https://prohashing.com/explorer/Einsteinium/";

        currentSaldo[EMC2] = @0.0;
        initialRatings[EMC2] = @0.0;

        mustUpdate = true;
    }

    if (!saldoUrls[SIACOIN]) {
        saldoUrls[SIACOIN] = @"https://explore.sia.tech";

        currentSaldo[SC] = @0.0;
        initialRatings[SC] = @0.0;

        mustUpdate = true;
    }

    if (!saldoUrls[DOGECOIN]) {
        saldoUrls[DOGECOIN] = @"https://dogechain.info";

        currentSaldo[GAME] = @0.0;
        initialRatings[GAME] = @0.0;

        mustUpdate = true;
    }

    // Lösche die alten Schlüssel für Ripple
    if (saldoUrls[@"Ripple"]) {
        [saldoUrls removeObjectForKey:@"Ripple"];

        [currentSaldo removeObjectForKey:@"XRP"];
        [initialRatings removeObjectForKey:@"XRP"];

        mustUpdate = true;
    }

    // Lösche die alten Schlüssel für Stellar Lumens
    if (saldoUrls[@"Stellar Lumens"]) {
        [saldoUrls removeObjectForKey:@"Stellar Lumens"];

        [currentSaldo removeObjectForKey:@"STR"];
        [initialRatings removeObjectForKey:@"STR"];

        mustUpdate = true;
    }

    if (mustUpdate) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        NSLog(@"Migrating Calculator settings...");

        [defaults setObject:saldoUrls forKey:KEY_SALDO_URLS];
        [defaults setObject:currentSaldo forKey:KEY_CURRENT_SALDO];
        [defaults setObject:initialRatings forKey:KEY_INITIAL_RATINGS];

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
- (void)updateCheckpointForAsset:(NSString *)asset withBTCUpdate:(BOOL) btcUpdate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (currentRatings == nil || initialRatings == nil) {
        NSLog(@"updateCheckPointForAsset: NO DATA");

        return;
    }

    if ([asset isEqualToString:DASHBOARD]) {
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
        CP_PERCENT: @(percent),
        CP_EFFECTIVE_PRICE: @((1 + (percent / 100.0)) * currentPrice)
    };
}

/**
 * Liefert die aktuellen Veränderungen in Prozent
 *
 * @return NSDictionary
 */
- (NSDictionary*)checkpointChanges {
    NSMutableDictionary *checkpointChanges = [[NSMutableDictionary alloc] init];

    for (id cAsset in currentRatings) {
        if ([cAsset isEqualToString:USD]) continue;

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
- (double)calculateWithRatings:(NSDictionary*)ratings currency:(NSString *)currency {

    for (id key in ratings) {
        if ([ratings[key] doubleValue] == 0.0) {
            NSLog(@"ERROR IN CALCULATOR: DIVISION BY ZERO");
            return 0;
        }
    }

    double btcRating = [ratings[BTC] doubleValue];
    double zecRating = [ratings[ZEC] doubleValue];
    double ethRating = [ratings[ETH] doubleValue];
    double xmrRating = [ratings[XMR] doubleValue];
    double ltcRating = [ratings[LTC] doubleValue];

    double gameRating = [ratings[GAME] doubleValue];
    double emc2Rating = [ratings[EMC2] doubleValue];
    double maidRating = [ratings[MAID] doubleValue];
    double scRating = [ratings[SC] doubleValue];
    double dogeRating = [ratings[DOGE] doubleValue];

    double btc = [currentSaldo[BTC] doubleValue] / btcRating;
    double zec = [currentSaldo[ZEC] doubleValue] / zecRating;
    double eth = [currentSaldo[ETH] doubleValue] / ethRating;
    double ltc = [currentSaldo[LTC] doubleValue] / ltcRating;
    double xmr = [currentSaldo[XMR] doubleValue] / xmrRating;

    double game = [currentSaldo[GAME] doubleValue] / gameRating;
    double emc2 = [currentSaldo[EMC2] doubleValue] / emc2Rating;
    double maid = [currentSaldo[MAID] doubleValue] / maidRating;
    double sc = [currentSaldo[SC] doubleValue] / scRating;
    double doge = [currentSaldo[DOGE] doubleValue] / dogeRating;

    double sum = btc + zec + eth + ltc + xmr + game + emc2 + maid + sc + doge;

    if ([currency isEqualToString:fiatCurrencies[0]]) {
        return sum;
    }

    return sum * [ratings[currency] doubleValue];
}

/**
 * Berechnet die realen Preise anhand des Handelsvolumens auf Poloniex
 */
- (NSDictionary*)realPrices {
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
        if ([key isEqualToString:BTC]) {
            continue;
        }

        double v1 = [volumes[key][@"in"] doubleValue];
        double v2 = [volumes[key][@"out"] doubleValue];

        double realPrice = v1 / v2;
        double price = [currentRatings[BTC] doubleValue] / [currentRatings[key] doubleValue];
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
 */
- (NSDictionary*)realChanges {
    NSDictionary *realPrices = [self realPrices];
    NSMutableDictionary *changes = [[NSMutableDictionary alloc] init];

    for (id key in realPrices) {
        changes[key] = [realPrices[key] objectForKey:RP_CHANGE];
    }

    return changes;
}

/**
 * Automatisches Kaufen...
 *
 * @param cAsset
 * @param wantedAmount
 */
- (void)autoBuy:(NSString*)cAsset amount:(double)wantedAmount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // @TODO Vielleicht sollten diese Zugangsdaten noch verschlüsselt werden...
    NSDictionary *ak = [defaults objectForKey:@"POLO_KEY"];
    NSString *sk = [defaults objectForKey:@"POLO_SEC"];

    if (ak == nil || sk == nil) {
        return;
    }

    double btcPrice = [currentRatings[BTC] doubleValue];
    double assetPrice = [currentRatings[cAsset] doubleValue];
    double cRate = btcPrice / assetPrice;

    // Bestimme die maximale Anzahl an BTC's, die verkauft werden können...
    double amountMax = [self currentSaldo:BTC] / cRate;
    double amount = amountMax;

    if (wantedAmount > 0) {
        amount = wantedAmount;
    }

    if ([cAsset isEqualToString:BTC] || [cAsset isEqualToString:USD] || [cAsset isEqualToString:EUR]) {
        // Illegale Kombination BTC_(cAsset)
        return;
    }

    // Es müssen mindestens 10 Cent (derzeit) umgesetzt werden...
    if ((amount * cRate) < 0.00005) {
        return;
    }

    // Es kann maximal für amountMax gekauft werden...
    if (amount > amountMax) {
        NSString *mText = NSLocalizedString(@"not_enough_btc", @"Zu wenig BTC");
        NSString *iText = NSLocalizedString(@"not_enough_btc_long", @"Sie haben zu wenig BTC zum Kauf");
        [Helper messageText:mText info:iText];
        return;
    }

    // Sollte einer dieser Beträge negativ sein, wird die Transaktion verhindert
    if (amount <= 0 || btcPrice <= 0 || assetPrice <= 0 || cRate <= 0) {
        NSString *mText = NSLocalizedString(@"not_enough_btc", @"Zu wenig BTC");
        NSString *iText = NSLocalizedString(@"not_enough_btc_long", @"Sie haben zu wenig BTC zum Kauf");
        [Helper messageText:mText info:iText];
        return;
    }

    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"buy_with_amount_asset_and_rate", @"Kaufe %.4f %@ für %.8f das Stück"), amount, cAsset, cRate];

    // Bei 0 gibts eine Kaufbestätigung, bei < 0 wird instant gekauft
    if (wantedAmount >= 0) {
        if ([Helper messageText:NSLocalizedString(@"buy_confirmation", "Kaufbestätigung") info:text] != NSAlertFirstButtonReturn) {
            // Abort Buy
            return;
        }
    }

    NSString *cPair = [NSString stringWithFormat:@"BTC_%@", cAsset];
    NSDictionary *order = [Brokerage buy:ak withSecret:sk currencyPair:cPair rate:cRate amount:amount onExchange:defaultExchange];

    if (order[@"orderNumber"]) {
        [self updateCheckpointForAsset:cAsset withBTCUpdate:false];
    }
}

/**
 * Automatisches Kaufen...
 *
 * @param cAsset
 * @param wantedAmount
 */
- (void)autoSell:(NSString*)cAsset amount:(double)wantedAmount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // @TODO Vielleicht sollten diese Zugangsdaten noch verschlüsselt werden...
    NSDictionary *ak = [defaults objectForKey:@"POLO_KEY"];
    NSString *sk = [defaults objectForKey:@"POLO_SEC"];

    if (ak == nil || sk == nil) {
        return;
    }

    double amountMax = [self currentSaldo:cAsset];
    double amount = amountMax;

    double btcPrice = [currentRatings[BTC] doubleValue];
    double assetPrice = [currentRatings[cAsset] doubleValue];

    if (wantedAmount > 0) {
        amount = wantedAmount;
    }

    if ([cAsset isEqualToString:BTC] || [cAsset isEqualToString:USD] || [cAsset isEqualToString:EUR]) {
        // Illegale Kombination BTC_(cAsset)
        return;
    }

    double cRate = btcPrice / assetPrice;

    // Sollte einer dieser Beträge negativ sein, wird die Transaktion verhindert
    if (amount > amountMax || amount <= 0 || btcPrice <= 0 || assetPrice <= 0 || cRate <= 0) {
        NSString *mText = [NSString stringWithFormat: NSLocalizedString(@"not_enough_asset_param", @"Zu wenig %@"), cAsset];
        NSString *iText = [NSString stringWithFormat: NSLocalizedString(@"not_enough_asset_long_param", @"Zu wenig %@ zum Verkaufen"), cAsset];
        [Helper messageText:mText info:iText];
        return;
    }

    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"sell_with_amount_asset_and_rate", @"Verkaufe %.4f %@ für %.8f das Stück"), amount, cAsset, cRate];

    // Bei 0 gibts eine Verkaufsbestätigung, bei < 0 wird instant gekauft
    if (wantedAmount >= 0) {
        if ([Helper messageText:NSLocalizedString(@"sell_confirmation", @"Verkaufsbestätigung") info:text] != NSAlertFirstButtonReturn) {
            // Abort Sell
            return;
        }
    }

    NSString *cPair = [NSString stringWithFormat:@"BTC_%@", cAsset];
    NSDictionary *order = [Brokerage sell:ak withSecret:sk currencyPair:cPair rate:cRate amount:amount onExchange:defaultExchange];

    if (order[@"orderNumber"]) {
        [self updateCheckpointForAsset:BTC withBTCUpdate:false];
    }
}

/**
 * Automatisches Kaufen...
 *
 * @param cAsset
 */
- (void)autoBuyAll:(NSString*)cAsset {
    static NSString *lastBoughtAsset = @"";

    double ask = -1;
    if ([cAsset isEqualToString:lastBoughtAsset]) {
        ask = 0;
    }

    [self autoBuy:cAsset amount:ask];
    lastBoughtAsset = cAsset;
}

/**
 * Automatisches Verkaufen...
 *
 * @param cAsset
 */
- (void)autoSellAll:(NSString*)cAsset {
    [self autoSell:cAsset amount:-1];
}

/**
 * Verkaufe Altcoins, die im Wert um "wantedEuros" gestiegen sind
 *
 * @param wantedEuros
 */
- (void)sellWithProfitInEuro:(double)wantedEuros {
    for (id key in currentSaldo) {
        if ([key isEqualToString:BTC]) continue;
        if ([key isEqualToString:USD]) continue;

        NSDictionary *checkpoint = [self checkpointForAsset:key];

        double currentPrice = [checkpoint[CP_CURRENT_PRICE] doubleValue];
        double effectivePrice = [checkpoint[CP_EFFECTIVE_PRICE] doubleValue];

        double currentBalanceInEUR = currentPrice * [self currentSaldo:key];
        double effectiveBalanceInEUR = effectivePrice * [self currentSaldo:key];

        double gain = effectiveBalanceInEUR - currentBalanceInEUR;

        if (gain > wantedEuros) {
            [self autoSellAll:key];
        }
    }
}

/**
 * Verkaufe Altcoins mit mindestens 1 Euro im Bestand, deren Exchange-Rate um "wantedPercent" Prozent gestiegen sind...
 *
 * @param wantedPercent
 */
- (void)sellWithProfitInPercent:(double)wantedPercent {
    for (id key in currentSaldo) {
        if ([key isEqualToString:BTC]) continue;
        if ([key isEqualToString:USD]) continue;

        NSDictionary *checkpoint = [self checkpointForAsset:key];
        NSDictionary *btcCheckpoint = [self checkpointForAsset:BTC];

        double currentPrice = [checkpoint[CP_CURRENT_PRICE] doubleValue];
        double btcPercent = [btcCheckpoint[CP_PERCENT] doubleValue];
        double percent = [checkpoint[CP_PERCENT] doubleValue];

        double effectivePercent = percent - btcPercent;
        double balance = currentPrice * [self currentSaldo:key];

        if ((effectivePercent > wantedPercent) && (balance > 1.0)) {
            [self autoSellAll:key];
        }
    }
}

/**
 * Kaufe Assets mit einer Investor-Rate von "rate"% oder mehr...
 *
 * @param rate
 */
- (void)buyByInvestors:(double)rate {
    NSDictionary *currencyUnits = [self realChanges];

    NSNumber *highest = [[currencyUnits allValues] valueForKeyPath:@"@max.self"];

    if (highest != nil) {
        NSString *highestKey = [currencyUnits allKeysForObject:highest][0];
        double investorsRate = [currencyUnits[highestKey] doubleValue];

        // Kaufe auf Grundlage der aktuellen Investoren-Rate
        if (investorsRate > rate) {
            if (![highestKey isEqualToString:EMC2]) [self autoBuyAll:highestKey];
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
 * @ Aktualsiert den Bestand (synchronisiert und thread-safe)
 *
 * falls automatedTrading an ist, wird nur der handelbare Bestand angezeigt.
 * falls automatedTrading aus ist, wird der handelbare(available) und der investierte(onOrders) Bestand angezeigt.
 */
- (void)updateBalances {

    @synchronized (self) {
        [self unsynchronizedUpdateBalances];
    }
}

/**
 * @ Aktualsiert den Bestand mit dem Poloniex-Key
 *
 * falls automatedTrading an ist, wird nur der handelbare Bestand angezeigt.
 * falls automatedTrading aus ist, wird der handelbare(available) und der investierte(onOrders) Bestand angezeigt.
 */
- (void)unsynchronizedUpdateBalances {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSDictionary *ak = nil;
    NSString *sk = nil;

    if ([defaultExchange isEqualToString:EXCHANGE_POLONIEX]) {
        // @TODO Vielleicht sollten diese Zugangsdaten noch verschlüsselt werden...
        ak = [defaults objectForKey:@"POLO_KEY"];
        sk = [defaults objectForKey:@"POLO_SEC"];
    }

    if ([defaultExchange isEqualToString:EXCHANGE_BITTREX]) {
        // @TODO Vielleicht sollten diese Zugangsdaten noch verschlüsselt werden...
        ak = [defaults objectForKey:@"BITTREX_KEY"];
        sk = [defaults objectForKey:@"BITTREX_SEC"];
    }

    if (ak == nil || sk == nil) {
        return;
    }

    NSDictionary *currentBalance = [Brokerage balance:ak withSecret:sk forExchange:defaultExchange];

    if (currentBalance[@"error"]) {
        [Helper messageText:currentBalance[@"error"] info:@"CHECK https://poloniex.com/apiKeys"];
        return;
    }

    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    for (id key in currentSaldo) {
        double sum = [[currentBalance[key] objectForKey:@"available"] doubleValue];
        if (!self.automatedTrading) sum += [[currentBalance[key] objectForKey:@"onOrders"] doubleValue];

        dictionary[key] = @(sum);
    }

    [self currentSaldoForDictionary:dictionary];
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
 * Besorge die Kurse von der Börse per JSON-Request und speichere Sie in den App-Einstellungen
 */
- (void)unsynchronizedUpdateRatings {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *tickerDictionary;

    if ([defaultExchange isEqualToString:EXCHANGE_POLONIEX]) tickerDictionary = [Brokerage poloniexTicker:fiatCurrencies];
    if ([defaultExchange isEqualToString:EXCHANGE_BITTREX]) tickerDictionary = [Brokerage bittrexTicker:fiatCurrencies forCurrencyPairs:[currentSaldo allKeys]];

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

    double btcValue = 1.0 / [tickerDictionary[@"BTC_EUR"][POLONIEX_LAST] doubleValue];

    currentRatings = [[NSMutableDictionary alloc] init];

    currentRatings[BTC] = @(btcValue);
    currentRatings[fiatCurrencies[1]] = tickerDictionary[fiatCurrencies[1]];

    for (id key in tickerKeys) {
        double assetValue = btcValue;

        if (![key isEqualToString:BTC]) {
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
 * Ersetzt die aktuellen Saldi mit den Werten aus dem Dictionary
 *
 * @param dictionary
 */
- (void)currentSaldoForDictionary:(NSMutableDictionary*)dictionary {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (dictionary == nil) return;
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
- (void)saldoUrlsForDictionary:(NSMutableDictionary*)dictionary {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (dictionary == nil) return;
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
- (void)initialRatingsWithDictionary:(NSMutableDictionary*)dictionary {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (dictionary == nil) return;
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

- (NSDictionary*)tickerKeys {
    return tickerKeys;
}

@end
