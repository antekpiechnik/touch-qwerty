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
        points = 0;
        correctHits = 0;
        totalHits = 0;
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
    [dictionaryComboBox setEnabled:NO];
    [startStopButton setEnabled:NO];
    [pointsTextField setIntegerValue:0];
    [self resetStats];
    [NSThread detachNewThreadSelector:@selector(wordGenerator) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(wordReposition) toTarget:self withObject:nil];
}

- (void)stopGame {
    NSEnumerator *it;
    NSTextField *word;
    
    gameIsRunning = NO;
    [dictionaryComboBox setEnabled:YES];
    [startStopButton setEnabled:YES];
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
    Word *word;
    NSRect rect;
    float speed;
    
    speed = 0.4 + (float)(rand() % 100) / 100.0;
    dict = [self currentDictionary];
    rect = NSMakeRect((NSUInteger)([boardView frame].size.width),
                      rand() % (NSUInteger)([boardView frame].size.height),
                      1,
                      1);
    if (rect.origin.y <= 60.0) {
        rect.origin.y = 60.0;
    }
    word = [[Word alloc] initWithFrame:rect word:[dict nextWord] andSpeed:speed];
    [words addObject:word];
    [boardView addSubview:word];
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
    Word *word;
    NSAutoreleasePool *pool;
    BOOL stop;
    
    stop = NO;
    pool = [[NSAutoreleasePool alloc] init];
    while (gameIsRunning) {
        [lock lock];
        it = [words objectEnumerator];
        while (word = [it nextObject]) {
            if ([word reposition]) {
                stop = YES;
            }
        }
        [lock unlock];
        if (stop) {
            [self stopGame];
        }
        usleep(40000);
    }
}

- (void)keyDown:(NSString *)c {
    Word *word;
    NSEnumerator *it;
    NSMutableArray *toRemove;
    BOOL valid;
    NSUInteger newPoints;

    if (! gameIsRunning) return;
    valid = NO;
    newPoints = 0;
    toRemove = [[NSMutableArray alloc] initWithCapacity:2];
    it = [words objectEnumerator];
    [lock lock];
    while (word = [it nextObject]) {
        if ([word updateWithLetter:c]) {
            valid = YES;
        }
        if ([word shouldBeRemoved]) {
            [word removeFromSuperview];
            [toRemove addObject:word];
            newPoints += [[word stringValue] length];
        }
    }
    if (! valid) { // minus points, nothing matched
        [self updatePoints:-5 validHit:false];
    } else { // adding points
        [self updatePoints:newPoints validHit:true];
    }
    if ([toRemove count] > 0) {
        [words removeObjectsInArray:toRemove];
        it = [words objectEnumerator];
        while (word = [it nextObject]) {
            [word clearTypedLetters];
        }
    }
    [lock unlock];
}

- (void)resetStats {
    points = 0;
    correctHits = 0;
    totalHits = 0;
    [self updateStatsView];
}

- (void)updatePoints:(NSInteger)newPoints validHit:(BOOL)validHit {
    if ((NSInteger)points + newPoints < 0) {
        points = 0;
    } else {
        points += newPoints;
    }

    totalHits += 1;
    if (validHit) correctHits += 1;
    [self updateStatsView];
}

- (void)updateStatsView {
    float perc;
    
    if (totalHits == 0) {
        perc = 0.0;
    } else {
        perc = 100.0 * correctHits / totalHits;
    }
    [pointsTextField setStringValue:[NSString stringWithFormat:@"pts:%d", points]];
    [statsTextField setStringValue:[NSString stringWithFormat:@"%d/%d (%.2f)",
                                    correctHits,
                                    totalHits,
                                    perc]];
}
@end
