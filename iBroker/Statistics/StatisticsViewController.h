//
//  StatisticsViewController.h
//  iBroker
//
//  Created by Markus Bröker on 26.09.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StatisticsViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property(strong) IBOutlet NSTextField *openOrdersLabel;
@property(strong) IBOutlet NSButton *dismissButton;
@property(weak) IBOutlet NSTableView *ordersTableView;

@property(strong) NSMutableArray *dataRows;

- (IBAction)doubleClick:(id)sender;
- (IBAction)dismissActionClicked:(id)sender;

@end
