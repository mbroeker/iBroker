//
//  ViewController.m
//  iBroker
//
//  Created by Markus Bröker on 04.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "TemplateViewController.h"

@implementation TemplateViewController {
@private
    NSDictionary *applications;
    NSDictionary *traders;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSImage *image = [NSApp applicationIconImage];
    [self.homepageButton setImage:image];
    
    applications = @{
        @"Bitcoin": @"/Applications/mSIGNA.App",
        @"Ethereum": @"/Applications/Ethereum Wallet.App",
        @"Monero": @"/Applications/monero-wallet-gui.App",
        @"Dogecoin": @"/Applications/MultiDoge.App"
    };
    
    traders = @{
        @"homepage": @"https://www.4customers.de",
        @"trader1": @"https://www.shapeshift.io",
        @"trader2": @"https://www.blocktrades.us"
    };
}

- (void)homeURL:(NSString*)url {
    self->homeURL = url;
}

- (IBAction)homepageActionClicked:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: traders[@"homepage"]]];
}

- (IBAction)dismissActionClicked:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    
    NSButton *button = (NSButton*) sender;
    
    if ([button.title isEqualToString:@"Dashboard"]) {
        return;
    }
    
    [alert setAlertStyle:NSWarningAlertStyle];
    
    [alert addButtonWithTitle:@"Starten"];
    [alert addButtonWithTitle:@"Nein"];
    alert.messageText = [NSString stringWithFormat:@"%@ starten?", button.title];
    alert.informativeText = @"Das Programm wird automatisch gestartet.";
    
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        if (![[NSWorkspace sharedWorkspace] launchApplication:applications[button.title]]) {
            NSAlert *msg = [[NSAlert alloc] init];
            [msg setAlertStyle:NSWarningAlertStyle];
            
            [msg addButtonWithTitle:@"Abnicken"];
            msg.messageText = [NSString stringWithFormat:@"Fehler beim Starten der %@ Wallet", button.title];
            msg.informativeText = [NSString stringWithFormat:@"Das Programm %@ konnte nicht gestartet werden.", applications[button.title]];
            
            [msg runModal];
        }
    }
}

- (IBAction)homeActionClicked:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: self->homeURL]];
}

- (IBAction)leftActionClicked:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: traders[@"trader1"]]];
}

- (IBAction)rightActionClicked:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: traders[@"trader2"]]];
}

@end
