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

static GameState *sharedInstance = nil;

+(GameState*)sharedInstance {
    @synchronized([GameState class]) {
        if(!sharedInstance) {
            sharedInstance = [loadData(@"GameState") retain];
            if(!sharedInstance) {
                [[self alloc] init];
            }
        }
        return sharedInstance;
    }    
    return nil;
}

+(id)alloc {
    @synchronized([GameState class]) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a \
                 second instance of the GameState singleton");
        sharedInstance = [super alloc];
        return sharedInstance;
    }
}

-(void)save {
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
}

-(id)initWithCoder:(NSCoder *)decoder {
    //READ
    //NSLog(@"--- READ BEGIN");
    if((self = [super init])) {
        completedSeasonSpring2012 = [decoder decodeBoolForKey:@"CompletedSeasonSpring2012"];
        completedSeasonSummer2012 = [decoder decodeBoolForKey:@"CompletedSeasonSummer2012"];
        completedSeasonFall2012 = [decoder decodeBoolForKey:@"CompletedSeasonFall2012"];
        completedSeasonWinter2012 = [decoder decodeBoolForKey:@"CompletedSeasonWinter2012"];
        
        _musicEnabled = [decoder decodeBoolForKey:@"musicEnabled"];
        _soundEnabled = [decoder decodeBoolForKey:@"soundEnabled"];
        
        _gameOnceStarted = [decoder decodeBoolForKey:@"gameOnceStarted"];
        
        highScore = [decoder decodeObjectForKey:@"highScore"];
        //[highScore retain];
        if(tempHighScore == nil) {
            tempHighScore = [NSMutableDictionary dictionaryWithDictionary:highScore];
            [tempHighScore retain];
            //NSLog(@"---- READ tempHighScore %@", tempHighScore);
            //NSLog(@"---- READ tempHighScore retainCount %d", [tempHighScore retainCount]);
        }
        
        _levelLocked = [decoder decodeObjectForKey:@"levelLocked"];
        //NSLog(@"---- READ _levelLocked:%@", _levelLocked);
        _tempLevelLocked = [NSMutableDictionary dictionaryWithDictionary:_levelLocked];
        [_tempLevelLocked retain];
        
        
        _levelPassed = [decoder decodeObjectForKey:@"levelPassed"];
        _tempLevelPassed = [NSMutableDictionary dictionaryWithDictionary:_levelPassed];
        [_tempLevelPassed retain];
        _levelPassedInTime = [decoder decodeObjectForKey:@"levelPassedInTime"];
        _tempLevelPassedInTime = [NSMutableDictionary dictionaryWithDictionary:_levelPassedInTime];
        [_tempLevelPassedInTime retain];
        _levelPassedNoLivesLost = [decoder decodeObjectForKey:@"levelPassedNoLivesLost"];
        _tempLevelPassedNoLivesLost = [NSMutableDictionary dictionaryWithDictionary:_levelPassedNoLivesLost];
        [_tempLevelPassedNoLivesLost retain];
    }
    return self;
}

-(void)enableSoundAndMusic {
        _musicEnabled = YES;
        _soundEnabled = YES;
}

-(void)initGameState {
    if(_gameOnceStarted == NO) {    //has the game already been launched once?
        [self createLevelLockedDictionary];
        [self enableSoundAndMusic];
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
    //if(_gameOnceStarted == NO) {
        //game is launched for the very first time

        _levelLocked = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSNumber numberWithBool:NO], @"levelSpring2012001",
                       [NSNumber numberWithBool:NO], @"levelSpring2012002",
                       [NSNumber numberWithBool:NO], @"levelSpring2012003",
                       [NSNumber numberWithBool:NO], @"levelSpring2012004",
                       [NSNumber numberWithBool:NO], @"levelSpring2012005",
                       [NSNumber numberWithBool:NO], @"levelSpring2012006",
                       [NSNumber numberWithBool:NO], @"levelSpring2012007",
                       [NSNumber numberWithBool:NO], @"levelSpring2012008",
                       [NSNumber numberWithBool:NO], @"levelSpring2012009",
                       [NSNumber numberWithBool:NO], @"levelSpring2012010",
                       [NSNumber numberWithBool:NO], @"levelSpring2012011",
                       [NSNumber numberWithBool:NO], @"levelSpring2012012",
                       [NSNumber numberWithBool:NO], @"levelSpring2012013",
                       [NSNumber numberWithBool:NO], @"levelSpring2012014",
                       [NSNumber numberWithBool:NO], @"levelSpring2012015",
                       [NSNumber numberWithBool:NO], @"levelSpring2012016",
                       [NSNumber numberWithBool:NO], @"levelSpring2012017",
                       [NSNumber numberWithBool:NO], @"levelSpring2012018",
                       [NSNumber numberWithBool:NO], @"levelSpring2012019",
                       [NSNumber numberWithBool:NO], @"levelSpring2012020",
                       [NSNumber numberWithBool:NO], @"levelSpring2012021",
                       [NSNumber numberWithBool:NO], @"levelSpring2012022",
                       [NSNumber numberWithBool:NO], @"levelSpring2012023",
                       [NSNumber numberWithBool:NO], @"levelSpring2012024",
                       [NSNumber numberWithBool:NO], @"levelSpring2012025",
                       [NSNumber numberWithBool:NO], @"levelSpring2012026",
                       
                       [NSNumber numberWithBool:NO], @"levelSummer2012001",
                       [NSNumber numberWithBool:NO], @"levelSummer2012002",
                       [NSNumber numberWithBool:NO], @"levelSummer2012003",
                       [NSNumber numberWithBool:NO], @"levelSummer2012004",
                       [NSNumber numberWithBool:NO], @"levelSummer2012005",
                       [NSNumber numberWithBool:NO], @"levelSummer2012006",
                       [NSNumber numberWithBool:NO], @"levelSummer2012007",
                       [NSNumber numberWithBool:NO], @"levelSummer2012008",
                       [NSNumber numberWithBool:NO], @"levelSummer2012009",
                       [NSNumber numberWithBool:NO], @"levelSummer2012010",
                       [NSNumber numberWithBool:NO], @"levelSummer2012011",
                       [NSNumber numberWithBool:NO], @"levelSummer2012012",
                       [NSNumber numberWithBool:NO], @"levelSummer2012013",
                       [NSNumber numberWithBool:NO], @"levelSummer2012014",
                       [NSNumber numberWithBool:NO], @"levelSummer2012015",
                       [NSNumber numberWithBool:NO], @"levelSummer2012016",
                       [NSNumber numberWithBool:NO], @"levelSummer2012017",
                       [NSNumber numberWithBool:NO], @"levelSummer2012018",
                       [NSNumber numberWithBool:NO], @"levelSummer2012019",
                       [NSNumber numberWithBool:NO], @"levelSummer2012020",
                       [NSNumber numberWithBool:NO], @"levelSummer2012021",
                       [NSNumber numberWithBool:NO], @"levelSummer2012022",
                       [NSNumber numberWithBool:NO], @"levelSummer2012023",
                       [NSNumber numberWithBool:NO], @"levelSummer2012024",
                       [NSNumber numberWithBool:NO], @"levelSummer2012025",
                       [NSNumber numberWithBool:NO], @"levelSummer2012026",
                       
                       [NSNumber numberWithBool:NO], @"levelFall2012001",
                       [NSNumber numberWithBool:NO], @"levelFall2012002",
                       [NSNumber numberWithBool:NO], @"levelFall2012003",
                       [NSNumber numberWithBool:NO], @"levelFall2012004",
                       [NSNumber numberWithBool:NO], @"levelFall2012005",
                       [NSNumber numberWithBool:NO], @"levelFall2012006",
                       [NSNumber numberWithBool:NO], @"levelFall2012007",
                       [NSNumber numberWithBool:NO], @"levelFall2012008",
                       [NSNumber numberWithBool:NO], @"levelFall2012009",
                       [NSNumber numberWithBool:NO], @"levelFall2012010",
                       [NSNumber numberWithBool:NO], @"levelFall2012011",
                       [NSNumber numberWithBool:NO], @"levelFall2012012",
                       [NSNumber numberWithBool:NO], @"levelFall2012013",
                       [NSNumber numberWithBool:NO], @"levelFall2012014",
                       [NSNumber numberWithBool:NO], @"levelFall2012015",
                       [NSNumber numberWithBool:NO], @"levelFall2012016",
                       [NSNumber numberWithBool:NO], @"levelFall2012017",
                       [NSNumber numberWithBool:NO], @"levelFall2012018",
                       [NSNumber numberWithBool:NO], @"levelFall2012019",
                       [NSNumber numberWithBool:NO], @"levelFall2012020",
                       [NSNumber numberWithBool:NO], @"levelFall2012021",
                       [NSNumber numberWithBool:NO], @"levelFall2012022",
                       [NSNumber numberWithBool:NO], @"levelFall2012023",
                       [NSNumber numberWithBool:NO], @"levelFall2012024",
                       [NSNumber numberWithBool:NO], @"levelFall2012025",
                       [NSNumber numberWithBool:NO], @"levelFall2012026",
                       
                       [NSNumber numberWithBool:NO], @"levelWinter2012001",
                       [NSNumber numberWithBool:NO], @"levelWinter2012002",
                       [NSNumber numberWithBool:NO], @"levelWinter2012003",
                       [NSNumber numberWithBool:NO], @"levelWinter2012004",
                       [NSNumber numberWithBool:NO], @"levelWinter2012005",
                       [NSNumber numberWithBool:NO], @"levelWinter2012006",
                       [NSNumber numberWithBool:NO], @"levelWinter2012007",
                       [NSNumber numberWithBool:NO], @"levelWinter2012008",
                       [NSNumber numberWithBool:NO], @"levelWinter2012009",
                       [NSNumber numberWithBool:NO], @"levelWinter2012010",
                       [NSNumber numberWithBool:NO], @"levelWinter2012011",
                       [NSNumber numberWithBool:NO], @"levelWinter2012012",
                       [NSNumber numberWithBool:NO], @"levelWinter2012013",
                       [NSNumber numberWithBool:NO], @"levelWinter2012014",
                       [NSNumber numberWithBool:NO], @"levelWinter2012015",
                       [NSNumber numberWithBool:NO], @"levelWinter2012016",
                       [NSNumber numberWithBool:NO], @"levelWinter2012017",
                       [NSNumber numberWithBool:NO], @"levelWinter2012018",
                       [NSNumber numberWithBool:NO], @"levelWinter2012019",
                       [NSNumber numberWithBool:NO], @"levelWinter2012020",
                       [NSNumber numberWithBool:NO], @"levelWinter2012021",
                       [NSNumber numberWithBool:NO], @"levelWinter2012022",
                       [NSNumber numberWithBool:NO], @"levelWinter2012023",
                       [NSNumber numberWithBool:NO], @"levelWinter2012024",
                       [NSNumber numberWithBool:NO], @"levelWinter2012025",
                       [NSNumber numberWithBool:NO], @"levelWinter2012026",

                       nil];
        
        _gameOnceStarted = YES;
        //[_levelLocked retain];
    //}
    
    //if(_tempLevelLocked == nil) {
        _tempLevelLocked = [NSMutableDictionary dictionaryWithDictionary:_levelLocked];
        [_tempLevelLocked retain];
    //}
    
    NSLog(@"+++ createLevelLockedDictionary %@", _tempLevelLocked);
}

-(void)createLevelPassedDictionary {
    _levelPassed = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithBool:NO], @"levelSpring2012001",
                    [NSNumber numberWithBool:NO], @"levelSpring2012002",
                    [NSNumber numberWithBool:NO], @"levelSpring2012003",
                    [NSNumber numberWithBool:NO], @"levelSpring2012004",
                    [NSNumber numberWithBool:NO], @"levelSpring2012005",
                    [NSNumber numberWithBool:NO], @"levelSpring2012006",
                    [NSNumber numberWithBool:NO], @"levelSpring2012007",
                    [NSNumber numberWithBool:NO], @"levelSpring2012008",
                    [NSNumber numberWithBool:NO], @"levelSpring2012009",
                    [NSNumber numberWithBool:NO], @"levelSpring2012010",
                    [NSNumber numberWithBool:NO], @"levelSpring2012011",
                    [NSNumber numberWithBool:NO], @"levelSpring2012012",
                    [NSNumber numberWithBool:NO], @"levelSpring2012013",
                    [NSNumber numberWithBool:NO], @"levelSpring2012014",
                    [NSNumber numberWithBool:NO], @"levelSpring2012015",
                    [NSNumber numberWithBool:NO], @"levelSpring2012016",
                    [NSNumber numberWithBool:NO], @"levelSpring2012017",
                    [NSNumber numberWithBool:NO], @"levelSpring2012018",
                    [NSNumber numberWithBool:NO], @"levelSpring2012019",
                    [NSNumber numberWithBool:NO], @"levelSpring2012020",
                    [NSNumber numberWithBool:NO], @"levelSpring2012021",
                    [NSNumber numberWithBool:NO], @"levelSpring2012022",
                    [NSNumber numberWithBool:NO], @"levelSpring2012023",
                    [NSNumber numberWithBool:NO], @"levelSpring2012024",
                    [NSNumber numberWithBool:NO], @"levelSpring2012025",
                    [NSNumber numberWithBool:NO], @"levelSpring2012026",
                    
                    [NSNumber numberWithBool:NO], @"levelSummer2012001",
                    [NSNumber numberWithBool:NO], @"levelSummer2012002",
                    [NSNumber numberWithBool:NO], @"levelSummer2012003",
                    [NSNumber numberWithBool:NO], @"levelSummer2012004",
                    [NSNumber numberWithBool:NO], @"levelSummer2012005",
                    [NSNumber numberWithBool:NO], @"levelSummer2012006",
                    [NSNumber numberWithBool:NO], @"levelSummer2012007",
                    [NSNumber numberWithBool:NO], @"levelSummer2012008",
                    [NSNumber numberWithBool:NO], @"levelSummer2012009",
                    [NSNumber numberWithBool:NO], @"levelSummer2012010",
                    [NSNumber numberWithBool:NO], @"levelSummer2012011",
                    [NSNumber numberWithBool:NO], @"levelSummer2012012",
                    [NSNumber numberWithBool:NO], @"levelSummer2012013",
                    [NSNumber numberWithBool:NO], @"levelSummer2012014",
                    [NSNumber numberWithBool:NO], @"levelSummer2012015",
                    [NSNumber numberWithBool:NO], @"levelSummer2012016",
                    [NSNumber numberWithBool:NO], @"levelSummer2012017",
                    [NSNumber numberWithBool:NO], @"levelSummer2012018",
                    [NSNumber numberWithBool:NO], @"levelSummer2012019",
                    [NSNumber numberWithBool:NO], @"levelSummer2012020",
                    [NSNumber numberWithBool:NO], @"levelSummer2012021",
                    [NSNumber numberWithBool:NO], @"levelSummer2012022",
                    [NSNumber numberWithBool:NO], @"levelSummer2012023",
                    [NSNumber numberWithBool:NO], @"levelSummer2012024",
                    [NSNumber numberWithBool:NO], @"levelSummer2012025",
                    [NSNumber numberWithBool:NO], @"levelSummer2012026",
                    
                    [NSNumber numberWithBool:NO], @"levelFall2012001",
                    [NSNumber numberWithBool:NO], @"levelFall2012002",
                    [NSNumber numberWithBool:NO], @"levelFall2012003",
                    [NSNumber numberWithBool:NO], @"levelFall2012004",
                    [NSNumber numberWithBool:NO], @"levelFall2012005",
                    [NSNumber numberWithBool:NO], @"levelFall2012006",
                    [NSNumber numberWithBool:NO], @"levelFall2012007",
                    [NSNumber numberWithBool:NO], @"levelFall2012008",
                    [NSNumber numberWithBool:NO], @"levelFall2012009",
                    [NSNumber numberWithBool:NO], @"levelFall2012010",
                    [NSNumber numberWithBool:NO], @"levelFall2012011",
                    [NSNumber numberWithBool:NO], @"levelFall2012012",
                    [NSNumber numberWithBool:NO], @"levelFall2012013",
                    [NSNumber numberWithBool:NO], @"levelFall2012014",
                    [NSNumber numberWithBool:NO], @"levelFall2012015",
                    [NSNumber numberWithBool:NO], @"levelFall2012016",
                    [NSNumber numberWithBool:NO], @"levelFall2012017",
                    [NSNumber numberWithBool:NO], @"levelFall2012018",
                    [NSNumber numberWithBool:NO], @"levelFall2012019",
                    [NSNumber numberWithBool:NO], @"levelFall2012020",
                    [NSNumber numberWithBool:NO], @"levelFall2012021",
                    [NSNumber numberWithBool:NO], @"levelFall2012022",
                    [NSNumber numberWithBool:NO], @"levelFall2012023",
                    [NSNumber numberWithBool:NO], @"levelFall2012024",
                    [NSNumber numberWithBool:NO], @"levelFall2012025",
                    [NSNumber numberWithBool:NO], @"levelFall2012026",
                    
                    [NSNumber numberWithBool:NO], @"levelWinter2012001",
                    [NSNumber numberWithBool:NO], @"levelWinter2012002",
                    [NSNumber numberWithBool:NO], @"levelWinter2012003",
                    [NSNumber numberWithBool:NO], @"levelWinter2012004",
                    [NSNumber numberWithBool:NO], @"levelWinter2012005",
                    [NSNumber numberWithBool:NO], @"levelWinter2012006",
                    [NSNumber numberWithBool:NO], @"levelWinter2012007",
                    [NSNumber numberWithBool:NO], @"levelWinter2012008",
                    [NSNumber numberWithBool:NO], @"levelWinter2012009",
                    [NSNumber numberWithBool:NO], @"levelWinter2012010",
                    [NSNumber numberWithBool:NO], @"levelWinter2012011",
                    [NSNumber numberWithBool:NO], @"levelWinter2012012",
                    [NSNumber numberWithBool:NO], @"levelWinter2012013",
                    [NSNumber numberWithBool:NO], @"levelWinter2012014",
                    [NSNumber numberWithBool:NO], @"levelWinter2012015",
                    [NSNumber numberWithBool:NO], @"levelWinter2012016",
                    [NSNumber numberWithBool:NO], @"levelWinter2012017",
                    [NSNumber numberWithBool:NO], @"levelWinter2012018",
                    [NSNumber numberWithBool:NO], @"levelWinter2012019",
                    [NSNumber numberWithBool:NO], @"levelWinter2012020",
                    [NSNumber numberWithBool:NO], @"levelWinter2012021",
                    [NSNumber numberWithBool:NO], @"levelWinter2012022",
                    [NSNumber numberWithBool:NO], @"levelWinter2012023",
                    [NSNumber numberWithBool:NO], @"levelWinter2012024",
                    [NSNumber numberWithBool:NO], @"levelWinter2012025",
                    [NSNumber numberWithBool:NO], @"levelWinter2012026",
                
                    nil];

    _tempLevelPassed = [NSMutableDictionary dictionaryWithDictionary:_levelPassed];
    [_tempLevelPassed retain];
}

-(void)createLevelPassedInTimeDictionary {
    _levelPassedInTime = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithBool:NO], @"levelSpring2012001",
                    [NSNumber numberWithBool:NO], @"levelSpring2012002",
                    [NSNumber numberWithBool:NO], @"levelSpring2012003",
                    [NSNumber numberWithBool:NO], @"levelSpring2012004",
                    [NSNumber numberWithBool:NO], @"levelSpring2012005",
                    [NSNumber numberWithBool:NO], @"levelSpring2012006",
                    [NSNumber numberWithBool:NO], @"levelSpring2012007",
                    [NSNumber numberWithBool:NO], @"levelSpring2012008",
                    [NSNumber numberWithBool:NO], @"levelSpring2012009",
                    [NSNumber numberWithBool:NO], @"levelSpring2012010",
                    [NSNumber numberWithBool:NO], @"levelSpring2012011",
                    [NSNumber numberWithBool:NO], @"levelSpring2012012",
                    [NSNumber numberWithBool:NO], @"levelSpring2012013",
                    [NSNumber numberWithBool:NO], @"levelSpring2012014",
                    [NSNumber numberWithBool:NO], @"levelSpring2012015",
                    [NSNumber numberWithBool:NO], @"levelSpring2012016",
                    [NSNumber numberWithBool:NO], @"levelSpring2012017",
                    [NSNumber numberWithBool:NO], @"levelSpring2012018",
                    [NSNumber numberWithBool:NO], @"levelSpring2012019",
                    [NSNumber numberWithBool:NO], @"levelSpring2012020",
                    [NSNumber numberWithBool:NO], @"levelSpring2012021",
                    [NSNumber numberWithBool:NO], @"levelSpring2012022",
                    [NSNumber numberWithBool:NO], @"levelSpring2012023",
                    [NSNumber numberWithBool:NO], @"levelSpring2012024",
                    [NSNumber numberWithBool:NO], @"levelSpring2012025",
                    [NSNumber numberWithBool:NO], @"levelSpring2012026",
                    
                    [NSNumber numberWithBool:NO], @"levelSummer2012001",
                    [NSNumber numberWithBool:NO], @"levelSummer2012002",
                    [NSNumber numberWithBool:NO], @"levelSummer2012003",
                    [NSNumber numberWithBool:NO], @"levelSummer2012004",
                    [NSNumber numberWithBool:NO], @"levelSummer2012005",
                    [NSNumber numberWithBool:NO], @"levelSummer2012006",
                    [NSNumber numberWithBool:NO], @"levelSummer2012007",
                    [NSNumber numberWithBool:NO], @"levelSummer2012008",
                    [NSNumber numberWithBool:NO], @"levelSummer2012009",
                    [NSNumber numberWithBool:NO], @"levelSummer2012010",
                    [NSNumber numberWithBool:NO], @"levelSummer2012011",
                    [NSNumber numberWithBool:NO], @"levelSummer2012012",
                    [NSNumber numberWithBool:NO], @"levelSummer2012013",
                    [NSNumber numberWithBool:NO], @"levelSummer2012014",
                    [NSNumber numberWithBool:NO], @"levelSummer2012015",
                    [NSNumber numberWithBool:NO], @"levelSummer2012016",
                    [NSNumber numberWithBool:NO], @"levelSummer2012017",
                    [NSNumber numberWithBool:NO], @"levelSummer2012018",
                    [NSNumber numberWithBool:NO], @"levelSummer2012019",
                    [NSNumber numberWithBool:NO], @"levelSummer2012020",
                    [NSNumber numberWithBool:NO], @"levelSummer2012021",
                    [NSNumber numberWithBool:NO], @"levelSummer2012022",
                    [NSNumber numberWithBool:NO], @"levelSummer2012023",
                    [NSNumber numberWithBool:NO], @"levelSummer2012024",
                    [NSNumber numberWithBool:NO], @"levelSummer2012025",
                    [NSNumber numberWithBool:NO], @"levelSummer2012026",
                    
                    [NSNumber numberWithBool:NO], @"levelFall2012001",
                    [NSNumber numberWithBool:NO], @"levelFall2012002",
                    [NSNumber numberWithBool:NO], @"levelFall2012003",
                    [NSNumber numberWithBool:NO], @"levelFall2012004",
                    [NSNumber numberWithBool:NO], @"levelFall2012005",
                    [NSNumber numberWithBool:NO], @"levelFall2012006",
                    [NSNumber numberWithBool:NO], @"levelFall2012007",
                    [NSNumber numberWithBool:NO], @"levelFall2012008",
                    [NSNumber numberWithBool:NO], @"levelFall2012009",
                    [NSNumber numberWithBool:NO], @"levelFall2012010",
                    [NSNumber numberWithBool:NO], @"levelFall2012011",
                    [NSNumber numberWithBool:NO], @"levelFall2012012",
                    [NSNumber numberWithBool:NO], @"levelFall2012013",
                    [NSNumber numberWithBool:NO], @"levelFall2012014",
                    [NSNumber numberWithBool:NO], @"levelFall2012015",
                    [NSNumber numberWithBool:NO], @"levelFall2012016",
                    [NSNumber numberWithBool:NO], @"levelFall2012017",
                    [NSNumber numberWithBool:NO], @"levelFall2012018",
                    [NSNumber numberWithBool:NO], @"levelFall2012019",
                    [NSNumber numberWithBool:NO], @"levelFall2012020",
                    [NSNumber numberWithBool:NO], @"levelFall2012021",
                    [NSNumber numberWithBool:NO], @"levelFall2012022",
                    [NSNumber numberWithBool:NO], @"levelFall2012023",
                    [NSNumber numberWithBool:NO], @"levelFall2012024",
                    [NSNumber numberWithBool:NO], @"levelFall2012025",
                    [NSNumber numberWithBool:NO], @"levelFall2012026",
                    
                    [NSNumber numberWithBool:NO], @"levelWinter2012001",
                    [NSNumber numberWithBool:NO], @"levelWinter2012002",
                    [NSNumber numberWithBool:NO], @"levelWinter2012003",
                    [NSNumber numberWithBool:NO], @"levelWinter2012004",
                    [NSNumber numberWithBool:NO], @"levelWinter2012005",
                    [NSNumber numberWithBool:NO], @"levelWinter2012006",
                    [NSNumber numberWithBool:NO], @"levelWinter2012007",
                    [NSNumber numberWithBool:NO], @"levelWinter2012008",
                    [NSNumber numberWithBool:NO], @"levelWinter2012009",
                    [NSNumber numberWithBool:NO], @"levelWinter2012010",
                    [NSNumber numberWithBool:NO], @"levelWinter2012011",
                    [NSNumber numberWithBool:NO], @"levelWinter2012012",
                    [NSNumber numberWithBool:NO], @"levelWinter2012013",
                    [NSNumber numberWithBool:NO], @"levelWinter2012014",
                    [NSNumber numberWithBool:NO], @"levelWinter2012015",
                    [NSNumber numberWithBool:NO], @"levelWinter2012016",
                    [NSNumber numberWithBool:NO], @"levelWinter2012017",
                    [NSNumber numberWithBool:NO], @"levelWinter2012018",
                    [NSNumber numberWithBool:NO], @"levelWinter2012019",
                    [NSNumber numberWithBool:NO], @"levelWinter2012020",
                    [NSNumber numberWithBool:NO], @"levelWinter2012021",
                    [NSNumber numberWithBool:NO], @"levelWinter2012022",
                    [NSNumber numberWithBool:NO], @"levelWinter2012023",
                    [NSNumber numberWithBool:NO], @"levelWinter2012024",
                    [NSNumber numberWithBool:NO], @"levelWinter2012025",
                    [NSNumber numberWithBool:NO], @"levelWinter2012026",
                    
                    nil];
    
    _tempLevelPassedInTime = [NSMutableDictionary dictionaryWithDictionary:_levelPassedInTime];
    [_tempLevelPassedInTime retain];
}

-(void)createLevelPassedNoLivesLostDictionary {
    _levelPassedNoLivesLost = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithBool:YES], @"levelSpring2012001",
                          [NSNumber numberWithBool:YES], @"levelSpring2012002",
                          [NSNumber numberWithBool:YES], @"levelSpring2012003",
                          [NSNumber numberWithBool:YES], @"levelSpring2012004",
                          [NSNumber numberWithBool:YES], @"levelSpring2012005",
                          [NSNumber numberWithBool:YES], @"levelSpring2012006",
                          [NSNumber numberWithBool:YES], @"levelSpring2012007",
                          [NSNumber numberWithBool:YES], @"levelSpring2012008",
                          [NSNumber numberWithBool:YES], @"levelSpring2012009",
                          [NSNumber numberWithBool:YES], @"levelSpring2012010",
                          [NSNumber numberWithBool:YES], @"levelSpring2012011",
                          [NSNumber numberWithBool:YES], @"levelSpring2012012",
                          [NSNumber numberWithBool:YES], @"levelSpring2012013",
                          [NSNumber numberWithBool:YES], @"levelSpring2012014",
                          [NSNumber numberWithBool:YES], @"levelSpring2012015",
                          [NSNumber numberWithBool:YES], @"levelSpring2012016",
                          [NSNumber numberWithBool:YES], @"levelSpring2012017",
                          [NSNumber numberWithBool:YES], @"levelSpring2012018",
                          [NSNumber numberWithBool:YES], @"levelSpring2012019",
                          [NSNumber numberWithBool:YES], @"levelSpring2012020",
                          [NSNumber numberWithBool:YES], @"levelSpring2012021",
                          [NSNumber numberWithBool:YES], @"levelSpring2012022",
                          [NSNumber numberWithBool:YES], @"levelSpring2012023",
                          [NSNumber numberWithBool:YES], @"levelSpring2012024",
                          [NSNumber numberWithBool:YES], @"levelSpring2012025",
                          [NSNumber numberWithBool:YES], @"levelSpring2012026",
                               
                          [NSNumber numberWithBool:YES], @"levelSummer2012001",
                          [NSNumber numberWithBool:YES], @"levelSummer2012002",
                          [NSNumber numberWithBool:YES], @"levelSummer2012003",
                          [NSNumber numberWithBool:YES], @"levelSummer2012004",
                          [NSNumber numberWithBool:YES], @"levelSummer2012005",
                          [NSNumber numberWithBool:YES], @"levelSummer2012006",
                          [NSNumber numberWithBool:YES], @"levelSummer2012007",
                          [NSNumber numberWithBool:YES], @"levelSummer2012008",
                          [NSNumber numberWithBool:YES], @"levelSummer2012009",
                          [NSNumber numberWithBool:YES], @"levelSummer2012010",
                          [NSNumber numberWithBool:YES], @"levelSummer2012011",
                          [NSNumber numberWithBool:YES], @"levelSummer2012012",
                          [NSNumber numberWithBool:YES], @"levelSummer2012013",
                          [NSNumber numberWithBool:YES], @"levelSummer2012014",
                          [NSNumber numberWithBool:YES], @"levelSummer2012015",
                          [NSNumber numberWithBool:YES], @"levelSummer2012016",
                          [NSNumber numberWithBool:YES], @"levelSummer2012017",
                          [NSNumber numberWithBool:YES], @"levelSummer2012018",
                          [NSNumber numberWithBool:YES], @"levelSummer2012019",
                          [NSNumber numberWithBool:YES], @"levelSummer2012020",
                          [NSNumber numberWithBool:YES], @"levelSummer2012021",
                          [NSNumber numberWithBool:YES], @"levelSummer2012022",
                          [NSNumber numberWithBool:YES], @"levelSummer2012023",
                          [NSNumber numberWithBool:YES], @"levelSummer2012024",
                          [NSNumber numberWithBool:YES], @"levelSummer2012025",
                          [NSNumber numberWithBool:YES], @"levelSummer2012026",
                          
                          [NSNumber numberWithBool:YES], @"levelFall2012001",
                          [NSNumber numberWithBool:YES], @"levelFall2012002",
                          [NSNumber numberWithBool:YES], @"levelFall2012003",
                          [NSNumber numberWithBool:YES], @"levelFall2012004",
                          [NSNumber numberWithBool:YES], @"levelFall2012005",
                          [NSNumber numberWithBool:YES], @"levelFall2012006",
                          [NSNumber numberWithBool:YES], @"levelFall2012007",
                          [NSNumber numberWithBool:YES], @"levelFall2012008",
                          [NSNumber numberWithBool:YES], @"levelFall2012009",
                          [NSNumber numberWithBool:YES], @"levelFall2012010",
                          [NSNumber numberWithBool:YES], @"levelFall2012011",
                          [NSNumber numberWithBool:YES], @"levelFall2012012",
                          [NSNumber numberWithBool:YES], @"levelFall2012013",
                          [NSNumber numberWithBool:YES], @"levelFall2012014",
                          [NSNumber numberWithBool:YES], @"levelFall2012015",
                          [NSNumber numberWithBool:YES], @"levelFall2012016",
                          [NSNumber numberWithBool:YES], @"levelFall2012017",
                          [NSNumber numberWithBool:YES], @"levelFall2012018",
                          [NSNumber numberWithBool:YES], @"levelFall2012019",
                          [NSNumber numberWithBool:YES], @"levelFall2012020",
                          [NSNumber numberWithBool:YES], @"levelFall2012021",
                          [NSNumber numberWithBool:YES], @"levelFall2012022",
                          [NSNumber numberWithBool:YES], @"levelFall2012023",
                          [NSNumber numberWithBool:YES], @"levelFall2012024",
                          [NSNumber numberWithBool:YES], @"levelFall2012025",
                          [NSNumber numberWithBool:YES], @"levelFall2012026",
                          
                          [NSNumber numberWithBool:YES], @"levelWinter2012001",
                          [NSNumber numberWithBool:YES], @"levelWinter2012002",
                          [NSNumber numberWithBool:YES], @"levelWinter2012003",
                          [NSNumber numberWithBool:YES], @"levelWinter2012004",
                          [NSNumber numberWithBool:YES], @"levelWinter2012005",
                          [NSNumber numberWithBool:YES], @"levelWinter2012006",
                          [NSNumber numberWithBool:YES], @"levelWinter2012007",
                          [NSNumber numberWithBool:YES], @"levelWinter2012008",
                          [NSNumber numberWithBool:YES], @"levelWinter2012009",
                          [NSNumber numberWithBool:YES], @"levelWinter2012010",
                          [NSNumber numberWithBool:YES], @"levelWinter2012011",
                          [NSNumber numberWithBool:YES], @"levelWinter2012012",
                          [NSNumber numberWithBool:YES], @"levelWinter2012013",
                          [NSNumber numberWithBool:YES], @"levelWinter2012014",
                          [NSNumber numberWithBool:YES], @"levelWinter2012015",
                          [NSNumber numberWithBool:YES], @"levelWinter2012016",
                          [NSNumber numberWithBool:YES], @"levelWinter2012017",
                          [NSNumber numberWithBool:YES], @"levelWinter2012018",
                          [NSNumber numberWithBool:YES], @"levelWinter2012019",
                          [NSNumber numberWithBool:YES], @"levelWinter2012020",
                          [NSNumber numberWithBool:YES], @"levelWinter2012021",
                          [NSNumber numberWithBool:YES], @"levelWinter2012022",
                          [NSNumber numberWithBool:YES], @"levelWinter2012023",
                          [NSNumber numberWithBool:YES], @"levelWinter2012024",
                          [NSNumber numberWithBool:YES], @"levelWinter2012025",
                          [NSNumber numberWithBool:YES], @"levelWinter2012026",
                          
                          nil];
    
    _tempLevelPassedNoLivesLost = [NSMutableDictionary dictionaryWithDictionary:_levelPassedNoLivesLost];
    [_tempLevelPassedNoLivesLost retain];
}

/*
-(int)countDown {
   
    if(_countDown == nil) {
        _countDown = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInt:115], @"levelSpring2012001",
                    [NSNumber numberWithInt:116], @"levelSpring2012002",
                    [NSNumber numberWithInt:117], @"levelSpring2012003",
                    [NSNumber numberWithInt:118], @"levelSpring2012004",
                    [NSNumber numberWithInt:120], @"levelSpring2012005",
                    [NSNumber numberWithInt:120], @"levelSpring2012006",
                    [NSNumber numberWithInt:120], @"levelSpring2012007",
                    [NSNumber numberWithInt:120], @"levelSpring2012008",
                    [NSNumber numberWithInt:120], @"levelSpring2012009",
                    [NSNumber numberWithInt:120], @"levelSpring2012010",
                    [NSNumber numberWithInt:120], @"levelSpring2012011",
                    [NSNumber numberWithInt:120], @"levelSpring2012012",
                    [NSNumber numberWithInt:120], @"levelSpring2012013",
                    [NSNumber numberWithInt:120], @"levelSpring2012014",
                    [NSNumber numberWithInt:120], @"levelSpring2012015",
                    [NSNumber numberWithInt:120], @"levelSpring2012016",
                    [NSNumber numberWithInt:120], @"levelSpring2012017",
                    [NSNumber numberWithInt:120], @"levelSpring2012018",
                    [NSNumber numberWithInt:120], @"levelSpring2012019",
                    [NSNumber numberWithInt:120], @"levelSpring2012020",
                    [NSNumber numberWithInt:120], @"levelSpring2012021",
                    [NSNumber numberWithInt:120], @"levelSpring2012022",
                    [NSNumber numberWithInt:120], @"levelSpring2012023",
                    [NSNumber numberWithInt:120], @"levelSpring2012024",
                    [NSNumber numberWithInt:120], @"levelSpring2012025",
                    [NSNumber numberWithInt:120], @"levelSpring2012026",
                      
                    [NSNumber numberWithInt:120], @"levelSummer2012001",
                    [NSNumber numberWithInt:10], @"levelSummer2012002",
                    [NSNumber numberWithInt:120], @"levelSummer2012003",
                    [NSNumber numberWithInt:120], @"levelSummer2012004",
                    [NSNumber numberWithInt:120], @"levelSummer2012005",
                    [NSNumber numberWithInt:120], @"levelSummer2012006",
                    [NSNumber numberWithInt:120], @"levelSummer2012007",
                    [NSNumber numberWithInt:120], @"levelSummer2012008",
                    [NSNumber numberWithInt:120], @"levelSummer2012009",
                    [NSNumber numberWithInt:120], @"levelSummer2012010",
                    [NSNumber numberWithInt:120], @"levelSummer2012011",
                    [NSNumber numberWithInt:120], @"levelSummer2012012",
                    [NSNumber numberWithInt:120], @"levelSummer2012013",
                    [NSNumber numberWithInt:120], @"levelSummer2012014",
                    [NSNumber numberWithInt:120], @"levelSummer2012015",
                    [NSNumber numberWithInt:120], @"levelSummer2012016",
                    [NSNumber numberWithInt:120], @"levelSummer2012017",
                    [NSNumber numberWithInt:120], @"levelSummer2012018",
                    [NSNumber numberWithInt:120], @"levelSummer2012019",
                    [NSNumber numberWithInt:120], @"levelSummer2012020",
                    [NSNumber numberWithInt:120], @"levelSummer2012021",
                    [NSNumber numberWithInt:120], @"levelSummer2012022",
                    [NSNumber numberWithInt:120], @"levelSummer2012023",
                    [NSNumber numberWithInt:120], @"levelSummer2012024",
                    [NSNumber numberWithInt:120], @"levelSummer2012025",
                    [NSNumber numberWithInt:120], @"levelSummer2012026",
                    
                    [NSNumber numberWithInt:120], @"levelFall2012001",
                    [NSNumber numberWithInt:120], @"levelFall2012002",
                    [NSNumber numberWithInt:120], @"levelFall2012003",
                    [NSNumber numberWithInt:120], @"levelFall2012004",
                    [NSNumber numberWithInt:120], @"levelFall2012005",
                    [NSNumber numberWithInt:120], @"levelFall2012006",
                    [NSNumber numberWithInt:120], @"levelFall2012007",
                    [NSNumber numberWithInt:120], @"levelFall2012008",
                    [NSNumber numberWithInt:120], @"levelFall2012009",
                    [NSNumber numberWithInt:120], @"levelFall2012010",
                    [NSNumber numberWithInt:120], @"levelFall2012011",
                    [NSNumber numberWithInt:120], @"levelFall2012012",
                    [NSNumber numberWithInt:120], @"levelFall2012013",
                    [NSNumber numberWithInt:120], @"levelFall2012014",
                    [NSNumber numberWithInt:120], @"levelFall2012015",
                    [NSNumber numberWithInt:120], @"levelFall2012016",
                    [NSNumber numberWithInt:120], @"levelFall2012017",
                    [NSNumber numberWithInt:120], @"levelFall2012018",
                    [NSNumber numberWithInt:120], @"levelFall2012019",
                    [NSNumber numberWithInt:120], @"levelFall2012020",
                    [NSNumber numberWithInt:120], @"levelFall2012021",
                    [NSNumber numberWithInt:120], @"levelFall2012022",
                    [NSNumber numberWithInt:120], @"levelFall2012023",
                    [NSNumber numberWithInt:120], @"levelFall2012024",
                    [NSNumber numberWithInt:120], @"levelFall2012025",
                    [NSNumber numberWithInt:120], @"levelFall2012026",
                    
                    [NSNumber numberWithInt:120], @"levelWinter2012001",
                    [NSNumber numberWithInt:120], @"levelWinter2012002",
                    [NSNumber numberWithInt:120], @"levelWinter2012003",
                    [NSNumber numberWithInt:120], @"levelWinter2012004",
                    [NSNumber numberWithInt:120], @"levelWinter2012005",
                    [NSNumber numberWithInt:120], @"levelWinter2012006",
                    [NSNumber numberWithInt:120], @"levelWinter2012007",
                    [NSNumber numberWithInt:120], @"levelWinter2012008",
                    [NSNumber numberWithInt:120], @"levelWinter2012009",
                    [NSNumber numberWithInt:120], @"levelWinter2012010",
                    [NSNumber numberWithInt:120], @"levelWinter2012011",
                    [NSNumber numberWithInt:120], @"levelWinter2012012",
                    [NSNumber numberWithInt:120], @"levelWinter2012013",
                    [NSNumber numberWithInt:120], @"levelWinter2012014",
                    [NSNumber numberWithInt:120], @"levelWinter2012015",
                    [NSNumber numberWithInt:120], @"levelWinter2012016",
                    [NSNumber numberWithInt:120], @"levelWinter2012017",
                    [NSNumber numberWithInt:120], @"levelWinter2012018",
                    [NSNumber numberWithInt:120], @"levelWinter2012019",
                    [NSNumber numberWithInt:120], @"levelWinter2012020",
                    [NSNumber numberWithInt:120], @"levelWinter2012021",
                    [NSNumber numberWithInt:120], @"levelWinter2012022",
                    [NSNumber numberWithInt:120], @"levelWinter2012023",
                    [NSNumber numberWithInt:120], @"levelWinter2012024",
                    [NSNumber numberWithInt:120], @"levelWinter2012025",
                    [NSNumber numberWithInt:120], @"levelWinter2012026",
                    
                    nil];
        NSLog(@"+++ countDown - IF");
        [_countDown retain];
    } else {
        NSLog(@"+++ countDown - ELSE");
    }
    
    NSString* levelAsString = @"level";
    levelAsString = [levelAsString stringByAppendingString:[[GameManager sharedGameManager] seasonName]];
    NSString *sceneAsString = [NSString stringWithFormat:@"%d", [[GameManager sharedGameManager] currentScene]];
    levelAsString = [levelAsString stringByAppendingString:sceneAsString];
    
    NSLog(@"+++ _countDown: %d", [[_countDown objectForKey:levelAsString] intValue]);
    
    return [[_countDown objectForKey:levelAsString] intValue];
}
 */

-(BOOL)isPayingUser {
    return YES;
}

-(void)dealloc {
    [_tempLevelLocked release];
    [_tempLevelPassed release];
    [tempHighScore release];
    //[_countDown release];
    [super dealloc];
}

@end
