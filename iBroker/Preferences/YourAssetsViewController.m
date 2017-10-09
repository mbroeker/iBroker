//
//  YourAssetsViewController.m
//  iBroker
//
//  Created by Markus Bröker on 06.10.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "YourAssetsViewController.h"
#import "Calculator.h"
#import "Helper.h"

@implementation YourAssetsViewController {
    Calculator *calculator;
}

/**
 *
 */
- (void)viewDidLoad {
    calculator = [Calculator instance];

    // Properties List
    self.asset1Field.placeholderString = ASSET_KEY(1);
    self.asset2Field.placeholderString = ASSET_KEY(2);
    self.asset3Field.placeholderString = ASSET_KEY(3);
    self.asset4Field.placeholderString = ASSET_KEY(4);
    self.asset5Field.placeholderString = ASSET_KEY(5);

    self.asset6Field.placeholderString = ASSET_KEY(6);
    self.asset7Field.placeholderString = ASSET_KEY(7);
    self.asset8Field.placeholderString = ASSET_KEY(8);
    self.asset9Field.placeholderString = ASSET_KEY(9);
    self.asset10Field.placeholderString = ASSET_KEY(10);

    self.asset1Field.stringValue = ASSET_KEY(1);
    self.asset2Field.stringValue = ASSET_KEY(2);
    self.asset3Field.stringValue = ASSET_KEY(3);
    self.asset4Field.stringValue = ASSET_KEY(4);
    self.asset5Field.stringValue = ASSET_KEY(5);

    self.asset6Field.stringValue = ASSET_KEY(6);
    self.asset7Field.stringValue = ASSET_KEY(7);
    self.asset8Field.stringValue = ASSET_KEY(8);
    self.asset9Field.stringValue = ASSET_KEY(9);
    self.asset10Field.stringValue = ASSET_KEY(10);

#ifdef RELEASE_BUILD
    // MASTER ASSET is not changeable in UI!
    self.asset1Field.enabled = NO;
#endif

    // Images List
    self.asset1ImageButton.image = [NSImage imageNamed:ASSET_KEY(1)];
    self.asset2ImageButton.image = [NSImage imageNamed:ASSET_KEY(2)];
    self.asset3ImageButton.image = [NSImage imageNamed:ASSET_KEY(3)];
    self.asset4ImageButton.image = [NSImage imageNamed:ASSET_KEY(4)];
    self.asset5ImageButton.image = [NSImage imageNamed:ASSET_KEY(5)];

    self.asset6ImageButton.image = [NSImage imageNamed:ASSET_KEY(6)];
    self.asset7ImageButton.image = [NSImage imageNamed:ASSET_KEY(7)];
    self.asset8ImageButton.image = [NSImage imageNamed:ASSET_KEY(8)];
    self.asset9ImageButton.image = [NSImage imageNamed:ASSET_KEY(9)];
    self.asset10ImageButton.image = [NSImage imageNamed:ASSET_KEY(10)];
}

/**
 * Aktualisierung des Views vereinheitlicht
 */
- (void)updateView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // aktualisierten Saldo besorgen
    NSArray *currentAssets = [defaults objectForKey:KEY_CURRENT_ASSETS];

    self.asset1Field.stringValue = currentAssets[1][0];
    self.asset2Field.stringValue = currentAssets[2][0];
    self.asset3Field.stringValue = currentAssets[3][0];
    self.asset4Field.stringValue = currentAssets[4][0];
    self.asset5Field.stringValue = currentAssets[5][0];
    self.asset6Field.stringValue = currentAssets[6][0];
    self.asset7Field.stringValue = currentAssets[7][0];
    self.asset8Field.stringValue = currentAssets[8][0];
    self.asset9Field.stringValue = currentAssets[9][0];
    self.asset10Field.stringValue = currentAssets[10][0];

    // Images List
    self.asset1ImageButton.image = [NSImage imageNamed:currentAssets[1][0]];
    self.asset2ImageButton.image = [NSImage imageNamed:currentAssets[2][0]];
    self.asset3ImageButton.image = [NSImage imageNamed:currentAssets[3][0]];
    self.asset4ImageButton.image = [NSImage imageNamed:currentAssets[4][0]];
    self.asset5ImageButton.image = [NSImage imageNamed:currentAssets[5][0]];

    self.asset6ImageButton.image = [NSImage imageNamed:currentAssets[6][0]];
    self.asset7ImageButton.image = [NSImage imageNamed:currentAssets[7][0]];
    self.asset8ImageButton.image = [NSImage imageNamed:currentAssets[8][0]];
    self.asset9ImageButton.image = [NSImage imageNamed:currentAssets[9][0]];
    self.asset10ImageButton.image = [NSImage imageNamed:currentAssets[10][0]];
}

/**
 *
 * @param currentAssets
 */
- (void)migrateRatings:(NSArray *)currentAssets {
    NSArray *fiatCurrencies = [calculator fiatCurrencies];
    NSDictionary *tickerKeys = @{
        currentAssets[1][0]: [NSString stringWithFormat:@"%@_%@", currentAssets[1][0], fiatCurrencies[0]],
        currentAssets[2][0]: [NSString stringWithFormat:@"%@_%@", currentAssets[1][0], currentAssets[2][0]],
        currentAssets[3][0]: [NSString stringWithFormat:@"%@_%@", currentAssets[1][0], currentAssets[3][0]],
        currentAssets[4][0]: [NSString stringWithFormat:@"%@_%@", currentAssets[1][0], currentAssets[4][0]],
        currentAssets[5][0]: [NSString stringWithFormat:@"%@_%@", currentAssets[1][0], currentAssets[5][0]],
        currentAssets[6][0]: [NSString stringWithFormat:@"%@_%@", currentAssets[1][0], currentAssets[6][0]],
        currentAssets[7][0]: [NSString stringWithFormat:@"%@_%@", currentAssets[1][0], currentAssets[7][0]],
        currentAssets[8][0]: [NSString stringWithFormat:@"%@_%@", currentAssets[1][0], currentAssets[8][0]],
        currentAssets[9][0]: [NSString stringWithFormat:@"%@_%@", currentAssets[1][0], currentAssets[9][0]],
        currentAssets[10][0]: [NSString stringWithFormat:@"%@_%@", currentAssets[1][0], currentAssets[10][0]],
    };

    NSDictionary *tickerKeysDescription = @{
        currentAssets[1][1]: currentAssets[1][0],
        currentAssets[2][1]: currentAssets[2][0],
        currentAssets[3][1]: currentAssets[3][0],
        currentAssets[4][1]: currentAssets[4][0],
        currentAssets[5][1]: currentAssets[5][0],
        currentAssets[6][1]: currentAssets[6][0],
        currentAssets[7][1]: currentAssets[7][0],
        currentAssets[8][1]: currentAssets[8][0],
        currentAssets[9][1]: currentAssets[9][0],
        currentAssets[10][1]: currentAssets[10][0],
    };

    [Calculator migrateSaldoAndRatings:tickerKeys tickerKeysDescription:tickerKeysDescription];
}

/**
 * Speichern der Adressen des Nutzers
 *
 * @param sender
 */
- (IBAction)saveAction:(id)sender {

    NSArray *currentAssets = @[
        @[DASHBOARD, DASHBOARD],
        @[self.asset1Field.stringValue.uppercaseString, [self pictureForKey:self.asset1Field.stringValue.uppercaseString]],
        @[self.asset2Field.stringValue.uppercaseString, [self pictureForKey:self.asset2Field.stringValue.uppercaseString]],
        @[self.asset3Field.stringValue.uppercaseString, [self pictureForKey:self.asset3Field.stringValue.uppercaseString]],
        @[self.asset4Field.stringValue.uppercaseString, [self pictureForKey:self.asset4Field.stringValue.uppercaseString]],
        @[self.asset5Field.stringValue.uppercaseString, [self pictureForKey:self.asset5Field.stringValue.uppercaseString]],
        @[self.asset6Field.stringValue.uppercaseString, [self pictureForKey:self.asset6Field.stringValue.uppercaseString]],
        @[self.asset7Field.stringValue.uppercaseString, [self pictureForKey:self.asset7Field.stringValue.uppercaseString]],
        @[self.asset8Field.stringValue.uppercaseString, [self pictureForKey:self.asset8Field.stringValue.uppercaseString]],
        @[self.asset9Field.stringValue.uppercaseString, [self pictureForKey:self.asset9Field.stringValue.uppercaseString]],
        @[self.asset10Field.stringValue.uppercaseString, [self pictureForKey:self.asset10Field.stringValue.uppercaseString]],
    ];

    BOOL insertable = YES;
    for (int i = 0; i < currentAssets.count; i++) {
        NSArray *check = currentAssets[i];
        if ([check[0] isEqualToString:@""] || [check[1] isEqualToString:@""]) {
            insertable = NO;
            break;
        }
    }

    if (insertable) {
        self.titleLabel.stringValue = NSLocalizedString(@"restart_required", @"Restart required");
        self.titleLabel.textColor = [NSColor redColor];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        [defaults setObject:currentAssets forKey:KEY_CURRENT_ASSETS];
        [defaults synchronize];

        [self migrateRatings:currentAssets];
    }

    // Gepeicherte Daten neu einlesen...
    [self updateView];
}

/**
 * pictureForKey
 *
 * @param key
 * @return NSString*
 */
- (NSString *)pictureForKey:(NSString *)key {

    NSDictionary *images = @{
        @"BTCD": @"Bitcoin Dark",
        @"BTC": @"Bitcoin",
        @"BTS": @"BitShares",
        @"DASH": @"Digital Cash",
        @"DCR": @"Decred",
        @"DGB": @"DigiBytes",
        @"DOGE": @"Dogecoin",
        @"EMC2": @"Einsteinium",
        @"ETC": @"Ethereum Classic",
        @"ETH": @"Ethereum",
        @"GAME": @"GameCredits",
        @"LSK": @"Lisk",
        @"LTC": @"Litecoin",
        @"MAID": @"SafeMaid",
        @"OMG": @"Omise GO",
        @"SC": @"Siacoin",
        @"STEEM": @"Steem",
        @"STRAT": @"Stratis",
        @"SYS": @"Syscoin",
        @"XEM": @"New Economy",
        @"XMR": @"Monero",
        @"XRP": @"Ripple",
        @"ZEC": @"ZCash",
    };

    NSDictionary *bittrexImages = @{
        @"ADA": @"Cardano",
        @"ADX": @"AD Token",
        @"ARK": @"Ark Byte",
        @"BAT": @"Basic Attention",
        @"BCC": @"Bitcoin Cash",
        @"ERC": @"Europe Coin",
        @"IOP": @"Internet of People",
        @"KMD": @"Komodo",
        @"MCO": @"Monaco",
        @"NEO": @"NEO",
        @"OK": @"OK",
        @"PAY": @"Pay Token",
        @"PTC": @"Pesetacoin",
        @"QTUM": @"Qtum",
        @"RDD": @"Red Coin",
        @"RISE": @"Rise",
        @"XLM": @"Lumen",
        @"XVG": @"The Verge",
    };

    NSDictionary *poloniexImages = @{
        @"BCH": @"BC Cash",
        @"STR": @"Stellar Lumens",
    };

    NSString *image = images[key];

    if (!image) {
        if ([[calculator defaultExchange] isEqualToString:EXCHANGE_BITTREX]) {
            image = bittrexImages[key];
        } else {
            image = poloniexImages[key];
        }
    }

    // We are dealing with NSUSerDefaults: It must be a valid string
    if (!image) {
        NSString *exchange = [calculator.defaultExchange isEqualToString:EXCHANGE_BITTREX] ? @"Bittrex" : @"Poloniex";
        NSString *iText = [NSString stringWithFormat:@"Unsupported Market %@ on %@", key, exchange];
        [Helper notificationText:@"UNSUPPORTED MARKET" info:iText];

        return @"";
    }

    return image;
}

@end
