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

    BOOL hasFinished;
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

    // uR blockiert, das Warten nicht!
    while (!hasFinished) {
        [self safeSleep:0.1];
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
    hasFinished = false;

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
            [defaults setObject:currentRatings forKey:@"initialRatings"];
            initialRatings = [currentRatings mutableCopy];
        }

        [defaults synchronize];
        hasFinished = true;

    }] resume];
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

// Warte maximal n * timeout Sekunden und gebe dann auf...
- (void)safeSleep:(double)timeout {
    const int MAX_RETRIES = 250;

    static long int loops = 0;

    if (++loops < MAX_RETRIES) {
        [NSThread sleepForTimeInterval:timeout];
    } else {
        /* if ([Helper messageText:@"Bitte warten" info:@"Netzwerkauslastung ist derzeit sehr hoch."] == NSAlertFirstButtonReturn) {
            [NSApp terminate:self];
        } */

        NSLog(@"Mogelpackung: Die Daten konnten nicht aktualsiert werden.");
        hasFinished = true;
    }

    if (hasFinished) {
        loops = 0;
    }
}

- (NSMutableDictionary*)currentSaldo {
    return currentSaldo;
}

- (double)currentSaldo:(NSString*)unit {
    return [currentSaldo[unit] doubleValue];
}

- (void)currentSaldoForUnit:(NSString*)cUnit withDouble: (double) saldo {
    currentSaldo[cUnit] = [[NSNumber alloc] initWithDouble:saldo];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:currentSaldo forKey:@"currentSaldo"];
    [defaults synchronize];
}

- (NSString*)saldoUrlForLabel:(NSString*)label {
    return saldoUrls[label];
}

- (NSMutableDictionary*)initialRatings {
    return initialRatings;
}

- (NSMutableDictionary*)currentRatings {
    return currentRatings;
}

@end