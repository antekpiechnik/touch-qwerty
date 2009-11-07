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
		lock = [[NSLock alloc] init];
		gameIsRunning = NO;
	}
	return self;
}

- (IBAction)startStop:(id)sender {
	if (gameIsRunning) {
		[self stopGame];
	} else {
		[self startGame];
	}
}

- (void)startGame {
	gameIsRunning = YES;
	[startStopButton setTitle:@"Stop"];
	[dictionaryComboBox setEnabled:NO];
	[NSThread detachNewThreadSelector:@selector(wordGenerator) toTarget:self withObject:nil];
	[NSThread detachNewThreadSelector:@selector(wordReposition) toTarget:self withObject:nil];
}

- (void)stopGame {
	NSEnumerator *it;
	NSTextField *word;
	
	gameIsRunning = NO;
	[startStopButton setTitle:@"Start"];
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
	rect = NSMakeRect((NSUInteger)([boardView frame].size.width),
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
	NSAutoreleasePool *pool;
	
	pool = [[NSAutoreleasePool alloc] init];
	while (gameIsRunning) {
		[lock lock];
		[self addWord];
		[lock unlock];
		[NSThread sleepForTimeInterval:1];
	}
}

- (void)wordReposition {
	NSEnumerator *it;
	NSTextField *word;
	NSPoint origin;
	NSAutoreleasePool *pool;
	BOOL stop;
	
	stop = NO;
	pool = [[NSAutoreleasePool alloc] init];
	while (gameIsRunning) {
		[lock lock];
		it = [words objectEnumerator];
		while (word = [it nextObject]) {
			origin = [word frame].origin;
			[word setFrameOrigin:NSMakePoint(origin.x - 2, origin.y)];
			if (origin.x - 1 <= 0) {
				stop = YES;			}
		}
		[lock unlock];
		if (stop) {
			[self stopGame];
		}
		usleep(25000);
	}
}
@end
