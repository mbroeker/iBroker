//
//  PoloniexViewController.h
//  iBroker
//
//  Created by Markus Bröker on 26.05.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * Settings for Poloniex
 *
 * @author      Markus Bröker<broeker.markus@googlemail.com>
 * @copyright   Copyright (C) 2017 4customers UG
 */
@interface PoloniexViewController : NSViewController

@property(weak) IBOutlet NSTextField *apikeyField;
@property(weak) IBOutlet NSSecureTextField *secretField;

@property(weak) IBOutlet NSTextField *legalNoticeLabel;
@property(weak) IBOutlet NSButton *keyEraseButton;

@property(weak) IBOutlet NSButton *standardExchangeButton;
@property(weak) IBOutlet NSButton *saveButton;

/**
 *
 * @param sender id
 */
- (IBAction)keyEraseAction:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)saveAction:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)standardExchangeAction:(id)sender;
@end
