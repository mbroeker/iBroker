//
//  ExtraViewController.h
//  iBroker
//
//  Created by Markus Bröker on 19.09.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * Extra Settings Management
 *
 * @author      Markus Bröker<broeker.markus@googlemail.com>
 * @copyright   Copyright (C) 2017 4customers UG
 */
@interface ExtraViewController : NSViewController
@property(weak) IBOutlet NSButton *tradingWithConfirmationButton;
@property(weak) IBOutlet NSTextField *extraSettingsTextField;
@property(weak) IBOutlet NSButton *saveButton;

@property(weak) IBOutlet NSTextField *percentRateLabel;
@property(weak) IBOutlet NSLevelIndicator *percentRateIndicator;

// Die Action Handler
- (IBAction)sliderAction:(id)sender;

- (IBAction)saveAction:(id)sender;

@end


