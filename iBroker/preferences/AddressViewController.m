//
//  WalletsViewController.m
//  iBroker
//
//  Created by Markus Bröker on 26.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "AddressViewController.h"
#import "Calculator.h"

@implementation AddressViewController {
    Calculator *calculator;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self updateView];
}

/**
 * Aktualisierung des Views vereinheitlicht
 */
- (void)updateView {
    calculator = [Calculator instance];

    // aktualisierten Saldo besorgen
    NSMutableDictionary *saldoUrls = [calculator saldoUrls];
    
    self.btcField.stringValue = saldoUrls[BITCOIN];
    self.zecField.stringValue = saldoUrls[ZCASH];
    self.ethField.stringValue = saldoUrls[ETHEREUM];
    self.xmrField.stringValue = saldoUrls[MONERO];
    self.ltcField.stringValue = saldoUrls[LITECOIN];
    self.gameField.stringValue = saldoUrls[GAMECREDITS];
    self.emc2Field.stringValue = saldoUrls[EINSTEINIUM];
    self.maidField.stringValue = saldoUrls[SAFEMAID];
    self.scField.stringValue = saldoUrls[SIACOIN];
    self.dogeField.stringValue = saldoUrls[DOGECOIN];
    
    self.dashboardField.stringValue = saldoUrls[DASHBOARD];
}

/**
 * Speichern der Adressen des Nutzers
 *
 * @param sender
 */
- (IBAction)saveAction:(id)sender {
    // aktualisierten Saldo besorgen
    NSMutableDictionary *saldoUrls = [calculator saldoUrls];

    saldoUrls[BITCOIN] = self.btcField.stringValue;
    saldoUrls[ZCASH] = self.zecField.stringValue;
    saldoUrls[ETHEREUM] = self.ethField.stringValue;
    saldoUrls[MONERO] = self.xmrField.stringValue;
    saldoUrls[LITECOIN] = self.ltcField.stringValue;
    saldoUrls[GAMECREDITS] = self.gameField.stringValue;
    saldoUrls[EINSTEINIUM] = self.emc2Field.stringValue;
    saldoUrls[SAFEMAID] = self.maidField.stringValue;
    saldoUrls[SIACOIN] = self.scField.stringValue;
    saldoUrls[DOGECOIN] = self.dogeField.stringValue;
    saldoUrls[DASHBOARD] = self.dashboardField.stringValue;
    
    [calculator saldoUrlsForDictionary:saldoUrls];

    // Gespeicherte Daten neu einlesen...
    [self updateView];
}

@end
