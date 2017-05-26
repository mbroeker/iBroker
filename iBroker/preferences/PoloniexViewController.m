//
//  PoloniexController.m
//  iBroker
//
//  Created by Markus Bröker on 26.05.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "PoloniexViewController.h"

@implementation PoloniexViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self updateView];
}

- (void)updateView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSDictionary *apiKey = [defaults objectForKey:@"POLO_KEY"];
    NSString *secret = [defaults objectForKey:@"POLO_SEC"];

    self.apikeyField.stringValue = (apiKey != nil) ? apiKey[@"Key"] : @"";
    self.secretField.stringValue = (secret != nil) ? secret : @"";

    self.legalNoticeLabel.stringValue = NSLocalizedString(@"legal_notice", @"legal_notice");
}

- (IBAction)saveAction:(id)sender {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSMutableDictionary *apiKey = [[NSMutableDictionary alloc] init];
    NSString *secret = self.secretField.stringValue;
    apiKey[@"Key"] = self.apikeyField.stringValue;

    [defaults setObject:apiKey forKey:@"POLO_KEY"];
    [defaults setObject:secret forKey:@"POLO_SEC"];

    [defaults synchronize];

    [self updateView];
}

- (IBAction)keyEraseAction:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults removeObjectForKey:@"POLO_KEY"];
    [defaults removeObjectForKey:@"POLO_SEC"];

    [defaults synchronize];

    [self updateView];
}
@end
