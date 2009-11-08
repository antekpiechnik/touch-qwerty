//
//  RandomDictionary.h
//  Touch QWERTY
//
//  Created by Michal Bugno on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Dictionary.h"


@interface RandomDictionary : Dictionary <DictionaryProtocol> {
    NSUInteger minLength;
    NSUInteger maxLength;
}
- (id)initWithRange:(NSRange)range;

@end
