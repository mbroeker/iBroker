//
//  ViewController.m
//  iBroker
//
//  Created by Markus Bröker on 04.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "TemplateViewController.h"

@implementation TemplateViewController {
@private
    NSMutableDictionary *applications;
    NSMutableDictionary *traders;
    
    NSUserDefaults *defaults;
}

- (void)viewWillAppear {
    // Währungsformat mit 4 Nachkommastellen
    NSNumberFormatter *currencyFormatter = [self.currencyUnits formatter];
    
    [currencyFormatter setMinimumFractionDigits:4];
    [currencyFormatter setMaximumFractionDigits:4];

    // Crypto-Währungsformat mit 4-8 Nachkommastellen
    NSNumberFormatter *cryptoFormatter = [self.cryptoUnits formatter];
    [cryptoFormatter setMinimumSignificantDigits:4];
    [cryptoFormatter setMaximumSignificantDigits:8];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSImage *image = [NSApp applicationIconImage];
    [self.homepageButton setImage:image];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    applications = [[defaults objectForKey:@"applications"] mutableCopy];
    
    if (applications == NULL) {
    
        applications = [ @{
            @"Bitcoin": @"/Applications/mSIGNA.App",
            @"Ethereum": @"/Applications/Ethereum Wallet.App",
            @"Monero":  @"/Applications/monero-wallet-gui.App",
            @"Dogecoin": @"/Applications/MultiDoge.App",
        } mutableCopy];
        
        [defaults setObject:applications forKey:@"applications"];
    }
    
    traders = [[defaults objectForKey:@"traders"] mutableCopy];
    
    if (traders == NULL) {
        traders = [ @{
            @"homepage": @"https://www.4customers.de",
            @"trader1": @"https://www.shapeshift.io",
            @"trader2": @"https://www.blocktrades.us",
        } mutableCopy];
        
        [defaults setObject:traders forKey:@"traders"];
    }
    
    [defaults synchronize];
    
}

- (void)homeURL:(NSString*)url {
    
    self->homeURL = url;
    
}

- (IBAction)homepageActionClicked:(id)sender {
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: traders[@"homepage"]]];
    
}

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

- (IBAction)homeActionClicked:(id)sender {
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: self->homeURL]];
}

- (IBAction)leftActionClicked:(id)sender {
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: traders[@"trader1"]]];
}

- (IBAction)rightActionClicked:(id)sender {
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: traders[@"trader2"]]];
}

- (NSModalResponse)messageText:(NSString*) message info:(NSString*) info {
    
    NSAlert *msg = [[NSAlert alloc] init];
    
    [msg setAlertStyle:NSInformationalAlertStyle];
    [msg addButtonWithTitle:@"Aktualisieren"];
    [msg addButtonWithTitle:@"Verwerfen"];
    
    msg.messageText = message;
    msg.informativeText = info;
    
    return [msg runModal];
    
}

- (IBAction)multiActionClicked:(id)sender {

    NSString *pageTitle = [self.dismissButton title];
    
    NSMutableDictionary *initialRatings = [[defaults objectForKey:@"initialRatings"] mutableCopy];
    
    BOOL modified = false;
    if ([pageTitle isEqualToString:@"Dashboard"]) {
        if ([self messageText:@"Möchten Sie alle Kurse aktualisieren?" info:@"Der Vergleich (+/-) bezieht sich auf die zuletzt gespeicherten Kurse!"] == NSAlertFirstButtonReturn) {
            initialRatings = nil;
            modified = true;
        }
    }
    
    if ([pageTitle isEqualToString:@"Bitcoin"]) {
        if ([self messageText:@"Möchten Sie den Bitcoin-Kurs aktualisieren?" info:@"Der Vergleich (+/-) bezieht sich auf den zuletzt gespeicherten Kurs!"] == NSAlertFirstButtonReturn) {
            [initialRatings removeObjectForKey:@"BTC"];
            modified = true;
        }
    }
    
    if ([pageTitle isEqualToString:@"Ethereum"]) {
        if ([self messageText:@"Möchten Sie den Ethereum-Kurs aktualisieren?" info:@"Der Vergleich (+/-) bezieht sich auf den zuletzt gespeicherten Kurs!"] == NSAlertFirstButtonReturn) {
            [initialRatings removeObjectForKey:@"ETH"];
            modified = true;
        }
    }
    
    if ([pageTitle isEqualToString:@"Monero"]) {
        if ([self messageText:@"Möchten Sie den Monero-Kurs aktualisieren?" info:@"Der Vergleich (+/-) bezieht sich auf den zuletzt gespeicherten Kurs!"] == NSAlertFirstButtonReturn) {
            [initialRatings removeObjectForKey:@"XMR"];
            modified = true;
        }
    }
    
    if ([pageTitle isEqualToString:@"Dogecoin"]) {
        if ([self messageText:@"Möchten Sie den Dogecoin-Kurs aktualisieren?" info:@"Der Vergleich (+/-) bezieht sich auf den zuletzt gespeicherten Kurs!"] == NSAlertFirstButtonReturn) {
            [initialRatings removeObjectForKey:@"DOGE"];
            modified = true;
        }
    }
    
    if (modified) {
        [defaults setObject:initialRatings forKey:@"initialRatings"];
        [defaults synchronize];
    }
}

@end
