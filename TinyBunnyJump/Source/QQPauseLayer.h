//
//  QQPauseLayer.h
//  FunnyBunnyJump
//
//  Created by Que on 16.11.12.
//
//

#import "CCLayer.h"
#import "LevelHelperLoader.h"
#import "NSNotificationCenter+Utils.h"
#import "Constants.h"

@class QQLevel;

@interface QQPauseLayer : LHLayer {
    LevelHelperLoader *_loaderPause;
    QQLevel *_mainLayer;
    
    LHSprite *_spriteBackButton;
    LHSprite *_spriteResumeButton;
    LHSprite *_spriteReloadButton;
    NSMutableArray *_arrayLoaders;
    
    BOOL _pauseLayerVisible;
    stateMachine _levelState;
}

+(id)sharedInstance;

-(void)pauseLevel:(QQLevel*)mainLayer withLevelState:(stateMachine)levelState;
-(void)disableTouchesWithLoader:(LevelHelperLoader*)loader;
-(void)disableButtons;


@end
