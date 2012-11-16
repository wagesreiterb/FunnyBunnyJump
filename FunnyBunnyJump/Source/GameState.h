//
//  GameState.h
//  FunnyBunnyJump
//
//  Created by Que on 28.10.12.
//
//

#import <Foundation/Foundation.h>

@interface GameState : NSObject <NSCoding> {
    BOOL completedSeasonSpring2012;
    BOOL completedSeasonSummer2012;
    BOOL completedSeasonFall2012;
    BOOL completedSeasonWinter2012;
    
    NSDictionary *highScore;
    NSMutableDictionary *tempHighScore;
}

+(GameState*)sharedInstance;
-(void)save;
//-(void)load;
-(void)initDictionary;


//-(int)getHighScoreForLevelWithKey:(NSString*)level;
//-(void)setHighScoreForLevelWithKey:(NSString*)level withHighScore:(int)highScore_;


@property (assign) BOOL completedSeasonSpring2012;
@property (assign) BOOL completedSeasonSummer2012;
@property (assign) BOOL completedSeasonFall2012;
@property (assign) BOOL completedSeasonWinter2012;

@property (copy) NSDictionary *highScore;
@property (retain) NSMutableDictionary *tempHighScore;

@end
