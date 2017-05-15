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

- (void)updateView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // aktualisierten Saldo besorgen
    NSMutableDictionary *applications = [[defaults objectForKey:@"applications"] mutableCopy];
    
    self.btcField.stringValue = applications[@"Bitcoin"];
    self.ethField.stringValue = applications[@"Ethereum"];
    self.xmrField.stringValue = applications[@"Monero"];
    self.ltcField.stringValue = applications[@"Litecoin"];
    self.dogeField.stringValue = applications[@"Dogecoin"];
}

/**
 * Speichern der Adressen des Nutzers
 *
 * @param sender
 */
- (IBAction)saveAction:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // aktualisierten Saldo besorgen
    NSMutableDictionary *applications = [[defaults objectForKey:@"applications"] mutableCopy];
    
    applications[@"Bitcoin"] = self.btcField.stringValue;
    applications[@"Ethereum"] = self.ethField.stringValue;
    applications[@"Monero"] = self.xmrField.stringValue;
    applications[@"Litecoin"] = self.ltcField.stringValue;
    applications[@"Dogecoin"] = self.dogeField.stringValue;

    [defaults setObject:applications forKey:@"applications"];
    [defaults synchronize];

    [self updateView];
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

@end
