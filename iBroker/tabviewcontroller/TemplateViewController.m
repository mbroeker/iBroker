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
    NSUserDefaults *defaults;

    // Synchronisierte Einstellungen und Eigenschaften
    NSMutableDictionary *initialRatings;
    NSMutableDictionary *currentSaldo;

    // Normale Eigenschaften
    NSMutableDictionary *currentRatings;
    NSMutableDictionary *saldoUrls;

    NSMutableDictionary *applications;
    NSMutableDictionary *traders;

    // Bilder und URLs
    NSMutableDictionary *images;
    NSString *homeURL;

    BOOL hasFinished;
}

/**
 * Berechne den Gesamtwert der Geldbörsen in Euro oder Dollar...
 */
- (double)calculate:(NSString *)currency {
    currentSaldo = [[defaults objectForKey:@"currentSaldo"] mutableCopy];

    return [self calculateWithRatings:currentRatings currency:currency];
}

- (double)calculateWithRatings:(NSDictionary*)ratings currency:(NSString *)currency {
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
    defaults = [NSUserDefaults standardUserDefaults];

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
    NSDictionary *tabs = @{
        @"Dashboard": @[@"ALL", @"alle Kurse"],
        @"Bitcoin": @[@"BTC", @"den Bitcoin Kurs"],
        @"Ethereum": @[@"ETH", @"den Ethereum Kurs"],
        @"Litecoin": @[@"LTC", @"den Litecoin Kurs"],
        @"Monero": @[@"XMR", @"den Monero Kurs"],
        @"Dogecoin": @[@"DOGE", @"den Dogecoin Kurs"],
    };

    NSString *msg = [NSString stringWithFormat:@"Möchten Sie %@ aktualisieren?", tabs[key][1]];
    NSString *info = @"Der Vergleich (+/-) bezieht sich auf die zuletzt gespeicherten Kurse!";

    if ([Helper messageText:msg info:info] == NSAlertFirstButtonReturn) {
        if ([tabs[key][0] isEqualToString:@"ALL"]) {
            [defaults setObject:currentRatings forKey:@"initialRatings"];
        } else {
            initialRatings[tabs[key][0]] = currentRatings[tabs[key][0]];
            [defaults setObject:currentRatings forKey:@"initialRatings"];
        }
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

        currentRatings = [allkeys[@"EUR"] mutableCopy];
        initialRatings = [[defaults objectForKey:@"initialRatings"] mutableCopy];

        if (initialRatings == NULL) {
            [defaults setObject:currentRatings forKey:@"initialRatings"];
            initialRatings = [currentRatings mutableCopy];
        }

        hasFinished = true;

    }] resume];
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
    self.rateLabel.stringValue = [NSString stringWithFormat:@"iBroker Version %@", NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"]];
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
        NSLog(@"+++");
    }
    self.percentLabel.stringValue = [Helper double2GermanPercent:percent fractions:2];

    [self.currencyButton setImage:images[@"EUR"]];
    self.currencyUnits.doubleValue = [self calculate:@"EUR"];

    [self.cryptoButton setImage:images[@"USD"]];
    self.cryptoUnits.doubleValue = [self calculate:@"USD"];

    self.rateLabel.stringValue = [NSString stringWithFormat:@"1 EUR = %@ USD", [Helper double2German:[currentRatings[@"USD"] doubleValue] min:2 max:2]];
}

/**
 * Aktualisiere den jeweiligen Tab
 */
- (void)updateTemplateView:(NSString *)label {

    // Ratings aktualisieren
    [self waitForUpdateRatings];

    NSDictionary *tabs = @{
        @"Dashboard": @[@"USD", @1],
        @"Bitcoin": @[@"BTC", @1],
        @"Ethereum": @[@"ETH", @1],
        @"Litecoin": @[@"LTC", @1],
        @"Monero": @[@"XMR", @1],
        @"Dogecoin": @[@"DOGE", @(10000)],
    };

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
    self.rateLabel.stringValue = [NSString stringWithFormat:@"%@ %@ = %@ EUR", [Helper double2German:units min:0 max:0], unit, [Helper double2German:rate min:2 max:4]];
}

/**
 * Lösche alle Schlüssel
 */
- (void)resetDefaults {
    NSLog(@"resetDefaults");

    [defaults removeObjectForKey:@"applications"];
    [defaults removeObjectForKey:@"traders"];
    [defaults removeObjectForKey:@"saldoUrls"];
    [defaults removeObjectForKey:@"currentSaldo"];
    [defaults removeObjectForKey:@"initialRatings"];
}

/**
 * Action-Handler für den homepageButton
 */
- (IBAction)homepageActionClicked:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:traders[@"homepage"]]];
}

/**
 * Action-Handler zum Starten der jeweiligen Wallet-App
 */
- (IBAction)dismissActionClicked:(id)sender {
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
- (IBAction)homeActionClicked:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:homeURL]];
}

/**
 * Action-Handler zum Aufruf des Crypto-Shifters
 */
- (IBAction)leftActionClicked:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:traders[@"trader1"]]];
}

/**
 * Action-Handler zum Aufruf des Crypto-Shifters
 */
- (IBAction)rightActionClicked:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:traders[@"trader2"]]];
}

/**
 * Action-Handler zum Aktualisieren des initialen Kurses der gewählten Währung (blaues Info-Icon)
 */
- (IBAction)multiActionClicked:(id)sender {
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
                @"ETH": @0.11986671,
                @"XMR": @0.07404131,
                @"LTC": @1.03376546,
                @"DOGE": @5053.47368421,
            } mutableCopy];

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

        NSDictionary *tabs = @{
            @"Dashboard": @"USD",
            @"Bitcoin": @"BTC",
            @"Ethereum": @"ETH",
            @"Litecoin": @"LTC",
            @"Monero": @"XMR",
            @"Dogecoin": @"DOGE",
        };

        currentSaldo[tabs[tabTitle]] = [[NSNumber alloc] initWithDouble:self.cryptoUnits.doubleValue];
        self.currencyUnits.doubleValue = self.cryptoUnits.doubleValue / [currentRatings[tabs[tabTitle]] doubleValue];

        [defaults setObject:currentSaldo forKey:@"currentSaldo"];
    }
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
