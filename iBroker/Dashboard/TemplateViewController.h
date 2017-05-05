//
//  TemplateViewController.h
//  iBroker
//
//  Created by Markus Bröker on 04.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TemplateViewController : NSViewController

// Definition der Menü-Buttons
@property (weak) IBOutlet NSButton *homeButton;
@property (weak) IBOutlet NSButton *leftButton;
@property (weak) IBOutlet NSButton *rightButton;
@property (weak) IBOutlet NSButton *walletButton;

@property (weak) IBOutlet NSButton *homepageButton;

// Definition des blauen InfoButtons
@property (weak) IBOutlet NSButton *infoButton;

// Definition der Labels
@property (weak) IBOutlet NSTextField *headlineLabel;
@property (weak) IBOutlet NSTextFieldCell *percentLabel;
@property (strong) IBOutlet NSTextField *iBrokerLabel;
@property (strong) IBOutlet NSTextField *statusLabel;
@property (strong) IBOutlet NSTextField *infoLabel;

// Definition der Eingabefelder
@property (weak) IBOutlet NSButton *currencyButton;
@property (weak) IBOutlet NSTextField *currencyUnits;

@property (weak) IBOutlet NSButton *cryptoButton;
@property (weak) IBOutlet NSTextField *cryptoUnits;

// Definition der unteren Labels
@property (strong) IBOutlet NSTextField *rateInputLabel;
@property (strong) IBOutlet NSTextField *rateInputCurrencyLabel;
@property (weak) IBOutlet NSTextField *rateOutputLabel;

// Definition der Exchange Rate Labels und Felder
@property (strong) IBOutlet NSTextField *currency1Label;
@property (strong) IBOutlet NSTextField *currency2Label;
@property (strong) IBOutlet NSTextField *currency3Label;
@property (strong) IBOutlet NSTextField *currency4Label;
@property (strong) IBOutlet NSTextField *currency5Label;

@property (strong) IBOutlet NSTextField *currency1Field;
@property (strong) IBOutlet NSTextField *currency2Field;
@property (strong) IBOutlet NSTextField *currency3Field;
@property (strong) IBOutlet NSTextField *currency4Field;
@property (strong) IBOutlet NSTextField *currency5Field;

@property (strong) IBOutlet NSPopUpButton *exchangeSelection;

// Definition der Button-Actions
- (IBAction)homeAction:(id)sender;
- (IBAction)leftAction:(id)sender;
- (IBAction)rightAction:(id)sender;
- (IBAction)walletAction:(id)sender;
- (IBAction)infoAction:(id)sender;

- (IBAction)homepageAction:(id)sender;

// Währungssymbole
- (IBAction)currencyAction:(id)sender;
- (IBAction)cryptoAction:(id)sender;

// RateExchange
- (IBAction)rateInputAction:(id)sender;

// Getter für die privaten Variablen
- (NSDictionary*) applications;
- (NSDictionary*) traders;
- (NSDictionary*) images;
- (NSString*) homeURL;

// Methoden zum Aktualisieren der Ansichten
- (void)updateOverview;
- (void)updateTemplateView:(NSString*)label;
- (void)updateCurrentView;

// Methoden zum Einrichten der Datenstrukturen
- (void)initializeWithDefaults;
- (void)resetColors;

@end
