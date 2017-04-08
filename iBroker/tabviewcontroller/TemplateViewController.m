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
    NSDictionary *currentRatings;
    NSDictionary *saldoUrls;
    
    NSDictionary *applications;
    NSDictionary *traders;
    
    // Bilder und URLs
    NSDictionary *images;    
    NSString *homeURL;
}

/**
 * Lösche alle Schlüssel
 */
- (void) resetDefaults {
    defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:@"applications"];
    [defaults removeObjectForKey:@"traders"];
    [defaults removeObjectForKey:@"saldoUrls"];
    [defaults removeObjectForKey:@"currentSaldo"];
    [defaults removeObjectForKey:@"initialRatings"];
    
    [self initializeWithDefaults];
}

/**
 * Initialisiere alle Datenstrukturen
 */
- (void)initializeWithDefaults {
    defaults = [NSUserDefaults standardUserDefaults];

    images = @{
        @"EUR": [NSImage imageNamed:@"EUR"],
        @"USD": [NSImage imageNamed:@"USD"],
        @"BTC": [NSImage imageNamed:@"BTC"],
        @"ETH": [NSImage imageNamed:@"ETH"],
        @"XMR": [NSImage imageNamed:@"XMR"],
        @"DOGE": [NSImage imageNamed:@"DOGE"],
    };
    
    applications = [[defaults objectForKey:@"applications"] mutableCopy];
    
    if (applications == NULL) {
        applications = @{
            @"Bitcoin": @"/Applications/mSIGNA.App",
            @"Ethereum": @"/Applications/Ethereum Wallet.App",
            @"Monero":  @"/Applications/monero-wallet-gui.App",
            @"Dogecoin": @"/Applications/MultiDoge.App",
        };
        
        [defaults setObject:applications forKey:@"applications"];
        [defaults synchronize];
    }
    
    traders = [defaults objectForKey:@"traders"];
    
    if (traders == NULL) {
        traders = @{
            @"homepage": @"https://www.4customers.de",
            @"trader1": @"https://www.shapeshift.io",
            @"trader2": @"https://www.blocktrades.us",
        };
        
        [defaults setObject:traders forKey:@"traders"];
        [defaults synchronize];
    }
    
    currentSaldo = [[defaults objectForKey:@"currentSaldo"] mutableCopy];
    
    if (currentSaldo == NULL) {
        currentSaldo = [ @{
            @"BTC": @0.00414846,
            @"ETH": @0.23868595,
            @"XMR": @0.18477072,
            @"DOGE":@5053.47368421,
        } mutableCopy];
        
        [defaults setObject:currentSaldo forKey:@"currentSaldo"];
        [defaults synchronize];
    }
    
    saldoUrls = [defaults objectForKey:@"saldoUrls"];
    
    if (saldoUrls == NULL) {
        saldoUrls = @{
            @"Dashboard": @"https://www.poloniex.com/exchange#btc_xmr",
            @"Bitcoin": @"https://blockchain.info/de/address/31nHZc8qdNG48YgyKqzxi9Y1NUX16XHexi",
            @"Ethereum": @"https://etherscan.io/address/0xaa18EB5d55Eaf8b9BA5488a96f57f77Dc127BE26",
            @"Monero": @"https://moneroblocks.info",
            @"Dogecoin": @"http://dogechain.info/address/DTVbJzNLVvARmDPnK9cqcxutbd1mEDyUQ1",
        };
        
        [defaults setObject:saldoUrls forKey:@"saldoUrls"];
        [defaults synchronize];
    }
}

/**
 * Setzen der Formatierungsregeln für die Eingabefelder
 */
- (void)viewWillAppear {
    // Währungsformat mit 4 Nachkommastellen
    NSNumberFormatter *currencyFormatter = [self.currencyUnits formatter];
    [currencyFormatter setMinimumFractionDigits:2];
    [currencyFormatter setMaximumFractionDigits:4];
    
    // Crypto-Währungsformat mit 8-12 Nachkommastellen
    NSNumberFormatter *cryptoFormatter = [self.cryptoUnits formatter];
    [cryptoFormatter setMinimumFractionDigits:8];
    [cryptoFormatter setMaximumFractionDigits:8];

    // Ratings aktualisieren
    [self currentRatings];

    [_cryptoUnits setTarget:self];
    [_cryptoUnits setAction:@selector(cryptoAction:)];
}

/**
 * Initialisierung der Sicht / des View
 */
- (void)viewDidLoad {
    [super viewDidLoad];

    // Startseite aufrufen
    [self initialOverview];
}

- (void) firstStart {
    // Initialisieren der Anwendung und der Datenstrukturen
    [self initializeWithDefaults];

    if (initialRatings == NULL) {
        initialRatings = [[defaults objectForKey:@"initialRatings"] mutableCopy];

        if (initialRatings == NULL) {
            initialRatings = [ @{
                    @"USD": @1.0,
                    @"BTC": @1.0,
                    @"ETH": @1.0,
                    @"XMR": @1.0,
                    @"DOGE":@1.0,
            } mutableCopy];
        }
    }

    if (currentRatings == NULL) {
        currentRatings =[initialRatings mutableCopy];
    }

    [defaults synchronize];
}

/**
 * Übersicht mit Fakewerten beim ersten und initialen Start...
 */
- (void)initialOverview {
    NSString *tab = @"Dashboard";

    // Erst-Start-Überprüfung
    [self firstStart];

    // Setze die Standard-Homepage für den HomeButton
    homeURL = saldoUrls[tab];
    self.dismissButton.title = tab;

    self.percentLabel.stringValue = @"Bestand";

    [self.cryptoButton setImage:images[@"USD"]];
    self.cryptoUnits.stringValue = [Helper double2German:[self calculate:@"USD" ratings:initialRatings] min:2 max:2];
    
    [self.currencyButton setImage:images[@"EUR"]];
    self.currencyUnits.stringValue = [Helper double2German:[self calculate:@"EUR" ratings:initialRatings] min:2 max:2];

    self.rateLabel.stringValue = [NSString stringWithFormat:@"iBroker Version %@", NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"]];
}

/**
 * Action-Handler für den homepageButton
 */
- (IBAction)homepageActionClicked:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: traders[@"homepage"]]];
}

/**
 * Action-Handler zum Starten der jeweiligen Wallet-App
 */
- (IBAction)dismissActionClicked:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    NSButton *button = (NSButton*) sender;
    
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
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: homeURL]];
}

/**
 * Action-Handler zum Aufruf des Crypto-Shifters
 */
- (IBAction)leftActionClicked:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: traders[@"trader1"]]];
}

/**
 * Action-Handler zum Aufruf des Crypto-Shifters
 */
- (IBAction)rightActionClicked:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: traders[@"trader2"]]];
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
            @"Bitcoin":   @"BTC",
            @"Ethereum":  @"ETH",
            @"Monero":    @"XMR",
            @"Dogecoin":  @"DOGE",
        };
        
        currentSaldo[tabs[tabTitle]] = [[NSNumber alloc] initWithDouble:self.cryptoUnits.doubleValue];
        self.currencyUnits.doubleValue = self.cryptoUnits.doubleValue / [currentRatings[tabs[tabTitle]] doubleValue];

        [defaults setObject:currentSaldo forKey:@"currentSaldo"];
        [defaults synchronize];
    }
}

// Datenkapselung: Getter in Objective-C
- (NSDictionary*) applications {
    return applications;
}

// Datenkapselung: Getter in Objective-C
- (NSDictionary*) traders {
    return traders;
}

// Datenkapselung: Getter in Objective-C
- (NSDictionary*) images {
    return images;
}

// Datenkapselung: Getter in Objective-C
- (NSString*)homeURL {
    return homeURL;
}

// Datenkapselung: Setter in Objective-C
- (void)homeURL:(NSString*)url {
    homeURL = url;
}

/**
 * Berechne den Gesamtwert der Geldbörsen in Euro oder Dollar...
 */
- (double)calculate:(NSString*) currency ratings:(NSDictionary*)ratings{
    double btc = [currentSaldo[@"BTC"] doubleValue] / [ratings[@"BTC"] doubleValue];
    double eth = [currentSaldo[@"ETH"] doubleValue] / [ratings[@"ETH"] doubleValue];
    double xmr = [currentSaldo[@"XMR"] doubleValue] / [ratings[@"XMR"] doubleValue];
    double doge = [currentSaldo[@"DOGE"] doubleValue] / [ratings[@"DOGE"] doubleValue];
    
    double sum = btc + eth + xmr + doge;
    
    if ([currency isEqualToString:@"EUR"]) {
        return sum;
    }
    
    return sum * [ratings[@"USD"] doubleValue];
}

/**
 * Aktualisiere die Kurse der jeweiligen Währung
 */
- (void) updateRatings:(NSString*)key {    
    NSDictionary *tabs = @{
        @"Dashboard": @[@"ALL", @"alle Kurse"],
        @"Bitcoin": @[@"BTC", @"den Bitcoin Kurs"],
        @"Ethereum": @[@"ETH", @"den Ethereum Kurs"],
        @"Monero": @[@"XMR", @"den Monero Kurs"],
        @"Dogecoin": @[@"DOGE", @"den Dogecoin Kurs"],
    };
    
    NSString *msg = [NSString stringWithFormat:@"Möchten Sie %@ aktualisieren?", tabs[key][1]];
    NSString *info = @"Der Vergleich (+/-) bezieht sich auf die zuletzt gespeicherten Kurse!";

    if ([Helper messageText:msg info:info] == NSAlertFirstButtonReturn) {
        if ([tabs[key][0] isEqualToString:@"ALL"]) {
            [defaults setObject:currentRatings forKey:@"initialRatings"];
            [defaults synchronize];
        } else {
            [initialRatings setObject:currentRatings[tabs[key][0]] forKey:tabs[key][0]];
            [defaults setObject:currentRatings forKey:@"initialRatings"];
            [defaults synchronize];
        }
    }
}

/**
 * Besorge die Kurse von cryptocompare per JSON-Request und speichere Sie in den App-Einstellungen
 */
- (void)currentRatings {
    NSString *jsonURL = @"https://min-api.cryptocompare.com/data/pricemulti?fsyms=EUR&tsyms=USD,BTC,ETH,XMR,DOGE";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:jsonURL]];
    [request setHTTPMethod:@"GET"];
    
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
            initialRatings = [[defaults objectForKey:@"initialRatings"] mutableCopy];

#ifdef DEBUG
            NSLog(@"Initial Ratings: %@", initialRatings);
#endif

        }

        [defaults synchronize];

    }] resume];
}

/**
 * Übersicht mit richtigen Live-Werten
 */
- (void)updateOverview {
    self.percentLabel.stringValue = @"Aktuell";
    
    [self.cryptoButton setImage:images[@"USD"]];
    self.cryptoUnits.stringValue = [Helper double2German:[self calculate:@"USD" ratings:currentRatings] min:2 max:2];
    
    [self.currencyButton setImage:images[@"EUR"]];
    self.currencyUnits.stringValue = [Helper double2German:[self calculate:@"EUR" ratings:currentRatings] min:2 max:2];
    self.rateLabel.stringValue = [NSString stringWithFormat:@"1 EUR = %@ USD", [Helper double2German:[currentRatings[@"USD"] doubleValue] min:2 max:2]];
}

/**
 * Aktualisiere den jeweiligen Tab
 */
- (void)updateTemplateView:(NSString*)label {
    NSDictionary *tabs = @{
        @"Dashboard": @[@"USD", @1.0],
        @"Bitcoin": @[@"BTC", @1000.0],
        @"Ethereum": @[@"ETH", @10.0],
        @"Monero": @[@"XMR", @10.0],
        @"Dogecoin": @[@"DOGE", @(1 / 100.0)],
    };

    // Aktualisieren des Dismissbuttons und der headLine;
    self.dismissButton.title = label;
    self.headlineLabel.stringValue = label;

    NSString *unit = tabs[label][0];
    double units = [(NSNumber*) tabs[label][1] doubleValue];
    
    // Standards
    self->homeURL = saldoUrls[label];
    
    if ([label isEqualToString:@"Dashboard"]) {
        [self updateOverview];
        
        return;
    }
    
    // Aktiviere die Eingabe für die Crypto-Einheiten
    self.cryptoUnits.editable = true;
    
    
    [self.cryptoButton setImage:self.images[unit]];
    
    double percent = 100.0f * ([currentRatings[unit] doubleValue] / [initialRatings[unit] doubleValue]) - 100.0f;

#ifdef DEBUG
    NSLog(@"Percent %.4f = 100.0 * (%.8f / %.8f) - 100.0 ", percent, [currentRatings[unit] doubleValue], [initialRatings[unit] doubleValue]);
#endif

    self.percentLabel.stringValue = [Helper double2GermanPercent:percent fractions:2];
    
    self.cryptoUnits.doubleValue = [(NSNumber*)currentSaldo[unit] doubleValue];
    self.currencyUnits.doubleValue = self.cryptoUnits.doubleValue / [currentRatings[unit] doubleValue];
    
    double rate = units * [currentRatings[unit] doubleValue];
    self.rateLabel.stringValue = [NSString stringWithFormat:@"%g EUR = %@ %@", units, [Helper double2German:rate min:4 max:8], unit];
}

@end
