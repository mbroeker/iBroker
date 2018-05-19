//
//  AppDelegate.h
//  iBroker
//
//  Created by Markus Bröker on 04.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * Category for Migration of Preferences
 *
 * @author      Markus Bröker<broeker.markus@googlemail.com>
 * @copyright   Copyright (C) 2017 4customers UG
 */
@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>
@property(weak) IBOutlet NSMenuItem *menubarItem;
@property(weak) IBOutlet NSMenuItem *eurUSDItem;
@property(weak) IBOutlet NSMenuItem *usdEURItem;

@property(weak) IBOutlet NSMenuItem *eurGBPItem;
@property(weak) IBOutlet NSMenuItem *usdGBPItem;
@property(weak) IBOutlet NSMenuItem *usdCNYItem;
@property(weak) IBOutlet NSMenuItem *usdJPYItem;

/**
 * EUR / USD
 *
 * @param sender id
 */
- (IBAction)fiateurUSDAction:(id)sender;

/**
 * USD / EUR
 *
 * @param sender id
 */
- (IBAction)fiatusdEURAction:(id)sender;

/**
 * EUR / GBP
 *
 * @param sender id
 */
- (IBAction)fiateurGBPAction:(id)sender;

/**
 * USD / GBP
 *
 * @param sender id
 */
- (IBAction)fiatusdGBPAction:(id)sender;

/**
 * USD / CNY
 *
 * @param sender id
 */
- (IBAction)fiatusdCNYAction:(id)sender;

/**
 * USD / JPY
 *
 * @param sender id
 */
- (IBAction)fiatusdJPYAction:(id)sender;

/**
 * Menubar ON/OFF
 *
 * @param sender id
 */
- (IBAction)toggleMenuBar:(id)sender;

/**
* Reset the entire application data
*
* @param sender id
*/
- (IBAction)applicationReset:(id)sender;

@end