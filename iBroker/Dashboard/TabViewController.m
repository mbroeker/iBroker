//
//  TabViewController.m
//  iBroker
//
//  Created by Markus Bröker on 04.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "TabViewController.h"

@implementation TabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabView.delegate = self;
    
    TemplateViewController *controller = (TemplateViewController*)self.tabViewItems.firstObject.viewController;
        
    // Startseite aufrufen
    [controller initialOverview];
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    [super tabView:tabView didSelectTabViewItem:tabViewItem];
    
    NSString *tab = tabViewItem.label;

    TemplateViewController *controller = (TemplateViewController*)tabViewItem.viewController;
    [controller updateTemplateView:tab];
}

@end
