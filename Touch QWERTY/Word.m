//
//  Word.m
//  Touch QWERTY
//
//  Created by Michal Bugno on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Word.h"


@implementation Word

- (id)initWithFrame:(NSRect)frame word:(NSString *)word andSpeed:(float)aSpeed {
    self = [super initWithFrame:frame];
    if (self) {
        // the correct size will be computed with sizeToFit method
        [self setDrawsBackground:NO];
        [self setTextColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.3]];
        [self setEditable:NO];
        [self setBezeled:NO];
        [self setBordered:NO];
        [self setFont:[NSFont fontWithName:@"Tahoma" size:20.0]];
        [self setStringValue:word];
        [self sizeToFit];
        speed = aSpeed;
        typed = @"";
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (BOOL)reposition {
    NSPoint origin;

    origin = [self frame].origin;
    [self setFrameOrigin:NSMakePoint(origin.x - speed, origin.y)];
    return [self frame].origin.x <= 0;
}

- (BOOL)updateWithLetter:(NSString *)letter {
    NSString *newType;
    NSMutableAttributedString *value;
    double alpha;

    newType = [[typed stringByAppendingString: letter] retain];
    if ([[self stringValue] hasPrefix:newType]) {
        [typed release];
        typed = newType;
        value = [[NSMutableAttributedString alloc] initWithString:[self stringValue]];
        [value addAttribute:NSForegroundColorAttributeName
                      value:[NSColor redColor]
                      range:NSMakeRange(0, [typed length])];
        [self setAttributedStringValue: value];
        alpha = [[self textColor] alphaComponent];
        alpha += (0.7 / [[self stringValue] length]);
        [self setTextColor:[NSColor colorWithCalibratedRed:0.0
                                                     green:0.0
                                                      blue:0.0
                                                     alpha:alpha]];
        return YES;
    }
    return NO;
}

- (BOOL)shouldBeRemoved {
    return ! [[self stringValue] caseInsensitiveCompare:typed];
}

- (void)clearTypedLetters {
    typed = @"";
    [self setStringValue:[self stringValue]];
    [self setTextColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.3]];
}

@end
