//
//  ViewController.h
//  iBroker
//
//  Created by Markus Bröker on 04.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TemplateViewController : NSViewController {
@private
    NSString *homeURL;
}

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
@property (weak) IBOutlet NSTextField *currencyUnit;
@property (weak) IBOutlet NSTextField *currencyUnits;

@property (weak) IBOutlet NSTextField *cryptoUnit;
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

// Setter für die private Variable gleichen Namens
- (void) homeURL:(NSString*) url;

@end
