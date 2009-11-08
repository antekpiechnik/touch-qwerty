//
//  RandomDictionary.m
//  Touch QWERTY
//
//  Created by Michal Bugno on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RandomDictionary.h"


@implementation RandomDictionary
- (id)initWithRange:(NSRange)range {
    self = [super init];
    if (self) {
        minLength = range.location;
        maxLength = range.length;
    }
    return self;
}
- (NSString *)nextWord {
    NSString *str;
    unichar num;
    NSString *letter;
    NSUInteger length, i;
    
    length = rand() % (maxLength - minLength + 1) + minLength;
    str = @"";
    for (i = 0; i < length; i++) {
        num = (unichar)(random() % 26 + 65);
        letter = [[[NSString alloc] initWithCharacters:&num length:1] autorelease];
        str = [str stringByAppendingString:[letter lowercaseString]];
    }
    return str;
}
@end
