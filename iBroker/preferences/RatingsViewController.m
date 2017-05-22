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
    Calculator *calculator;
}

- (void)viewWillAppear {
    NSNumberFormatter *formatter;
    
    formatter  = self.btcField.formatter;
    [formatter setMinimumFractionDigits:4];
    [formatter setMaximumFractionDigits:4];

    formatter  = self.zecField.formatter;
    [formatter setMinimumFractionDigits:4];
    [formatter setMaximumFractionDigits:4];

    formatter  = self.ethField.formatter;
    [formatter setMinimumFractionDigits:4];
    [formatter setMaximumFractionDigits:4];

    formatter  = self.xmrField.formatter;
    [formatter setMinimumFractionDigits:4];
    [formatter setMaximumFractionDigits:4];

    formatter  = self.ltcField.formatter;
    [formatter setMinimumFractionDigits:4];
    [formatter setMaximumFractionDigits:4];

    formatter  = self.gameField.formatter;
    [formatter setMinimumFractionDigits:4];
    [formatter setMaximumFractionDigits:4];

    formatter  = self.emc2Field.formatter;
    [formatter setMinimumFractionDigits:4];
    [formatter setMaximumFractionDigits:4];

    formatter  = self.maidField.formatter;
    [formatter setMinimumFractionDigits:4];
    [formatter setMaximumFractionDigits:4];

    formatter  = self.scField.formatter;
    [formatter setMinimumFractionDigits:4];
    [formatter setMaximumFractionDigits:4];

    formatter  = self.dogeField.formatter;
    [formatter setMinimumFractionDigits:4];
    [formatter setMaximumFractionDigits:4];

    formatter  = self.usdField.formatter;
    [formatter setMinimumFractionDigits:4];
    [formatter setMaximumFractionDigits:4];
}

/**
 * Aktualisierung des Views vereinheitlicht
 */
- (void)updateView {
    calculator = [Calculator instance];

    // Aktualisierte Ratings besorgen
    NSMutableDictionary *ratings = [calculator initialRatings];

    self.btcField.doubleValue = 1 / [ratings[BTC] doubleValue];
    self.zecField.doubleValue = 1 / [ratings[ZEC] doubleValue];
    self.ethField.doubleValue = 1 / [ratings[ETH] doubleValue];
    self.xmrField.doubleValue = 1 / [ratings[XMR] doubleValue];
    self.ltcField.doubleValue = 1 / [ratings[LTC] doubleValue];
    self.gameField.doubleValue = 1 / [ratings[GAME] doubleValue];
    self.emc2Field.doubleValue = 1 / [ratings[EMC2] doubleValue];
    self.maidField.doubleValue = 1 / [ratings[MAID] doubleValue];
    self.scField.doubleValue = 1 / [ratings[SC] doubleValue];
    self.dogeField.doubleValue = 1 / [ratings[DOGE] doubleValue];
    self.usdField.doubleValue = 1 / [ratings[USD] doubleValue];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self updateView];
}

/**
 * Speichern des aktuellen Ratings per Klick
 *
 * @param sender
 */
- (IBAction)saveAction:(id)sender {
    // Aktualisierte Ratings besorgen
    NSMutableDictionary *initialRatings = [calculator initialRatings];

    double btc = 1 / self.btcField.doubleValue;
    double zec = 1 / self.zecField.doubleValue;
    double eth = 1 / self.ethField.doubleValue;
    double xmr = 1 / self.xmrField.doubleValue;
    double ltc = 1 / self.ltcField.doubleValue;
    double game = 1 / self.gameField.doubleValue;
    double emc2 = 1 / self.emc2Field.doubleValue;
    double maid = 1 / self.maidField.doubleValue;
    double sc = 1 / self.scField.doubleValue;
    double doge = 1 / self.dogeField.doubleValue;
    double dollar = 1 / self.usdField.doubleValue;

    initialRatings[BTC] = @(btc);
    initialRatings[ZEC] = @(zec);
    initialRatings[ETH] = @(eth);
    initialRatings[XMR] = @(xmr);
    initialRatings[LTC] = @(ltc);
    initialRatings[GAME] = @(game);
    initialRatings[EMC2] = @(emc2);
    initialRatings[MAID] = @(maid);
    initialRatings[SC] = @(sc);
    initialRatings[DOGE] = @(doge);
    initialRatings[USD] = @(dollar);

    [calculator initialRatingsWithDictionary:initialRatings];

    // Gespeicherte Daten neu einlesen...
    [self updateView];
}

@end
