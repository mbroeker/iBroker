//
//  ViewController.m
//  iBroker
//
//  Created by Markus Bröker on 04.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "TemplateViewController.h"
#import "Helper.h"

@implementation TemplateViewController {
@private
    NSMutableDictionary *applications;
    NSMutableDictionary *traders;
    
    NSUserDefaults *defaults;
}

- (void)viewWillAppear {
    
    // Währungsformat mit 4 Nachkommastellen
    NSNumberFormatter *currencyFormatter = [self.currencyUnits formatter];
    [currencyFormatter setMinimumFractionDigits:2];
    [currencyFormatter setMaximumFractionDigits:4];
    
    // Crypto-Währungsformat mit 8-12 Nachkommastellen
    NSNumberFormatter *cryptoFormatter = [self.cryptoUnits formatter];
    [cryptoFormatter setMinimumFractionDigits:8];
    [cryptoFormatter setMaximumFractionDigits:8];
    
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

- (void) updateRatings:(NSString*)key {
    
    NSMutableDictionary *initialRatings = [[defaults objectForKey:@"initialRatings"] mutableCopy];
    
    NSDictionary *tabs = @{
        @"Dashboard": [NSArray arrayWithObjects:@"ALL", @"alle Kurse", nil],
        @"Bitcoin":   [NSArray arrayWithObjects:@"BTC", @"den Bitcoin Kurs", nil],
        @"Ethereum":  [NSArray arrayWithObjects:@"ETH", @"den Ethereum Kurs", nil],
        @"Monero":    [NSArray arrayWithObjects:@"XMR", @"den Monero Kurs", nil],
        @"Dogecoin":  [NSArray arrayWithObjects:@"DOGE", @"den Dogecoin Kurs", nil],
    };
    
    NSString *msg = [NSString stringWithFormat:@"Möchten Sie %@ aktualisieren?", tabs[key][1]];
    NSString *info = @"Der Vergleich (+/-) bezieht sich auf die zuletzt gespeicherten Kurse!";
    
    BOOL modified = false;
    if ([Helper messageText:msg info:info] == NSAlertFirstButtonReturn) {
        if ([tabs[key][0] isEqualToString:@"ALL"]) {
            initialRatings = nil;
            modified = true;
        } else {
            [initialRatings removeObjectForKey:tabs[key][0]];
            modified = true;
        }
    }
    
    if (modified) {
        [defaults setObject:initialRatings forKey:@"initialRatings"];
        [defaults synchronize];
    }
    
}

- (IBAction)multiActionClicked:(id)sender {
    
    NSString *pageTitle = [self.dismissButton title];
    [self updateRatings:pageTitle];
    
}

@end
