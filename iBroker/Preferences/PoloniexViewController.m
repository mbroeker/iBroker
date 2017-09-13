//
//  BittrexViewController.m
//  iBroker
//
//  Created by Markus Bröker on 26.05.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "PoloniexViewController.h"
#import "Calculator.h"

#import "KeychainWrapper.h"

@implementation PoloniexViewController

- (void)awakeFromNib {
    NSColor *color = [NSColor whiteColor];
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[self.standardExchangeButton attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
    [self.standardExchangeButton setAttributedTitle:colorTitle];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self updateView];
}

- (void)updateView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSDictionary *keychain = [KeychainWrapper keychain2ApiKeyAndSecret:@"POLONIEX"];

    self.apikeyField.stringValue = (keychain[@"apiKey"] != nil) ? keychain[@"apiKey"][@"Key"] : @"";
    self.secretField.stringValue = (keychain[@"secret"] != nil) ? keychain[@"secret"] : @"";

    NSString *defaultExchange = [defaults objectForKey:KEY_DEFAULT_EXCHANGE];

    self.standardExchangeButton.state = NSOffState;
    if ([defaultExchange isEqualToString:@"POLONIEX_EXCHANGE"]) {
        self.standardExchangeButton.state = NSOnState;
    }

    self.legalNoticeLabel.stringValue = [NSString stringWithFormat:NSLocalizedString(@"legal_notice", @"legal_notice"), @"POLONIEX"];
}

- (IBAction)standardExchangeAction:(id)sender {
    Calculator *calculator = [Calculator instance];
    [calculator defaultExchange:@"POLONIEX_EXCHANGE"];

    [self updateView];
}

- (IBAction)saveAction:(id)sender {

    NSString *combinedKey = [NSString stringWithFormat:@"%@:%@", self.apikeyField.stringValue, self.secretField.stringValue];
    [KeychainWrapper createKeychainValue:combinedKey forIdentifier:@"POLONIEX"];

    [self updateView];
}

- (IBAction)keyEraseAction:(id)sender {
    [KeychainWrapper deleteItemFromKeychainWithIdentifier:@"POLONIEX"];
    [self updateView];
}
@end
