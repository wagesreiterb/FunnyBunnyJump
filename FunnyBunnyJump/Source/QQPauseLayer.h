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

@interface QQPauseLayer : LHLayer {
    LevelHelperLoader *_loaderPause;
    
    LHSprite *_spriteBackButton;
    LHSprite *_spriteResumeButton;
    LHSprite *_spriteReloadButton;
    NSMutableArray *_arrayLoaders;
}

+(NSUInteger)numberOfInstances;

-(void)pauseLevel:(LHLayer*)mainLayer withLevel:(id)level_;
-(void)disableTouchesWithLoader:(LevelHelperLoader*)loader;


@end
