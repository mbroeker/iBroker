//
//  main.m
//  iBrokerDaemon
//
//  Created by Markus Bröker on 30.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Calculator.h"

#include <string.h>

/**
 * Warte timeout Sekunden
 *
 * @param timeout
 */
void safeSleep(double timeout) {
    [NSThread sleepForTimeInterval:timeout];
}

/**
 * Hilfsmethode zum Zusammenbauen der jeweiligen Format-Strings
 *
 * @param checkpoint
 * @param currentRatings
 * @param btcPercent
 * @param cUnit
 * @return
 */
NSString *makeString(NSDictionary *checkpoint, NSDictionary *currentRatings, NSString *cUnit) {
    double effectivePrice = [checkpoint[@"effectivePrice"] doubleValue];
    double effectivePercent = [checkpoint[@"percent"] doubleValue];
    double priceInBTC = [currentRatings[@"BTC"] doubleValue] / [currentRatings[cUnit] doubleValue];

    NSString *theString = [NSString stringWithFormat:@"%.6f EUR / %.8f BTC / %+.4f%%",
            effectivePrice * (1 + effectivePercent / 100.0f),
            priceInBTC,
            effectivePercent
    ];

#ifdef WITH_BEEP
    // Falls einer der Checkpoints unter -4% liegt, wird auf Teufel komm raus rumgepiept, bis eingegriffen wird.
    if (([checkpoint[@"percent"] doubleValue] - btcPercent) < -4) {
        NSBeep();
    }
#endif

    return theString;
}

/**
 * Die Hauptroutine dieses Daemons
 *
 * @param calculator
 */
void brokerRun(Calculator *calculator) {
    NSDictionary *initialRatings = [calculator initialRatings];
    NSDictionary *currentRatings = [calculator currentRatings];

    double btcPrice = 1 / [initialRatings[@"BTC"] doubleValue];
    double ethPrice = 1 / [initialRatings[@"ETH"] doubleValue];
    double xmrPrice = 1 / [initialRatings[@"XMR"] doubleValue];
    double ltcPrice = 1 / [initialRatings[@"LTC"] doubleValue];
    double dogePrice = 1 / [initialRatings[@"DOGE"] doubleValue];

    static int counter = 0;

    for (;;) {

        if ((counter++ % 25) == 0) {
            printf("%%: %-43s | %-43s | %-43s | %-43s | %-43s\n",
                [[NSString stringWithFormat:@"1 BTC war %.2f EUR", btcPrice] UTF8String],
                [[NSString stringWithFormat:@"1 ETH war %.2f EUR", ethPrice] UTF8String],
                [[NSString stringWithFormat:@"1 XMR war %.2f EUR", xmrPrice] UTF8String],
                [[NSString stringWithFormat:@"1 LTC war %.2f EUR", ltcPrice] UTF8String],
                [[NSString stringWithFormat:@"1 DOGE war %.6f EUR", dogePrice] UTF8String]
            );

            if (counter == 25) counter = 0;
        }

        NSDictionary *btcCheckpoint = [calculator checkpointForUnit:@"BTC"];
        NSDictionary *ethCheckpoint = [calculator checkpointForUnit:@"ETH"];
        NSDictionary *xmrCheckpoint = [calculator checkpointForUnit:@"XMR"];
        NSDictionary *ltcCheckpoint = [calculator checkpointForUnit:@"LTC"];
        NSDictionary *dogeCheckpoint = [calculator checkpointForUnit:@"DOGE"];

        NSString *btcString = makeString(btcCheckpoint, currentRatings, @"BTC");
        NSString *ethString = makeString(ethCheckpoint, currentRatings, @"ETH");
        NSString *xmrString = makeString(xmrCheckpoint, currentRatings, @"XMR");
        NSString *ltcString = makeString(ltcCheckpoint, currentRatings, @"LTC");
        NSString *dogeString = makeString(dogeCheckpoint, currentRatings, @"DOGE");

        printf("%%: %-43s | %-43s | %-43s | %-43s | %-43s\n",
            [btcString UTF8String],
            [ethString UTF8String],
            [xmrString UTF8String],
            [ltcString UTF8String],
            [dogeString UTF8String]
        );

        [calculator updateRatings];
        currentRatings = [calculator currentRatings];

        safeSleep(15);
    }
}

/**
 * Simpler Command-Line-Parser ohne getopt
 *
 * @param argc
 * @param argv
 * @param calculator
 */
void parseOptions(int argc, const char **argv, Calculator *calculator) {

    double value = 0;

    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "--help") || !strcmp(argv[i], "-h")) {
            printf("Usage: %s [--btc BTC] [--eth ETH] [--xmr XMR] [--ltc LTC] [--doge DOGE]\n", argv[0]);
            printf("Usage: %s --help - prints this help\n", argv[0]);

            exit(EXIT_SUCCESS);
        }

        if (!strcmp(argv[i], "--btc")) {
            value = atof(argv[i+1]);
            [calculator currentSaldo:@"BTC" withDouble:value];
        }

        if (!strcmp(argv[i], "--eth")) {
            value = atof(argv[i+1]);
            [calculator currentSaldo:@"ETH" withDouble:value];
        }

        if (!strcmp(argv[i], "--xmr")) {
            value = atof(argv[i+1]);
            [calculator currentSaldo:@"XMR" withDouble:value];
        }

        if (!strcmp(argv[i], "--ltc")) {
            value = atof(argv[i+1]);
            [calculator currentSaldo:@"LTC" withDouble:value];
        }

        if (!strcmp(argv[i], "--doge")) {
            value = atof(argv[i+1]);
            [calculator currentSaldo:@"DOGE" withDouble:value];
        }

        if (!strcmp(argv[i], "--reset")) {
            [Calculator reset];
            exit(EXIT_SUCCESS);
        }
    }

    NSDictionary *dictionary = [calculator currentSaldo];

    printf("%s: Ihr aktueller Bestand beträgt:\n", argv[0]);
    for (id key in [dictionary allKeys]) {
        printf("%4s: %.8f\n", [key UTF8String], [[dictionary objectForKey:key] doubleValue]);
    }

    exit(EXIT_SUCCESS);
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

        Calculator *calculator = [Calculator instance];

        if (argc > 1) {
            parseOptions(argc, argv, calculator);
        }

        brokerRun(calculator);
    }

    return EXIT_SUCCESS;
}
