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
    NSMutableDictionary *initialRatings;
    NSDictionary *currentRatings;
    NSMutableDictionary *currentSaldo;
    NSMutableDictionary *saldoUrls;
    
    NSUserDefaults *defaults;
}

- (void) currentRatings {
    NSString *jsonURL = @"https://min-api.cryptocompare.com/data/pricemulti?fsyms=EUR&tsyms=USD,BTC,ETH,XMR,DOGE";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:jsonURL]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
        NSData *jsonData = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError;
        
        id allkeys = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&jsonError];
        if (!jsonError) {
            currentRatings = allkeys[@"EUR"];
            
            NSMutableDictionary *tempRatings = [[defaults objectForKey:@"initialRatings"] mutableCopy];
            
            // InitialRatings wurden nicht gespeichert?
            if (tempRatings == NULL) {

#if DEBUG
                NSLog(@"DEBUG: Initiale Kurse werden aktualisiert...");
#endif

                [defaults setObject:currentRatings forKey:@"initialRatings"];
                [defaults synchronize];
            } else {
            
                BOOL modified = false;
                for (id key in currentRatings) {
                    if (![tempRatings valueForKey:key]) {

#if DEBUG
                        NSLog(@"DEBUG: Initialer Kurs für '%@' wird aktualisiert...", key);
#endif
                        [tempRatings setObject:currentRatings[key] forKey:key];
                        modified = true;
                    }
                }
            
                if (modified) {
                    [defaults setObject:tempRatings forKey:@"initialRatings"];
                    [defaults synchronize];
                }
                
            }
        }
    }] resume];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabView.delegate = self;
    
    TemplateViewController *controller = (TemplateViewController*)self.tabViewItems.firstObject.viewController;
    controller.dismissButton.title = @"Dashboard";
    
    // Setze die Textfelder auf dem Dashboard auf editierbar...
    [controller.currencyUnits setEditable:true];
    [controller.cryptoUnits setEditable:true];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    currentSaldo = [[defaults objectForKey:@"currentSaldo"] mutableCopy];
    
    if (currentSaldo == NULL) {
        currentSaldo = [@{
            @"BTC": @0.0000,
            @"ETH": @0.2400,
            @"XMR": @0.4656,
            @"DOGE":@5053.4737
        } mutableCopy];
        
        [defaults setObject:currentSaldo forKey:@"currentSaldo"];
    }
    
    saldoUrls = [[defaults objectForKey:@"saldoUrls"] mutableCopy];
    
    if (saldoUrls == NULL) {
        saldoUrls = [ @{
            @"Dashboard": @"https://www.poloniex.com/exchange#btc_xmr",
            @"Bitcoin": @"https://blockchain.info/de/address/1DC11D43ZFKEhprgjmyJAqrPVRYFpy9QJA",
            @"Ethereum": @"https://etherscan.io/address/0xaa18EB5d55Eaf8b9BA5488a96f57f77Dc127BE26",
            @"Monero": @"https://moneroblocks.info",
            @"Dogecoin": @"http://dogechain.info/address/DTVbJzNLVvARmDPnK9cqcxutbd1mEDyUQ1",
        } mutableCopy];
        
        [defaults setObject:saldoUrls forKey:@"saldoUrls"];
    }

    // Einfach mal aktualisieren, sollte nicht schaden
    [defaults synchronize];
    
    [controller homeURL:saldoUrls[@"Dashboard"]];
    
    controller.currencyUnit.stringValue = @"ETH";
    controller.currencyUnits.doubleValue = [(NSNumber*)currentSaldo[@"ETH"] doubleValue];
    
    controller.cryptoUnit.stringValue = @"XMR";
    controller.cryptoUnits.doubleValue = [(NSNumber*)currentSaldo[@"XMR"] doubleValue];
    
    controller.rateLabel.stringValue = [NSString stringWithFormat:@"iBroker %@", NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"]];
    
    [self currentRatings];
}

- (void) tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    [super tabView:tabView didSelectTabViewItem:tabViewItem];
    
    NSString *label = tabViewItem.label;
    
    TemplateViewController *controller = (TemplateViewController*)tabViewItem.viewController;
    controller.dismissButton.title = label;
    
    initialRatings = [defaults objectForKey:@"initialRatings"];
    [self currentRatings];
    
    // Standards
    [controller homeURL:self->saldoUrls[label]];
    controller.currencyUnit.stringValue = @"EUR";
    
    double percent;
    
    if ([label isEqual: @"Dashboard"]) {

        controller.currencyUnit.stringValue = @"ETH";
        controller.currencyUnits.doubleValue = [currentSaldo[@"ETH"] doubleValue];
        
        controller.cryptoUnit.stringValue = @"XMR";
        controller.cryptoUnits.doubleValue = [currentSaldo[@"XMR"] doubleValue];
        
        controller.rateLabel.stringValue = [NSString stringWithFormat:@"1 EUR = %@ USD", currentRatings[@"USD"]];

    } else if ([label isEqual: @"Bitcoin"]) {
        
        percent = 100.0f * ([currentRatings[@"BTC"] doubleValue] / [initialRatings[@"BTC"] doubleValue]) - 100.0f;
        controller.percentLabel.stringValue = [NSString stringWithFormat:@"%+.2f%%", percent];
        
        controller.cryptoUnit.stringValue = @"BTC";
        controller.cryptoUnits.doubleValue = [(NSNumber*)currentSaldo[@"BTC"] doubleValue];
        controller.currencyUnits.doubleValue = controller.cryptoUnits.doubleValue / [currentRatings[@"BTC"] doubleValue];
        
        controller.rateLabel.stringValue = [NSString stringWithFormat:@"1000 EUR = %.4f BTC", 1000 * [currentRatings[@"BTC"] doubleValue]];
        
    } else if ([label isEqual: @"Ethereum"]) {
        
        percent = 100.0f * ([currentRatings[@"ETH"] doubleValue] / [initialRatings[@"ETH"] doubleValue]) - 100.0f;
        controller.percentLabel.stringValue = [NSString stringWithFormat:@"%+.2f%%", percent];
        
        controller.cryptoUnit.stringValue = @"ETH";
        controller.cryptoUnits.doubleValue = [(NSNumber*)currentSaldo[@"ETH"] doubleValue];
        controller.currencyUnits.doubleValue = controller.cryptoUnits.doubleValue / [currentRatings[@"ETH"] doubleValue];
        
        controller.rateLabel.stringValue = [NSString stringWithFormat:@"10 EUR = %.4f ETH", 10 * [currentRatings[@"ETH"] doubleValue]];
        
    } else if ([label isEqual: @"Monero"]) {
        
        percent = 100.0f * ([currentRatings[@"XMR"] doubleValue] / [initialRatings[@"XMR"] doubleValue]) - 100.0f;
        controller.percentLabel.stringValue = [NSString stringWithFormat:@"%+.2f%%", percent];
        
        controller.cryptoUnit.stringValue = @"XMR";
        controller.cryptoUnits.doubleValue = [(NSNumber*)currentSaldo[@"XMR"] doubleValue];
        controller.currencyUnits.doubleValue = controller.cryptoUnits.doubleValue / [currentRatings[@"XMR"] doubleValue];
        
        controller.rateLabel.stringValue = [NSString stringWithFormat:@"10 EUR = %.4f XMR", 10 * [currentRatings[@"XMR"] doubleValue]];
        
    } else if ([label isEqual: @"Dogecoin"]) {
        
        percent = 100.0f * ([currentRatings[@"DOGE"] doubleValue] / [initialRatings[@"DOGE"] doubleValue]) - 100.0f;
        controller.percentLabel.stringValue = [NSString stringWithFormat:@"%+.2f%%", percent];

        controller.cryptoUnit.stringValue = @"DOG";
        controller.cryptoUnits.doubleValue = [(NSNumber*)currentSaldo[@"DOGE"] doubleValue];
        controller.currencyUnits.doubleValue = controller.cryptoUnits.doubleValue / [currentRatings[@"DOGE"] doubleValue];
        
        controller.rateLabel.stringValue = [NSString stringWithFormat:@"1 CENT = %.4f DOGE", 0.01 * [currentRatings[@"DOGE"] doubleValue]];
        
    }
}

@end
