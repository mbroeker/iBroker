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
@property (strong) IBOutlet NSTextField *zecField;
@property (strong) IBOutlet NSTextField *ethField;
@property (strong) IBOutlet NSTextField *xmrField;
@property (strong) IBOutlet NSTextField *ltcField;
@property (strong) IBOutlet NSTextField *gameField;
@property (strong) IBOutlet NSTextField *xrpField;
@property (strong) IBOutlet NSTextField *maidField;
@property (strong) IBOutlet NSTextField *strField;
@property (strong) IBOutlet NSTextField *dogeField;
@property (strong) IBOutlet NSTextField *dashboardField;

- (IBAction)saveAction:(id)sender;

@end
