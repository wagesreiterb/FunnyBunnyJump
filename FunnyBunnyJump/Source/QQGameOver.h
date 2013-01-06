//
//  QQGameOver.h
//  FunnyBunnyJump
//
//  Created by Que on 18.12.12.
//
//

#import "LHLayer.h"
#import "LevelHelperLoader.h"

@interface QQGameOver : LHLayer {
    LHLayer* _mainLayer;
    CGPoint _levelPassedPosition;
    CGPoint _levelPassedInTimePosition;
    CGPoint _levelPassedNoLivesLostPosition;
    float _durationOfStarMove;
    float _delayOfStarMove;
}

//-(void)pauseLevel:(LHLayer*)mainLayer;
-(void)showGameOverLayer:(LHLayer*)mainLayer
         withLevelPassed:(BOOL)levelPassed_
   withLevelPassedInTime:(BOOL)levelPassedInTime_
         withPlayerLives:(int)playerLives_
               withScore:(int)score_
           withHighScore:(int)highScore_;

@end
