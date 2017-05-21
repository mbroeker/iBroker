//
//  SaldoViewController.m
//  iBroker
//
//  Created by Markus Bröker on 26.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "SaldoViewController.h"
#import "Calculator.h"

@implementation SaldoViewController {
    Calculator *calculator;
}

- (void)viewWillAppear {
    NSNumberFormatter *formatter;
    
    formatter  = self.btcField.formatter;
    [formatter setMinimumFractionDigits:8];
    [formatter setMaximumFractionDigits:8];

    formatter  = self.zecField.formatter;
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

    formatter  = self.gameField.formatter;
    [formatter setMinimumFractionDigits:8];
    [formatter setMaximumFractionDigits:8];

    formatter  = self.emc2Field.formatter;
    [formatter setMinimumFractionDigits:8];
    [formatter setMaximumFractionDigits:8];

    formatter  = self.maidField.formatter;
    [formatter setMinimumFractionDigits:8];
    [formatter setMaximumFractionDigits:8];

    formatter  = self.scField.formatter;
    [formatter setMinimumFractionDigits:8];
    [formatter setMaximumFractionDigits:8];

    formatter  = self.dogeField.formatter;
    [formatter setMinimumFractionDigits:8];
    [formatter setMaximumFractionDigits:8];
}

/**
 * Aktualisierung des Views vereinheitlicht
 */
- (void)updateView {
    calculator = [Calculator instance];

    // Aktualisierte Ratings besorgen
    NSMutableDictionary *currentSaldo = [calculator currentSaldo];

    self.btcField.doubleValue = [currentSaldo[BTC] doubleValue];
    self.zecField.doubleValue = [currentSaldo[ZEC] doubleValue];
    self.ethField.doubleValue = [currentSaldo[ETH] doubleValue];
    self.xmrField.doubleValue = [currentSaldo[XMR] doubleValue];
    self.ltcField.doubleValue = [currentSaldo[LTC] doubleValue];
    self.gameField.doubleValue = [currentSaldo[GAME] doubleValue];
    self.emc2Field.doubleValue = [currentSaldo[EMC2] doubleValue];
    self.maidField.doubleValue = [currentSaldo[MAID] doubleValue];
    self.scField.doubleValue = [currentSaldo[SC] doubleValue];
    self.dogeField.doubleValue = [currentSaldo[DOGE] doubleValue];
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
    NSMutableDictionary *currentSaldo = [calculator currentSaldo];

    double btc = self.btcField.doubleValue;
    double zec = self.zecField.doubleValue;
    double eth = self.ethField.doubleValue;
    double xmr = self.xmrField.doubleValue;
    double ltc = self.ltcField.doubleValue;
    double game = self.gameField.doubleValue;
    double emc2 = self.emc2Field.doubleValue;
    double maid = self.maidField.doubleValue;
    double sc = self.scField.doubleValue;
    double doge = self.dogeField.doubleValue;

    currentSaldo[BTC] = @(btc);
    currentSaldo[ZEC] = @(zec);
    currentSaldo[ETH] = @(eth);
    currentSaldo[XMR] = @(xmr);
    currentSaldo[LTC] = @(ltc);
    currentSaldo[GAME] = @(game);
    currentSaldo[EMC2] = @(emc2);
    currentSaldo[MAID] = @(maid);
    currentSaldo[SC] = @(sc);
    currentSaldo[DOGE] = @(doge);

    [calculator currentSaldoForDictionary:currentSaldo];

    // Gespeicherte Daten neu einlesen...
    [self updateView];
}

@end
