//
//  TemplateViewController.m
//  iBroker
//
//  Created by Markus Bröker on 04.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "TemplateViewController.h"
#import "Helper.h"

@implementation TemplateViewController {
@private
    // Synchronisierte Einstellungen und Eigenschaften
    NSMutableDictionary *initialRatings;
    NSMutableDictionary *currentSaldo;

    // Normale Eigenschaften
    NSMutableDictionary *currentRatings;
    NSMutableDictionary *saldoUrls;

    NSMutableDictionary *applications;
    NSMutableDictionary *traders;

    // Die Tabs
    NSDictionary *tabs;

    // Bilder und URLs
    NSMutableDictionary *images;
    NSString *homeURL;

    BOOL hasFinished;
}

/**
 * Berechne den Gesamtwert der Geldbörsen in Euro oder Dollar...
 */
- (double)calculate:(NSString *)currency {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    currentSaldo = [[defaults objectForKey:@"currentSaldo"] mutableCopy];

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

    return sum * [ratings[@"USD"] doubleValue];
}

/**
 * Initialisiere alle Datenstrukturen
 */
- (void)initializeWithDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    tabs = @{
        @"Dashboard": @[@"USD", @1],
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
            @"Dashboard": @"https://coinmarketcap.com/currencies/#EUR",
            @"Bitcoin": @"https://blockchain.info/de/address/31nHZc8qdNG48YgyKqzxi9Y1NUX16XHexi",
            @"Ethereum": @"https://etherscan.io/address/0xaa18EB5d55Eaf8b9BA5488a96f57f77Dc127BE26",
            @"Litecoin": @"https://chainz.cryptoid.info/ltc/address.dws?LMnHSGGr7FEi97gCgG5dB8418G91TSanMP.htm",
            @"Monero": @"https://moneroblocks.info",
            @"Dogecoin": @"http://dogechain.info/address/DTVbJzNLVvARmDPnK9cqcxutbd1mEDyUQ1",
        } mutableCopy];

        [defaults setObject:saldoUrls forKey:@"saldoUrls"];
    }
    
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

    [self firstStart];
}

- (void)firstStart {
    // Initialisieren der Anwendung und der Datenstrukturen
    [self initializeWithDefaults];
}

/**
 * Aktualisiere die Kurse der jeweiligen Währung
 */
- (void)updateRatings:(NSString *)key {
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

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([Helper messageText:msg info:info] == NSAlertFirstButtonReturn) {
        if ([tabStrings[key][0] isEqualToString:@"ALL"]) {
            [defaults setObject:currentRatings forKey:@"initialRatings"];
        } else {
            initialRatings[tabStrings[key][0]] = currentRatings[tabStrings[key][0]];
            [defaults setObject:initialRatings forKey:@"initialRatings"];
        }
        
        [defaults synchronize];
    }
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
        if ([Helper messageText:@"Bitte warten" info:@"Netzwerkauslastung ist derzeit sehr hoch."] == NSAlertFirstButtonReturn) {
            [NSApp terminate:self];
        }

        hasFinished = true;
    }
    
    if (hasFinished) {
        loops = 0;
    }
}

/**
 * Übersicht mit Semaphore
 */
- (void)initialOverview {
    // Ratings aktualisieren
    [self waitForUpdateRatings];

    [self updateOverview];
}

- (int)sumUp:(int) a b:(int)b {
    return a+b;
}

// Spielwiese für neue Sprachfeatures
- (void)test {
    int (^summe)(int a, int b) = ^(int a, int b) {
        return a + b;
    };
    
    NSLog(@"Summe ist %d", summe(4, 5));
}

/**
 * Übersicht mit richtigen Live-Werten
 */
- (void)updateOverview {
    self.dismissButton.title = @"Dashboard";
    
    double total = [self calculate:@"EUR"];
    double initial = [self calculateWithRatings:initialRatings currency:@"EUR"];
    double percent = (total / initial * 100.0) - 100.0;

    double prices = 0;
    for (id unit in [[currentSaldo allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
        double initialPrice = 1.0 / [initialRatings[unit] doubleValue];
        double currentPrice = 1.0 / [currentRatings[unit] doubleValue];

        double amount = [currentSaldo[unit] doubleValue] / [currentRatings[unit] doubleValue];
        double share = (amount / total) * 100.0;
        double price = ((currentPrice / initialPrice) * amount) - amount;

        NSLog(@"%4s: %10s | %10s | %8s | %8s | %8s",
            [unit UTF8String],
            [[Helper double2German:initialPrice min:2 max:4] UTF8String],
            [[Helper double2German:currentPrice min:2 max:4] UTF8String],
            [[Helper double2GermanPercent:share fractions:2] UTF8String],
            [[Helper double2German:amount min:4 max:2] UTF8String],
            [[Helper double2German:price min:2 max:2] UTF8String]
        );
        prices += price;
    }
    
    NSLog(@" ALL: %10s | %10s | %8s | %8s | %8s",
        [[Helper double2German:initial min:2 max:4] UTF8String],
        [[Helper double2German:total min:2 max:4] UTF8String],
        [[Helper double2GermanPercent:percent fractions:2] UTF8String],
        [[Helper double2German:total min:2 max:2] UTF8String],
        [[Helper double2German:prices min:2 max:2] UTF8String]
    );

    if (percent < 0.0) {
        NSLog(@"---");
        [self.percentLabel setTextColor:[NSColor redColor]];
    } else {
        [self.percentLabel setTextColor:[NSColor whiteColor]];
        NSLog(@"+++");
    }
    self.percentLabel.stringValue = [Helper double2GermanPercent:percent fractions:2];

    [self.currencyButton setImage:images[@"EUR"]];
    self.currencyUnits.doubleValue = [self calculate:@"EUR"];

    [self.cryptoButton setImage:images[@"USD"]];
    self.cryptoUnits.doubleValue = [self calculate:@"USD"];

    self.rateOutputLabel.stringValue = [NSString stringWithFormat:@"%@", [Helper double2German:[currentRatings[@"USD"] doubleValue] min:2 max:2]];

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
    
    [self.exchangeSelection selectItemWithTitle:@"EUR"];
}

/**
 * Aktualisiere den jeweiligen Tab
 */
- (void)updateTemplateView:(NSString *)label {

    // Ratings aktualisieren
    [self waitForUpdateRatings];

    // Aktualisieren des Dismissbuttons und der headLine;
    self.dismissButton.title = label;
    self.headlineLabel.stringValue = label;

    NSString *unit = tabs[label][0];
    double units = [(NSNumber *) tabs[label][1] doubleValue];

    // Standards
    self->homeURL = saldoUrls[label];

    if ([label isEqualToString:@"Dashboard"]) {
        [self updateOverview];

        return;
    }

    // Aktiviere die Eingabe für die Crypto-Einheiten
    self.cryptoUnits.editable = true;


    [self.cryptoButton setImage:self.images[unit]];

    double initialPrice = 1.0 / [initialRatings[unit] doubleValue];
    double currentPrice = 1.0 / [currentRatings[unit] doubleValue];

    double percent = 100.0 * (currentPrice / initialPrice) - 100.0;

    if (percent < 0.0) {
        [self.percentLabel setTextColor:[NSColor redColor]];
    }

    self.percentLabel.stringValue = [Helper double2GermanPercent:percent fractions:2];

    self.cryptoUnits.doubleValue = [currentSaldo[unit] doubleValue];
    self.currencyUnits.doubleValue = self.cryptoUnits.doubleValue / [currentRatings[unit] doubleValue];

    double rate = units / [currentRatings[unit] doubleValue];
    self.rateInputLabel.stringValue = [Helper double2German:units min:0 max:0];
    self.rateInputCurrencyLabel.stringValue = unit;
    self.rateOutputLabel.stringValue = [NSString stringWithFormat:@"%@", [Helper double2German:rate min:2 max:4]];
    
    double cUnit = [currentRatings[unit] doubleValue];
    
    if ([unit isEqualToString:@"DOGE"]) cUnit /= [tabs[@"Dogecoin"][1] doubleValue];
    
    NSDictionary *currentPriceInUnits = @{
        @"BTC": [NSNumber numberWithDouble:[currentRatings[@"BTC"] doubleValue] / cUnit],
        @"ETH": [NSNumber numberWithDouble:[currentRatings[@"ETH"] doubleValue] / cUnit],
        @"XMR": [NSNumber numberWithDouble:[currentRatings[@"XMR"] doubleValue] / cUnit],
        @"LTC": [NSNumber numberWithDouble:[currentRatings[@"LTC"] doubleValue] / cUnit],
        @"DOGE": [NSNumber numberWithDouble:[currentRatings[@"DOGE"] doubleValue] / cUnit]
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
    
    NSMutableDictionary *currencyUnits = [[NSMutableDictionary alloc] init];
    for (id currencyUnit in currentRatings) {
        double initialPrice = 1.0 / [initialRatings[currencyUnit] doubleValue];
        double currentPrice = 1.0 / [currentRatings[currencyUnit] doubleValue];
    
        double cPercent = 100.0 * (currentPrice / initialPrice) - 100.0;
        
        [currencyUnits setObject:[NSNumber numberWithDouble:cPercent] forKey:currencyUnit];
    }
    
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
    
    self.exchangeSelection.title = @"EUR";
}

/**
 * Lösche alle Schlüssel
 */
- (void)resetDefaults {
    NSLog(@"resetDefaults");

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults removeObjectForKey:@"applications"];
    [defaults removeObjectForKey:@"traders"];
    [defaults removeObjectForKey:@"saldoUrls"];
    [defaults removeObjectForKey:@"currentSaldo"];
    [defaults removeObjectForKey:@"initialRatings"];
    
    [defaults synchronize];
}

/**
 * Action-Handler für den homepageButton
 */
- (IBAction)homepageAction:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:traders[@"homepage"]]];
}

/**
 * Action-Handler zum Starten der jeweiligen Wallet-App
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
 */
- (IBAction)homeAction:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:homeURL]];
}

/**
 * Action-Handler zum Aufruf des Crypto-Shifters
 */
- (IBAction)leftAction:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:traders[@"trader1"]]];
}

/**
 * Action-Handler zum Aufruf des Crypto-Shifters
 */
- (IBAction)rightAction:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:traders[@"trader2"]]];
}

/**
 * Action-Handler zum Aktualisieren des initialen Kurses der gewählten Währung (blaues Info-Icon)
 */
- (IBAction)multiAction:(id)sender {
    NSString *tabTitle = [self.dismissButton title];
    [self updateRatings:tabTitle];
}

/**
 * noch frei
 */
- (IBAction)currencyAction:(id)sender {
    NSLog(@"BTC: %@ ETH: %@ XMR: %@ LTC: %@ DOGE: %@",
        [Helper double2German:[initialRatings[@"BTC"] doubleValue] min:4 max:8],
        [Helper double2German:[initialRatings[@"ETH"] doubleValue] min:4 max:8],
        [Helper double2German:[initialRatings[@"XMR"] doubleValue] min:4 max:8],
        [Helper double2German:[initialRatings[@"LTC"] doubleValue] min:4 max:8],
        [Helper double2German:[initialRatings[@"DOGE"] doubleValue] min:4 max:8]
    );
    
    NSLog(@"BTC: %@ ETH: %@ XMR: %@ LTC: %@ DOGE: %@",
        [Helper double2German:[currentRatings[@"BTC"] doubleValue] min:4 max:8],
        [Helper double2German:[currentRatings[@"ETH"] doubleValue] min:4 max:8],
        [Helper double2German:[currentRatings[@"XMR"] doubleValue] min:4 max:8],
        [Helper double2German:[currentRatings[@"LTC"] doubleValue] min:4 max:8],
        [Helper double2German:[currentRatings[@"DOGE"] doubleValue] min:4 max:8]
    );
    
    NSLog(@"---");
    
    NSLog(@"BTC: %@ ETH: %@ XMR: %@ LTC: %@ DOGE: %@",
        [Helper double2German:[currentSaldo[@"BTC"] doubleValue] min:4 max:8],
        [Helper double2German:[currentSaldo[@"ETH"] doubleValue] min:4 max:8],
        [Helper double2German:[currentSaldo[@"XMR"] doubleValue] min:4 max:8],
        [Helper double2German:[currentSaldo[@"LTC"] doubleValue] min:4 max:8],
        [Helper double2German:[currentSaldo[@"DOGE"] doubleValue] min:4 max:8]
    );

    if ([Helper messageText:@"Anwendungs-Reset" info:@"Möchten Sie auf die Standard-Einstellungen zurück setzen und beenden?"] == NSAlertFirstButtonReturn) {
        [self resetDefaults];

        if ([NSUserName() isEqualToString:@"mbroeker"]) {
            NSLog(@"Setzte meinen Kontostand zurück...");
            currentSaldo = [@{
                @"BTC": @0.00034846,
                @"ETH": @0.00000000,
                @"XMR": @0.00000000,
                @"LTC": @0.00000000,
                @"DOGE": @35919.11904761,
            } mutableCopy];

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:currentSaldo forKey:@"currentSaldo"];
            [defaults synchronize];
        }
    }
}

/**
 * Aktualisieren des eingegeben Bestands per Click
 *
 * @TODO: Enter-Handler implementieren
 */
- (IBAction)cryptoAction:(id)sender {
    NSString *tabTitle = [self.dismissButton title];
    NSString *text = [NSString stringWithFormat:@"%@ Bestand aktualisieren", tabTitle];

    if ([tabTitle isEqualToString:@"Dashboard"]) {
        return;
    }

    if ([Helper messageText:text info:@"Möchten Sie Ihren aktuellen Bestand aktualisieren?"] == NSAlertFirstButtonReturn) {
        NSString *cUnit = tabs[tabTitle][0];
        
        currentSaldo[cUnit] = [[NSNumber alloc] initWithDouble:self.cryptoUnits.doubleValue];
        self.currencyUnits.doubleValue = self.cryptoUnits.doubleValue / [currentRatings[cUnit] doubleValue];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:currentSaldo forKey:@"currentSaldo"];
        [defaults synchronize];
    }
}

// Einfacher Währungsumrechner
- (IBAction)rateInputAction:(id)sender {
    NSString *tabTitle = [self.dismissButton title];
    
    NSString *cUnit = tabs[tabTitle][0];
    NSString *exchangeUnit = self.exchangeSelection.selectedItem.title;
    
    double exchangeFactor = ([exchangeUnit isEqualToString:@"EUR"]) ? 1 : [currentRatings[exchangeUnit] doubleValue];
    
    double amount = self.rateInputLabel.doubleValue;
    double result = amount / [currentRatings[cUnit] doubleValue] * exchangeFactor;
    
    self.rateInputCurrencyLabel.stringValue = cUnit;
    self.rateOutputLabel.stringValue = [NSString stringWithFormat:@"%@", [Helper double2German:result min:4 max:4]];
}

// Datenkapselung: Getter in Objective-C
- (NSDictionary *)applications {
    return applications;
}

// Datenkapselung: Getter in Objective-C
- (NSDictionary *)traders {
    return traders;
}

// Datenkapselung: Getter in Objective-C
- (NSDictionary *)images {
    return images;
}

// Datenkapselung: Getter in Objective-C
- (NSString *)homeURL {
    return homeURL;
}

// Datenkapselung: Setter in Objective-C
- (void)homeURL:(NSString *)url {
    homeURL = url;
}

@end
