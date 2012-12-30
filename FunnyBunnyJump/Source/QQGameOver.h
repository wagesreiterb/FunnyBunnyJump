//
//  QQGameOver.h
//  FunnyBunnyJump
//
//  Created by Que on 18.12.12.
//
//

#import "LHLayer.h"
#import "LevelHelperLoader.h"

@interface QQGameOver : LHLayer

//-(void)pauseLevel:(LHLayer*)mainLayer;
-(void)showGameOverLayer:(LHLayer*)mainLayer
         withLevelPassed:(BOOL)levelPassed_
   withLevelPassedInTime:(BOOL)levelPassedInTime_;

@end
