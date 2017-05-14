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
* Lösche alle Schlüssel
*
* @param sender
*/
- (IBAction)applicationReset:(id)sender {
    if ([Helper messageText:NSLocalizedString(@"application_reset", @"Anwendungs-Reset") info:NSLocalizedString(@"wanna_reset_to_app_defaults", @"Möchten Sie auf die Standard-Einstellungen zurück setzen?")] == NSAlertFirstButtonReturn) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        [defaults removeObjectForKey:@"applications"];
        [defaults removeObjectForKey:@"traders"];
        [defaults removeObjectForKey:KEY_SALDO_URLS];
        [defaults removeObjectForKey:KEY_CURRENT_SALDO];
        [defaults removeObjectForKey:KEY_INITIAL_RATINGS];

        [defaults synchronize];

        [NSApp terminate: self];
    }
}

@end
