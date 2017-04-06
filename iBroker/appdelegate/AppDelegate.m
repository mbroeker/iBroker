//
//  AppDelegate.m
//  iBroker
//
//  Created by Markus Bröker on 04.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "AppDelegate.h"

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

@end
