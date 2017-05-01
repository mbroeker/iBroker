//
//  TabView.m
//  iBroker
//
//  Created by Markus Bröker on 04.04.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "TabView.h"

@implementation TabView

/**
 * Sinn und Zweck: Füllen des Hintergrunds des TabViews mit der gewählten Farbe
 *
 * @param dirtyRect
 */
- (void) drawRect:(NSRect)dirtyRect {
    static const NSRect offsetRect = (NSRect) { 0, 0, 0, 0 };
    
    NSRect rect = self.frame;
    
    rect.origin.x += offsetRect.origin.x;
    rect.origin.y += offsetRect.origin.y;
    rect.size.width += offsetRect.size.width;
    rect.size.height += offsetRect.size.height;

    [[NSColor colorWithCalibratedRed:21.0f/255.0f green:48.0f/255.0f blue:80.0f/255.0f alpha:1.0f] set];

    NSRectFill(rect);
    
    [super drawRect: dirtyRect];
}

@end
