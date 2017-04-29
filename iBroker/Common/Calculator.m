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

    // Normale Eigenschaften
    NSMutableDictionary *currentRatings;
    NSMutableDictionary *saldoUrls;
}

/*
 * Singleton Pattern nach Recherche im Internet...
 */
+ (id)instance {
    static Calculator *calculator = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        calculator = [[Calculator alloc] init];
    });

    return calculator;
}

/**
 * Der private Konstruktor der Klasse, der deswegen nicht in Calculator.h gelistet wird.
 *
 */
- (id)init {

    if (self = [super init]) {

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        currentSaldo = [[defaults objectForKey:@"currentSaldo"] mutableCopy];

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
    }

    [self waitForUpdateRatings];

    return self;
}

/**
 * Aktualisiere die Kurse der jeweiligen Währung
 */
- (void)checkPointForKey:(NSString *)key {
    NSDictionary *tabStrings = @{
        @"Dashboard": @[@"ALL", @"alle Kurse"],
        @"Bitcoin": @[@"BTC", @"den Bitcoin Kurs"],
        @"Ethereum": @[@"ETH", @"den Ethereum Kurs"],
        @"Litecoin": @[@"LTC", @"den Litecoin Kurs"],
        @"Monero": @[@"XMR", @"den Monero Kurs"],
        @"Dogecoin": @[@"DOGE", @"den Dogecoin Kurs"],
    };

    NSString *msg = [NSString stringWithFormat:@"Möchten Sie %@ aktualisieren?", tabStrings[key][1]];
    NSString *info = @"Der Vergleich (+/-) bezieht sich auf die zuletzt gespeicherten Kurse!";

    if ([Helper messageText:msg info:info] == NSAlertFirstButtonReturn) {

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        if ([tabStrings[key][0] isEqualToString:@"ALL"]) {
            initialRatings = [currentRatings mutableCopy];
        } else {
            initialRatings[tabStrings[key][0]] = currentRatings[tabStrings[key][0]];
        }

        [defaults setObject:initialRatings forKey:@"initialRatings"];
        [defaults synchronize];
    }
}

/**
 * Liefert NSDictionary mit den Schlüsseln "initialPrice", "currentPrice", "percent"
 *
 * @param unit
 * @return NSDictionary*
 */
- (NSDictionary*)unitsAndPercent:(NSString*)unit {
    double initialPrice = 1.0 / [initialRatings[unit] doubleValue];
    double currentPrice = 1.0 / [currentRatings[unit] doubleValue];

    double percent = 100.0 * (currentPrice / initialPrice) - 100.0;

    return @{
        @"initialPrice": @(initialPrice),
        @"currentPrice": @(currentPrice),
        @"percent": @(percent)
    };
}

/**
 * Berechne den Gesamtwert der Geldbörsen in Euro oder Dollar...
 */
- (double)calculate:(NSString *)currency {
    return [self calculateWithRatings:currentRatings currency:currency];
}

- (double)calculateWithRatings:(NSDictionary*)ratings currency:(NSString *)currency {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    currentSaldo = [[defaults objectForKey:@"currentSaldo"] mutableCopy];

    double btc = [currentSaldo[@"BTC"] doubleValue] / [ratings[@"BTC"] doubleValue];
    double eth = [currentSaldo[@"ETH"] doubleValue] / [ratings[@"ETH"] doubleValue];
    double ltc = [currentSaldo[@"LTC"] doubleValue] / [ratings[@"LTC"] doubleValue];
    double xmr = [currentSaldo[@"XMR"] doubleValue] / [ratings[@"XMR"] doubleValue];
    double doge = [currentSaldo[@"DOGE"] doubleValue] / [ratings[@"DOGE"] doubleValue];

    double sum = btc + eth + ltc + xmr + doge;

    if ([currency isEqualToString:@"EUR"]) {
        return sum;
    }

    return sum * [ratings[currency] doubleValue];
}

/**
 * synchronisierter Block, der garantiert, dass es nur ein Update gibt
 */
- (void) waitForUpdateRatings {

    @synchronized (self) {
        [self updateRatings];
    }
}

/**
 * Besorge die Kurse von cryptocompare per JSON-Request und speichere Sie in den App-Einstellungen
 */
- (void)updateRatings {
    NSString *jsonURL = @"https://min-api.cryptocompare.com/data/pricemulti?fsyms=EUR&tsyms=USD,BTC,ETH,LTC,XMR,DOGE";

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
            [Helper messageText:[jsonError description] info:[jsonError debugDescription]];
            return;
        }

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        currentRatings = [allkeys[@"EUR"] mutableCopy];
        initialRatings = [[defaults objectForKey:@"initialRatings"] mutableCopy];

        // DOGE RATINGS faken
        currentRatings[@"DOGE"] = [NSString stringWithFormat:@"%.8f", [self updateDoge]];

        if (initialRatings == NULL) {
            [self initialRatingsWithDictionary:currentRatings withUpdate:true];
        }

        hasFinished = true;

    }] resume];

    while(!hasFinished) {
        [self safeSleep:01];
    }
}

- (double) updateDoge {
    NSString *jsonURL = @"https://api.cryptonator.com/api/ticker/doge-eur";

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
            [Helper messageText:[jsonError description] info:[jsonError debugDescription]];
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

// Warte timeout Sekunden
- (void)safeSleep:(double)timeout {
    [NSThread sleepForTimeInterval:timeout];
}

/**
 * Liefert den aktuellen Saldo der jeweiligen Crypto-Währung
 */
- (double)currentSaldo:(NSString*)cUnit {
    return [currentSaldo[cUnit] doubleValue];
}

/**
 * Liefert die aktuelle URL für das angegebene Label/Tab
 */
- (NSString*)saldoUrlForLabel:(NSString*)label {
    return saldoUrls[label];
}

/**
 * Aktualisiert den aktuellen Saldo für die CryptoWährung "cUnit" mit dem Wert "saldo"
 */
- (void)currentSaldo:(NSString*)cUnit withDouble: (double) saldo {
    currentSaldo[cUnit] = [[NSNumber alloc] initWithDouble:saldo];

    [self currentSaldoForDictionary:currentSaldo withUpdate:false];
}

/**
 * Ersetzt die aktuellen Saldo mit den Werten aus dem Dictionary
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
 */
- (void)initialRatingsWithDictionary:(NSMutableDictionary*)dictionary withUpdate:(BOOL)update {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:dictionary forKey:@"initialRatings"];
    [defaults synchronize];

    if (update) {
        initialRatings = [dictionary mutableCopy];
    }
}

/* Properties gefallen mir nicht */
- (NSMutableDictionary*)currentSaldo {
    return currentSaldo;
}

- (NSMutableDictionary*)saldoUrls {
    return saldoUrls;
}

- (NSMutableDictionary*)initialRatings {
    return initialRatings;
}

- (NSMutableDictionary*)currentRatings {
    return currentRatings;
}

@end