//
//  GameController.m
//  Touch QWERTY
//
//  Created by Michal Bugno on 11/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameController.h"


@implementation GameController
- (id) init {
	self = [super init];
	if (self) {
		dictionaries = [[NSMutableDictionary alloc] initWithCapacity: 4];
		words = [[NSMutableArray alloc] initWithCapacity:16];
		gameIsRunning = NO;
	}
	return self;
}

- (IBAction)startStop:(id)sender {
	if (gameIsRunning) {
		[sender setTitle:@"Start"];
		[self stopGame];
	} else {
		[sender setTitle:@"Stop"];
		[self startGame];
	}
}

- (void)startGame {
	gameIsRunning = YES;
	[dictionaryComboBox setEnabled:NO];
	[NSThread detachNewThreadSelector:@selector(wordGenerator) toTarget:self withObject:nil];
	[NSThread detachNewThreadSelector:@selector(wordReposition) toTarget:self withObject:nil];
}

- (void)stopGame {
	NSEnumerator *it;
	NSTextField *word;
	
	gameIsRunning = NO;
	[dictionaryComboBox setEnabled:YES];
	it = [words objectEnumerator];
	while (word = [it nextObject]) {
		[word removeFromSuperview];
	}
	[words removeAllObjects];
	[boardView setNeedsDisplay:YES];
}

- (void)awakeFromNib {
	[self registerDictionary: @"EnglishWords.txt" withName: @"English words"];
	[dictionaryComboBox addItemsWithObjectValues:[dictionaries allKeys]];
	[dictionaryComboBox selectItemAtIndex:0];
}

- (void)registerDictionary:(NSString *)path withName:(NSString *)name {
	FileDictionary *dict;
	NSString *fullPath, *fileName, *extension;
	
	fileName = [path stringByDeletingPathExtension];
	extension = [path pathExtension];
	fullPath = [[NSBundle mainBundle] pathForResource:fileName ofType:extension];
	dict = [[FileDictionary alloc] initWithFilename:fullPath];
	[dictionaries setObject:dict forKey:name];
	NSLog(@"Registered dictionary with name %@ (count: %d)", name, [dict count]);
}

- (Dictionary *)currentDictionary {
	return [dictionaries objectForKey:[dictionaryComboBox objectValueOfSelectedItem]];
}

- (void)addWord {
	Dictionary *dict;
	NSString *word;
	NSTextField *textField;
	NSRect rect;
	
	dict = [self currentDictionary];
	word = [dict nextWord];
	rect = NSMakeRect((NSUInteger)([boardView frame].size.width - 50),
					  rand() % (NSUInteger)([boardView frame].size.height),
					  1,
					  1);
	textField = [[NSTextField alloc] initWithFrame:rect];
	[textField setBackgroundColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.0]];
	[textField setEditable:NO];
	[textField setBezeled:NO];
	[textField setBordered:NO];
	[textField setStringValue:word];
	[textField setFont:[NSFont fontWithName:@"Futura" size:20.0]];
	[textField sizeToFit];
	[words addObject:textField];
	[boardView addSubview:textField];
	[boardView setNeedsDisplay:YES];
}

- (void)wordGenerator {
	while (gameIsRunning) {
		[self addWord];
		[NSThread sleepForTimeInterval:1];
	}
}

- (void)wordReposition {
	NSEnumerator *it;
	NSTextField *word;
	NSPoint origin;
	
	while (gameIsRunning) {
		it = [words objectEnumerator];
		while (word = [it nextObject]) {
			origin = [word frame].origin;
			[word setFrameOrigin:NSMakePoint(origin.x - 1, origin.y)];
		}
		[NSThread sleepForTimeInterval:1];
	}
}
@end
