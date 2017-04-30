//
// Created by Markus Bröker on 28.04.17.
// Copyright (c) 2017 Markus Bröker. All rights reserved.
//

#import "Calculator.h"

/**
 * Berechnungklasse für Crypto-Währungen
 */
@implementation Calculator {
    // Synchronisierte Einstellungen und Eigenschaften
    NSMutableDictionary *initialRatings;
    NSMutableDictionary *currentSaldo;

    // Normale Eigenschaften
    NSMutableDictionary *currentRatings;
    NSMutableDictionary *saldoUrls;
    
    NSArray *fiatCurrencies;
}

/**
 * Der öffentliche Konstruktor mit Vorbelegung EUR/USD
 */
+ (id)instance {
    return [self instance:@[@"EUR", @"USD"]];
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
    return [self initWithFiatCurrencies:@[@"EUR", @"USD"]];
}

/**
 * Der private Konstruktor der Klasse, der deswegen nicht in Calculator.h gelistet wird.
 *
 */
- (id)initWithFiatCurrencies:(NSArray*)currencies {

    if (self = [super init]) {

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        currentSaldo = [[defaults objectForKey:@"currentSaldo"] mutableCopy];

        fiatCurrencies = currencies;

        if (currentSaldo == NULL) {
            currentSaldo = [@{
                @"BTC": @0.0,
                @"ETH": @0.0,
                @"LTC": @0.0,
                @"XMR": @0.0,
                @"DOGE": @0.0,
            } mutableCopy];

            [defaults setObject:currentSaldo forKey:@"currentSaldo"];
        }

        saldoUrls = [defaults objectForKey:@"saldoUrls"];

        if (saldoUrls == NULL) {
            saldoUrls = [@{
                @"Dashboard": @"https://poloniex.com/exchange#btc_xmr",
                @"Bitcoin": @"https://blockchain.info/",
                @"Ethereum": @"https://etherscan.io/",
                @"Litecoin": @"https://chainz.cryptoid.info/ltc/",
                @"Monero": @"https://moneroblocks.info",
                @"Dogecoin": @"http://dogechain.info/",
            } mutableCopy];

            [defaults setObject:saldoUrls forKey:@"saldoUrls"];
        }

        [defaults synchronize];
        [self updateRatings];
    }

    return self;
}

/**
 * Aktualisiere die Kurse der jeweiligen Währung
 */
- (void)checkPointForKey:(NSString *)key withBTCUpdate:(BOOL) btcUpdate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([key isEqualToString:@"ALL"]) {
        initialRatings = [currentRatings mutableCopy];
    } else {
        if (![key isEqualToString:@"BTC"]) {
            // aktualisiere den Kurs der Währung
            initialRatings[key] = currentRatings[key];
        }

        if (btcUpdate) {
            // aktualisiere den BTC Kurs, auf den sich die Transaktion bezog
            initialRatings[@"BTC"] = currentRatings[@"BTC"];
        }
    }

    [defaults setObject:initialRatings forKey:@"initialRatings"];
    [defaults synchronize];
}

/**
 * Liefert NSDictionary mit den Schlüsseln "initialPrice", "currentPrice", "percent"
 *
 * @param unit
 * @return NSDictionary*
 */
- (NSDictionary*)checkpointForUnit:(NSString*)unit {
    double initialPrice = 1.0 / [initialRatings[unit] doubleValue];
    double currentPrice = 1.0 / [currentRatings[unit] doubleValue];

    double percent = 100.0 * (currentPrice / initialPrice) - 100.0;

    return @{
        @"initialPrice": @(initialPrice),
        @"currentPrice": @(currentPrice),
        @"percent": @(percent),
        @"estimatedPrice": @((1 + percent / 100.0) * currentPrice)
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
    currentSaldo = [[defaults objectForKey:@"currentSaldo"] mutableCopy];

    double btc = [currentSaldo[@"BTC"] doubleValue] / [ratings[@"BTC"] doubleValue];
    double eth = [currentSaldo[@"ETH"] doubleValue] / [ratings[@"ETH"] doubleValue];
    double ltc = [currentSaldo[@"LTC"] doubleValue] / [ratings[@"LTC"] doubleValue];
    double xmr = [currentSaldo[@"XMR"] doubleValue] / [ratings[@"XMR"] doubleValue];
    double doge = [currentSaldo[@"DOGE"] doubleValue] / [ratings[@"DOGE"] doubleValue];

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
    NSString *jsonURL =
        [NSString stringWithFormat:@"https://min-api.cryptocompare.com/data/pricemulti?fsyms=%@&tsyms=%@,BTC,ETH,LTC,XMR,DOGE", fiatCurrencies[0], fiatCurrencies[1]];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:jsonURL]];
    [request setHTTPMethod:@"GET"];

    // Warte auf das Synchronisieren ohne Semaphore
    __block BOOL hasFinished = false;

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

        NSData *jsonData = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError;

        id allkeys = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&jsonError];
        if (jsonError) {
            // Fehlermeldung wird angezeigt
            NSLog(@"%@", [jsonError description]);

            hasFinished = true;
            
            return;
        }

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        currentRatings = [allkeys[fiatCurrencies[0]] mutableCopy];
        initialRatings = [[defaults objectForKey:@"initialRatings"] mutableCopy];

        // DOGE RATINGS aktualisieren, da dieser WS das nicht kann.
        currentRatings[@"DOGE"] = [NSString stringWithFormat:@"%.8f", [self unsynchronizedUdateDoge]];

        if (initialRatings == NULL) {
            [self initialRatingsWithDictionary:currentRatings withUpdate:true];
        }

        [defaults synchronize];
        hasFinished = true;

    }] resume];

    while(!hasFinished) {
        [self safeSleep:0.1];
    }
}

/**
 * Hilfsmethode, da der Kurs bei Cryptocompare ewig falsch ist.
 *
 * @return double
 */
- (double) unsynchronizedUdateDoge {
    NSString *jsonURL =
        [NSString stringWithFormat:@"https://api.cryptonator.com/api/ticker/doge-%@", [fiatCurrencies[0] lowercaseString]];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:jsonURL]];
    [request setHTTPMethod:@"GET"];

    // Warte auf das Synchronisieren ohne Semaphore
    __block BOOL dogeHasFinished = false;
    __block double dogePrice = 0;

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

        NSData *jsonData = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError;

        id allkeys = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&jsonError];
        if (jsonError) {
            // Fehlermeldung wird angezeigt
            NSLog(@"%@", [jsonError description]);
            
            return;
        }

        dogePrice = 1 / [allkeys[@"ticker"][@"price"] doubleValue];
        dogeHasFinished = TRUE;

    }] resume];

    while (!dogeHasFinished) {
        [self safeSleep:0.1];
    }

    return dogePrice;
}

/**
 * Warte timeout Sekunden
 *
 * @param timeout
 */
- (void)safeSleep:(double)timeout {
    [NSThread sleepForTimeInterval:timeout];
}

/**
 * Liefert den aktuellen Saldo der jeweiligen Crypto-Währung
 *
 * @param cUnit
 * @return double
 */
- (double)currentSaldo:(NSString*)cUnit {
    return [currentSaldo[cUnit] doubleValue];
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
 * Aktualisiert den aktuellen Saldo für die CryptoWährung "cUnit" mit dem Wert "saldo"
 *
 * @param cUnit
 * @param saldo
 */
- (void)currentSaldo:(NSString*)cUnit withDouble: (double) saldo {
    currentSaldo[cUnit] = [[NSNumber alloc] initWithDouble:saldo];

    [self currentSaldoForDictionary:currentSaldo withUpdate:false];
}

/**
 * Ersetzt die aktuellen Saldo mit den Werten aus dem Dictionary
 *
 * @param dictionary
 * @param withUpdate
 */
- (void)currentSaldoForDictionary:(NSMutableDictionary*)dictionary withUpdate:(BOOL)update {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:dictionary forKey:@"currentSaldo"];
    [defaults synchronize];

    if (update) {
        currentSaldo = [dictionary mutableCopy];
    }
}

/**
 * Ersetzt die aktuellen saldoUrls mit den Werten aus dem Dictionary
 *
 * @param dictionary
 * @param withUpdate
 */
- (void)saldoUrlsForDictionary:(NSMutableDictionary*)dictionary withUpdate:(BOOL)update {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:dictionary forKey:@"saldoUrls"];
    [defaults synchronize];

    if (update) {
        saldoUrls = [dictionary mutableCopy];
    }
}

/**
 * Ersetzt die aktuellen initialRatings mit den Werten aus dem Dictionary
 *
 * @param dictionary
 * @param withUpdate
 */
- (void)initialRatingsWithDictionary:(NSMutableDictionary*)dictionary withUpdate:(BOOL)update {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:dictionary forKey:@"initialRatings"];
    [defaults synchronize];

    if (update) {
        initialRatings = [dictionary mutableCopy];
    }
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
    return currentSaldo;
}

/**
 * Getter für das saldoUrls
 *
 * @return NSMutableDictionary*
 */
- (NSMutableDictionary*)saldoUrls {
    return saldoUrls;
}

/**
 * Getter für initialRatings
 *
 * @return NSMutableDictionary*
 */
- (NSMutableDictionary*)initialRatings {
    return initialRatings;
}

/**
 * Getter für currentRatings
 *
 * @return NSMutableDictionary*
 */
- (NSMutableDictionary*)currentRatings {
    return currentRatings;
}

@end