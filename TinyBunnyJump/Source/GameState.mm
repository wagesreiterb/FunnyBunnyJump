//
//  GameState.m
//  FunnyBunnyJump
//
//  Created by Que on 28.10.12.
//
//

#import "GameState.h"
#import "GCDatabase.h"

@implementation GameState


@synthesize completedSeasonSpring2012;
@synthesize completedSeasonSummer2012;
@synthesize completedSeasonFall2012;
@synthesize completedSeasonWinter2012;

@synthesize highScore;
@synthesize tempHighScore;

//static GameState *sharedInstance = nil;
//
//+(GameState*)sharedInstance {
//    @synchronized([GameState class]) {
//        if(!sharedInstance) {
//            NSLog(@"GameState::init - 3");
//            sharedInstance = loadData(@"GameState");
//            // Add an observer that will respond to loginComplete
////            [[NSNotificationCenter defaultCenter] addObserver:self
////                                                     selector:@selector(appDelegateResume:)
////                                                         name:@"appDelegateResume" object:nil];
//            
//            if(!sharedInstance) {
//                NSLog(@"GameState::init - 4");
//                [[self alloc] init];
//                
//            }
//        }
//        return sharedInstance;
//    }    
//    return nil;
//}
//
//+(id)alloc {
//    @synchronized([GameState class]) {
//        NSAssert(sharedInstance == nil, @"Attempted to allocate a \
//                 second instance of the GameState singleton");
//        sharedInstance = [super alloc];
//        return sharedInstance;
//    }
//}

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        //_sharedObject = [[self alloc] init]; // or some other init method
        if(!(_sharedObject = loadData(@"GameState"))) {
            _sharedObject = [[self alloc] init];
        }
    });
    //NSLog(@"... sharedInstance GameState");
    return _sharedObject;
}

-(void)save {
    NSLog(@"save");
    saveData(self, @"GameState");
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    //WRITE
    [encoder encodeBool:completedSeasonSpring2012 forKey:@"CompletedSeasonSpring2012"];
    [encoder encodeBool:completedSeasonSummer2012 forKey:@"CompletedSeasonSummer2012"];
    [encoder encodeBool:completedSeasonFall2012 forKey:@"CompletedSeasonFall2012"];
    [encoder encodeBool:completedSeasonWinter2012 forKey:@"CompletedSeasonWinter2012"];
    
    [encoder encodeBool:_musicEnabled forKey:@"musicEnabled"];
    [encoder encodeBool:_soundEnabled forKey:@"soundEnabled"];
    [encoder encodeBool:_gameOnceStarted forKey:@"gameOnceStarted"];
    [encoder encodeBool:_payingUser forKey:@"payingUser"];
    
    //NSLog(@"--- WRITE BEGIN");
    
    highScore = [NSDictionary dictionaryWithDictionary:tempHighScore];
    [encoder encodeObject:highScore forKey:@"highScore"];
    //NSLog(@"---READ tempHighScore retainCount %d", [tempHighScore retainCount]);
    
    //is level Locked
    _levelLocked = [NSDictionary dictionaryWithDictionary:_tempLevelLocked];
    [encoder encodeObject:_levelLocked forKey:@"levelLocked"];
    
    _levelPassed = [NSDictionary dictionaryWithDictionary:_tempLevelPassed];
    [encoder encodeObject:_levelPassed forKey:@"levelPassed"];
    _levelPassedInTime = [NSDictionary dictionaryWithDictionary:_tempLevelPassedInTime];
    [encoder encodeObject:_levelPassedInTime forKey:@"levelPassedInTime"];
    _levelPassedNoLivesLost = [NSDictionary dictionaryWithDictionary:_tempLevelPassedNoLivesLost];
    [encoder encodeObject:_levelPassedNoLivesLost forKey:@"levelPassedNoLivesLost"];
    
    
    [encoder encodeInteger:_redTrampolinesLeft forKey:@"redTrampolinesLeft"];
    [encoder encodeInteger:_jumpButtonsLeft forKey:@"jumpButtonsLeft"];
    [encoder encodeInteger:_lifesLeft forKey:@"lifesLeft"];
}

-(id)init {
    NSLog(@"GameState::init");
    if((self = [super init])) {
        
        _seasonsAsStringArray = [NSArray arrayWithObjects:@"Spring", @"Summer", @"Fall", @"Winter", nil];
        _levelsAsStringArray = [NSArray arrayWithObjects:@"2012001", @"2012002", @"2012003", @"2012004", @"2012005",
                                @"2012006", @"2012007", @"2012008", @"2012009", @"2012010",
                                @"2012011", @"2012012", @"2012013", @"2012014", @"2012015", nil];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)decoder {
    //READ
    if((self = [super init])) {
        completedSeasonSpring2012 = [decoder decodeBoolForKey:@"CompletedSeasonSpring2012"];
        completedSeasonSummer2012 = [decoder decodeBoolForKey:@"CompletedSeasonSummer2012"];
        completedSeasonFall2012 = [decoder decodeBoolForKey:@"CompletedSeasonFall2012"];
        completedSeasonWinter2012 = [decoder decodeBoolForKey:@"CompletedSeasonWinter2012"];
        
        _musicEnabled = [decoder decodeBoolForKey:@"musicEnabled"];
        _soundEnabled = [decoder decodeBoolForKey:@"soundEnabled"];
        _gameOnceStarted = [decoder decodeBoolForKey:@"gameOnceStarted"];
        _payingUser = [decoder decodeBoolForKey:@"payingUser"];
        
        highScore = [decoder decodeObjectForKey:@"highScore"];

        if(tempHighScore == nil) {
            tempHighScore = [NSMutableDictionary dictionaryWithDictionary:highScore];
        }
        
        _levelLocked = [decoder decodeObjectForKey:@"levelLocked"];
        _tempLevelLocked = [NSMutableDictionary dictionaryWithDictionary:_levelLocked];
        
        
        _levelPassed = [decoder decodeObjectForKey:@"levelPassed"];
        _tempLevelPassed = [NSMutableDictionary dictionaryWithDictionary:_levelPassed];
        _levelPassedInTime = [decoder decodeObjectForKey:@"levelPassedInTime"];
        _tempLevelPassedInTime = [NSMutableDictionary dictionaryWithDictionary:_levelPassedInTime];
        _levelPassedNoLivesLost = [decoder decodeObjectForKey:@"levelPassedNoLivesLost"];
        _tempLevelPassedNoLivesLost = [NSMutableDictionary dictionaryWithDictionary:_levelPassedNoLivesLost];
        
        _redTrampolinesLeft = [decoder decodeIntegerForKey:@"redTrampolinesLeft"];
        _jumpButtonsLeft = [decoder decodeIntegerForKey:@"jumpButtonsLeft"];
        _lifesLeft = [decoder decodeIntegerForKey:@"lifesLeft"];
        
        NSLog(@"_lifesLeft: %d", _lifesLeft);
        
    }
    return self;
}

-(void)enableSoundAndMusic {
    _musicEnabled = YES;
    _soundEnabled = YES;
}

-(void)initInAppPurchaseValues {
    //sets the default values for i.e. redTrampoline when the app launches for the very first time
    _redTrampolinesLeft = 5;
    _jumpButtonsLeft = 5;
    _lifesLeft = 5;
}

-(void)initGameState {
    if(_gameOnceStarted == NO) {    //has the game already been launched once?
        [self createLevelLockedDictionary];
        [self enableSoundAndMusic];
        [self initInAppPurchaseValues];
    }
}

-(BOOL)isLevelLockedWithSeason:(NSString*)season_ andLevel:(int)level_ {
    NSString* levelAsString = @"level";
    levelAsString = [levelAsString stringByAppendingString:season_];
    NSString *level = [NSString stringWithFormat:@"%d", level_];
    levelAsString = [levelAsString stringByAppendingString:level];

    return [[_tempLevelLocked objectForKey:levelAsString] boolValue];
}

-(BOOL)isLevelPassed {
    NSString* levelAsString = @"level";
    levelAsString = [levelAsString stringByAppendingString:[[GameManager sharedGameManager] seasonName]];
    NSString *sceneAsString = [NSString stringWithFormat:@"%d", [[GameManager sharedGameManager] currentScene]];
    levelAsString = [levelAsString stringByAppendingString:sceneAsString];
    
    NSLog(@"__ xxx : %@", levelAsString);
    
    return [[_tempLevelPassed objectForKey:levelAsString] boolValue];
}

-(BOOL)isLevelPassed:(NSString*)levelName_ {
    return [[_tempLevelPassed objectForKey:levelName_] boolValue];
}

-(void)setLevelPassed {
    NSString* levelAsString = @"level";
    levelAsString = [levelAsString stringByAppendingString:[[GameManager sharedGameManager] seasonName]];
    NSString *sceneAsString = [NSString stringWithFormat:@"%d", [[GameManager sharedGameManager] currentScene]];
    levelAsString = [levelAsString stringByAppendingString:sceneAsString];
    
    
    [_tempLevelPassed setObject:[NSNumber numberWithBool:YES] forKey:levelAsString];
    
    NSLog(@"__ xxx : %@", levelAsString);
}

-(BOOL)isLevelPassedInTime {
    NSString* levelAsString = @"level";
    levelAsString = [levelAsString stringByAppendingString:[[GameManager sharedGameManager] seasonName]];
    NSString *sceneAsString = [NSString stringWithFormat:@"%d", [[GameManager sharedGameManager] currentScene]];
    levelAsString = [levelAsString stringByAppendingString:sceneAsString];

    return [[_tempLevelPassedInTime objectForKey:levelAsString] boolValue];
}

-(BOOL)isLevelPassedInTime:(NSString*)levelName_ {
    return [[_tempLevelPassedInTime objectForKey:levelName_] boolValue];
}

-(void)setLevelPassedInTime {
    NSString* levelAsString = @"level";
    levelAsString = [levelAsString stringByAppendingString:[[GameManager sharedGameManager] seasonName]];
    NSString *sceneAsString = [NSString stringWithFormat:@"%d", [[GameManager sharedGameManager] currentScene]];
    levelAsString = [levelAsString stringByAppendingString:sceneAsString];
    
    [_tempLevelPassedInTime setObject:[NSNumber numberWithBool:YES] forKey:levelAsString];
}

-(BOOL)isLevelPassedWithNoLivesLost {
    NSString* levelAsString = @"level";
    levelAsString = [levelAsString stringByAppendingString:[[GameManager sharedGameManager] seasonName]];
    NSString *sceneAsString = [NSString stringWithFormat:@"%d", [[GameManager sharedGameManager] currentScene]];
    levelAsString = [levelAsString stringByAppendingString:sceneAsString];
    
    return [[_tempLevelPassedNoLivesLost objectForKey:levelAsString] boolValue];
}

-(BOOL)isLevelPassedWithNoLivesLost:(NSString*)levelName_ {
    return [[_tempLevelPassedNoLivesLost objectForKey:levelName_] boolValue];
}

-(void)setLevelPassedWithNoLivesLost {
    NSString* levelAsString = @"level";
    levelAsString = [levelAsString stringByAppendingString:[[GameManager sharedGameManager] seasonName]];
    NSString *sceneAsString = [NSString stringWithFormat:@"%d", [[GameManager sharedGameManager] currentScene]];
    levelAsString = [levelAsString stringByAppendingString:sceneAsString];
    
    [_tempLevelPassedNoLivesLost setObject:[NSNumber numberWithBool:YES] forKey:levelAsString];
}

-(void)unlockNextLevel {
    NSLog(@"GameState --- %d", [[GameManager sharedGameManager] currentScene]);
    NSLog(@"GameState --- %@", [[GameManager sharedGameManager] seasonName]);
    NSLog(@"GameState next Scene --- %d", [[GameManager sharedGameManager] currentScene] + 1);
    
    NSString* nextLevelAsString = @"";
    if([[GameManager sharedGameManager] currentScene] == LAST_LEVEL
       && [[GameManager sharedGameManager] season] == spring) {
        nextLevelAsString = @"levelSummer2012001";
        completedSeasonSpring2012 = true;
    } else if([[GameManager sharedGameManager] currentScene] == LAST_LEVEL
              && [[GameManager sharedGameManager] season] == summer) {
        nextLevelAsString = @"levelFall2012001";
        completedSeasonSummer2012 = true;
    } else if([[GameManager sharedGameManager] currentScene] == LAST_LEVEL
              && [[GameManager sharedGameManager] season] == fall) {
        nextLevelAsString = @"levelWinter2012001";
        completedSeasonFall2012 = true;
    } else if([[GameManager sharedGameManager] currentScene] == LAST_LEVEL
              && [[GameManager sharedGameManager] season] == winter) {
        nextLevelAsString = @"levelWinter2012001";  //stupid, or?
        completedSeasonWinter2012 = true;
    } else {
        nextLevelAsString = @"level";
        nextLevelAsString = [nextLevelAsString stringByAppendingString:[[GameManager sharedGameManager] seasonName]];
        NSString *nextSceneAsString = [NSString stringWithFormat:@"%d", [[GameManager sharedGameManager] currentScene] + 1];
        nextLevelAsString = [nextLevelAsString stringByAppendingString:nextSceneAsString];
    }
    
    NSLog(@"xxx %@", nextLevelAsString);

    [_tempLevelLocked setObject:[NSNumber numberWithBool:NO] forKey:nextLevelAsString];
}

/*
-(NSString*)nextLevelAsString {
    NSString* nextLevelAsString = @"";
    if([[GameManager sharedGameManager] currentScene] == LAST_LEVEL
       && [[GameManager sharedGameManager] season] == spring) {
        nextLevelAsString = @"levelSummer2012001";
    } else if([[GameManager sharedGameManager] currentScene] == LAST_LEVEL
              && [[GameManager sharedGameManager] season] == summer) {
        nextLevelAsString = @"levelFall2012001";
    } else if([[GameManager sharedGameManager] currentScene] == LAST_LEVEL
              && [[GameManager sharedGameManager] season] == fall) {
        nextLevelAsString = @"levelWinter2012001";
    } else if([[GameManager sharedGameManager] currentScene] == LAST_LEVEL
              && [[GameManager sharedGameManager] season] == winter) {
        //TODO: do nothing, or??
    } else {
        nextLevelAsString = @"level";
        nextLevelAsString = [nextLevelAsString stringByAppendingString:[[GameManager sharedGameManager] seasonName]];
        NSString *nextSceneAsString = [NSString stringWithFormat:@"%d", [[GameManager sharedGameManager] currentScene] + 1];
        nextLevelAsString = [nextLevelAsString stringByAppendingString:nextSceneAsString];
    }
    
    return nextLevelAsString;
}
 */

-(BOOL)isNextLevelUnlocked {
    NSString* nextLevelAsString = @"";
    if([[GameManager sharedGameManager] currentScene] == LAST_LEVEL
       && [[GameManager sharedGameManager] season] == spring) {
        nextLevelAsString = @"levelSummer2012001";
    } else if([[GameManager sharedGameManager] currentScene] == LAST_LEVEL
              && [[GameManager sharedGameManager] season] == summer) {
        nextLevelAsString = @"levelFall2012001";
    } else if([[GameManager sharedGameManager] currentScene] == LAST_LEVEL
              && [[GameManager sharedGameManager] season] == fall) {
        nextLevelAsString = @"levelWinter2012001";
    } else if([[GameManager sharedGameManager] currentScene] == LAST_LEVEL
              && [[GameManager sharedGameManager] season] == winter) {
        //TODO: do nothing, or??
    } else {
        nextLevelAsString = @"level";
        nextLevelAsString = [nextLevelAsString stringByAppendingString:[[GameManager sharedGameManager] seasonName]];
        NSString *nextSceneAsString = [NSString stringWithFormat:@"%d", [[GameManager sharedGameManager] currentScene] + 1];
        nextLevelAsString = [nextLevelAsString stringByAppendingString:nextSceneAsString];
    }
    
    return ![[_tempLevelLocked objectForKey:nextLevelAsString] boolValue];
}

-(void)createLevelLockedDictionary {
    _tempLevelLocked = [[NSMutableDictionary alloc] init];
    
    for (id seasonAsString in _seasonsAsStringArray) {
        for (id levelAsString in _levelsAsStringArray) {
            NSString *fullLevelName = @"level";
            fullLevelName = [fullLevelName stringByAppendingString:seasonAsString];
            fullLevelName = [fullLevelName stringByAppendingString:levelAsString];
            [_tempLevelLocked setObject:[NSNumber numberWithBool:YES] forKey:fullLevelName];
        }
    }
    
    [_tempLevelLocked setObject:[NSNumber numberWithBool:NO] forKey:@"levelSpring2012001"];
    [_tempLevelLocked setObject:[NSNumber numberWithBool:NO] forKey:@"levelSpring2012005"];
    [_tempLevelLocked setObject:[NSNumber numberWithBool:NO] forKey:@"levelSummer2012001"];
    
    _gameOnceStarted = YES;
}

-(void)createLevelPassedDictionary {
    _tempLevelPassed = [[NSMutableDictionary alloc] init];
    
    for (id seasonAsString in _seasonsAsStringArray) {
        for (id levelAsString in _levelsAsStringArray) {
            NSString *fullLevelName = @"level";
            fullLevelName = [fullLevelName stringByAppendingString:seasonAsString];
            fullLevelName = [fullLevelName stringByAppendingString:levelAsString];
            [_tempLevelPassed setObject:[NSNumber numberWithBool:NO] forKey:fullLevelName];
        }
    }
}

-(void)createLevelPassedInTimeDictionary {
    _tempLevelPassedInTime = [[NSMutableDictionary alloc] init];
    
    for (id seasonAsString in _seasonsAsStringArray) {
        for (id levelAsString in _levelsAsStringArray) {
            NSString *fullLevelName = @"level";
            fullLevelName = [fullLevelName stringByAppendingString:seasonAsString];
            fullLevelName = [fullLevelName stringByAppendingString:levelAsString];
            [_tempLevelPassedInTime setObject:[NSNumber numberWithBool:NO] forKey:fullLevelName];
        }
    }
}

-(void)createLevelPassedNoLivesLostDictionary {
    _tempLevelPassedNoLivesLost = [[NSMutableDictionary alloc] init];
    
    for (id seasonAsString in _seasonsAsStringArray) {
        for (id levelAsString in _levelsAsStringArray) {
            NSString *fullLevelName = @"level";
            fullLevelName = [fullLevelName stringByAppendingString:seasonAsString];
            fullLevelName = [fullLevelName stringByAppendingString:levelAsString];
            [_tempLevelPassedNoLivesLost setObject:[NSNumber numberWithBool:NO] forKey:fullLevelName];
        }
    }
}

@end
