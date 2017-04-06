//
//  TabViewController.m
//  iBroker
//
//  Created by Markus Bröker on 04.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "TabViewController.h"
#import "TemplateViewController.h"

#import "Helper.h"

@implementation TabViewController {
@private
    NSMutableDictionary *initialRatings;
    NSMutableDictionary *currentRatings;
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
        if (jsonError) {            

#if DEBUG
            NSLog(@"DEBUG: jsonError => %@", jsonError);
#endif
         
            // Fehlermeldung wird angezeigt
            [Helper messageText:[jsonError description] info:[jsonError debugDescription]];
            return;
        }
        
        self->currentRatings = [allkeys[@"EUR"] mutableCopy];
        
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
        
    }] resume];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabView.delegate = self;
    
    defaults = [NSUserDefaults standardUserDefaults];
    [self currentRatings];
    
    currentSaldo = [[defaults objectForKey:@"currentSaldo"] mutableCopy];
    
    if (currentSaldo == NULL) {
        currentSaldo = [@{
            @"BTC": @0.00414846,
            @"ETH": @0.23868595,
            @"XMR": @0.18477072,
            @"DOGE":@5053.47368421,
        } mutableCopy];
        
        [defaults setObject:currentSaldo forKey:@"currentSaldo"];
    }
    
    saldoUrls = [[defaults objectForKey:@"saldoUrls"] mutableCopy];
    
    if (saldoUrls == NULL) {
        saldoUrls = [ @{
            @"Dashboard": @"https://www.poloniex.com/exchange#btc_xmr",
            @"Bitcoin": @"https://blockchain.info/de/address/31nHZc8qdNG48YgyKqzxi9Y1NUX16XHexi",
            @"Ethereum": @"https://etherscan.io/address/0xaa18EB5d55Eaf8b9BA5488a96f57f77Dc127BE26",
            @"Monero": @"https://moneroblocks.info",
            @"Dogecoin": @"http://dogechain.info/address/DTVbJzNLVvARmDPnK9cqcxutbd1mEDyUQ1",
        } mutableCopy];
        
        [defaults setObject:saldoUrls forKey:@"saldoUrls"];
    }
    
    // TODO: Wie löse ich am Besten mein Synchronisationsproblem?
    TemplateViewController *controller = (TemplateViewController*)self.tabViewItems.firstObject.viewController;
    controller.dismissButton.title = @"Dashboard";
    [controller homeURL:saldoUrls[@"Dashboard"]];
    controller.rateLabel.stringValue = [NSString stringWithFormat:@"iBroker %@", NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"]];
    
    // Einfach mal aktualisieren, sollte nicht schaden
    [defaults synchronize];
}

- (double) calculate:(NSString*) currency ratings:(NSDictionary*)ratings{
    double btc = [currentSaldo[@"BTC"] doubleValue] / [ratings[@"BTC"] doubleValue];
    double eth = [currentSaldo[@"ETH"] doubleValue] / [ratings[@"ETH"] doubleValue];
    double xmr = [currentSaldo[@"XMR"] doubleValue] / [ratings[@"XMR"] doubleValue];
    double doge = [currentSaldo[@"DOGE"] doubleValue] / [ratings[@"DOGE"] doubleValue];
    
    double sum = btc + eth + xmr + doge;
    
    if ([currency isEqualToString:@"EUR"]) {
        return sum;
    }
    
    return sum * [currentRatings[@"USD"] doubleValue];
}

- (void) updateOverview:(TemplateViewController*)controller {
    
    controller.cryptoUnit.stringValue = @"USD";
    controller.cryptoUnits.stringValue = [Helper double2German:[self calculate:@"USD" ratings:currentRatings ] min:2 max:2];
    
    controller.currencyUnits.stringValue = [Helper double2German:[self calculate:@"EUR" ratings:currentRatings] min:2 max:2];
    controller.rateLabel.stringValue = [NSString stringWithFormat:@"1 EUR = %@ USD", [Helper double2German:[currentRatings[@"USD"] doubleValue] min:2 max:2]];
}

- (void) updateTemplateView:(TemplateViewController*) controller label:(NSString*)label {

    initialRatings = [[defaults objectForKey:@"initialRatings"] mutableCopy];
    
    NSDictionary *tabs = @{
        @"Dashboard": [NSArray arrayWithObjects:@"USD", [NSNumber numberWithDouble:1], nil],
        @"Bitcoin":   [NSArray arrayWithObjects:@"BTC", [NSNumber numberWithDouble:1000], nil],
        @"Ethereum":  [NSArray arrayWithObjects:@"ETH", [NSNumber numberWithDouble:10], nil],
        @"Monero":    [NSArray arrayWithObjects:@"XMR", [NSNumber numberWithDouble:10], nil],
        @"Dogecoin":  [NSArray arrayWithObjects:@"DOGE", [NSNumber numberWithDouble:1/100.0], nil],
    };
    
    NSString *unit = tabs[label][0];
    double units = [(NSNumber*) tabs[label][1] doubleValue];
    
    // Standards
    [controller homeURL:self->saldoUrls[label]];
    controller.currencyUnit.stringValue = @"EUR";
    
    if ([label isEqualToString:@"Dashboard"]) {
        [self updateOverview:controller];
        
        return;
    }
    
    double percent = 100.0f * ([currentRatings[unit] doubleValue] / [initialRatings[unit] doubleValue]) - 100.0f;
    controller.percentLabel.stringValue = [Helper double2GermanPercent:percent fractions:2];
    
    controller.cryptoUnit.stringValue = [unit substringToIndex:3];
    controller.cryptoUnits.doubleValue = [(NSNumber*)currentSaldo[unit] doubleValue];
    controller.currencyUnits.doubleValue = controller.cryptoUnits.doubleValue / [currentRatings[unit] doubleValue];
    
    double rate = units * [currentRatings[unit] doubleValue];
    controller.rateLabel.stringValue = [NSString stringWithFormat:@"%g EUR = %@ %@", units, [Helper double2German:rate min:4 max:8], unit];
}

- (void) tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    [super tabView:tabView didSelectTabViewItem:tabViewItem];
    
    NSString *label = tabViewItem.label;
    
    TemplateViewController *controller = (TemplateViewController*)tabViewItem.viewController;

    // aktualisiere headLine und dismissButton
    controller.dismissButton.title = label;
    [controller.headlineLabel setStringValue:label];
    
    [self currentRatings];
    [self updateTemplateView:controller label:label];
    
}

@end
