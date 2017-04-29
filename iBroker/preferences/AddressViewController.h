//
//  WalletsViewController.h
//  iBroker
//
//  Created by Markus Bröker on 26.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AddressViewController : NSViewController

@property (strong) IBOutlet NSTextField *btcField;
@property (strong) IBOutlet NSTextField *ethField;
@property (strong) IBOutlet NSTextField *xmrField;
@property (strong) IBOutlet NSTextField *ltcField;
@property (strong) IBOutlet NSTextField *dogeField;
@property (strong) IBOutlet NSTextField *dashboardField;

- (IBAction)btcAction:(id)sender;
- (IBAction)ethAction:(id)sender;
- (IBAction)xmrAction:(id)sender;
- (IBAction)ltcAction:(id)sender;
- (IBAction)dogeAction:(id)sender;
- (IBAction)dashboardAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@end
