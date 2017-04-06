//
//  TabViewController.h
//  iBroker
//
//  Created by Markus Bröker on 04.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TabViewController : NSTabViewController<NSTabViewDelegate>

// Berechne die Summe im Wallet
- (double) calculate:(NSString*)currency ratings:(NSDictionary*)ratings;

@end
