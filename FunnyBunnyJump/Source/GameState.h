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
    
    int punkte;
}

+(GameState*)sharedInstance;
-(void)save;
//-(void)load;

@property (assign) BOOL completedSeasonSpring2012;
@property (assign) BOOL completedSeasonSummer2012;
@property (assign) BOOL completedSeasonFall2012;
@property (assign) BOOL completedSeasonWinter2012;

@property (assign) int punkte;

@end
