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
    self.gameField.stringValue = applications[GAMECOIN];
    self.emc2Field.stringValue = applications[EINSTEINIUM];
    self.maidField.stringValue = applications[SAFEMAID];
    self.scField.stringValue = applications[SIACOIN];
    self.dogeField.stringValue = applications[DOGECOIN];
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
    applications[GAMECOIN] = self.gameField.stringValue;
    applications[EINSTEINIUM] = self.emc2Field.stringValue;
    applications[SAFEMAID] = self.maidField.stringValue;
    applications[SIACOIN] = self.scField.stringValue;
    applications[DOGECOIN] = self.dogeField.stringValue;

    [defaults setObject:applications forKey:TV_APPLICATIONS];
    [defaults synchronize];

    // Gepeicherte Daten neu einlesen...
    [self updateView];
}

@end
