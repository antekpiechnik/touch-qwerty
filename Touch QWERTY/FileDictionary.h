//
//  FileDictionary.h
//  Touch QWERTY
//
//  Created by Michal Bugno on 11/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Dictionary.h"


@interface FileDictionary : Dictionary {
	NSArray *words;
}

- (id)initWithFilename:(NSString *)filename;
- (NSUInteger)count;
@end
