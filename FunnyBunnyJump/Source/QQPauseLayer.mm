//
//  QQPauseLayer.m
//  FunnyBunnyJump
//
//  Created by Que on 16.11.12.
//
//

#import "QQPauseLayer.h"
#import "GameManager.h"

@implementation QQPauseLayer

-(void)pauseLevel:(LHLayer*)mainLayer {
    _loaderPause = [[LevelHelperLoader alloc] initWithContentOfFile:@"pauseLayer1"];
    [_loaderPause addSpritesToLayer:mainLayer];
    
    _spriteBackButton = [_loaderPause spriteWithUniqueName:@"buttonBack"];
    [_spriteBackButton registerTouchBeganObserver:self selector:@selector(touchBeganBackButton:)];
    
    _spriteResumeButton = [_loaderPause spriteWithUniqueName:@"buttonResume"];
    [_spriteResumeButton registerTouchBeganObserver:self selector:@selector(touchBeganResumeButton:)];
    
    _spriteReloadButton = [_loaderPause spriteWithUniqueName:@"buttonReload"];
    [_spriteReloadButton registerTouchBeganObserver:self selector:@selector(touchBeganReloadButton:)];
    
    [LevelHelperLoader setPaused:YES];
    [[CCDirector sharedDirector] pause];
}

-(void)disableTouchesWithLoader:(LevelHelperLoader*)loader {
    //workaround because self.isTouchEnabled = NO; doesn't work for cocos2d 2.0
    //and setTouchesEnabled is only available on cocos2d 2.irgendwas
    if(nil == _arrayLoaders) {
        _arrayLoaders = [NSMutableArray arrayWithObject:loader];
        [_arrayLoaders retain];
    } else {
        [_arrayLoaders addObject:loader];
    }
    NSArray *sprites = [loader allSprites];
    for(LHSprite *sprite in sprites) {
        [sprite setTouchesDisabled:YES];
    }
}

-(void)onEnter
{
	[super onEnter];
}

-(void)touchBeganBackButton:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"***** touchBeganBackButton");
        [LevelHelperLoader setPaused:NO];
        [[GameManager sharedGameManager] runSceneWithID:kLevelChooser];
    }
}

-(void)touchBeganResumeButton:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"***** touchBeganResumeButton");
        [LevelHelperLoader setPaused:NO];
        [[CCDirector sharedDirector] resume];
        [self release];
    }
}

-(void)touchBeganReloadButton:(LHTouchInfo*)info{
    if(info.sprite) {
        [[GameManager sharedGameManager] runSceneWithID:[[GameManager sharedGameManager] currentScene]];
        NSLog(@"***** touchBeganReloadButton");
    }
}

-(void)enableTouchesForAllLoaders {
    for(LevelHelperLoader *loader_ in _arrayLoaders) {
        NSArray *sprites = [loader_ allSprites];
        for(LHSprite *sprite in sprites) {
            [sprite setTouchesDisabled:NO];
        }
    }
    [_arrayLoaders release];
}

-(void)dealloc {
    NSLog(@"--- dealloc");
    [self enableTouchesForAllLoaders];
    [_loaderPause release];
    _loaderPause = nil;
    [super dealloc];
}
@end
