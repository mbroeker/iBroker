//
//  TemplateViewController.m
//  iBroker
//
//  Created by Markus Bröker on 04.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//
#ifndef DEBUG
#define DEBUG 1
#endif

const double CHECKPOINT_PERCENTAGE = 5.0;

typedef struct COINCHANGE {
    double effectivePercent;
    double diffsInPercent;
    double diffsInEuro;
} COINCHANGE;

typedef struct DASHBOARD {
    COINCHANGE coinchange;

    double initialBalancesInEUR;
    double totalBalancesInEUR;
    double balancesInEUR;
    double balancesInBTC;
    double shares;
} DASHBOARD;

#import "TemplateViewController.h"
#import "Helper.h"
#import "Calculator.h"

@implementation TemplateViewController {
@private
    Calculator *calculator;

    NSMutableDictionary *applications;
    NSMutableDictionary *traders;

    // Die Tabs
    NSDictionary *tabs;
    NSDictionary *labels;

    // Bilder und URLs
    NSDictionary *images;
    NSString *homeURL;

    // EURO UND USD derzeit
    NSArray *fiatCurrencies;
    NSString *fiatCurrencySymbol;

    // meine nettes Rot
    NSColor *defaultDangerColor;

    NSColor *defaultGainColor;
    NSColor *defaultLooseColor;

    // Low / High
    NSColor *defaultLowerColor;
    NSColor *defaultHigherColor;

    // Low / High
    NSColor *defaultLowestColor;
    NSColor *defaultHighestColor;
}

/**
 * AKtualsiert das aktive Tab
 */
- (void)updateCurrentView:(BOOL)withRatings {
    if (withRatings) {
        [calculator updateRatings];
    }

    // View aktualisieren
    NSString *label = self.headlineLabel.stringValue;
    [self updateTemplateView:labels[label]];
}

/**
 * Zurücksetzen der Farben
 */
- (void)resetColors {
    NSColor *chartBGColor = [NSColor whiteColor];
    NSColor *infoBarFGColor = [NSColor colorWithCalibratedRed:178.0f / 255.0f green:178.0f / 255.0f blue:178.0f / 255.0f alpha:1.0f];

    // Poloniex Leiste
    self.volumeField.backgroundColor = chartBGColor;
    self.highField.backgroundColor = chartBGColor;
    self.changeField.backgroundColor = chartBGColor;
    self.high24Field.backgroundColor = chartBGColor;
    self.low24Field.backgroundColor = chartBGColor;

    // Chart Leiste
    self.currency1Field.backgroundColor = chartBGColor;
    self.currency2Field.backgroundColor = chartBGColor;
    self.currency3Field.backgroundColor = chartBGColor;
    self.currency4Field.backgroundColor = chartBGColor;
    self.currency5Field.backgroundColor = chartBGColor;

    self.percentLabel.textColor = [NSColor whiteColor];

    self.iBrokerLabel.textColor = infoBarFGColor;
    self.statusLabel.textColor = infoBarFGColor;
    self.infoLabel.textColor = infoBarFGColor;
}

/**
 * Initialisiere alle Datenstrukturen
 */
- (void)initializeWithDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    calculator = [Calculator instance];

    // Liste der Fiat-Währungen
    fiatCurrencies = [calculator fiatCurrencies];

    if ([fiatCurrencies[0] isEqualToString:@"EUR"]) {
        fiatCurrencySymbol = @"€";
    } else {
        fiatCurrencySymbol = @"$";
    }

    tabs = @{
        @"Dashboard": @[@"Dashboard", @1],
        BTC: @[@"Bitcoin", @1],
        ZEC: @[@"ZCash", @1],
        ETH: @[@"Ethereum", @1],
        XMR: @[@"Monero", @1],
        LTC: @[@"Litecoin", @1],
        GAME: @[@"Gamecoin", @1],
        XRP: @[@"Ripple", @1],
        MAID: @[@"Safe Maid Coin", @1],
        STR: @[@"Stellar Lumens", @1],
        DOGE: @[@"Dogecoin", @1],
    };

    labels = @{
        @"Dashboard": @"Dashboard",
        @"Bitcoin": BTC,
        @"ZCash": ZEC,
        @"Ethereum": ETH,
        @"Monero": XMR,
        @"Litecoin": LTC,
        @"Gamecoin": GAME,
        @"Ripple": XRP,
        @"Safe Maid Coin": MAID,
        @"Stellar Lumens": STR,
        @"Dogecoin": DOGE
    };

    images = @{
        EUR: [NSImage imageNamed:EUR],
        USD: [NSImage imageNamed:USD],
        BTC: [NSImage imageNamed:BTC],
        ZEC: [NSImage imageNamed:ZEC],
        ETH: [NSImage imageNamed:ETH],
        XMR: [NSImage imageNamed:XMR],
        LTC: [NSImage imageNamed:LTC],
        GAME: [NSImage imageNamed:GAME],
        XRP: [NSImage imageNamed:XRP],
        MAID: [NSImage imageNamed:MAID],
        STR: [NSImage imageNamed:STR],
        DOGE: [NSImage imageNamed:DOGE]
    };

    applications = [[defaults objectForKey:@"applications"] mutableCopy];

    if (applications == NULL) {
        applications = [@{
            @"Bitcoin": @"/Applications/Electrum.App",
            @"ZCash": @"",
            @"Ethereum": @"/Applications/Ethereum Wallet.App",
            @"Monero": @"/Applications/monero-wallet-gui.App",
            @"Litecoin": @"/Applications/Electrum-LTC.App",
            @"Gamecoin": @"",
            @"Ripple": @"",
            @"Safe Maid Coin": @"",
            @"Stellar Lumens": @"",
            @"Dogecoin": @"/Applications/MultiDoge.App",
        } mutableCopy];

        [defaults setObject:applications forKey:@"applications"];
    }

    traders = [defaults objectForKey:@"traders"];

    if (traders == NULL) {
        traders = [@{
            @"homepage": @"https://www.4customers.de/ibroker/",
            @"trader1": @"https://www.shapeshift.io",
            @"trader2": @"https://www.blocktrades.us",
        } mutableCopy];

        [defaults setObject:traders forKey:@"traders"];
    }

    // Ich brauche den Placeholder Text eigentlich nur in Xcode zum Finden des Labels
    self.statusLabel.placeholderString = @"+/- 0";
    self.infoLabel.placeholderString = @"Escobar Edition";

    // mein patentgeschützer Rotton
    defaultDangerColor = [NSColor colorWithCalibratedRed:200.0f/255.0f green:79.0f/255.0f blue:35.0f/255.0f alpha:1.0f];

    defaultHigherColor = [NSColor greenColor];
    defaultHighestColor = [NSColor magentaColor];
    defaultGainColor = [NSColor blueColor];

    defaultLowerColor = [NSColor yellowColor];
    defaultLowestColor = [NSColor orangeColor];
    defaultLooseColor = [NSColor redColor];

    [defaults synchronize];

    // Setze das Label des Eingabefeldes für den Taschenrechner auf Fiat-Währung 2 = USD
    self.rateInputCurrencyLabel.stringValue = fiatCurrencies[1];

    // Setze das selektierte Element des Taschenrechners auf Fiat Währung 1 = EUR
    [self.exchangeSelection selectItemWithTitle:fiatCurrencies[0]];

    // Migration älterer Installationen
    if (!applications[@"ZCash"]) {
        [self updateAssistant];
    }
}

/**
 * simpler Upgrade Assistent
 */
- (void)updateAssistant {

    BOOL mustUpdate = false;

    if (!applications[@"ZCash"]) {
        applications[@"ZCash"] = @"https://explorer.zcha.in";
        mustUpdate = true;
    }

    if (!applications[@"Gamecoin"]) {
        applications[@"Gamecoin"] = @"";
        mustUpdate = true;
    }

    if (!applications[@"Ripple"]) {
        applications[@"Ripple"] = @"";
        mustUpdate = true;
    }

    if (!applications[@"Maid Safe Coin"]) {
        applications[@"Maid Safe Coin"] = @"";
        mustUpdate = true;
    }

    if (!applications[@"Stellar Lumens"]) {
        applications[@"Stellar Lumens"] = @"";
        mustUpdate = true;
    }

    if (mustUpdate) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:applications forKey:@"applications"];
        NSLog(@"Migrating applications");

        [defaults synchronize];
    }

}

/**
 * Setzen der Formatierungsregeln für die Eingabefelder
 */
- (void)viewWillAppear {
    // Währungsformat mit 2 Nachkommastellen
    NSNumberFormatter *currencyFormatter = [self.currencyUnits formatter];
    [currencyFormatter setMinimumFractionDigits:2];
    [currencyFormatter setMaximumFractionDigits:2];

    // Crypto-Währungsformat mit 4-8 Nachkommastellen
    NSNumberFormatter *cryptoFormatter = [self.cryptoUnits formatter];
    [cryptoFormatter setMinimumFractionDigits:8];
    [cryptoFormatter setMaximumFractionDigits:8];

    [_cryptoUnits setTarget:self];
    [_cryptoUnits setAction:@selector(cryptoAction:)];
}

/**
 * Initialisierung der Sicht / des View
 */
- (void)viewDidLoad {
    [super viewDidLoad];

    // Initialisieren der Anwendung und der Datenstrukturen
    [self initializeWithDefaults];
}

/**
 * Markieren der Gewinner obersten Leiste
 */
- (void)markGainers {
    // Hole die aktualisierten Dictionaries
    NSDictionary *btcCheckpoint = [calculator checkpointForAsset:BTC];
    NSMutableDictionary *currentRatings = [calculator currentRatings];

    double btcPercent = [btcCheckpoint[BTC] doubleValue];

    NSMutableDictionary *currencyUnits = [[NSMutableDictionary alloc] init];
    for (id cAsset in currentRatings) {
        NSDictionary *aCheckpoint = [calculator checkpointForAsset:cAsset];

        double cPercent = [aCheckpoint[KEY_PERCENT] doubleValue];

        if ([cAsset isEqualToString:BTC] && cPercent > 0) self.currency1Field.backgroundColor = defaultHigherColor;
        if ([cAsset isEqualToString:ZEC] && cPercent > 0) self.currency2Field.backgroundColor = defaultHigherColor;
        if ([cAsset isEqualToString:ETH] && cPercent > 0) self.currency3Field.backgroundColor = defaultHigherColor;
        if ([cAsset isEqualToString:XMR] && cPercent > 0) self.currency4Field.backgroundColor = defaultHigherColor;
        if ([cAsset isEqualToString:LTC] && cPercent > 0) self.currency5Field.backgroundColor = defaultHigherColor;
        if ([cAsset isEqualToString:GAME] && cPercent > 0) self.currency6Field.backgroundColor = defaultHigherColor;
        if ([cAsset isEqualToString:XRP] && cPercent > 0) self.currency7Field.backgroundColor = defaultHigherColor;
        if ([cAsset isEqualToString:MAID] && cPercent > 0) self.currency8Field.backgroundColor = defaultHigherColor;
        if ([cAsset isEqualToString:STR] && cPercent > 0) self.currency9Field.backgroundColor = defaultHigherColor;
        if ([cAsset isEqualToString:DOGE] && cPercent > 0) self.currency10Field.backgroundColor = defaultHigherColor;

        if ([cAsset isEqualToString:BTC] && cPercent > CHECKPOINT_PERCENTAGE) self.currency1Field.backgroundColor = defaultHighestColor;
        if ([cAsset isEqualToString:ZEC] && cPercent > CHECKPOINT_PERCENTAGE) self.currency2Field.backgroundColor = defaultHighestColor;
        if ([cAsset isEqualToString:ETH] && cPercent > CHECKPOINT_PERCENTAGE) self.currency3Field.backgroundColor = defaultHighestColor;
        if ([cAsset isEqualToString:XMR] && cPercent > CHECKPOINT_PERCENTAGE) self.currency4Field.backgroundColor = defaultHighestColor;
        if ([cAsset isEqualToString:LTC] && cPercent > CHECKPOINT_PERCENTAGE) self.currency5Field.backgroundColor = defaultHighestColor;
        if ([cAsset isEqualToString:GAME] && cPercent > CHECKPOINT_PERCENTAGE) self.currency6Field.backgroundColor = defaultHighestColor;
        if ([cAsset isEqualToString:XRP] && cPercent > CHECKPOINT_PERCENTAGE) self.currency7Field.backgroundColor = defaultHighestColor;
        if ([cAsset isEqualToString:MAID] && cPercent > CHECKPOINT_PERCENTAGE) self.currency8Field.backgroundColor = defaultHighestColor;
        if ([cAsset isEqualToString:STR] && cPercent > CHECKPOINT_PERCENTAGE) self.currency9Field.backgroundColor = defaultHighestColor;
        if ([cAsset isEqualToString:DOGE] && cPercent > CHECKPOINT_PERCENTAGE) self.currency10Field.backgroundColor = defaultHighestColor;

        // Bilde die Differenz aus BTC und der jeweiligen Cryptowährung, falls es sich nicht um BTC handelt.
        if (![cAsset isEqualToString:BTC]) {
            cPercent -= btcPercent;
        }

        currencyUnits[cAsset] = @(cPercent);
    }

    NSNumber *highest = [[currencyUnits allValues] valueForKeyPath:@"@max.self"];

    if (highest != nil) {
        NSString *highestKey = [currencyUnits allKeysForObject:highest][0];

        if ([highestKey isEqualToString:BTC]) self.currency1Field.backgroundColor = defaultGainColor;
        if ([highestKey isEqualToString:ZEC]) self.currency2Field.backgroundColor = defaultGainColor;
        if ([highestKey isEqualToString:ETH]) self.currency3Field.backgroundColor = defaultGainColor;
        if ([highestKey isEqualToString:XMR]) self.currency4Field.backgroundColor = defaultGainColor;
        if ([highestKey isEqualToString:LTC]) self.currency5Field.backgroundColor = defaultGainColor;
        if ([highestKey isEqualToString:GAME]) self.currency6Field.backgroundColor = defaultGainColor;
        if ([highestKey isEqualToString:XRP]) self.currency7Field.backgroundColor = defaultGainColor;
        if ([highestKey isEqualToString:MAID]) self.currency8Field.backgroundColor = defaultGainColor;
        if ([highestKey isEqualToString:STR]) self.currency9Field.backgroundColor = defaultGainColor;
        if ([highestKey isEqualToString:DOGE]) self.currency10Field.backgroundColor = defaultGainColor;
    }
}

/**
 * Markieren der Verlierer der obersten Leiste
 */
- (void)markLoosers {
    NSMutableDictionary *currentRatings = [calculator currentRatings];

    NSDictionary *btcCheckpoint = [calculator checkpointForAsset:BTC];
    double btcPercent = [btcCheckpoint[BTC] doubleValue];

    NSMutableDictionary *currencyUnits = [[NSMutableDictionary alloc] init];
    for (id cAsset in currentRatings) {
        NSDictionary *aCheckpoint = [calculator checkpointForAsset:cAsset];

        double cPercent = [aCheckpoint[KEY_PERCENT] doubleValue];

        if ([cAsset isEqualToString:BTC] && cPercent < 0) self.currency1Field.backgroundColor = defaultLowerColor;
        if ([cAsset isEqualToString:ZEC] && cPercent < 0) self.currency2Field.backgroundColor = defaultLowerColor;
        if ([cAsset isEqualToString:ETH] && cPercent < 0) self.currency3Field.backgroundColor = defaultLowerColor;
        if ([cAsset isEqualToString:XMR] && cPercent < 0) self.currency4Field.backgroundColor = defaultLowerColor;
        if ([cAsset isEqualToString:LTC] && cPercent < 0) self.currency5Field.backgroundColor = defaultLowerColor;
        if ([cAsset isEqualToString:GAME] && cPercent < 0) self.currency6Field.backgroundColor = defaultLowerColor;
        if ([cAsset isEqualToString:XRP] && cPercent < 0) self.currency7Field.backgroundColor = defaultLowerColor;
        if ([cAsset isEqualToString:MAID] && cPercent < 0) self.currency8Field.backgroundColor = defaultLowerColor;
        if ([cAsset isEqualToString:STR] && cPercent < 0) self.currency9Field.backgroundColor = defaultLowerColor;
        if ([cAsset isEqualToString:DOGE] && cPercent < 0) self.currency10Field.backgroundColor = defaultLowerColor;

        if ([cAsset isEqualToString:BTC] && cPercent < -CHECKPOINT_PERCENTAGE) self.currency1Field.backgroundColor = defaultLowestColor;
        if ([cAsset isEqualToString:ZEC] && cPercent < -CHECKPOINT_PERCENTAGE) self.currency2Field.backgroundColor = defaultLowestColor;
        if ([cAsset isEqualToString:ETH] && cPercent < -CHECKPOINT_PERCENTAGE) self.currency3Field.backgroundColor = defaultLowestColor;
        if ([cAsset isEqualToString:XMR] && cPercent < -CHECKPOINT_PERCENTAGE) self.currency4Field.backgroundColor = defaultLowestColor;
        if ([cAsset isEqualToString:LTC] && cPercent < -CHECKPOINT_PERCENTAGE) self.currency5Field.backgroundColor = defaultLowestColor;
        if ([cAsset isEqualToString:GAME] && cPercent < -CHECKPOINT_PERCENTAGE) self.currency6Field.backgroundColor = defaultLowestColor;
        if ([cAsset isEqualToString:XRP] && cPercent < -CHECKPOINT_PERCENTAGE) self.currency7Field.backgroundColor = defaultLowestColor;
        if ([cAsset isEqualToString:MAID] && cPercent < -CHECKPOINT_PERCENTAGE) self.currency8Field.backgroundColor = defaultLowestColor;
        if ([cAsset isEqualToString:STR] && cPercent < -CHECKPOINT_PERCENTAGE) self.currency9Field.backgroundColor = defaultLowestColor;
        if ([cAsset isEqualToString:DOGE] && cPercent < -CHECKPOINT_PERCENTAGE) self.currency10Field.backgroundColor = defaultLowestColor;

        // Bilde die Differenz aus BTC und der jeweiligen Cryptowährung, falls es sich nicht um BTC handelt.
        if (![cAsset isEqualToString:BTC]) {
            cPercent -= btcPercent;
        }

        currencyUnits[cAsset] = @(cPercent);
    }

    NSNumber *lowest = [[currencyUnits allValues] valueForKeyPath:@"@min.self"];

    if (lowest != nil) {
        NSString *lowestKey = [currencyUnits allKeysForObject:lowest][0];

        if ([lowestKey isEqualToString:BTC]) self.currency1Field.backgroundColor = defaultLooseColor;
        if ([lowestKey isEqualToString:ZEC]) self.currency2Field.backgroundColor = defaultLooseColor;
        if ([lowestKey isEqualToString:ETH]) self.currency3Field.backgroundColor = defaultLooseColor;
        if ([lowestKey isEqualToString:XMR]) self.currency4Field.backgroundColor = defaultLooseColor;
        if ([lowestKey isEqualToString:LTC]) self.currency5Field.backgroundColor = defaultLooseColor;
        if ([lowestKey isEqualToString:GAME]) self.currency6Field.backgroundColor = defaultLooseColor;
        if ([lowestKey isEqualToString:XRP]) self.currency7Field.backgroundColor = defaultLooseColor;
        if ([lowestKey isEqualToString:MAID]) self.currency8Field.backgroundColor = defaultLooseColor;
        if ([lowestKey isEqualToString:STR]) self.currency9Field.backgroundColor = defaultLooseColor;
        if ([lowestKey isEqualToString:DOGE]) self.currency10Field.backgroundColor = defaultLooseColor;
    }
}

/**
 * Einfärben der Labels
 */
- (void)markDockLabels:(COINCHANGE) loop_vars {
    if (loop_vars.effectivePercent < 0.0) {
        self.percentLabel.textColor = defaultLooseColor;
    }

    if (loop_vars.diffsInPercent < 0.0) {
        self.infoLabel.textColor = defaultDangerColor;
    }

    if (loop_vars.diffsInEuro < 0.0) {
        self.statusLabel.textColor = defaultDangerColor;
    }

    if (loop_vars.diffsInEuro < 0.0 && loop_vars.diffsInPercent < 0.0) {
        self.iBrokerLabel.textColor = defaultDangerColor;
    }
}

// Simpler Fetch der Poloniex Daten
-(void)updateTicker:(NSString*)label {

    if ([label isEqualToString:@"Dashboard"]) {
        self.volumeField.stringValue = @"---";
        self.highField.stringValue = @"---";
        self.changeField.stringValue = @"---";
        self.high24Field.stringValue = @"---";
        self.low24Field.stringValue = @"---";

        return;
    }

    NSDictionary *keys = [calculator tickerKeys];

    NSDictionary *ticker = [calculator ticker];
    NSDictionary *tickerData = ticker[keys[label]];

    double factor = [tabs[label][1] doubleValue];

    int fractions = 8;

    if ([label isEqualToString:BTC]) {
        fractions = 2;
        self.highLabel.stringValue = @"OPEN";
    }

    double changeInPercent = 100 * [tickerData[POLONIEX_PERCENT] doubleValue];
    self.volumeField.stringValue = [Helper double2German:factor * [tickerData[POLONIEX_LAST] doubleValue] min:fractions max:fractions];
    self.highField.stringValue = [Helper double2German:factor * [tickerData[POLONIEX_HIGH] doubleValue] min:fractions max:fractions];
    self.changeField.stringValue = [Helper double2GermanPercent:changeInPercent fractions:2];
    self.high24Field.stringValue = [Helper double2German:factor * [tickerData[POLONIEX_HIGH24] doubleValue] min:fractions max:fractions];
    self.low24Field.stringValue = [Helper double2German:factor * [tickerData[POLONIEX_LOW24] doubleValue] min:fractions max:fractions];

    if (changeInPercent < 0) {
        self.changeField.backgroundColor = defaultLowerColor;
    }

    if (changeInPercent > 0) {
        self.changeField.backgroundColor = defaultHigherColor;
    }

    if (changeInPercent < -CHECKPOINT_PERCENTAGE) {
        self.changeField.backgroundColor = defaultLowestColor;
    }

    if (changeInPercent > CHECKPOINT_PERCENTAGE) {
        self.changeField.backgroundColor = defaultHighestColor;
    }
}

/**
 * Übersicht mit richtigen Live-Werten
 */
- (void)updateOverview {
    // Aktualisiere die URL für den HOME-Button
    homeURL = [calculator saldoUrlForLabel:@"Dashboard"];

    // Farben zurück setzen
    [self resetColors];

#ifdef DEBUG
    NSLog(@"%4s %14s | %14s | %14s | %14s | %14s | %10s | %11s | %9s |\n",
        [@"####" UTF8String],
        [@"BALANCE" UTF8String],
        [@"BALANCE IN EUR" UTF8String],
        [@"BALANCE IN BTC" UTF8String],
        [@"INITIAL IN EUR" UTF8String],
        [@"CURRENT IN EUR" UTF8String],
        [@"SHARE IN %" UTF8String],
        [@"DIFF IN EUR" UTF8String],
        [@"DIFF IN %" UTF8String]
    );
#endif

    NSMutableDictionary *currentSaldo = [calculator currentSaldo];
    NSMutableDictionary *initialRatings = [calculator initialRatings];
    NSMutableDictionary *currentRatings = [calculator currentRatings];

    // Standardmäßig sind die Werte zwar genullt, aber schaden tuts nicht.
    DASHBOARD loop_vars = { {0, 0, 0}, 0, 0, 0, 0, 0 };

    loop_vars.totalBalancesInEUR = [calculator calculate:fiatCurrencies[0]];
    loop_vars.initialBalancesInEUR = [calculator calculateWithRatings:initialRatings currency:fiatCurrencies[0]];
    if (loop_vars.initialBalancesInEUR != 0) loop_vars.coinchange.effectivePercent = (loop_vars.totalBalancesInEUR / loop_vars.initialBalancesInEUR * 100.0) - 100.0;

    for (id asset in [[currentSaldo allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
        NSDictionary *checkpoint = [calculator checkpointForAsset:asset];

        double initialPrice = [checkpoint[KEY_INITIAL_PRICE] doubleValue];
        double currentPrice = [checkpoint[KEY_CURRENT_PRICE] doubleValue];
        double btcPrice = [asset isEqualToString:BTC] ? 1 : [currentRatings[BTC] doubleValue] / [currentRatings[asset] doubleValue];

        double amount = [currentSaldo[asset] doubleValue];

        double balanceInEUR =  amount * currentPrice;
        double balanceInBTC = amount * btcPrice;

        double share = 0;
        if (loop_vars.totalBalancesInEUR != 0) share = (balanceInEUR / loop_vars.totalBalancesInEUR) * 100.0;

        double diffInEuro = ((currentPrice / initialPrice) * balanceInEUR) - balanceInEUR;
        double diffInPercent = (amount >= 0) ? [checkpoint[KEY_PERCENT] doubleValue] : 0;

        #ifdef DEBUG
        NSLog(@"%4s %14s | %14s | %14s | %14s | %14s | %10s | %11s | %9s |\n",
            [asset UTF8String],
            [[Helper double2German:amount min:8 max:8] UTF8String],
            [[Helper double2German:balanceInEUR min:2 max:2] UTF8String],
            [[Helper double2German:balanceInBTC min:8 max:8] UTF8String],
            [[Helper double2German:initialPrice min:2 max:2] UTF8String],
            [[Helper double2German:currentPrice min:2 max:2] UTF8String],
            [[Helper double2GermanPercent:share fractions:2] UTF8String],
            [[Helper double2German:diffInEuro min:2 max:2] UTF8String],
            [[Helper double2GermanPercent:diffInPercent fractions:2] UTF8String]
        );
        #endif

        loop_vars.shares += share;
        loop_vars.coinchange.diffsInEuro += diffInEuro;
        loop_vars.coinchange.diffsInPercent += diffInPercent;
        loop_vars.balancesInEUR += balanceInEUR;
        loop_vars.balancesInBTC += balanceInBTC;
    }

#ifdef DEBUG
    NSLog(@"%4s %14s | %14s | %14s | %14s | %14s | %10s | %11s | %9s |\n",
        [@"ALL" UTF8String],
        [@"   ---   " UTF8String],
        [[Helper double2German:loop_vars.balancesInEUR min:2 max:2] UTF8String],
        [[Helper double2German:loop_vars.balancesInBTC min:8 max:8] UTF8String],
        [[Helper double2German:loop_vars.initialBalancesInEUR min:2 max:2] UTF8String],
        [[Helper double2German:loop_vars.totalBalancesInEUR min:2 max:2] UTF8String],
        [[Helper double2GermanPercent:loop_vars.shares fractions:0] UTF8String],
        [[Helper double2German:loop_vars.coinchange.diffsInEuro min:2 max:2] UTF8String],
        [[Helper double2GermanPercent:loop_vars.coinchange.effectivePercent fractions:2] UTF8String]
    );
#endif

    self.percentLabel.stringValue = [Helper double2GermanPercent:loop_vars.coinchange.effectivePercent fractions:2];
    if (loop_vars.coinchange.diffsInEuro != 0)
        self.statusLabel.stringValue = [NSString stringWithFormat:@"%@ %@", [Helper double2German:loop_vars.coinchange.diffsInEuro min:2 max:2], fiatCurrencySymbol];

    [self markDockLabels:loop_vars.coinchange];

    [self.currencyButton setImage:images[fiatCurrencies[0]]];
    self.currencyUnits.doubleValue = [calculator calculate:fiatCurrencies[0]];

    [self.cryptoButton setImage:images[fiatCurrencies[1]]];
    self.cryptoUnits.doubleValue = [calculator calculate:fiatCurrencies[1]];

    self.rateInputLabel.placeholderString = @"1";
    self.rateOutputLabel.placeholderString = [NSString stringWithFormat:@"%@", [Helper double2German:1.0f / [currentRatings[fiatCurrencies[1]] doubleValue] min:2 max:4]];

    self.currency1Field.stringValue = [Helper double2German:1 / [currentRatings[BTC] doubleValue] min:2 max:4];
    self.currency2Field.stringValue = [Helper double2German:1 / [currentRatings[ZEC] doubleValue] min:2 max:4];
    self.currency3Field.stringValue = [Helper double2German:1 / [currentRatings[ETH] doubleValue] min:2 max:4];
    self.currency4Field.stringValue = [Helper double2German:1 / [currentRatings[XMR] doubleValue] min:2 max:4];
    self.currency5Field.stringValue = [Helper double2German:1 / [currentRatings[LTC] doubleValue] min:2 max:4];
    self.currency6Field.stringValue = [Helper double2German:1 / [currentRatings[GAME] doubleValue] min:2 max:4];
    self.currency7Field.stringValue = [Helper double2German:1 / [currentRatings[XRP] doubleValue] min:2 max:4];
    self.currency8Field.stringValue = [Helper double2German:1 / [currentRatings[MAID] doubleValue] min:2 max:4];
    self.currency9Field.stringValue = [Helper double2German:1 / [currentRatings[STR] doubleValue] min:2 max:4];
    self.currency10Field.stringValue = [Helper double2German:1 / [currentRatings[DOGE] doubleValue] min:2 max:4];

    [self markGainers];
    [self markLoosers];

    [self updateTicker:@"Dashboard"];
}

/**
 * Aktualisiere den jeweiligen Tab
 *
 * @param label
 */
- (void)updateTemplateView:(NSString *)label {

    // Farben zurück setzen
    [self resetColors];

    // Aktualisieren der Headline
    self.headlineLabel.stringValue = tabs[label][0];

    NSString *asset = label;
    double assets = [(NSNumber *) tabs[label][1] doubleValue];

    // Standards
    homeURL = [calculator saldoUrlForLabel:tabs[label][0]];

    // Aktualisiere den Kurs des Tabs - falls einer gesetzt ist
    [self rateInputAction:self];

    if ([label isEqualToString:@"Dashboard"]) {
        [self updateOverview];

        return;
    }
    
    // Aktiviere die Eingabe für die Crypto-Einheiten
    self.cryptoUnits.editable = true;

    // Setze das Bild für die FiatWährung
    [self.currencyButton setImage:self.images[fiatCurrencies[0]]];

    // Setze das Bild für die Einheit
    [self.cryptoButton setImage:self.images[asset]];

    if ([self.rateInputLabel.stringValue isEqualToString:@""]) {
        // Setze den Taschenrechner auf EUR
        self.exchangeSelection.title = fiatCurrencies[0];
    }

    // Hole die aktualisierten Dictionaries
    NSDictionary *checkpoint = [calculator checkpointForAsset:asset];
    NSDictionary *btcCheckpoint = [calculator checkpointForAsset:BTC];
    NSMutableDictionary *currentRatings = [calculator currentRatings];

    double percent = [checkpoint[KEY_PERCENT] doubleValue];
    double btcPercent = [btcCheckpoint[KEY_PERCENT] doubleValue];

    double assetRating = [currentRatings[asset] doubleValue];
    double saldo = [calculator currentSaldo:asset];
    double priceInEuro = saldo / assetRating;
    double diffInEuro = priceInEuro * (percent / 100);

    double diffPercent = percent;

    if (![asset isEqualToString:BTC]) {
        diffPercent -= btcPercent;
    }

    NSString *infoPercentString = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"exchange", @"Tausch"), [Helper double2GermanPercent:diffPercent fractions:2]];

    self.percentLabel.stringValue = [Helper double2GermanPercent:percent fractions:2];
    self.infoLabel.stringValue = infoPercentString;

    self.cryptoUnits.doubleValue = saldo;
    self.currencyUnits.doubleValue = priceInEuro;

    if (diffInEuro != 0) {
        self.statusLabel.stringValue = [NSString stringWithFormat:@"%@ %@", [Helper double2German:diffInEuro min:2 max:2], fiatCurrencySymbol];
    } else {
        // Placeholder reaktivieren
        self.statusLabel.stringValue = @"";
    }

    double rate = assets / assetRating;
    self.rateInputLabel.placeholderString = [Helper double2German:assets min:0 max:0];
    self.rateInputCurrencyLabel.stringValue = asset;
    self.rateOutputLabel.placeholderString = [NSString stringWithFormat:@"%@", [Helper double2German:rate min:2 max:4]];

    if (percent < 0.0) {
        self.percentLabel.textColor = defaultLooseColor;
    }

    COINCHANGE coinchange = { 0, diffPercent, diffInEuro };
    [self markDockLabels:coinchange];

    NSDictionary *currentPriceInUnits = @{
        BTC: @([currentRatings[BTC] doubleValue] / assetRating),
        ZEC: @([currentRatings[ZEC] doubleValue] / assetRating),
        ETH: @([currentRatings[ETH] doubleValue] / assetRating),
        XMR: @([currentRatings[XMR] doubleValue] / assetRating),
        LTC: @([currentRatings[LTC] doubleValue] / assetRating),
        GAME: @([currentRatings[GAME] doubleValue] / assetRating),
        XRP: @([currentRatings[XRP] doubleValue] / assetRating),
        MAID: @([currentRatings[MAID] doubleValue] / assetRating),
        STR: @([currentRatings[STR] doubleValue] / assetRating),
        DOGE: @([currentRatings[DOGE] doubleValue] / assetRating)
    };

    int fractions = 8;
    self.currency1Field.stringValue = [Helper double2German: [currentPriceInUnits[BTC] doubleValue] min:fractions max:fractions];
    self.currency2Field.stringValue = [Helper double2German: [currentPriceInUnits[ZEC] doubleValue] min:fractions max:fractions];
    self.currency3Field.stringValue = [Helper double2German: [currentPriceInUnits[ETH] doubleValue] min:fractions max:fractions];
    self.currency4Field.stringValue = [Helper double2German: [currentPriceInUnits[XMR] doubleValue] min:fractions max:fractions];
    self.currency5Field.stringValue = [Helper double2German: [currentPriceInUnits[LTC] doubleValue] min:fractions max:fractions];

    fractions = 5;
    self.currency6Field.stringValue = [Helper double2German: [currentPriceInUnits[GAME] doubleValue] min:fractions max:fractions];
    self.currency7Field.stringValue = [Helper double2German: [currentPriceInUnits[XRP] doubleValue] min:fractions max:fractions];
    self.currency8Field.stringValue = [Helper double2German: [currentPriceInUnits[MAID] doubleValue] min:fractions max:fractions];
    self.currency9Field.stringValue = [Helper double2German: [currentPriceInUnits[STR] doubleValue] min:fractions max:fractions];

    fractions = 2;
    self.currency10Field.stringValue = [Helper double2German: [currentPriceInUnits[DOGE] doubleValue] min:fractions max:fractions];

    if ([asset isEqualToString:BTC]) self.currency1Field.stringValue = @"1";
    if ([asset isEqualToString:ZEC]) self.currency2Field.stringValue = @"1";
    if ([asset isEqualToString:ETH]) self.currency3Field.stringValue = @"1";
    if ([asset isEqualToString:XMR]) self.currency4Field.stringValue = @"1";
    if ([asset isEqualToString:LTC]) self.currency5Field.stringValue = @"1";
    if ([asset isEqualToString:GAME]) self.currency6Field.stringValue = @"1";
    if ([asset isEqualToString:XRP]) self.currency7Field.stringValue = @"1";
    if ([asset isEqualToString:MAID]) self.currency8Field.stringValue = @"1";
    if ([asset isEqualToString:STR]) self.currency9Field.stringValue = @"1";
    if ([asset isEqualToString:DOGE]) self.currency10Field.stringValue = @"1";

    [self markGainers];
    [self markLoosers];

    [self updateTicker:label];
}

/**
 * Action-Handler für den homepageButton
 *
 * @param sender
 */
- (IBAction)homepageAction:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:traders[@"homepage"]]];
}

/**
 * Action-Handler zum Starten der jeweiligen Wallet-App
 *
 * @param sender
 */
- (IBAction)walletAction:(id)sender {
    NSString *title = self.headlineLabel.stringValue;

    if ([title isEqualToString:@"Dashboard"]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:self.vendorURL]];
        return;
    }

    if (![[NSWorkspace sharedWorkspace] launchApplication:applications[title]]) {
        NSAlert *msg = [[NSAlert alloc] init];
        [msg setAlertStyle:NSWarningAlertStyle];

        [msg addButtonWithTitle:NSLocalizedString(@"ok", @"OK"])];
        msg.messageText = [NSString stringWithFormat:NSLocalizedString(@"error_starting_app_with_param", @"Fehler beim Starten der %@ Wallet"), title];
        msg.informativeText = [NSString stringWithFormat:NSLocalizedString(@"install_app_with_param", @"Installieren Sie %@."), applications[title]];

        [msg runModal];
    }
}

/**
 * Action-Handler zum Starten der Crypto-Page des Vertrauens
 *
 * @param sender
 */
- (IBAction)homeAction:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:homeURL]];
}

/**
 * Action-Handler zum Aufruf des Crypto-Shifters
 *
 * @param sender
 */
- (IBAction)leftAction:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:traders[@"trader1"]]];
}

/**
 * Action-Handler zum Aufruf des Crypto-Shifters
 *
 * @param sender
 */
- (IBAction)rightAction:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:traders[@"trader2"]]];
}

/**
 * Action-Handler zum Aktualisieren des initialen Kurses der gewählten Währung (blaues Info-Icon)
 *
 * @param sender
 */
- (IBAction)infoAction:(id)sender {
    NSString *tabTitle = labels[self.headlineLabel.stringValue];
    NSString *withAsset = tabs[tabTitle][0];

    if ([withAsset isEqualToString:@"Dashboard"]) {
        withAsset = NSLocalizedString(@"all_charts", @"alle Kurse");
    }

    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"wanna_update_with_asset", @"Möchten Sie %@ aktualisieren?"), withAsset];
    NSString *info = NSLocalizedString(@"comparison_belongs_to_checkpoint", @"Der Vergleich (+/-) bezieht sich auf den zuletzt gespeicherten Checkpoint!");

    if ([Helper messageText:msg info:info] == NSAlertFirstButtonReturn) {
        [calculator updateCheckpointForAsset:tabTitle withBTCUpdate:FALSE];
    }

    [self updateCurrentView:false];
}

/**
 * Action Handler für das Anzeigen des umgerechneten Bestands
 *
 * @param sender
 */
- (IBAction)currencyAction:(id)sender {

    // Aktualisierte Ratings besorgen
    NSMutableDictionary *currentRatings = [calculator currentRatings];
    NSString *text;

    NSArray *data = @[
        @([calculator calculateWithRatings:currentRatings currency:BTC]),
        @([calculator calculateWithRatings:currentRatings currency:ZEC]),
        @([calculator calculateWithRatings:currentRatings currency:ETH]),
        @([calculator calculateWithRatings:currentRatings currency:XMR]),
        @([calculator calculateWithRatings:currentRatings currency:LTC]),
        @([calculator calculateWithRatings:currentRatings currency:GAME]),
        @([calculator calculateWithRatings:currentRatings currency:XRP]),
        @([calculator calculateWithRatings:currentRatings currency:MAID]),
        @([calculator calculateWithRatings:currentRatings currency:STR]),
        @([calculator calculateWithRatings:currentRatings currency:DOGE]),
        @([calculator calculateWithRatings:currentRatings currency:USD])
    ];

    text = [NSString stringWithFormat:@"%@ BTC\n%@ ZEC\n%@ ETH\n%@ XMR\n%@ LTC\n%@ GAME\n%@ XRP\n%@ MAID\n%@ STR\n%@ DOGE\n%@ USD",
          [Helper double2German:[data[0] doubleValue] min:4 max:8],
          [Helper double2German:[data[1] doubleValue] min:4 max:8],
          [Helper double2German:[data[2] doubleValue] min:4 max:8],
          [Helper double2German:[data[3] doubleValue] min:4 max:8],
          [Helper double2German:[data[4] doubleValue] min:4 max:8],
          [Helper double2German:[data[5] doubleValue] min:4 max:8],
          [Helper double2German:[data[6] doubleValue] min:4 max:8],
          [Helper double2German:[data[7] doubleValue] min:4 max:8],
          [Helper double2German:[data[8] doubleValue] min:4 max:8],
          [Helper double2German:[data[9] doubleValue] min:4 max:8],
          [Helper double2German:[data[10] doubleValue] min:4 max:8]
    ];

    [Helper messageText:NSLocalizedString(@"total_saldo", @"Gesamtbestand umgerechnet:") info:text];
}

/**
 * Aktualisieren des eingegeben Bestands per Klick
 *
 * @param sender
 */
- (IBAction)cryptoAction:(id)sender {
    NSString *tabTitle = self.headlineLabel.stringValue;
    if ([tabTitle isEqualToString:@"Dashboard"]) {
        return;
    }

    // Aktualisierte Ratings besorgen
    NSMutableDictionary *currentRatings = [calculator currentRatings];

    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"update_saldo_with_asset", @"%@ Bestand aktualisieren"), tabTitle];

    if ([Helper messageText:text info:NSLocalizedString(@"wanna_update_current_saldo", @"Möchten Sie Ihren aktuellen Bestand aktualisieren?")] == NSAlertFirstButtonReturn) {
        NSString *asset = labels[tabTitle];

        BOOL mustUpdateBecauseIHaveBought = (self.cryptoUnits.doubleValue > [calculator currentSaldo:asset]);

        [calculator currentSaldo:asset withDouble: self.cryptoUnits.doubleValue];
        self.currencyUnits.doubleValue = self.cryptoUnits.doubleValue / [currentRatings[asset] doubleValue];

        if (mustUpdateBecauseIHaveBought) {
            // Checkpoint aktualisieren
            [calculator updateCheckpointForAsset:asset withBTCUpdate:TRUE];
        }

        // nach dem Aktualisieren des Bestands muss die Statusleiste aktualisisiert werden...
        [self updateCurrentView:false];
    }
}

/**
 * Einfacher Währungsumrechner
 *
 * @param sender
 */
- (IBAction)rateInputAction:(id)sender {
    NSString *tabTitle = self.headlineLabel.stringValue;

    NSString *cAsset = ([tabTitle isEqualToString:@"Dashboard"] ? fiatCurrencies[1] : labels[tabTitle]);
    NSString *exchangeUnit = self.exchangeSelection.selectedItem.title;

    // Aktualisierte Ratings besorgen
    NSMutableDictionary *currentRatings = [calculator currentRatings];

    double exchangeFactor = ([exchangeUnit isEqualToString:fiatCurrencies[0]]) ? 1 : [currentRatings[exchangeUnit] doubleValue];

    if ([self.rateInputLabel.stringValue isEqualToString:@""]) {
        // keine Eingabe, reaktiviere den Placeholder!
        self.rateOutputLabel.stringValue = @"";
        return;
    }

    double amount = self.rateInputLabel.doubleValue;
    double result = amount / [currentRatings[cAsset] doubleValue] * exchangeFactor;

    self.rateOutputLabel.stringValue = [NSString stringWithFormat:@"%@", [Helper double2German:result min:4 max:4]];
}

/**
 * Getter für das applications Dictionary
 *
 * @return NSDictionary*
 */
- (NSDictionary *)applications {
    return applications;
}

/**
 * Getter für das traders Dictionary
 *
 * @return NSDictionary*
 */
- (NSDictionary *)traders {
    return traders;
}

/**
 * Getter für das images Dictionary
 *
 * @return NSDictionary*
 */
- (NSDictionary *)images {
    return images;
}

/**
 * Getter für die vendorURL
 *
 * @return NSString*
 */
- (NSString *)vendorURL {
    return @"https://www.4customers.de/ibroker/";
}

/**
 * Getter für die homeURL
 *
 * @return NSString*
 */
- (NSString *)homeURL {
    return homeURL;
}

@end
