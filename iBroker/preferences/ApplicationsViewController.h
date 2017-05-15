//
//  ApplicationsViewController.h
//  iBroker
//
//  Created by Markus Bröker on 15.05.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ApplicationsViewController : NSViewController

@property (strong) IBOutlet NSTextField *applicationsHeadline;

// Properties List
@property (strong) IBOutlet NSTextField *btcField;
@property (strong) IBOutlet NSTextField *ethField;
@property (strong) IBOutlet NSTextField *xmrField;
@property (strong) IBOutlet NSTextField *ltcField;
@property (strong) IBOutlet NSTextField *dogeField;

// Action Handler
- (IBAction)saveAction:(id)sender;

// Optionale ActiontHandler für später
- (IBAction)btcAction:(id)sender;
- (IBAction)ethAction:(id)sender;
- (IBAction)xmrAction:(id)sender;
- (IBAction)ltcAction:(id)sender;
- (IBAction)dogeAction:(id)sender;

// Interne Methode zum Aktualisieren des Views
- (void)updateView;

@end
