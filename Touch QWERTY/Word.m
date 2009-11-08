//
//  Word.m
//  Touch QWERTY
//
//  Created by Michal Bugno on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Word.h"


@implementation Word

- (id)initWithFrame:(NSRect)frame word:(NSString *)word {
    self = [super initWithFrame:frame];
    if (self) {
        // the correct size will be computed with sizeToFit method
        [self setDrawsBackground:NO];
        [self setTextColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.3]];
        [self setEditable:NO];
        [self setBezeled:NO];
        [self setBordered:NO];
        [self setFont:[NSFont fontWithName:@"Futura" size:20.0]];
        [self setStringValue:word];
        [self sizeToFit];
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
    [self setFrameOrigin:NSMakePoint(origin.x - 2, origin.y)];
    return [self frame].origin.x <= 0;
}

- (void)updateWithLetter:(NSString *)letter {
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
        alpha *= 1.15;
        if (alpha > 1.0) {
            alpha = 1.0;
        }
        [self setTextColor:[NSColor colorWithCalibratedRed:0.0
                                                  green:0.0
                                                   blue:0.0
                                                  alpha:alpha]];
	}
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
