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

// Definition des blauen InfoButtons
@property (weak) IBOutlet NSButton *multiButton;

// Definition der Eingabefelder
@property (weak) IBOutlet NSButton *currencyButton;
@property (weak) IBOutlet NSTextField *currencyUnits;

@property (weak) IBOutlet NSButton *cryptoButton;
@property (weak) IBOutlet NSTextField *cryptoUnits;

// Definition des unteren Labels
@property (weak) IBOutlet NSTextField *rateLabel;

// Definition der Button-Actions
- (IBAction)homepageActionClicked:(id)sender;
- (IBAction)dismissActionClicked:(id)sender;

- (IBAction)homeActionClicked:(id)sender;
- (IBAction)leftActionClicked:(id)sender;
- (IBAction)rightActionClicked:(id)sender;
- (IBAction)multiActionClicked:(id)sender;

// Währungssymbole
- (IBAction)currencyAction:(id)sender;
- (IBAction)cryptoAction:(id)sender;

// Getter für die privaten Variablen
- (NSDictionary*) applications;
- (NSDictionary*) traders;
- (NSDictionary*) images;

// Getter und Setter
- (void) homeURL:(NSString*) url;
- (NSString*) homeURL;

// Berechne die Summe im Wallet
- (double)calculate:(NSString*)currency ratings:(NSDictionary*)ratings;

// Methoden fürs Aktualisieren der Wechselkurse und zum Updaten dieser
- (void)updateRatings;
- (void) updateRatings:(NSString*)key;

// Methoden zum Aktualisieren der Ansichten
- (void)initialOverview;
- (void)updateOverview;
- (void)updateTemplateView:(NSString*)label;

- (void)initializeWithDefaults;

@end
