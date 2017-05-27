//
//  TabViewController.m
//  iBroker
//
//  Created by Markus Bröker on 04.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "TabViewController.h"

#define DEFAULT_TIMEOUT 60

@implementation TabViewController {
@private
    TemplateViewController *controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tabView.delegate = self;

    controller = (TemplateViewController*)self.tabViewItems.firstObject.viewController;
    [controller updateAssistant];

    // Startseite aufrufen
    [controller updateOverview];

    dispatch_queue_t autoRefreshQueue = dispatch_queue_create("Auto-Refresh",NULL);
    dispatch_async(autoRefreshQueue, ^{

        while(true) {
            [NSThread sleepForTimeInterval:DEFAULT_TIMEOUT];

            dispatch_async(dispatch_get_main_queue(), ^{
                [controller updateCurrentView:true];
                [controller sellWithProfit:0.75];
                [controller buyTheBest];
            });
        }

    });
}

/**
 * Sinn und Zweck: Erkennen des jeweils angewählten Tabs
 *
 * @param tabViewItem
 */
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    [super tabView:tabView didSelectTabViewItem:tabViewItem];

    NSString *tab = tabViewItem.label;

    controller = (TemplateViewController*)tabViewItem.viewController;
    [controller updateTemplateView:tab];
}

@end
