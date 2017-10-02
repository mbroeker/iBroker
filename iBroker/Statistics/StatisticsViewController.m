//
//  StatisticsViewController.m
//  iBroker
//
//  Created by Markus Bröker on 26.09.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "StatisticsViewController.h"
#import "OrderData.h"
#import "Helper.h"

@interface StatisticsViewController()
@property BOOL isActive;
@end

@implementation StatisticsViewController

/**
 *
 */
- (void)awakeFromNib {

    self.openOrdersLabel.stringValue = NSLocalizedString(@"open_orders", "Open Orders");

    self.ordersTableView.delegate = self;
    self.ordersTableView.dataSource = self;

    [self.ordersTableView setDoubleAction:@selector(doubleClick:)];
}

/**
 *
 * @param sender
 */
- (void)doubleClick:(id)sender {
    NSInteger row = self.ordersTableView.selectedRow;

    if (row == -1) return;

    OrderData *data = self.dataRows[row];

    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"cancel_order_param", @"Auftrag löschen?"), data.pair];
    NSString *info = NSLocalizedString(@"cancel_order_long", @"Auftrag löschen?");

    if ([Helper messageText:message info:info] == NSAlertFirstButtonReturn) {
        if ([data cancelOrder]) {
            [self.dataRows removeObject:data];
            [self.ordersTableView reloadData];
        }
    }
}

/**
 *
 */
- (void)updateTableData {

    NSArray *data = [OrderData fetchOrderData];

    if (self.dataRows == nil) {
        self.dataRows = [[NSMutableArray alloc] initWithArray:data];
    } else {
        [self.dataRows setArray:data];
    }

    for (long i = 0; i < data.count; i++) {
        [self.ordersTableView beginUpdates];
        [self.ordersTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:i] withAnimation:NSTableViewAnimationEffectFade];
        [self.ordersTableView endUpdates];
    }

    [self.ordersTableView reloadData];
}

/**
 *
 */
- (void)viewDidLoad {
    [super viewDidLoad];

    self.isActive = true;

    dispatch_queue_t updateOpenOrdersQueue = dispatch_queue_create("de.4customers.iBroker.updateOpenOrdersQueue", NULL);
    dispatch_async(updateOpenOrdersQueue, ^{

        while (self.isActive) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateTableData];
            });

            [NSThread sleepForTimeInterval:15];
        }

    });
}

/**
 *
 * @param tableView
 * @return
 */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.dataRows.count;
}

/**
 *
 * @param tableView
 * @param tableColumn
 * @param row
 * @return
 */
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    if (row == -1) { return nil; }
    if (row >= self.dataRows.count) { return nil; }

    OrderData *data = (OrderData *) self.dataRows[row];

    if (data == nil) {
        return nil;
    }

    if ([tableColumn.title isEqualToString:@"DATE"]) {
        NSDateFormatter *from = [[NSDateFormatter alloc] init];
        [from setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.'zz"];

        NSDate *fromDate = [from dateFromString:data.date];

        NSDateFormatter *to = [[NSDateFormatter alloc] init];
        [to setDateFormat:@"yyyy-MM-dd"];

        return [to stringFromDate:fromDate];
    }

    if ([tableColumn.title isEqualToString:@"PAIR"]) {
        return data.pair;
    }

    if ([tableColumn.title isEqualToString:@"AMOUNT"]) {
        return [Helper double2German:data.amount.doubleValue min:8 max:8];
    }

    if ([tableColumn.title isEqualToString:@"RATE"]) {
        return [Helper double2German:data.rate.doubleValue min:8 max:8];
    }

    return nil;
}

/**
 * close the dialog
 *
 * @param sender
 */
- (IBAction)dismissActionClicked:(id)sender {
    NSWindow *window = self.view.window;
    [window.sheetParent endSheet:window returnCode:NSModalResponseOK];

    self.isActive = false;
}

@end
