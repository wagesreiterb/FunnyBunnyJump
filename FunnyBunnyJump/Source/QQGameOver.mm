//
//  QQGameOver.m
//  FunnyBunnyJump
//
//  Created by Que on 18.12.12.
//
//

#import "QQGameOver.h"
#import "GameManager.h"
#import "GameState.h"

@implementation QQGameOver

LevelHelperLoader *_loaderGameOver;

LHSprite *_spriteBackButton;
LHSprite *_spriteReloadButton;
LHSprite *_spriteNextButton;

/*
-(void)showGameOverLayer {
    //TODO: release xxLoader
    LevelHelperLoader* xxLoader = [[LevelHelperLoader alloc] initWithContentOfFile:@"overlayGameOver"];
    [xxLoader addObjectsToWorld:_world cocos2dLayer:self]; //creating the objects
}*/

-(void)pauseLevel:(LHLayer*)mainLayer {
    _loaderGameOver = [[LevelHelperLoader alloc] initWithContentOfFile:@"overlayGameOver"];
    [_loaderGameOver addSpritesToLayer:mainLayer];
    
    _spriteBackButton = [_loaderGameOver spriteWithUniqueName:@"buttonBackBalloon"];
    [_spriteBackButton registerTouchBeganObserver:self selector:@selector(touchBeganBackButton:)];
    
    _spriteReloadButton = [_loaderGameOver spriteWithUniqueName:@"buttonReloadBalloon"];
    [_spriteReloadButton registerTouchBeganObserver:self selector:@selector(touchBeganReloadButton:)];
    
    _spriteNextButton = [_loaderGameOver spriteWithUniqueName:@"buttonNextBalloon"];
    [_spriteNextButton registerTouchBeganObserver:self selector:@selector(touchBeganNextButton:)];
    
    [LevelHelperLoader setPaused:YES];
    [[CCDirector sharedDirector] pause];
    
    //NSLog(@"xxx --- %d", [[GameManager sharedGameManager] currentScene]);
    //NSLog(@"xxx --- %@", [[GameManager sharedGameManager] seasonName]);
    [[GameState sharedInstance] unlockNextLevel];
    

}

-(void)touchBeganBackButton:(LHTouchInfo*)info{
    if(info.sprite) {
        [[GameManager sharedGameManager] runSceneWithID:kLevelChooser];
        NSLog(@"***** touchBeganBackButton");
        [self release];
    }
}

-(void)touchBeganReloadButton:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"***** touchBeganReloadButton");
        [[GameManager sharedGameManager] runSceneWithID:[[GameManager sharedGameManager] currentScene]];
        [self release];
    }
}

-(void)touchBeganNextButton:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"***** touchBeganNextButton");
        [self release];
    }
}

-(void)dealloc {
    //NSLog(@"--- dealloc");
    //[self enableTouchesForAllLoaders];
    //[_loaderPause release];
    //_loaderPause = nil;
    [super dealloc];
}

@end
