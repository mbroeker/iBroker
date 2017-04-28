//
//  AppDelegate.m
//  iBroker
//
//  Created by Markus Bröker on 04.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "AppDelegate.h"
#import "Helper.h"

@implementation AppDelegate
@synthesize window = _window;

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    _window = [[[NSApplication sharedApplication] windows] objectAtIndex:0];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return true;
}
/**
* Lösche alle Schlüssel
*/
- (IBAction)applicationReset:(id)sender {

    if ([Helper messageText:@"Anwendungs-Reset" info:@"Möchten Sie auf die Standard-Einstellungen zurück setzen?"] == NSAlertFirstButtonReturn) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        [defaults removeObjectForKey:@"applications"];
        [defaults removeObjectForKey:@"traders"];
        [defaults removeObjectForKey:@"saldoUrls"];
        [defaults removeObjectForKey:@"currentSaldo"];
        [defaults removeObjectForKey:@"initialRatings"];

        [defaults synchronize];
    }
}

@end
