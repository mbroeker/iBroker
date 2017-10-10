//
//  BuyAndSellViewController.h
//  iBroker
//
//  Created by Markus Bröker on 22.09.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * BuyAndSell Segue Overlay
 *
 * @author      Markus Bröker<broeker.markus@googlemail.com>
 * @copyright   Copyright (C) 2017 4customers UG
 */
@interface BuyAndSellViewController : NSViewController
@property(strong) IBOutlet NSButton *dismissButton;
@property(weak) NSString *currentAsset;

@property(strong) IBOutlet NSTextField *buyAssetField;
@property(strong) IBOutlet NSTextField *buyAssetPriceField;
@property(strong) IBOutlet NSTextField *buyAsset1TotalField;

@property(strong) IBOutlet NSTextField *sellAssetField;
@property(strong) IBOutlet NSTextField *sellAssetPriceField;
@property(strong) IBOutlet NSTextField *sellAsset1TotalField;

@property(strong) IBOutlet NSButton *buyAssetImage;
@property(strong) IBOutlet NSButton *buyAsset1Image;
@property(strong) IBOutlet NSButton *buyAsset1TotalImage;

@property(strong) IBOutlet NSButton *sellAssetImage;
@property(strong) IBOutlet NSButton *sellAsset1Image;
@property(strong) IBOutlet NSButton *sellAsset1TotalImage;

@property(strong) IBOutlet NSButton *buyButton;
@property(strong) IBOutlet NSButton *sellButton;

/**
 *
 * @param sender id
 */
- (IBAction)dismissActionClicked:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)buyButtonAction:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)sellButtonAction:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)buyAssetAction:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)buyAsset1Action:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)buyAsset1TotalAction:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)sellAssetAction:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)sellAsset1Action:(id)sender;

/**
 *
 * @param sender id
 */
- (IBAction)sellAsset1TotalAction:(id)sender;

@end
