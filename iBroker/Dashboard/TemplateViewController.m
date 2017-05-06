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
    double balancesInZEC;
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

    // Bilder und URLs
    NSMutableDictionary *images;
    NSString *homeURL;

    // EURO UND USD derzeit
    NSArray *fiatCurrencies;

    // meine nettes Rot
    NSColor *dangerColor;
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
    [self updateTemplateView:label];
}

/**
 * Zurücksetzen der Farben
 */
- (void)resetColors {
    NSColor *chartBGColor = [NSColor whiteColor];
    NSColor *infoBarFGColor = [NSColor colorWithCalibratedRed:178.0f / 255.0f green:178.0f / 255.0f blue:178.0f / 255.0f alpha:1.0f];

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

    tabs = @{
        @"Dashboard": @[fiatCurrencies[1], @1],
        @"Bitcoin": @[BTC, @1],
        @"Ethereum": @[ETH, @1],
        @"Litecoin": @[LTC, @1],
        @"Monero": @[XMR, @1],
        @"Dogecoin": @[DOGE, @10000],
    };

    images = [@{
        EUR: [NSImage imageNamed:EUR],
        USD: [NSImage imageNamed:USD],
        BTC: [NSImage imageNamed:BTC],
        ETH: [NSImage imageNamed:ETH],
        LTC: [NSImage imageNamed:LTC],
        XMR: [NSImage imageNamed:XMR],
        DOGE: [NSImage imageNamed:DOGE],
    } mutableCopy];

    applications = [[defaults objectForKey:@"applications"] mutableCopy];

    if (applications == NULL) {
        applications = [@{
            @"Bitcoin": @"/Applications/Electrum.App",
            @"Ethereum": @"/Applications/Ethereum Wallet.App",
            @"Litecoin": @"/Applications/Electrum-LTC.App",
            @"Monero": @"/Applications/monero-wallet-gui.App",
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
    dangerColor = [NSColor colorWithCalibratedRed:200.0f/255.0f green:79.0f/255.0f blue:35.0f/255.0f alpha:1.0f];

    [defaults synchronize];
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
    [cryptoFormatter setMinimumFractionDigits:4];
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

        // Bilde die Differenz aus BTC und der jeweiligen Cryptowährung, falls es sich nicht um BTC handelt.
        if (![cAsset isEqualToString:BTC]) {
            cPercent -= btcPercent;
        }

        currencyUnits[cAsset] = @(cPercent);
    }

    NSNumber *highest = [[currencyUnits allValues] valueForKeyPath:@"@max.self"];
    NSString *highestKey = [currencyUnits allKeysForObject:highest][0];
    NSColor *highestColor = [NSColor greenColor];

    if ([highest doubleValue] > CHECKPOINT_PERCENTAGE) highestColor = [NSColor blueColor];

    if ([highestKey isEqualToString:BTC]) self.currency1Field.backgroundColor = highestColor;
    if ([highestKey isEqualToString:ETH]) self.currency2Field.backgroundColor = highestColor;
    if ([highestKey isEqualToString:XMR]) self.currency3Field.backgroundColor = highestColor;
    if ([highestKey isEqualToString:LTC]) self.currency4Field.backgroundColor = highestColor;
    if ([highestKey isEqualToString:DOGE]) self.currency5Field.backgroundColor = highestColor;

    NSNumber *lowest = [[currencyUnits allValues] valueForKeyPath:@"@min.self"];
    NSString *lowestKey = [currencyUnits allKeysForObject:lowest][0];
    NSColor *lowestColor = dangerColor;

    if ([lowest doubleValue] < -CHECKPOINT_PERCENTAGE) lowestColor = [NSColor magentaColor];

    if ([lowestKey isEqualToString:BTC]) [self.currency1Field setBackgroundColor:lowestColor];
    if ([lowestKey isEqualToString:ETH]) [self.currency2Field setBackgroundColor:lowestColor];
    if ([lowestKey isEqualToString:XMR]) [self.currency3Field setBackgroundColor:lowestColor];
    if ([lowestKey isEqualToString:LTC]) [self.currency4Field setBackgroundColor:lowestColor];
    if ([lowestKey isEqualToString:DOGE]) [self.currency5Field setBackgroundColor:lowestColor];
}

/**
 * Markieren der Verlierer der obersten Leiste
 */
- (void)markLoosers {
    NSMutableDictionary *initialRatings = [calculator initialRatings];
    NSMutableDictionary *currentRatings = [calculator currentRatings];

    // Beachte: Es sind Kehrwerte ...
    if ([currentRatings[BTC] doubleValue] > [initialRatings[BTC] doubleValue]) {
        self.currency1Field.backgroundColor = [NSColor yellowColor];
    }

    if ([currentRatings[ETH] doubleValue] > [initialRatings[ETH] doubleValue]) {
        self.currency2Field.backgroundColor = [NSColor yellowColor];
    }

    if ([currentRatings[XMR] doubleValue] > [initialRatings[XMR] doubleValue]) {
        self.currency3Field.backgroundColor = [NSColor yellowColor];
    }

    if ([currentRatings[LTC] doubleValue] > [initialRatings[LTC] doubleValue]) {
        self.currency4Field.backgroundColor = [NSColor yellowColor];
    }

    if ([currentRatings[DOGE] doubleValue] > [initialRatings[DOGE] doubleValue]) {
        self.currency5Field.backgroundColor = [NSColor yellowColor];
    }
}

/**
 * Einfärben der Labels
 */
- (void)markDockLabels:(COINCHANGE) loop_vars {
    if (loop_vars.effectivePercent < 0.0) {
        self.percentLabel.textColor = [NSColor redColor];
    }

    if (loop_vars.diffsInPercent < 0.0) {
        self.infoLabel.textColor = dangerColor;
    }

    if (loop_vars.diffsInEuro < 0.0) {
        self.statusLabel.textColor = dangerColor;
    }

    if (loop_vars.diffsInEuro < 0.0 && loop_vars.diffsInPercent < 0.0) {
        self.iBrokerLabel.textColor = dangerColor;
    }
}

/**
 * Übersicht mit richtigen Live-Werten
 */
- (void)updateOverview {
    // Setze das Label des Eingabefeldes für den Taschenrechner auf Fiat-Währung 2 = USD
    self.rateInputCurrencyLabel.stringValue = fiatCurrencies[1];

    // Setze das selektierte Element des Taschenrechners auf Fiat Währung 1 = EUR
    [self.exchangeSelection selectItemWithTitle:fiatCurrencies[0]];

    // Aktualisiere die URL für den HOME-Button
    homeURL = [calculator saldoUrlForLabel:@"Dashboard"];

    // Farben zurück setzen
    [self resetColors];

#ifdef DEBUG
    NSLog(@"%4s %14s | %14s | %14s | %14s | %14s | %10s | %11s | %9s |\n",
        [@"####" UTF8String],
        [@"BALANCE IN EUR" UTF8String],
        [@"BALANCE IN BTC" UTF8String],
        [@"BALANCE IN ZEC" UTF8String],
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
    DASHBOARD loop_vars = { {0, 0, 0}, 0, 0, 0, 0, 0, 0};

    loop_vars.totalBalancesInEUR = [calculator calculate:fiatCurrencies[0]];
    loop_vars.initialBalancesInEUR = [calculator calculateWithRatings:initialRatings currency:fiatCurrencies[0]];
    if (loop_vars.initialBalancesInEUR != 0) loop_vars.coinchange.effectivePercent = (loop_vars.totalBalancesInEUR / loop_vars.initialBalancesInEUR * 100.0) - 100.0;

    for (id asset in [[currentSaldo allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
        NSDictionary *checkpoint = [calculator checkpointForAsset:asset];

        double initialPrice = [checkpoint[KEY_INITIAL_PRICE] doubleValue];
        double currentPrice = [checkpoint[KEY_CURRENT_PRICE] doubleValue];
        double btcPrice = [asset isEqualToString:BTC] ? 1 : [currentRatings[BTC] doubleValue] / [currentRatings[asset] doubleValue];
        double zecPrice = [asset isEqualToString:ZEC] ? 1 : [currentRatings[ZEC] doubleValue] / [currentRatings[asset] doubleValue];

        double amount = [currentSaldo[asset] doubleValue];

        double balanceInEUR =  amount * currentPrice;
        double balanceInBTC = amount * btcPrice;
        double balanceInZEC = amount * zecPrice;

        double share = 0;
        if (loop_vars.totalBalancesInEUR != 0) share = (balanceInEUR / loop_vars.totalBalancesInEUR) * 100.0;

        double diffInEuro = ((currentPrice / initialPrice) * balanceInEUR) - balanceInEUR;
        double diffInPercent = (amount >= 0) ? [checkpoint[KEY_PERCENT] doubleValue] : 0;

        #ifdef DEBUG
        NSLog(@"%4s %14s | %14s | %14s | %14s | %14s | %10s | %11s | %9s |\n",
            [asset UTF8String],
            [[Helper double2German:balanceInEUR min:2 max:2] UTF8String],
            [[Helper double2German:balanceInBTC min:8 max:8] UTF8String],
            [[Helper double2German:balanceInZEC min:8 max:8] UTF8String],
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
        loop_vars.balancesInZEC += balanceInZEC;
    }

#ifdef DEBUG
    NSLog(@"%4s %14s | %14s | %14s | %14s | %14s | %10s | %11s | %9s |\n",
        [@"ALL" UTF8String],
        [[Helper double2German:loop_vars.balancesInEUR min:2 max:2] UTF8String],
        [[Helper double2German:loop_vars.balancesInBTC min:8 max:8] UTF8String],
        [[Helper double2German:loop_vars.balancesInZEC min:8 max:8] UTF8String],
        [[Helper double2German:loop_vars.initialBalancesInEUR min:2 max:2] UTF8String],
        [[Helper double2German:loop_vars.totalBalancesInEUR min:2 max:2] UTF8String],
        [[Helper double2GermanPercent:loop_vars.shares fractions:0] UTF8String],
        [[Helper double2German:loop_vars.coinchange.diffsInEuro min:2 max:2] UTF8String],
        [[Helper double2GermanPercent:loop_vars.coinchange.effectivePercent fractions:2] UTF8String]
    );
#endif

    /* Diese beiden Annahmen, dass die berechneten Werte maximal um eine Milli-Einheit abweichen, müssen immer erfüllt sein */
    if (loop_vars.shares != 0) {
        assert(fabs(loop_vars.totalBalancesInEUR - loop_vars.balancesInEUR) < 0.001);
        assert(fabs(loop_vars.shares - 100.0) < 0.001);
    }

    self.percentLabel.stringValue = [Helper double2GermanPercent:loop_vars.coinchange.effectivePercent fractions:2];
    if (loop_vars.coinchange.diffsInEuro != 0) self.statusLabel.stringValue = [NSString stringWithFormat:@"%@ EUR", [Helper double2German:loop_vars.coinchange.diffsInEuro min:2 max:2]];

    [self markDockLabels:loop_vars.coinchange];

    [self.currencyButton setImage:images[fiatCurrencies[0]]];
    self.currencyUnits.doubleValue = [calculator calculate:fiatCurrencies[0]];

    [self.cryptoButton setImage:images[fiatCurrencies[1]]];
    self.cryptoUnits.doubleValue = [calculator calculate:fiatCurrencies[1]];

    self.rateInputLabel.placeholderString = @"1";
    self.rateOutputLabel.placeholderString = [NSString stringWithFormat:@"%@", [Helper double2German:1.0f / [currentRatings[fiatCurrencies[1]] doubleValue] min:2 max:4]];

    self.currency1Field.stringValue = [Helper double2German:1 / [currentRatings[BTC] doubleValue] min:2 max:4];
    self.currency2Field.stringValue = [Helper double2German:1 / [currentRatings[ETH] doubleValue] min:2 max:4];
    self.currency3Field.stringValue = [Helper double2German:1 / [currentRatings[XMR] doubleValue] min:2 max:4];
    self.currency4Field.stringValue = [Helper double2German:1 / [currentRatings[LTC] doubleValue] min:2 max:4];
    self.currency5Field.stringValue = [Helper double2German:[tabs[@"Dogecoin"][1] doubleValue] / [currentRatings[DOGE] doubleValue] min:2 max:4];

    [self markGainers];
    [self markLoosers];
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
    self.headlineLabel.stringValue = label;

    NSString *asset = tabs[label][0];
    double assets = [(NSNumber *) tabs[label][1] doubleValue];

    // Standards
    homeURL = [calculator saldoUrlForLabel:label];

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

    // Setze den Taschenrechner auf EUR
    self.exchangeSelection.title = fiatCurrencies[0];

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

    NSString *infoPercentString = [NSString stringWithFormat:@"Tausch %@", [Helper double2GermanPercent:diffPercent fractions:2]];

    self.percentLabel.stringValue = [Helper double2GermanPercent:percent fractions:2];
    self.infoLabel.stringValue = infoPercentString;

    self.cryptoUnits.doubleValue = saldo;
    self.currencyUnits.doubleValue = priceInEuro;

    if (diffInEuro != 0) self.statusLabel.stringValue = [NSString stringWithFormat:@"%@ EUR", [Helper double2German:diffInEuro min:2 max:2]];

    double rate = assets / assetRating;
    self.rateInputLabel.placeholderString = [Helper double2German:assets min:0 max:0];
    self.rateInputCurrencyLabel.stringValue = asset;
    self.rateOutputLabel.placeholderString = [NSString stringWithFormat:@"%@", [Helper double2German:rate min:2 max:4]];

    if (percent < 0.0) {
        self.percentLabel.textColor = [NSColor redColor];
    }

    COINCHANGE coinchange = { 0, diffPercent, diffInEuro };
    [self markDockLabels:coinchange];

    if ([asset isEqualToString:DOGE]) assetRating /= [tabs[@"Dogecoin"][1] doubleValue];

    NSDictionary *currentPriceInUnits = @{
        BTC: @([currentRatings[BTC] doubleValue] / assetRating),
        ETH: @([currentRatings[ETH] doubleValue] / assetRating),
        XMR: @([currentRatings[XMR] doubleValue] / assetRating),
        LTC: @([currentRatings[LTC] doubleValue] / assetRating),
        DOGE: @([currentRatings[DOGE] doubleValue] / assetRating)
    };

    self.currency1Field.stringValue = [Helper double2German: [currentPriceInUnits[BTC] doubleValue] min:4 max:4];
    self.currency2Field.stringValue = [Helper double2German: [currentPriceInUnits[ETH] doubleValue] min:4 max:4];
    self.currency3Field.stringValue = [Helper double2German: [currentPriceInUnits[XMR] doubleValue] min:4 max:4];
    self.currency4Field.stringValue = [Helper double2German: [currentPriceInUnits[LTC] doubleValue] min:4 max:4];
    self.currency5Field.stringValue = [Helper double2German: [currentPriceInUnits[DOGE] doubleValue] min:4 max:4];

    if ([asset isEqualToString:BTC]) self.currency1Field.stringValue = @"1";
    if ([asset isEqualToString:ETH]) self.currency2Field.stringValue = @"1";
    if ([asset isEqualToString:XMR]) self.currency3Field.stringValue = @"1";
    if ([asset isEqualToString:LTC]) self.currency4Field.stringValue = @"1";
    if ([asset isEqualToString:DOGE]) self.currency5Field.stringValue = @"1";

    [self markGainers];
    [self markLoosers];
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

        [msg addButtonWithTitle:@"Abnicken"];
        msg.messageText = [NSString stringWithFormat:@"Fehler beim Starten der %@ Wallet", title];
        msg.informativeText = [NSString stringWithFormat:@"Installieren Sie %@.", applications[title]];

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
    NSString *tabTitle = self.headlineLabel.stringValue;

    NSDictionary *tabStrings = @{
        @"Dashboard":  @[@"ALL", @"alle Kurse"],
        @"Bitcoin": @[BTC, @"den Bitcoin Kurs"],
        @"Ethereum": @[ETH, @"den Ethereum Kurs"],
        @"Monero":  @[XMR, @"den Monero Kurs"],
        @"Litecoin": @[LTC, @"den Litecoin Kurs"],
        @"Dogecoin": @[DOGE, @"den Dogecoin Kurs"]
    };

    NSString *msg = [NSString stringWithFormat:@"Möchten Sie %@ aktualisieren?", tabStrings[tabTitle][1]];
    NSString *info = @"Der Vergleich (+/-) bezieht sich auf den zuletzt gespeicherten Checkpoint!";

    if ([Helper messageText:msg info:info] == NSAlertFirstButtonReturn) {
        [calculator updateCheckpointForAsset:tabStrings[tabTitle][0] withBTCUpdate:FALSE];
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

    text = [NSString stringWithFormat:@"%@ BTC\n%@ ETH\n%@ XMR\n%@ LTC\n%@ DOGE\n%@ ZEC\n%@ DASH\n%@ XRP\n%@ USD",
          [Helper double2German:[calculator calculateWithRatings:currentRatings currency:BTC] min:4 max:8],
          [Helper double2German:[calculator calculateWithRatings:currentRatings currency:ETH] min:4 max:8],
          [Helper double2German:[calculator calculateWithRatings:currentRatings currency:XMR] min:4 max:8],
          [Helper double2German:[calculator calculateWithRatings:currentRatings currency:LTC] min:4 max:8],
          [Helper double2German:[calculator calculateWithRatings:currentRatings currency:DOGE] min:4 max:8],
          [Helper double2German:[calculator calculateWithRatings:currentRatings currency:ZEC] min:4 max:8],
          [Helper double2German:[calculator calculateWithRatings:currentRatings currency:DASH] min:4 max:8],
          [Helper double2German:[calculator calculateWithRatings:currentRatings currency:XRP] min:4 max:8],
          [Helper double2German:[calculator calculateWithRatings:currentRatings currency:USD] min:4 max:8]
    ];

    [Helper messageText:@"Gesamtbestand umgerechnet:" info:text];
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

    NSString *text = [NSString stringWithFormat:@"%@ Bestand aktualisieren", tabTitle];

    if ([Helper messageText:text info:@"Möchten Sie Ihren aktuellen Bestand aktualisieren?"] == NSAlertFirstButtonReturn) {
        NSString *asset = tabs[tabTitle][0];

        BOOL mustUpdateBecauseIHaveBought = (self.cryptoUnits.doubleValue > [calculator currentSaldo:asset]);

        [calculator currentSaldo:asset withDouble: self.cryptoUnits.doubleValue];
        self.currencyUnits.doubleValue = self.cryptoUnits.doubleValue / [currentRatings[asset] doubleValue];

        if (mustUpdateBecauseIHaveBought) {
            // Checkpoint aktualisieren
            [calculator updateCheckpointForAsset:asset withBTCUpdate:TRUE];
        }
    }
}

/**
 * Einfacher Währungsumrechner
 *
 * @param sender
 */
- (IBAction)rateInputAction:(id)sender {
    NSString *tabTitle = self.headlineLabel.stringValue;

    NSString *cAsset = tabs[tabTitle][0];
    NSString *exchangeUnit = self.exchangeSelection.selectedItem.title;

    // Aktualisierte Ratings besorgen
    NSMutableDictionary *currentRatings = [calculator currentRatings];

    double exchangeFactor = ([exchangeUnit isEqualToString:fiatCurrencies[0]]) ? 1 : [currentRatings[exchangeUnit] doubleValue];

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
