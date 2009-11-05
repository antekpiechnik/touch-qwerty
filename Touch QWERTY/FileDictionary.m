//
//  FileDictionary.m
//  Touch QWERTY
//
//  Created by Michal Bugno on 11/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FileDictionary.h"


@implementation FileDictionary
- (id)initWithFilename:(NSString *)path {
	NSString *fileContents;
	NSCharacterSet *separator;
	
	self = [super init];
	if (self) {
		fileContents = [NSString stringWithContentsOfFile:path
												 encoding:NSUTF8StringEncoding
													error:nil];
		separator = [NSCharacterSet newlineCharacterSet];
		words = [fileContents componentsSeparatedByCharactersInSet:separator];
		[words retain];
	}
	return self;
}

- (NSString *)nextWord {
	NSUInteger randomIndex;
	
	randomIndex = rand() % [self count];
	return [words objectAtIndex:randomIndex];
}

- (NSUInteger)count {
	return [words count];
}

- (void)dealloc {
	[words release];
	[super dealloc];
}
@end
