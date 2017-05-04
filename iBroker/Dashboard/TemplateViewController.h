//
//  TemplateViewController.h
//  iBroker
//
//  Created by Markus Bröker on 04.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TemplateViewController : NSViewController

// Definition der Buttons
@property (weak) IBOutlet NSButton *homepageButton;
@property (weak) IBOutlet NSButton *dismissButton;

@property (weak) IBOutlet NSButton *homeButton;
@property (weak) IBOutlet NSButton *leftButton;
@property (weak) IBOutlet NSButton *rightButton;

// Definition der Labels
@property (weak) IBOutlet NSTextField *headlineLabel;
@property (weak) IBOutlet NSTextFieldCell *percentLabel;
@property (strong) IBOutlet NSTextField *iBrokerLabel;
@property (strong) IBOutlet NSTextField *statusLabel;

// Definition des blauen InfoButtons
@property (weak) IBOutlet NSButton *multiButton;

// Definition der Eingabefelder
@property (weak) IBOutlet NSButton *currencyButton;
@property (weak) IBOutlet NSTextField *currencyUnits;

@property (weak) IBOutlet NSButton *cryptoButton;
@property (weak) IBOutlet NSTextField *cryptoUnits;

// Definition des unteren Labels
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
- (IBAction)homepageAction:(id)sender;
- (IBAction)dismissAction:(id)sender;

- (IBAction)homeAction:(id)sender;
- (IBAction)leftAction:(id)sender;
- (IBAction)rightAction:(id)sender;
- (IBAction)multiAction:(id)sender;

// Währungssymbole
- (IBAction)currencyAction:(id)sender;
- (IBAction)cryptoAction:(id)sender;

// RateExchange
- (IBAction)rateInputAction:(id)sender;

// Getter für die privaten Variablen
- (NSDictionary*) applications;
- (NSDictionary*) traders;
- (NSDictionary*) images;

// Getter und Setter
- (void) homeURL:(NSString*) url;
- (NSString*) homeURL;

// Methoden zum Aktualisieren der Ansichten
- (void)updateOverview;
- (void)updateTemplateView:(NSString*)label;

- (void)initializeWithDefaults;

@end
