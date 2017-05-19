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

@synthesize window = _window;

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    _window = [[[NSApplication sharedApplication] windows] objectAtIndex:0];
}

/**
 * Sinn und Zweck: Benachrichtigung des Programmierers, dass das Teil geladen wurde...
 *
 * @param aNotification
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *state = [defaults valueForKey:@"menubar"];

    self.menubarItem.state = state.integerValue;
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
    return true;
}

/**
 * Schaltet die Menübar an/aus
 *
 * @param sender
 */
- (IBAction)toggleMenuBar:(id)sender {
    NSMenuItem *item = (NSMenuItem*)sender;

    item.state = !item.state;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *state = [NSNumber numberWithInteger:item.state];

    [defaults setValue:state forKey: @"menubar"];
    [defaults synchronize];
}

/**
* Lösche alle Schlüssel
*
* @param sender
*/
- (IBAction)applicationReset:(id)sender {
    if ([Helper messageText:NSLocalizedString(@"application_reset", @"Anwendungs-Reset") info:NSLocalizedString(@"wanna_reset_to_app_defaults", @"Möchten Sie auf die Standard-Einstellungen zurück setzen?")] == NSAlertFirstButtonReturn) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        [defaults removeObjectForKey:TV_APPLICATIONS];
        [defaults removeObjectForKey:TV_TRADERS];
        [defaults removeObjectForKey:KEY_SALDO_URLS];
        [defaults removeObjectForKey:KEY_CURRENT_SALDO];
        [defaults removeObjectForKey:KEY_INITIAL_RATINGS];

        [defaults synchronize];

        [NSApp terminate: self];
    }
}

@end
