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

@class QQLevel;

@interface QQPauseLayer : LHLayer {
    LevelHelperLoader *_loaderPause;
    QQLevel *_mainLayer;
    
    LHSprite *_spriteBackButton;
    LHSprite *_spriteResumeButton;
    LHSprite *_spriteReloadButton;
    NSMutableArray *_arrayLoaders;
    
    BOOL isPauseLayerVisible;
}

+(id)sharedInstance;

-(void)pauseLevel:(QQLevel*)mainLayer;
-(void)disableTouchesWithLoader:(LevelHelperLoader*)loader;


@end
