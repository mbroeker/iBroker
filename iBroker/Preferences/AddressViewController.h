//
//  WalletsViewController.h
//  iBroker
//
//  Created by Markus Bröker on 26.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * Address Management
 *
 * @author      Markus Bröker<broeker.markus@googlemail.com>
 * @copyright   Copyright (C) 2017 4customers UG
 */
@interface AddressViewController : NSViewController

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
@property(strong) IBOutlet NSTextField *dashboardField;

// Images List
@property(strong) IBOutlet NSImageView *asset1ImageView;
@property(strong) IBOutlet NSImageView *asset2ImageView;
@property(strong) IBOutlet NSImageView *asset3ImageView;
@property(strong) IBOutlet NSImageView *asset4ImageView;
@property(strong) IBOutlet NSImageView *asset5ImageView;
@property(strong) IBOutlet NSImageView *asset6ImageView;
@property(strong) IBOutlet NSImageView *asset7ImageView;
@property(strong) IBOutlet NSImageView *asset8ImageView;
@property(strong) IBOutlet NSImageView *asset9ImageView;
@property(strong) IBOutlet NSImageView *asset10ImageView;

/**
 *
 * @param sender id
 */
- (IBAction)saveAction:(id)sender;

@end
