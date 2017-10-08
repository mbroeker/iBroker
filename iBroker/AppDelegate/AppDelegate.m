//
//  AppDelegate.m
//  iBroker
//
//  Created by Markus Bröker on 04.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "AppDelegate.h"
#import "Helper.h"
#import "Calculator.h"

@implementation AppDelegate

/**
 * Sinn und Zweck: Benachrichtigung des Programmierers, dass das Teil geladen wurde...
 *
 * @param aNotification
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSDebug(@"AppDelegate::applicationDidFinishLaunching");

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *state = [defaults valueForKey:OPTIONS_MENUBAR];

    self.menubarItem.state = state.integerValue;

    [self checkFiatMenuState];
}

/**
 * Sinn und Zweck: Benachrichtigung des Programmierers, dass das Teil beendet wird
 *
 * @param aNotification
 */
- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

/**
 * Sinn und Zweck: Das Programm soll beim Beenden nicht im Hintergrund weiter laufen. 
 *
 * Es ist eine Konvention aus vergangenen Zeiten, MAC-Apps offen gehalten zu lassen
 *
 * @param sender
 */
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

/**
 * Aktivierung nur einer Fiatwährung erzwingen
 *
 */
- (void)checkFiatMenuState {
    NSDebug(@"AppDelegate::checkFiatMenuState");

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *fiatCurrencies = [defaults objectForKey:@"fiatCurrencies"];

    // alle deaktivieren
    self.eurUSDItem.state = NSOffState;
    self.usdEURItem.state = NSOffState;
    self.eurGBPItem.state = NSOffState;

    self.usdGBPItem.state = NSOffState;
    self.usdCNYItem.state = NSOffState;
    self.usdJPYItem.state = NSOffState;

    // und dann den einzelnen selektieren
    if ([fiatCurrencies[0] isEqualToString:EUR] &&
        [fiatCurrencies[1] isEqualToString:USD]) {
        self.eurUSDItem.state = NSOnState;
    }

    if ([fiatCurrencies[0] isEqualToString:USD] &&
        [fiatCurrencies[1] isEqualToString:EUR]) {
        self.usdEURItem.state = NSOnState;
    }

    // und dann den einzelnen selektieren
    if ([fiatCurrencies[0] isEqualToString:EUR] &&
        [fiatCurrencies[1] isEqualToString:GBP]) {
        self.eurGBPItem.state = NSOnState;
    }

    if ([fiatCurrencies[0] isEqualToString:USD] &&
        [fiatCurrencies[1] isEqualToString:GBP]) {
        self.usdGBPItem.state = NSOnState;
    }

    // und dann den einzelnen selektieren
    if ([fiatCurrencies[0] isEqualToString:USD] &&
        [fiatCurrencies[1] isEqualToString:CNY]) {
        self.usdCNYItem.state = NSOnState;
    }

    if ([fiatCurrencies[0] isEqualToString:USD] &&
        [fiatCurrencies[1] isEqualToString:JPY]) {
        self.usdJPYItem.state = NSOnState;
    }
}

/**
 * EUR / USD
 *
 * @param sender
 */
- (IBAction)fiateurUSDAction:(id)sender {
    NSDebug(@"AppDelegate::fiateurUSDAction");

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:@[EUR, USD] forKey:@"fiatCurrencies"];
    [defaults synchronize];

    [Helper relaunchAfterDelay:0];
}

/**
 * USD / EUR
 *
 * @param sender
 */
- (IBAction)fiatusdEURAction:(id)sender {
    NSDebug(@"AppDelegate::fiatusdEURAction");

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:@[USD, EUR] forKey:@"fiatCurrencies"];
    [defaults synchronize];

    [Helper relaunchAfterDelay:0];
}


/**
 * EUR / GBP
 *
 * @param sender
 */
- (IBAction)fiateurGBPAction:(id)sender {
    NSDebug(@"AppDelegate::fiateurGBPAction");

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:@[EUR, GBP] forKey:@"fiatCurrencies"];
    [defaults synchronize];

    [Helper relaunchAfterDelay:0];
}

/**
 * USD / GBP
 *
 * @param sender
 */
- (IBAction)fiatusdGBPAction:(id)sender {
    NSDebug(@"AppDelegate::fiatusdGBPAction");

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:@[USD, GBP] forKey:@"fiatCurrencies"];
    [defaults synchronize];

    [Helper relaunchAfterDelay:0];
}

/**
 * USD / CNY
 *
 * @param sender
 */
- (IBAction)fiatusdCNYAction:(id)sender {
    NSDebug(@"AppDelegate::fiatusdCNYAction");

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:@[USD, CNY] forKey:@"fiatCurrencies"];
    [defaults synchronize];

    [Helper relaunchAfterDelay:0];
}

/**
 * USD / JPY
 *
 * @param sender
 */
- (IBAction)fiatusdJPYAction:(id)sender {
    NSDebug(@"AppDelegate::fiatusdJPYAction");

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:@[USD, JPY] forKey:@"fiatCurrencies"];
    [defaults synchronize];

    [Helper relaunchAfterDelay:0];
}

/**
 * Schaltet die Menübar an/aus
 *
 * @param sender
 */
- (IBAction)toggleMenuBar:(id)sender {
    NSDebug(@"AppDelegate::toggleMenuBar");

    NSMenuItem *item = (NSMenuItem *) sender;

    item.state = !item.state;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *state = @(item.state);

    [defaults setValue:state forKey:OPTIONS_MENUBAR];
    [defaults synchronize];
}

/**
* Lösche alle Schlüssel
*
* @param sender
*/
- (IBAction)applicationReset:(id)sender {
    NSDebug(@"AppDelegate::applicationReset");

    if ([Helper messageText:NSLocalizedString(@"application_reset", @"Anwendungs-Reset") info:NSLocalizedString(@"wanna_reset_to_app_defaults", @"Möchten Sie auf die Standard-Einstellungen zurück setzen?")] == NSAlertFirstButtonReturn) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        [defaults removeObjectForKey:TV_APPLICATIONS];
        [defaults removeObjectForKey:COINCHANGE_PERCENTAGE];
        [defaults removeObjectForKey:TV_TRADERS];
        [defaults removeObjectForKey:KEY_TRADING_WITH_CONFIRMATION];

        [Calculator reset];

        [defaults synchronize];

        [Helper relaunchAfterDelay:0];
    }
}

@end
