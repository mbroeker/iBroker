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
    
    calculator = [Calculator instance];

    // aktualisierten Saldo besorgen
    NSMutableDictionary *saldoUrls = [calculator saldoUrls];
    
    self.btcField.stringValue = saldoUrls[@"Bitcoin"];
    self.zecField.stringValue = saldoUrls[@"ZCash"];
    self.ethField.stringValue = saldoUrls[@"Ethereum"];
    self.xmrField.stringValue = saldoUrls[@"Monero"];
    self.ltcField.stringValue = saldoUrls[@"Litecoin"];
    self.gameField.stringValue = saldoUrls[@"Gamecoin"];
    self.xrpField.stringValue = saldoUrls[@"Ripple"];
    self.maidField.stringValue = saldoUrls[@"Safe Maid Coin"];
    self.strField.stringValue = saldoUrls[@"Stellar Lumens"];
    self.dogeField.stringValue = saldoUrls[@"Dogecoin"];
    
    self.dashboardField.stringValue = saldoUrls[@"Dashboard"];
}

/**
 * Speichern der Adressen des Nutzers
 *
 * @param sender
 */
- (IBAction)saveAction:(id)sender {
    // aktualisierten Saldo besorgen
    NSMutableDictionary *saldoUrls = [calculator saldoUrls];

    saldoUrls[@"Bitcoin"] = self.btcField.stringValue;
    saldoUrls[@"ZCash"] = self.zecField.stringValue;
    saldoUrls[@"Ethereum"] = self.ethField.stringValue;
    saldoUrls[@"Monero"] = self.xmrField.stringValue;
    saldoUrls[@"Litecoin"] = self.ltcField.stringValue;
    saldoUrls[@"Gamecoin"] = self.gameField.stringValue;
    saldoUrls[@"Ripple"] = self.xrpField.stringValue;
    saldoUrls[@"Safe Maid Coin"] = self.maidField.stringValue;
    saldoUrls[@"Stellar Lumens"] = self.strField.stringValue;
    saldoUrls[@"Dogecoin"] = self.dogeField.stringValue;
    saldoUrls[@"Dashboard"] = self.dashboardField.stringValue;
    
    [calculator saldoUrlsForDictionary:saldoUrls];
}

@end
