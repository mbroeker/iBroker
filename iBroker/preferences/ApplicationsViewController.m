//
//  ApplicationsViewController.m
//  iBroker
//
//  Created by Markus Bröker on 15.05.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "ApplicationsViewController.h"
#import "Calculator.h"

@implementation ApplicationsViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self updateView];
}

/**
 * Aktualisierung des Views vereinheitlicht
 */
- (void)updateView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // aktualisierten Saldo besorgen
    NSMutableDictionary *applications = [[defaults objectForKey:TV_APPLICATIONS] mutableCopy];
    
    self.btcField.stringValue = applications[BITCOIN];
    self.zecField.stringValue = applications[ZCASH];
    self.ethField.stringValue = applications[ETHEREUM];
    self.xmrField.stringValue = applications[MONERO];
    self.ltcField.stringValue = applications[LITECOIN];
    self.gameField.stringValue = applications[GAMECREDITS];
    self.emc2Field.stringValue = applications[STEEMCOIN];
    self.maidField.stringValue = applications[SAFEMAID];
    self.btsField.stringValue = applications[BITSHARES];
    self.scField.stringValue = applications[SIACOIN];
}

/**
 * Speichern der Adressen des Nutzers
 *
 * @param sender
 */
- (IBAction)saveAction:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // aktualisierten Saldo besorgen
    NSMutableDictionary *applications = [[defaults objectForKey:TV_APPLICATIONS] mutableCopy];
    
    applications[BITCOIN] = self.btcField.stringValue;
    applications[ZCASH] = self.zecField.stringValue;
    applications[ETHEREUM] = self.ethField.stringValue;
    applications[MONERO] = self.xmrField.stringValue;
    applications[LITECOIN] = self.ltcField.stringValue;
    applications[GAMECREDITS] = self.gameField.stringValue;
    applications[STEEMCOIN] = self.emc2Field.stringValue;
    applications[SAFEMAID] = self.maidField.stringValue;
    applications[BITSHARES] = self.btsField.stringValue;    
    applications[SIACOIN] = self.scField.stringValue;

    [defaults setObject:applications forKey:TV_APPLICATIONS];
    [defaults synchronize];

    // Gepeicherte Daten neu einlesen...
    [self updateView];
}

@end
