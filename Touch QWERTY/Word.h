//
//  Word.h
//  Touch QWERTY
//
//  Created by Michal Bugno on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Word : NSTextField {
	NSString *typed;
}
- (id)initWithFrame:(NSRect)frame word:(NSString *)word;
- (BOOL)reposition;
- (void)updateWithLetter:(NSString *)letter;
@end