//
//  GameController.h
//  Touch QWERTY
//
//  Created by Michal Bugno on 11/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Dictionary.h"
#import "FileDictionary.h"


@interface GameController : NSObject {
	NSMutableDictionary *dictionaries;
	IBOutlet NSComboBox *dictionaryComboBox;
	bool gameIsRunning;
}
- (void)registerDictionary:(NSString *)path withName:(NSString *)name;
- (Dictionary *)currentDictionary;
- (IBAction)startStop:(id)sender;
- (void)startGame;
- (void)stopGame;
- (void)addWord;
@end
