//
//  RatingsViewController.h
//  iBroker
//
//  Created by Markus Bröker on 26.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RatingsViewController : NSViewController

// Properties List
@property (strong) IBOutlet NSTextField *btcField;
@property (strong) IBOutlet NSTextField *zecField;
@property (strong) IBOutlet NSTextField *ethField;
@property (strong) IBOutlet NSTextField *xmrField;
@property (strong) IBOutlet NSTextField *ltcField;
@property (strong) IBOutlet NSTextField *gameField;
@property (strong) IBOutlet NSTextField *emc2Field;
@property (strong) IBOutlet NSTextField *maidField;
@property (strong) IBOutlet NSTextField *scField;
@property (strong) IBOutlet NSTextField *dogeField;
@property (strong) IBOutlet NSTextField *usdField;

// Action Handler
- (IBAction)saveAction:(id)sender;

// Interne Methode zum Aktualisieren des Views
- (void)updateView;

@end
