//
//  RatingsViewController.m
//  iBroker
//
//  Created by Markus Bröker on 26.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "RatingsViewController.h"
#import "Calculator.h"

@implementation RatingsViewController {
    NSMutableDictionary *initialRatings;
    Calculator *calculator;
}

- (void)viewWillAppear {
    NSNumberFormatter *formatter;
    
    formatter  = self.btcField.formatter;
    [formatter setMinimumFractionDigits:8];
    [formatter setMaximumFractionDigits:8];

    formatter  = self.ethField.formatter;
    [formatter setMinimumFractionDigits:8];
    [formatter setMaximumFractionDigits:8];

    formatter  = self.xmrField.formatter;
    [formatter setMinimumFractionDigits:8];
    [formatter setMaximumFractionDigits:8];

    formatter  = self.ltcField.formatter;
    [formatter setMinimumFractionDigits:8];
    [formatter setMaximumFractionDigits:8];

    formatter  = self.dogeField.formatter;
    [formatter setMinimumFractionDigits:8];
    [formatter setMaximumFractionDigits:8];

    formatter  = self.usdField.formatter;
    [formatter setMinimumFractionDigits:8];
    [formatter setMaximumFractionDigits:8];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    calculator = [Calculator instance];
    initialRatings = [calculator initialRatings];
    
    self.btcField.doubleValue = [initialRatings[@"BTC"] doubleValue];
    self.ethField.doubleValue = [initialRatings[@"ETH"] doubleValue];
    self.xmrField.doubleValue = [initialRatings[@"XMR"] doubleValue];
    self.ltcField.doubleValue = [initialRatings[@"LTC"] doubleValue];
    self.dogeField.doubleValue = [initialRatings[@"DOGE"] doubleValue];
    self.usdField.doubleValue = [initialRatings[@"USD"] doubleValue];
}

/**
 * Speichern des aktuellen Ratings per Klick
 *
 * @param sender
 */
- (IBAction)saveAction:(id)sender {
    double btc = self.btcField.doubleValue;
    double eth = self.ethField.doubleValue;
    double xmr = self.xmrField.doubleValue;
    double ltc = self.ltcField.doubleValue;
    double doge = self.dogeField.doubleValue;
    double dollar = self.usdField.doubleValue;

    initialRatings[@"BTC"] = @(btc);
    initialRatings[@"ETH"] = @(eth);
    initialRatings[@"XMR"] = @(xmr);
    initialRatings[@"LTC"] = @(ltc);
    initialRatings[@"DOGE"] = @(doge);
    initialRatings[@"USD"] = @(dollar);

    [calculator initialRatingsWithDictionary:initialRatings];
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
- (IBAction)dogeAction:(id)sender {
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
- (IBAction)usdAction:(id)sender {
}

@end
