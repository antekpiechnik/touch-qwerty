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
#import "RandomDictionary.h"
#import "BoardView.h"
#import "Word.h"


@interface GameController : NSObject {
    NSMutableDictionary *dictionaries;
    NSMutableArray *words;
    NSLock *lock;
    IBOutlet NSComboBox *dictionaryComboBox;
    IBOutlet BoardView *boardView;
    IBOutlet NSButton *startStopButton;
    IBOutlet NSTextField *pointsTextField;
    IBOutlet NSTextField *statsTextField;    
    bool gameIsRunning;
    NSUInteger points;
    NSUInteger correctHits;
    NSUInteger totalHits;
    NSUInteger totalWords;
}
- (void)registerDictionary:(Dictionary *)dict withName:(NSString *)name;
- (void)registerFileDictionary:(NSString *)path withName:(NSString *)name;
- (Dictionary *)currentDictionary;
- (IBAction)startStop:(id)sender;
- (void)startGame;
- (void)stopGame;
- (void)addWord;
- (void)wordGenerator;
- (void)wordReposition;
- (void)keyDown:(NSString *)c;
- (void)updatePoints:(NSInteger)newPoints words:(NSUInteger)wordsRemoved validHit:(BOOL)validHit;
- (void)updateStatsView;
- (void)resetStats;
@end
