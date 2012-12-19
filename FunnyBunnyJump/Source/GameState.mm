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
     
    NSLog(@"--- WRITE BEGIN");   
    
    highScore = [NSDictionary dictionaryWithDictionary:tempHighScore];
    [encoder encodeObject:highScore forKey:@"highScore"];
    NSLog(@"---READ tempHighScore retainCount %d", [tempHighScore retainCount]);
    
    //is level Locked
    _levelLocked = [NSDictionary dictionaryWithDictionary:_tempLevelLocked];
    [encoder encodeObject:_levelLocked forKey:@"levelLocked"];
}

-(id)initWithCoder:(NSCoder *)decoder {
    //READ
    NSLog(@"--- READ BEGIN");
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
            NSLog(@"---- READ tempHighScore %@", tempHighScore);
            NSLog(@"---- READ tempHighScore retainCount %d", [tempHighScore retainCount]);
        }
        
        _levelLocked = [decoder decodeObjectForKey:@"levelLocked"];
        NSLog(@"---- READ _levelLocked:%@", _levelLocked);
        //if(_tempLevelLocked == nil) {
        //    NSLog(@"----READ _tempLevelLocked im IF");
        //    _tempLevelLocked = [NSMutableDictionary dictionaryWithDictionary:_levelLocked];
        //    [_tempLevelLocked retain];
        //}
        //[_levelLocked retain];
        
        _tempLevelLocked = [NSMutableDictionary dictionaryWithDictionary:_levelLocked];
        [_tempLevelLocked retain];
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

-(void)unlockNextLevel {
    NSLog(@"GameState --- %d", [[GameManager sharedGameManager] currentScene]);
    NSLog(@"GameState --- %@", [[GameManager sharedGameManager] seasonName]);
    NSLog(@"GameState next Scene --- %d", [[GameManager sharedGameManager] currentScene] + 1);
    
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
    
    NSLog(@"xxx %@", nextLevelAsString);
    //[[[GameState sharedInstance] tempLevelLocked] setObject:[NSNumber numberWithBool:NO] forKey:@"levelSpring2012002"];
    [_tempLevelLocked setObject:[NSNumber numberWithBool:NO] forKey:nextLevelAsString];
}

-(void)createLevelLockedDictionary {
    //if(_gameOnceStarted == NO) {
        //game is launched for the very first time
        NSLog(@"////// here I am");
        _levelLocked = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSNumber numberWithBool:NO], @"levelSpring2012001",
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

-(void)dealloc {
    [_tempLevelLocked release];
    [tempHighScore release];
    [super dealloc];
}

@end
