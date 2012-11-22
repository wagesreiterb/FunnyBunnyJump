//
//  QQPauseLayer.h
//  FunnyBunnyJump
//
//  Created by Que on 16.11.12.
//
//

#import "CCLayer.h"
#import "LevelHelperLoader.h"


@interface QQPauseLayer : LHLayer {
    LevelHelperLoader *_loaderPause;
    
    LHSprite *_spriteBackButton;
    LHSprite *_spriteResumeButton;
    LHSprite *_spriteReloadButton;
    NSMutableArray *_arrayLoaders;
}

-(void)pauseLevel:(LHLayer*)mainLayer;
-(void)disableTouchesWithLoader:(LevelHelperLoader*)loader;


@end
