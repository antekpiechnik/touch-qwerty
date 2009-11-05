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
	[dictionaryComboBox setEnabled:NO];
	[self addWord];
	gameIsRunning = YES;
}

- (void)stopGame {
	[dictionaryComboBox setEnabled:YES];
	gameIsRunning = NO;
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
	
	dict = [self currentDictionary];
	NSLog(@"Word: %@", [dict nextWord]);
}
@end
