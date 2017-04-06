//
//  TabViewController.m
//  iBroker
//
//  Created by Markus Bröker on 04.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "TabViewController.h"
#import "TemplateViewController.h"

@implementation TabViewController {
@private
    NSDictionary *currentRatings;
    NSDictionary *currentSaldo;
    NSDictionary *saldoUrls;
}

- (void) currentRatings {
    NSString *jsonURL = @"https://min-api.cryptocompare.com/data/pricemulti?fsyms=EUR&tsyms=USD,BTC,ETH,XMR,DOGE";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:jsonURL]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        //NSLog(@"requestReply: %@", requestReply);
        
        NSData *jsonData = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError;
        
        id allkeys = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&jsonError];
        if (!jsonError) {
            currentRatings = allkeys[@"EUR"];
        }
    }] resume];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabView.delegate = self;
    
    TemplateViewController *controller = (TemplateViewController*)self.tabViewItems.firstObject.viewController;
    controller.dismissButton.title = @"Dashboard";
    
    self->currentSaldo = @{
        @"BTC": @0.0000,
        @"ETH": @0.2400,
        @"XMR": @0.4656,
        @"DOGE":@5053.4737
    };
    
    self->saldoUrls = @{
        @"Dashboard": @"http://coinmarketcap.com/#EUR",
        @"Bitcoin": @"https://blockchain.info/de/address/1DC11D43ZFKEhprgjmyJAqrPVRYFpy9QJA",
        @"Ethereum": @"https://etherscan.io/address/0xaa18EB5d55Eaf8b9BA5488a96f57f77Dc127BE26",
        @"Monero": @"https://moneroblocks.info",
        @"Doge": @"http://dogechain.info/address/DTVbJzNLVvARmDPnK9cqcxutbd1mEDyUQ1",
    };
    
    [controller homeURL:self->saldoUrls[@"Dashboard"]];
    
    controller.currencyUnit.stringValue = @"ETH";
    controller.currencyUnits.doubleValue = [(NSNumber*)currentSaldo[@"ETH"] doubleValue];
    
    controller.cryptoUnit.stringValue = @"XMR";
    controller.cryptoUnits.doubleValue = [(NSNumber*)currentSaldo[@"XMR"] doubleValue];
    
    [self currentRatings];
}

- (void) tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    [super tabView:tabView didSelectTabViewItem:tabViewItem];
    
    NSString *label = tabViewItem.label;
    
    TemplateViewController *controller = (TemplateViewController*)tabViewItem.viewController;
    controller.dismissButton.title = label;
    
    [self currentRatings];
    
    // Standard
    [controller homeURL:self->saldoUrls[label]];
    controller.currencyUnit.stringValue = @"EUR";
    
    if ([label isEqual: @"Dashboard"]) {

        controller.currencyUnit.stringValue = @"ETH";
        controller.currencyUnits.doubleValue = [currentSaldo[@"ETH"] doubleValue];
        
        controller.cryptoUnit.stringValue = @"XMR";
        controller.cryptoUnits.doubleValue = [currentSaldo[@"XMR"] doubleValue];

    } else if ([label isEqual: @"Bitcoin"]) {
        
        controller.cryptoUnit.stringValue = @"BTC";
        controller.cryptoUnits.doubleValue = [(NSNumber*)currentSaldo[@"BTC"] doubleValue];
        controller.currencyUnits.doubleValue = controller.cryptoUnits.doubleValue / [currentRatings[@"BTC"] doubleValue];
        
    } else if ([label isEqual: @"Ethereum"]) {
        
        controller.cryptoUnit.stringValue = @"ETH";
        controller.cryptoUnits.doubleValue = [(NSNumber*)currentSaldo[@"ETH"] doubleValue];
        controller.currencyUnits.doubleValue = controller.cryptoUnits.doubleValue / [currentRatings[@"ETH"] doubleValue];
        
    } else if ([label isEqual: @"Monero"]) {
        
        controller.cryptoUnit.stringValue = @"XMR";
        controller.cryptoUnits.doubleValue = [(NSNumber*)currentSaldo[@"XMR"] doubleValue];
        controller.currencyUnits.doubleValue = controller.cryptoUnits.doubleValue / [currentRatings[@"XMR"] doubleValue];
        
    } else if ([label isEqual: @"Dogecoin"]) {

        controller.cryptoUnit.stringValue = @"DOG";
        controller.cryptoUnits.doubleValue = [(NSNumber*)currentSaldo[@"DOGE"] doubleValue];
        controller.currencyUnits.doubleValue = controller.cryptoUnits.doubleValue / [currentRatings[@"DOGE"] doubleValue];
        
    }
}

@end
