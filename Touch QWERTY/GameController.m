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
        dictionaries = [[NSMutableDictionary alloc] initWithCapacity:4];
        dictionariesOrder = [[NSMutableArray alloc] initWithCapacity:4];
        words = [[NSMutableArray alloc] initWithCapacity:16];
        lock = [[NSLock alloc] init];
        gameIsRunning = NO;
        points = 0;
        correctHits = 0;
        totalHits = 0;
        totalWords = 0;
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
    [self registerFileDictionary:@"EnglishWords.txt" withName:@"English words"];
    [self registerFileDictionary:@"UnixCommands.txt" withName:@"Unix commands"];
    [self registerDictionary:[[RandomDictionary alloc] initWithRange:NSMakeRange(5, 7)]
                    withName:@"Random words (5..7)"];
    [dictionaryComboBox addItemsWithObjectValues:dictionariesOrder];
    [dictionaryComboBox selectItemAtIndex:0];
    [self resetStats];
}

- (void)registerFileDictionary:(NSString *)path withName:(NSString *)name {
    FileDictionary *dict;
    NSString *fullPath, *fileName, *extension;
    
    fileName = [path stringByDeletingPathExtension];
    extension = [path pathExtension];
    fullPath = [[NSBundle mainBundle] pathForResource:fileName ofType:extension];
    dict = [[FileDictionary alloc] initWithFilename:fullPath];
    [self registerDictionary:dict withName:name];
}

- (void)registerDictionary:(Dictionary *)dict withName:(NSString *)name {
    [dictionaries setObject:dict forKey:name];
    [dictionariesOrder addObject:name];
    NSLog(@"Registered dictionary with name %@", name);
}

- (Dictionary *)currentDictionary {
    return [dictionaries objectForKey:[dictionaryComboBox objectValueOfSelectedItem]];
}

- (void)addWord {
    Dictionary *dict;
    Word *word;
    NSRect rect;
    float speed;
    
    speed = (float)(rand() % 100) / 250.0 + log10f(correctHits * 1.0 + 10.0);
    dict = [self currentDictionary];
    rect = NSMakeRect((NSUInteger)([boardView frame].size.width),
                      35 + rand() % ((NSUInteger)([boardView frame].size.height) - 35),
                      1,
                      1);
    if (rect.origin.y > [boardView frame].origin.y - 25.0) {
        rect.origin.y -= 25.0;
    }
    word = [[Word alloc] initWithFrame:rect word:[dict nextWord] andSpeed:speed];
    [words addObject:word];
    [boardView addSubview:word];
    [boardView setNeedsDisplay:YES];
}

- (void)wordGenerator {
    NSAutoreleasePool *pool;
    float sleepTime;
    
    pool = [[NSAutoreleasePool alloc] init];
    while (gameIsRunning) {
        [lock lock];
        [self addWord];
        [lock unlock];
        
        // empirical sleep time randomized a bit
        sleepTime = 7000000 / (log10f(correctHits * 1.0 + 30.0) / log10f(6.5));
        sleepTime -= rand() % (int)(0.2 * sleepTime);
        usleep(sleepTime);
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
    BOOL valid, wordsRemoved;
    NSUInteger newPoints;

    wordsRemoved = 0;
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
            wordsRemoved += 1;
            [word removeFromSuperview];
            [toRemove addObject:word];
            newPoints += [[word stringValue] length];
        }
    }
    if (! valid) { // minus points, nothing matched
        [self updatePoints:-5 words:wordsRemoved validHit:false];
    } else { // adding points
        [self updatePoints:newPoints words:wordsRemoved validHit:true];
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
    totalWords = 0;
    [self updateStatsView];
}

- (void)updatePoints:(NSInteger)newPoints words:(NSUInteger)wordsRemoved validHit:(BOOL)validHit {
    if ((NSInteger)points + newPoints < 0) {
        points = 0;
    } else {
        points += newPoints;
    }

    totalHits += 1;
    if (validHit) correctHits += 1;
    totalWords += wordsRemoved;
    [self updateStatsView];
}

- (void)updateStatsView {
    float perc;
    
    if (totalHits == 0) {
        perc = 0.0;
    } else {
        perc = 100.0 * correctHits / totalHits;
    }
    [pointsTextField setStringValue:[NSString stringWithFormat:@"pts:%u", points]];
    [statsTextField setStringValue:[NSString stringWithFormat:@"%u/%u/%u (%.2f%%)",
                                    correctHits,
                                    totalHits,
                                    totalWords,
                                    perc]];
}
@end
