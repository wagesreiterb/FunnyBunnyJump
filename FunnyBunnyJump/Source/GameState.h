//
//  GameState.h
//  FunnyBunnyJump
//
//  Created by Que on 28.10.12.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "GameManager.h"

@interface GameState : NSObject <NSCoding> {
    BOOL completedSeasonSpring2012;
    BOOL completedSeasonSummer2012;
    BOOL completedSeasonFall2012;
    BOOL completedSeasonWinter2012;
    
    NSDictionary *highScore;
    NSMutableDictionary *tempHighScore;
    
    //NSDictionary *levelLocked;
}

@property (assign) BOOL completedSeasonSpring2012;
@property (assign) BOOL completedSeasonSummer2012;
@property (assign) BOOL completedSeasonFall2012;
@property (assign) BOOL completedSeasonWinter2012;

@property (copy) NSDictionary *highScore;
@property (retain) NSMutableDictionary *tempHighScore;

@property (copy) NSDictionary *levelLocked;
@property (retain) NSMutableDictionary *tempLevelLocked;

@property (getter = isSoundEnabled) BOOL soundEnabled;
@property (getter = isMusicEnabled) BOOL musicEnabled;
@property BOOL gameOnceStarted;

+(GameState*)sharedInstance;
-(void)save;
//-(void)initDictionary;
//-(void)createLevelLockedDictionary;
//-(void)enableSoundAndMusic;
-(void)initGameState;
-(void)unlockNextLevel;
-(BOOL)isLevelLockedWithSeason:(NSString*)season_ andLevel:(int)level_;

@end
