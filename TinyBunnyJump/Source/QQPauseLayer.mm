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

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    
    NSLog(@"... sharedInstance");
    return _sharedObject;
}

-(id)init
{
	if( (self=[super init])) {
        _loaderPause = [[LevelHelperLoader alloc] initWithContentOfFile:@"pauseLayer1"];        
	}
	return self;
}

-(void)removeAllObjects:(QQLevel*)mainLayer {
    
}

//-(void)pauseLevel:(QQLevel*)mainLayer {
-(void)pauseLevel:(QQLevel*)mainLayer withLevelState:(stateMachine)levelState {
    NSLog(@"... pauseLevel");
    _levelState = levelState;
        NSLog(@"##### 1 _levelState: %d", _levelState);
    
    if(!_pauseLayerVisible) {
        _pauseLayerVisible = YES;

        _mainLayer = mainLayer;
        [[CCDirector sharedDirector] pause];
        
        //_loaderPause = [[LevelHelperLoader alloc] initWithContentOfFile:@"pauseLayer1"];
        [_loaderPause addSpritesToLayer:mainLayer];
        [_mainLayer disableTouchesForPause:TRUE];

        
        _spriteBackButton = [_loaderPause spriteWithUniqueName:@"buttonBack"];
        [_spriteBackButton registerTouchBeganObserver:self selector:@selector(touchBeganBackButton:)];
        [_spriteBackButton registerTouchEndedObserver:self selector:@selector(touchEndedBackButton:)];
        
        _spriteResumeButton = [_loaderPause spriteWithUniqueName:@"buttonResume"];
        [_spriteResumeButton registerTouchBeganObserver:self selector:@selector(touchBeganResumeButton:)];
        [_spriteResumeButton registerTouchEndedObserver:self selector:@selector(touchEndedResumeButton:)];
        
        _spriteReloadButton = [_loaderPause spriteWithUniqueName:@"buttonReload"];
        [_spriteReloadButton registerTouchBeganObserver:self selector:@selector(touchBeganReloadButton:)];
        [_spriteReloadButton registerTouchEndedObserver:self selector:@selector(touchEndedReloadButton:)];
        
        [[GameManager sharedGameManager] stopMusic];
    }
}

-(void)disableButtons {
    [_spriteBackButton setTouchesDisabled:YES];
    [_spriteResumeButton setTouchesDisabled:YES];
    [_spriteReloadButton setTouchesDisabled:YES];
}

//TODO: braucht das wer?!?! Wo wird _arrayLoaders gesetzt?!?!
-(void)disableTouchesWithLoader:(LevelHelperLoader*)loader {
    //workaround because self.isTouchEnabled = NO; doesn't work for cocos2d 2.0
    //and setTouchesEnabled is only available on cocos2d 2.x
    if(nil == _arrayLoaders) {
        _arrayLoaders = [NSMutableArray arrayWithObject:loader];
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
    [self.scheduler unscheduleAllForTarget:self];
}

-(void)touchBeganBackButton:(LHTouchInfo*)info{
    if(info.sprite) {
    }
}

-(void)touchBeganResumeButton:(LHTouchInfo*)info{
    if(info.sprite) {
    }
}

-(void)touchBeganReloadButton:(LHTouchInfo*)info{
    if(info.sprite) {
    }
}

-(void)touchEndedResumeButton:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"..... touchEndedResumeButton");

        [self removeFromParentAndCleanup:YES];
        [_mainLayer disableTouchesForPause:FALSE];
        //[_mainLayer setLevelState:levelRunning];

        NSArray *sprites = [_loaderPause allSprites];
        for(LHSprite *sprite in sprites) {
            [sprite removeSelf];
        }
        
        NSLog(@"##### 2 _levelState: %d", _levelState);
        [_mainLayer changeLevelStatus:_levelState withActionRequired:NO];
        [[CCDirector sharedDirector] resume];
        _mainLayer = nil;
        _pauseLayerVisible = NO;
        [[GameManager sharedGameManager] startMusic];
    }
}

-(void)touchEndedBackButton:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"+++++++++++++++++++++++++++++++++ touchEndedBackButton");
        [[CCDirector sharedDirector] resume];
        
        [self removeFromParentAndCleanup:YES];
        [_mainLayer makeObjectsStatic];
        [_mainLayer disableTouchesForPause:FALSE];
        [_mainLayer setBackLevel:YES];

        NSArray *sprites = [_loaderPause allSprites];
        for(LHSprite *sprite in sprites) {
            [sprite removeSelf];
        }

        _mainLayer = nil;
        _pauseLayerVisible = NO;
        [[GameManager sharedGameManager] startMusic];
    }
}

-(void)touchEndedReloadButton:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"+++++++++++++++++++++++++++++++++ touchEndedReloadButton");

        [self removeFromParentAndCleanup:YES];
        [_mainLayer makeObjectsStatic];
        [_mainLayer disableTouchesForPause:FALSE];
        [_mainLayer setReloadLevel:YES];
        
        NSArray *sprites = [_loaderPause allSprites];
        for(LHSprite *sprite in sprites) {
            [sprite removeSelf];
        }
        [[CCDirector sharedDirector] resume];
        _mainLayer = nil;
        _pauseLayerVisible = NO;
        [[GameManager sharedGameManager] startMusic];
    }
}

//-(void)enableTouchesForAllLoaders {
//    for(LevelHelperLoader *loader_ in _arrayLoaders) {
//        NSArray *sprites = [loader_ allSprites];
//        for(LHSprite *sprite in sprites) {
//            [sprite setTouchesDisabled:NO];
//        }
//    }
//}

-(void)dealloc {
    NSLog(@"..... pause::dealloc");
    //[self enableTouchesForAllLoaders];
    _loaderPause = nil;
}

//-(void)dealloc {
//    NSLog(@"..... pause::dealloc");
//    instances--;
//    [self enableTouchesForAllLoaders];
//    _loaderPause = nil;
//}
@end
