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

#import "TemplateViewController.h"
#import "Helper.h"
#import "Calculator.h"

@implementation TemplateViewController {
@private
    Calculator *calculator;

    // Normale Eigenschaften
    NSMutableDictionary *initialRatings;
    NSMutableDictionary *currentRatings;

    NSMutableDictionary *applications;
    NSMutableDictionary *traders;

    // Die Tabs
    NSDictionary *tabs;

    // Bilder und URLs
    NSMutableDictionary *images;
    NSString *homeURL;

    
    NSArray *fiatCurrencies;
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
        @"Bitcoin": @[@"BTC", @1],
        @"Ethereum": @[@"ETH", @1],
        @"Litecoin": @[@"LTC", @1],
        @"Monero": @[@"XMR", @1],
        @"Dogecoin": @[@"DOGE", @10000],
    };

    images = [@{
        @"EUR": [NSImage imageNamed:@"EUR"],
        @"USD": [NSImage imageNamed:@"USD"],
        @"BTC": [NSImage imageNamed:@"BTC"],
        @"ETH": [NSImage imageNamed:@"ETH"],
        @"LTC": [NSImage imageNamed:@"LTC"],
        @"XMR": [NSImage imageNamed:@"XMR"],
        @"DOGE": [NSImage imageNamed:@"DOGE"],
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

    initialRatings = [calculator initialRatings];
    currentRatings = [calculator currentRatings];

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
 * Übersicht mit richtigen Live-Werten
 */
- (void)updateOverview {
    // Setze den Button-Text aufs Dashboard
    self.dismissButton.title = @"Dashboard";
    
    // Setze das Label des Eingabefeldes für den Taschenrechner auf Fiat-Währung 2 = USD
    self.rateInputCurrencyLabel.stringValue = fiatCurrencies[1];
    
    // Setze das selektierte Element des Taschenrechners auf Fiat Währung 1 = EUR
    [self.exchangeSelection selectItemWithTitle:fiatCurrencies[0]];
    
    // Aktualisiere die URL für den HOME-Button
    homeURL = [calculator saldoUrlForLabel:@"Dashboard"];

    double percent = 0;
    double total = [calculator calculate:fiatCurrencies[0]];
    double initial = [calculator calculateWithRatings:initialRatings currency:fiatCurrencies[0]];
    if (initial != 0) percent = (total / initial * 100.0) - 100.0;

    NSMutableDictionary *currentSaldo = [calculator currentSaldo];

#ifdef DEBUG
    printf("%4s: %24s | %24s | %24s | %24s | %24s\n",
        [@"####" UTF8String],
        [@"INITIAL" UTF8String],
        [@"CURRENT" UTF8String],
        [@"SHARE" UTF8String],
        [@"AMOUNT" UTF8String],
        [@"DIFF" UTF8String]
    );
#endif

    double prices = 0;
    for (id unit in [[currentSaldo allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
        double initialPrice = 1.0 / [initialRatings[unit] doubleValue];
        double currentPrice = 1.0 / [currentRatings[unit] doubleValue];

        double amount = [currentSaldo[unit] doubleValue] / [currentRatings[unit] doubleValue];

        double share = 0;
        if (total != 0) share = (amount / total) * 100.0;
        double price = ((currentPrice / initialPrice) * amount) - amount;

    #ifdef DEBUG
        printf("%4s: %24s | %24s | %24s | %24s | %24s\n",
            [unit UTF8String],
            [[Helper double2German:initialPrice min:2 max:4] UTF8String],
            [[Helper double2German:currentPrice min:2 max:4] UTF8String],
            [[Helper double2GermanPercent:share fractions:2] UTF8String],
            [[Helper double2German:amount min:4 max:2] UTF8String],
            [[Helper double2German:price min:2 max:2] UTF8String]
        );
    #endif
        
        prices += price;
    }

#ifdef DEBUG
    printf(" ALL: %24s | %24s | %24s | %24s | %24s\n",
        [[Helper double2German:initial min:2 max:4] UTF8String],
        [[Helper double2German:total min:2 max:4] UTF8String],
        [[Helper double2GermanPercent:percent fractions:2] UTF8String],
        [[Helper double2German:total min:2 max:2] UTF8String],
        [[Helper double2German:prices min:2 max:2] UTF8String]
    );
#endif

    if (percent < 0.0) {
    #ifdef DEBUG
        printf("---\n");
    #endif
        [self.percentLabel setTextColor:[NSColor redColor]];
    } else {
        [self.percentLabel setTextColor:[NSColor whiteColor]];
    #ifdef DEBUG
        printf("+++\n");
    #endif
    }

#ifdef DEBUG
    printf("####: %24s | %24s | %24s | %24s | %24s\n",
        [@"BTC" UTF8String],
        [@"ETH" UTF8String],
        [@"XMR" UTF8String],
        [@"LTC" UTF8String],
        [@"DOGE" UTF8String]
    );
#endif
    
    self.percentLabel.stringValue = [Helper double2GermanPercent:percent fractions:2];

    [self.currencyButton setImage:images[fiatCurrencies[0]]];
    self.currencyUnits.doubleValue = [calculator calculate:fiatCurrencies[0]];

    [self.cryptoButton setImage:images[fiatCurrencies[1]]];
    self.cryptoUnits.doubleValue = [calculator calculate:fiatCurrencies[1]];

    self.rateInputLabel.placeholderString = @"1";
    self.rateOutputLabel.placeholderString = [NSString stringWithFormat:@"%@", [Helper double2German:1.0f / [currentRatings[fiatCurrencies[1]] doubleValue] min:2 max:4]];

    self.currency1Field.stringValue = [Helper double2German:1 / [currentRatings[@"BTC"] doubleValue] min:2 max:4];
    self.currency2Field.stringValue = [Helper double2German:1 / [currentRatings[@"ETH"] doubleValue] min:2 max:4];
    self.currency3Field.stringValue = [Helper double2German:1 / [currentRatings[@"XMR"] doubleValue] min:2 max:4];
    self.currency4Field.stringValue = [Helper double2German:1 / [currentRatings[@"LTC"] doubleValue] min:2 max:4];
    self.currency5Field.stringValue = [Helper double2German:[tabs[@"Dogecoin"][1] doubleValue] / [currentRatings[@"DOGE"] doubleValue] min:2 max:4];

    // Beachte: Es sind Kehrwerte ...
    if ([currentRatings[@"BTC"] doubleValue] > [initialRatings[@"BTC"] doubleValue]) {
        [self.currency1Field setBackgroundColor:[NSColor yellowColor]];
    }

    if ([currentRatings[@"ETH"] doubleValue] > [initialRatings[@"ETH"] doubleValue]) {
        [self.currency2Field setBackgroundColor:[NSColor yellowColor]];
    }

    if ([currentRatings[@"XMR"] doubleValue] > [initialRatings[@"XMR"] doubleValue]) {
        [self.currency3Field setBackgroundColor:[NSColor yellowColor]];
    }

    if ([currentRatings[@"LTC"] doubleValue] > [initialRatings[@"LTC"] doubleValue]) {
        [self.currency4Field setBackgroundColor:[NSColor yellowColor]];
    }

    if ([currentRatings[@"DOGE"] doubleValue] > [initialRatings[@"DOGE"] doubleValue]) {
        [self.currency5Field setBackgroundColor:[NSColor yellowColor]];
    }
}

/**
 * Aktualisiere den jeweiligen Tab
 *
 * @param label
 */
- (void)updateTemplateView:(NSString *)label {

    // Ratings aktualisieren
    [calculator updateRatings];

    // Aktualisieren des Dismissbuttons und der headLine;
    self.dismissButton.title = label;
    self.headlineLabel.stringValue = label;

    NSString *unit = tabs[label][0];
    double units = [(NSNumber *) tabs[label][1] doubleValue];

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
    [self.cryptoButton setImage:self.images[unit]];
    
    // Setze den Taschenrechner auf EUR
    self.exchangeSelection.title = fiatCurrencies[0];

    NSDictionary *pricesAndPercent = [calculator checkpointForUnit:unit];

    double percent = [pricesAndPercent[@"percent"] doubleValue];

    if (percent < 0.0) {
        [self.percentLabel setTextColor:[NSColor redColor]];
    } else {
        [self.percentLabel setTextColor:[NSColor whiteColor]];
    }

    self.percentLabel.stringValue = [Helper double2GermanPercent:percent fractions:2];

    self.cryptoUnits.doubleValue = [calculator currentSaldo:unit];
    self.currencyUnits.doubleValue = self.cryptoUnits.doubleValue / [currentRatings[unit] doubleValue];

    double rate = units / [currentRatings[unit] doubleValue];
    self.rateInputLabel.placeholderString = [Helper double2German:units min:0 max:0];
    self.rateInputCurrencyLabel.stringValue = unit;
    self.rateOutputLabel.placeholderString = [NSString stringWithFormat:@"%@", [Helper double2German:rate min:2 max:4]];

    double cUnit = [currentRatings[unit] doubleValue];

    if ([unit isEqualToString:@"DOGE"]) cUnit /= [tabs[@"Dogecoin"][1] doubleValue];

    NSDictionary *currentPriceInUnits = @{
        @"BTC": @([currentRatings[@"BTC"] doubleValue] / cUnit),
        @"ETH": @([currentRatings[@"ETH"] doubleValue] / cUnit),
        @"XMR": @([currentRatings[@"XMR"] doubleValue] / cUnit),
        @"LTC": @([currentRatings[@"LTC"] doubleValue] / cUnit),
        @"DOGE": @([currentRatings[@"DOGE"] doubleValue] / cUnit)
    };

    self.currency1Field.stringValue = [Helper double2German: [currentPriceInUnits[@"BTC"] doubleValue] min:4 max:4];
    self.currency2Field.stringValue = [Helper double2German: [currentPriceInUnits[@"ETH"] doubleValue] min:4 max:4];
    self.currency3Field.stringValue = [Helper double2German: [currentPriceInUnits[@"XMR"] doubleValue] min:4 max:4];
    self.currency4Field.stringValue = [Helper double2German: [currentPriceInUnits[@"LTC"] doubleValue] min:4 max:4];
    self.currency5Field.stringValue = [Helper double2German: [currentPriceInUnits[@"DOGE"] doubleValue] min:4 max:4];

    if ([unit isEqualToString:@"BTC"]) self.currency1Field.stringValue = @"1";
    if ([unit isEqualToString:@"ETH"]) self.currency2Field.stringValue = @"1";
    if ([unit isEqualToString:@"XMR"]) self.currency3Field.stringValue = @"1";
    if ([unit isEqualToString:@"LTC"]) self.currency4Field.stringValue = @"1";
    if ([unit isEqualToString:@"DOGE"]) self.currency5Field.stringValue = @"1";

    // Beachte: Es sind Kehrwerte ...
    if ([currentRatings[@"BTC"] doubleValue] > [initialRatings[@"BTC"] doubleValue]) {
        [self.currency1Field setBackgroundColor:[NSColor yellowColor]];
    }

    if ([currentRatings[@"ETH"] doubleValue] > [initialRatings[@"ETH"] doubleValue]) {
        [self.currency2Field setBackgroundColor:[NSColor yellowColor]];
    }

    if ([currentRatings[@"XMR"] doubleValue] > [initialRatings[@"XMR"] doubleValue]) {
        [self.currency3Field setBackgroundColor:[NSColor yellowColor]];
    }

    if ([currentRatings[@"LTC"] doubleValue] > [initialRatings[@"LTC"] doubleValue]) {
        [self.currency4Field setBackgroundColor:[NSColor yellowColor]];
    }

    if ([currentRatings[@"DOGE"] doubleValue] > [initialRatings[@"DOGE"] doubleValue]) {
        [self.currency5Field setBackgroundColor:[NSColor yellowColor]];
    }

    double btcPercent = [[calculator checkpointForUnit:@"BTC"][@"percent"] doubleValue];
    NSMutableDictionary *currencyUnits = [[NSMutableDictionary alloc] init];
    for (id currencyUnit in currentRatings) {
        NSDictionary *cPricesAndPercent = [calculator checkpointForUnit:currencyUnit];

        double cPercent = [cPricesAndPercent[@"percent"] doubleValue];

        // Bilde die Differenz aus BTC und der jeweiligen Währung, falls es sich nicht um BTC handelt.
        if (![currencyUnit isEqualToString:@"BTC"]) {
            cPercent -= btcPercent;
        }

        currencyUnits[currencyUnit] = @(cPercent);
    }

#ifdef DEBUG
    printf("%4s: %+23.4f%% | %23.4f%% | %23.4f%% | %23.4f%% | %23.8f%%\n",
        [@"%" UTF8String],
        [currencyUnits[@"BTC"] doubleValue],
        [currencyUnits[@"ETH"] doubleValue],
        [currencyUnits[@"XMR"] doubleValue],
        [currencyUnits[@"LTC"] doubleValue],
        [currencyUnits[@"DOGE"] doubleValue]
    );

    printf("%4s: %+23.4f%% | %24.4f | %24.4f | %24.4f | %24.8f\n",
        [@"+/-" UTF8String],
        [calculator currentSaldo:@"BTC"] * (1 + [currencyUnits[@"BTC"] doubleValue] / 100.0) - [calculator currentSaldo:@"BTC"],
        [calculator currentSaldo:@"ETH"] * (1 + [currencyUnits[@"ETH"] doubleValue] / 100.0) - [calculator currentSaldo:@"ETH"],
        [calculator currentSaldo:@"XMR"] * (1 + [currencyUnits[@"XMR"] doubleValue] / 100.0) - [calculator currentSaldo:@"XMR"],
        [calculator currentSaldo:@"LTC"] * (1 + [currencyUnits[@"LTC"] doubleValue] / 100.0) - [calculator currentSaldo:@"LTC"],
        [calculator currentSaldo:@"DOGE"] * (1 + [currencyUnits[@"DOGE"] doubleValue] / 100.0) - [calculator currentSaldo:@"DOGE"]
    );
#endif

    NSNumber *highest = [[currencyUnits allValues] valueForKeyPath:@"@max.self"];
    NSString *highestKey = [currencyUnits allKeysForObject:highest][0];
    NSColor *highestColor = [NSColor greenColor];

    if ([highest doubleValue] > 10.0) highestColor = [NSColor blueColor];

    if ([highestKey isEqualToString:@"BTC"]) [self.currency1Field setBackgroundColor:highestColor];
    if ([highestKey isEqualToString:@"ETH"]) [self.currency2Field setBackgroundColor:highestColor];
    if ([highestKey isEqualToString:@"XMR"]) [self.currency3Field setBackgroundColor:highestColor];
    if ([highestKey isEqualToString:@"LTC"]) [self.currency4Field setBackgroundColor:highestColor];
    if ([highestKey isEqualToString:@"DOGE"]) [self.currency5Field setBackgroundColor:highestColor];

    NSNumber *lowest = [[currencyUnits allValues] valueForKeyPath:@"@min.self"];
    NSString *lowestKey = [currencyUnits allKeysForObject:lowest][0];
    NSColor *lowestColor = [NSColor redColor];

    if ([lowest doubleValue] < -10.0) lowestColor = [NSColor magentaColor];

    if ([lowestKey isEqualToString:@"BTC"]) [self.currency1Field setBackgroundColor:lowestColor];
    if ([lowestKey isEqualToString:@"ETH"]) [self.currency2Field setBackgroundColor:lowestColor];
    if ([lowestKey isEqualToString:@"XMR"]) [self.currency3Field setBackgroundColor:lowestColor];
    if ([lowestKey isEqualToString:@"LTC"]) [self.currency4Field setBackgroundColor:lowestColor];
    if ([lowestKey isEqualToString:@"DOGE"]) [self.currency5Field setBackgroundColor:lowestColor];
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
- (IBAction)dismissAction:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    NSButton *button = (NSButton *) sender;

    if ([button.title isEqualToString:@"Dashboard"]) {
        return;
    }

    [alert setAlertStyle:NSInformationalAlertStyle];

    [alert addButtonWithTitle:@"Starten"];
    [alert addButtonWithTitle:@"Nein"];
    alert.messageText = [NSString stringWithFormat:@"%@ starten?", button.title];
    alert.informativeText = @"Das Programm wird automatisch gestartet.";

    if ([alert runModal] == NSAlertFirstButtonReturn) {
        if (![[NSWorkspace sharedWorkspace] launchApplication:applications[button.title]]) {
            NSAlert *msg = [[NSAlert alloc] init];
            [msg setAlertStyle:NSWarningAlertStyle];

            [msg addButtonWithTitle:@"Abnicken"];
            msg.messageText = [NSString stringWithFormat:@"Fehler beim Starten der %@ Wallet", button.title];
            msg.informativeText = [NSString stringWithFormat:@"Installieren Sie %@.", applications[button.title]];

            [msg runModal];
        }
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
- (IBAction)multiAction:(id)sender {
    NSString *tabTitle = [self.dismissButton title];
    
    NSDictionary *tabStrings = @{
        @"Dashboard":  @[@"ALL", @"alle Kurse"],
        @"Bitcoin": @[@"BTC", @"den Bitcoin Kurs"],
        @"Ethereum": @[@"ETH", @"den Ethereum Kurs"],
        @"Monero":  @[@"XMR", @"den Monero Kurs"],
        @"Litecoin": @[@"LTC", @"den Litecoin Kurs"],
        @"Dogecoin": @[@"DOGE", @"den Dogecoin Kurs"]
    };    
    
    NSString *msg = [NSString stringWithFormat:@"Möchten Sie %@ aktualisieren?", tabStrings[tabTitle][1]];
    NSString *info = @"Der Vergleich (+/-) bezieht sich auf die zuletzt gespeicherten Kurse!";

    if ([Helper messageText:msg info:info] == NSAlertFirstButtonReturn) {
        [calculator checkPointForKey:tabStrings[tabTitle][0] withBTCUpdate:FALSE];
    }
}

/**
 * Action Handler für das Anzeigen des umgerechneten Bestands
 *
 * @param sender
 */
- (IBAction)currencyAction:(id)sender {

    NSString *text;

    text = [NSString stringWithFormat:@"%@ BTC\n%@ ETH\n%@ XMR\n%@ LTC\n%@ DOGE",
        [Helper double2German:[calculator calculateWithRatings:currentRatings currency:@"BTC"] min:4 max:8],
        [Helper double2German:[calculator calculateWithRatings:currentRatings currency:@"ETH"] min:4 max:8],
        [Helper double2German:[calculator calculateWithRatings:currentRatings currency:@"XMR"] min:4 max:8],
        [Helper double2German:[calculator calculateWithRatings:currentRatings currency:@"LTC"] min:4 max:8],
        [Helper double2German:[calculator calculateWithRatings:currentRatings currency:@"DOGE"] min:4 max:8]
    ];

    [Helper messageText:@"Gesamtbestand umgerechnet:" info:text];
}

/**
 * Aktualisieren des eingegeben Bestands per Klick
 *
 * @param sender
 */
- (IBAction)cryptoAction:(id)sender {
    NSString *tabTitle = [self.dismissButton title];

    if ([tabTitle isEqualToString:@"Dashboard"]) {
        return;
    }

    NSString *text = [NSString stringWithFormat:@"%@ Bestand aktualisieren", tabTitle];

    if ([Helper messageText:text info:@"Möchten Sie Ihren aktuellen Bestand aktualisieren?"] == NSAlertFirstButtonReturn) {
        NSString *cUnit = tabs[tabTitle][0];

        [calculator currentSaldo:cUnit withDouble: self.cryptoUnits.doubleValue];
        self.currencyUnits.doubleValue = self.cryptoUnits.doubleValue / [currentRatings[cUnit] doubleValue];

        // Checkpoint aktualisieren
        [calculator checkPointForKey:cUnit withBTCUpdate:TRUE];
    }
}

/**
 * Einfacher Währungsumrechner 
 *
 * @param sender
 */
- (IBAction)rateInputAction:(id)sender {
    NSString *tabTitle = [self.dismissButton title];

    NSString *cUnit = tabs[tabTitle][0];
    NSString *exchangeUnit = self.exchangeSelection.selectedItem.title;

    double exchangeFactor = ([exchangeUnit isEqualToString:fiatCurrencies[0]]) ? 1 : [currentRatings[exchangeUnit] doubleValue];

    double amount = self.rateInputLabel.doubleValue;
    double result = amount / [currentRatings[cUnit] doubleValue] * exchangeFactor;

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
 * Getter für homeURL
 *
 * @return NSString*
 */
- (NSString *)homeURL {
    return homeURL;
}

/**
 * Setter für die homeURL
 *
 * @param NSString*
 */
- (void)homeURL:(NSString *)url {
    homeURL = url;
}

@end
