//
//  PortfolioViewController.h
//  iBroker
//
//  Created by Markus Bröker on 14.09.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * Portfolio Manager
 *
 * @author      Markus Bröker<broeker.markus@googlemail.com>
 * @copyright   Copyright (C) 2017 4customers UG
 */
@interface PortfolioViewController : NSViewController

// Properties List
@property(strong) IBOutlet NSTextField *asset1Field;
@property(strong) IBOutlet NSTextField *asset2Field;
@property(strong) IBOutlet NSTextField *asset3Field;
@property(strong) IBOutlet NSTextField *asset4Field;
@property(strong) IBOutlet NSTextField *asset5Field;
@property(strong) IBOutlet NSTextField *asset6Field;
@property(strong) IBOutlet NSTextField *asset7Field;
@property(strong) IBOutlet NSTextField *asset8Field;
@property(strong) IBOutlet NSTextField *asset9Field;
@property(strong) IBOutlet NSTextField *asset10Field;

// Images List
@property(strong) IBOutlet NSButton *asset1ImageButton;
@property(strong) IBOutlet NSButton *asset2ImageButton;
@property(strong) IBOutlet NSButton *asset3ImageButton;
@property(strong) IBOutlet NSButton *asset4ImageButton;
@property(strong) IBOutlet NSButton *asset5ImageButton;

@property(strong) IBOutlet NSButton *asset6ImageButton;
@property(strong) IBOutlet NSButton *asset7ImageButton;
@property(strong) IBOutlet NSButton *asset8ImageButton;
@property(strong) IBOutlet NSButton *asset9ImageButton;
@property(strong) IBOutlet NSButton *asset10ImageButton;

/**
 *
 * @param sender id
 */
- (IBAction)asset1ClickedAction:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)asset2ClickedAction:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)asset3ClickedAction:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)asset4ClickedAction:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)asset5ClickedAction:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)asset6ClickedAction:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)asset7ClickedAction:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)asset8ClickedAction:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)asset9ClickedAction:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)asset10ClickedAction:(id)sender;

@end
