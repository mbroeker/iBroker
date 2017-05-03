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
    NSMutableDictionary *saldoUrls;
    Calculator *calculator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    calculator = [Calculator instance];
    saldoUrls = [calculator saldoUrls];
    
    self.btcField.stringValue = saldoUrls[@"Bitcoin"];
    self.ethField.stringValue = saldoUrls[@"Ethereum"];
    self.xmrField.stringValue = saldoUrls[@"Monero"];
    self.ltcField.stringValue = saldoUrls[@"Litecoin"];
    self.dogeField.stringValue = saldoUrls[@"Dogecoin"];
    self.dashboardField.stringValue = saldoUrls[@"Dashboard"];
}

/**
 * Speichern der Adressen des Nutzers
 *
 * @param sender
 */
- (IBAction)saveAction:(id)sender {
    saldoUrls[@"Bitcoin"] = self.btcField.stringValue;
    saldoUrls[@"Ethereum"] = self.ethField.stringValue;
    saldoUrls[@"Monero"] = self.xmrField.stringValue;
    saldoUrls[@"Litecoin"] = self.ltcField.stringValue;
    saldoUrls[@"Dogecoin"] = self.dogeField.stringValue;
    saldoUrls[@"Dashboard"] = self.dashboardField.stringValue;
    
    [calculator saldoUrlsForDictionary:saldoUrls];
}

/**
 *
 * @param sender
 */
- (IBAction)btcAction:(id)sender {
}

/**
 *
 * @param sender
 */
- (IBAction)ethAction:(id)sender {
}

/**
 *
 * @param sender
 */
- (IBAction)xmrAction:(id)sender {
}

/**
 *
 * @param sender
 */
- (IBAction)ltcAction:(id)sender {
}

/**
 *
 * @param sender
 */
- (IBAction)dogeAction:(id)sender {
}

/**
 *
 * @param sender
 */
- (IBAction)dashboardAction:(id)sender {
}

@end
