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

    NSArray *fiatCurrencies;

    NSDictionary *tickerKeys;
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
                GAMECOIN: @"https://blockexplorer.gamecredits.com",
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

    if (!saldoUrls[GAMECOIN]) {
        saldoUrls[GAMECOIN] = @"https://blockexplorer.gamecredits.com";

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
    double initialPrice = 1.0 / [initialRatings[asset] doubleValue];
    double currentPrice = 1.0 / [currentRatings[asset] doubleValue];

    double percent = 100.0 * ((currentPrice / initialPrice) - 1);

    return @{
        CP_INITIAL_PRICE: @(initialPrice),
        CP_CURRENT_PRICE: @(currentPrice),
        CP_PERCENT: @(percent),
        CP_EFFECTIVE_PRICE: @((1 + percent / 100.0) * currentPrice)
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    currentSaldo = [[defaults objectForKey:KEY_CURRENT_SALDO] mutableCopy];

    double btc = [currentSaldo[BTC] doubleValue] / [ratings[BTC] doubleValue];
    double zec = [currentSaldo[ZEC] doubleValue] / [ratings[ZEC] doubleValue];
    double eth = [currentSaldo[ETH] doubleValue] / [ratings[ETH] doubleValue];
    double ltc = [currentSaldo[LTC] doubleValue] / [ratings[LTC] doubleValue];
    double xmr = [currentSaldo[XMR] doubleValue] / [ratings[XMR] doubleValue];
    double game = [currentSaldo[GAME] doubleValue] / [ratings[GAME] doubleValue];
    double emc2 = [currentSaldo[EMC2] doubleValue] / [ratings[EMC2] doubleValue];
    double maid = [currentSaldo[MAID] doubleValue] / [ratings[MAID] doubleValue];
    double sc = [currentSaldo[SC] doubleValue] / [ratings[SC] doubleValue];
    double doge = [currentSaldo[DOGE] doubleValue] / [ratings[DOGE] doubleValue];

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
 * Automatisches Kaufen...
 *
 * @param cAsset
 * @param wantedAmount
 */
- (void)autoBuy:(NSString*)cAsset amount:(double)wantedAmount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    //
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

    // Es kann maximal amountMax vertickt werden.
    if (amount > amountMax) {
        NSString *mText = NSLocalizedString(@"not_enough_btc", @"Zu wenig BTC");
        NSString *iText = NSLocalizedString(@"not_enough_btc_long", @"Sie haben zu wenig BTC zum Kauf");
        [Helper messageText:mText info:iText];
        return;
    }

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
    [Brokerage buy:ak withSecret:sk currencyPair:cPair rate:cRate amount:amount];
    [self updateCheckpointForAsset:cAsset withBTCUpdate:false];
}

/**
 * Automatisches Kaufen...
 *
 * @param cAsset
 * @param wantedAmount
 */
- (void)autoSell:(NSString*)cAsset amount:(double)wantedAmount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Temp Taschenrechner
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
    [Brokerage sell:ak withSecret:sk currencyPair:cPair rate:cRate amount:amount];
    [self updateCheckpointForAsset:BTC withBTCUpdate:false];
}

/**
 * Automatisches Kaufen...
 *
 * @param cAsset
 */
- (void)autoBuyAll:(NSString*)cAsset {
    [self autoBuy:cAsset amount:-1];
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
 * Verkaufe Altcoins, die im Wert um "profit" Prozent gestiegen sind...
 *
 * @param profit
 */
- (void)sellWithProfit:(double)profit {
    NSDictionary *currencyUnits = [self checkpointChanges];

    for (id key in currencyUnits) {
        if ([key isEqualToString:BTC]) continue;

        NSDictionary *checkpoint = [self checkpointForAsset:key];
        double currentPrice = [checkpoint[CP_CURRENT_PRICE] doubleValue];
        double balanceEUR = currentPrice * [self currentSaldo:key];
        double percent = [currencyUnits[key] doubleValue];

        if ((percent > profit) && (balanceEUR > 0.5)) {
            [self autoSellAll:key];
        }
    }
}

/**
 * BuyTheBest and go on rally
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
 * BuyTheWorst and become a longterm trader
 *
 */
- (void)buyTheWorst {
    NSDictionary *currencyUnits = [self checkpointChanges];

    NSNumber *lowest = [[currencyUnits allValues] valueForKeyPath:@"@min.self"];

    if (lowest != nil) {
        NSString *lowestKey = [currencyUnits allKeysForObject:lowest][0];
        [self autoBuyAll:lowestKey];
    }
}

/**
 * @ Aktualisieren des Bestands per POLONIEX KEY
 */
- (void)updateBalances {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSDictionary *ak = [defaults objectForKey:@"POLO_KEY"];
    NSString *sk = [defaults objectForKey:@"POLO_SEC"];

    if (ak == nil || sk == nil) {
        return;
    }

    NSDictionary *currentBalance = [Brokerage balance:ak withSecret:sk];

    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    for (id key in currentSaldo) {
        dictionary[key] = currentBalance[key];
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
 * Besorge die Kurse von Poloniex per JSON-Request und speichere Sie in den App-Einstellungen
 */
- (void)unsynchronizedUpdateRatings {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *tickerDictionary = [Brokerage poloniexTicker:fiatCurrencies];

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

    double btcValue = 1 / [tickerDictionary[@"BTC_EUR"][POLONIEX_LAST] doubleValue];

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

- (NSDictionary*)tickerKeys {
    return tickerKeys;
}

@end
