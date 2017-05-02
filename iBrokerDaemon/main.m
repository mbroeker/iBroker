//
//  main.m
//  iBrokerDaemon
//
//  Created by Markus Bröker on 30.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Calculator.h"

#ifndef DEFAULT_TIMEOUT
#define DEFAULT_TIMEOUT 60
#endif

#ifndef DEFAULT_ROWS
#define DEFAULT_ROWS 50
#endif

typedef struct CONFIG {
    NSTimeInterval timeout;
    int rows;
} CONFIG;

/**
 * Warte timeout Sekunden
 *
 * @param timeout
 */
void safeSleep(NSTimeInterval timeout) {
    [NSThread sleepForTimeInterval:timeout];
}

/**
 * Hilfsfunktion zum Zusammenbauen der Headline
 *
 * @param checkpoint
 * @param currency
 * @return
 */
const char *makeHeadlineString(NSDictionary *checkpoint, NSString *currency) {
    NSString *format = format = @"1 %@ : %.2f EUR : %.2f EUR : %.2f%%";

    if ([currency isEqualToString:@"DOGE"]) {
        format = @"1 %@ : %.6f EUR : %.6f EUR : %.2f%%";
    }

    NSString *theHeadLine = [
        NSString stringWithFormat:format,
            currency,
            [checkpoint[@"initialPrice"] doubleValue],
            [checkpoint[@"currentPrice"] doubleValue],
            [checkpoint[@"percent"] doubleValue]
    ];

    return [theHeadLine UTF8String];
}

/**
 * Hilfsfunktion zum Zusammenbauen der Zeile
 *
 * @param checkpoint
 * @param currency
 * @param currentRatings
 * @param btcPercent
 * @return
 */
const char *makeString(NSDictionary *checkpoint, NSString *currency, NSDictionary *currentRatings, double btcPercent) {
    double effectivePercent = [checkpoint[@"percent"] doubleValue];
    if (![currency isEqualToString:@"BTC"]) effectivePercent -= btcPercent;

    double currentPrice = [checkpoint[@"currentPrice"] doubleValue];
    double currentPriceInBTC = [currentRatings[@"BTC"] doubleValue] / [currentRatings[currency] doubleValue];

    NSString *theString = [
        NSString stringWithFormat:@"%.6f EUR / %.8f BTC / %+.2f%%",
            currentPrice,
            currentPriceInBTC,
            effectivePercent
    ];

    return [theString UTF8String];
}

/**
 * Die Hauptroutine dieses Daemons
 *
 * @param config
 */
void brokerRun(CONFIG config) {

    static unsigned long counter = 0;

    Calculator *calculator = [Calculator instance];

    for (;;) {
        NSDictionary *currentRatings = [calculator currentRatings];

        NSDictionary *btcCheckpoint = [calculator checkpointForUnit:@"BTC"];
        NSDictionary *ethCheckpoint = [calculator checkpointForUnit:@"ETH"];
        NSDictionary *xmrCheckpoint = [calculator checkpointForUnit:@"XMR"];
        NSDictionary *ltcCheckpoint = [calculator checkpointForUnit:@"LTC"];
        NSDictionary *dogCheckpoint = [calculator checkpointForUnit:@"DOGE"];

        double btcPercent = [btcCheckpoint[@"percent"] doubleValue];

        if ((counter++ % config.rows) == 0) {
            printf("%%: %-43s | %-43s | %-43s | %-43s | %-43s\n",
                makeHeadlineString(btcCheckpoint, @"BTC"),
                makeHeadlineString(ethCheckpoint, @"ETH"),
                makeHeadlineString(xmrCheckpoint, @"XMR"),
                makeHeadlineString(ltcCheckpoint, @"LTC"),
                makeHeadlineString(dogCheckpoint, @"DOGE")
            );
        }

        printf("%%: %-43s | %-43s | %-43s | %-43s | %-43s\n",
            makeString(btcCheckpoint, @"BTC", currentRatings, btcPercent),
            makeString(ethCheckpoint, @"ETH", currentRatings, btcPercent),
            makeString(xmrCheckpoint, @"XMR", currentRatings, btcPercent),
            makeString(ltcCheckpoint, @"LTC", currentRatings, btcPercent),
            makeString(dogCheckpoint, @"DOGE", currentRatings, btcPercent)
        );

        [calculator updateRatings];
        safeSleep(config.timeout);
    }
}
/**
 * Kompakte Übersicht der Funktionen des Daemons
 *
 * @param name
 */
void usage(const char *name) {
    printf("Anzeige der Gewinne und Verluste beim Handeln mit Alt-Coins\n\n");
    printf("Copyright   Copyright(C) 2017 4customers UG\n");
    printf("Autor       Markus Bröker<broeker.markus@googlemail.com>\n\n");

    printf("Benutzung:  %s [OPTIONEN]\n\n", name);

    printf("Kontooptionen\n\n");

    printf("  --balance\t\tZeige den aktuellen Gesamtsaldo aller Coins an\n");
    printf("  --list\n\n");

    printf("  --btc ANZAHL\t\tSetze den aktuellen Saldo für Bitcoins\n");
    printf("  --eth ANZAHL\t\tSetze den aktuellen Saldo für Ethereum\n");
    printf("  --xmr ANZAHL\t\tSetze den aktuellen Saldo für Monero\n");
    printf("  --ltc ANZAHL\t\tSetze den aktuellen Saldo für Lightcoins\n");
    printf("  --doge ANZAHL\t\tSetze den aktuellen Saldo für Dogecoins\n\n");

    printf("ANZAHL im amerikanische Dezimalformat (0.5 anstatt 0,5)\n\n");

    printf("Allgemeine Optionen\n\n");

    printf("  --rows ROWS\t\tAnzeige der Überschrift nach ROWS Zeilen\n");
    printf("  --timeout TIMEOUT\tAktualisierungsinterval TIMEOUT in Sekunden\n");
    printf("  --reset\t\tSetze die Daten auf die Anfangseinstellungen zurück\n");
    printf("  --help\t\tZeige diese Hilfe an\n\n");

    printf("Bei Fragen und Anregungen kontaktieren Sie den Support unter +49 0151 54129488!\n");

    exit(EXIT_SUCCESS);
}

/**
 * Simpler Command-Line-Parser ohne getopt
 *
 * @param argc
 * @param argv
 */
void parseOptions(int argc, const char **argv, CONFIG *config) {

    Calculator *calculator = [Calculator instance];
    double value = 0;

    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "--help") || !strcmp(argv[i], "-h")) {
            usage(argv[0]);
        }

        if (!strcmp(argv[i], "--btc")) {
            value = atof(argv[i + 1]);
            [calculator currentSaldo:@"BTC" withDouble:value];
        }

        if (!strcmp(argv[i], "--eth")) {
            value = atof(argv[i + 1]);
            [calculator currentSaldo:@"ETH" withDouble:value];
        }

        if (!strcmp(argv[i], "--xmr")) {
            value = atof(argv[i + 1]);
            [calculator currentSaldo:@"XMR" withDouble:value];
        }

        if (!strcmp(argv[i], "--ltc")) {
            value = atof(argv[i + 1]);
            [calculator currentSaldo:@"LTC" withDouble:value];
        }

        if (!strcmp(argv[i], "--doge")) {
            value = atof(argv[i + 1]);
            [calculator currentSaldo:@"DOGE" withDouble:value];
        }

        if (!strcmp(argv[i], "--timeout") || !strcmp(argv[i], "-t")) {
            value = atof(argv[i + 1]);
            config->timeout = value;
        }

        if (!strcmp(argv[i], "--rows")) {
            value = atof(argv[i + 1]);
            config->rows = value;
        }

        if (!strcmp(argv[i], "--reset") || !strcmp(argv[i], "-r")) {
            [Calculator reset];

            exit(EXIT_SUCCESS);
        }

        if (!strcmp(argv[i], "--balance") || !strcmp(argv[i], "--list")) {
            NSDictionary *dictionary = [calculator currentSaldo];

            for (id key in [dictionary allKeys]) {
                printf("%4s: %.8f\n", [key UTF8String], [dictionary[key] doubleValue]);
            }

            exit(EXIT_SUCCESS);
        }
    }
}

/**
 * Hauptroutine des kleinen, handlichen Daemons
 *
 * @param argc
 * @param argv
 * @return
 */
int main(int argc, const char *argv[]) {
    @autoreleasepool {
        CONFIG config = { DEFAULT_TIMEOUT, DEFAULT_ROWS };

        if (argc > 1) {
            parseOptions(argc, argv, &config);
        }

        brokerRun(config);
    }

    return EXIT_SUCCESS;
}
