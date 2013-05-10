//
//  QQPauseLayer.m
//  FunnyBunnyJump
//
//  Created by Que on 16.11.12.
//
//

#import "QQPauseLayer.h"
#import "GameManager.h"

static NSUInteger instances = 0;

@implementation QQPauseLayer

+(NSUInteger)numberOfInstances {
    return instances;
}

-(id)init
{
	if( (self=[super init])) {
        instances++;
	}
	return self;
}

-(void)pauseLevel:(LHLayer*)mainLayer withLevel:(id)level_{
    [[CCDirector sharedDirector] pause];
    
    _loaderPause = [[LevelHelperLoader alloc] initWithContentOfFile:@"pauseLayer1"];
    [_loaderPause addSpritesToLayer:mainLayer];
    
    _spriteBackButton = [_loaderPause spriteWithUniqueName:@"buttonBack"];
    [_spriteBackButton registerTouchBeganObserver:self selector:@selector(touchBeganBackButton:)];
    [_spriteBackButton registerTouchEndedObserver:self selector:@selector(touchEndedBackButton:)];
    
    _spriteResumeButton = [_loaderPause spriteWithUniqueName:@"buttonResume"];
    [_spriteResumeButton registerTouchBeganObserver:self selector:@selector(touchBeganResumeButton:)];
    [_spriteResumeButton registerTouchEndedObserver:self selector:@selector(touchEndedResumeButton:)];
    
    _spriteReloadButton = [_loaderPause spriteWithUniqueName:@"buttonReload"];
    [_spriteReloadButton registerTouchBeganObserver:self selector:@selector(touchBeganReloadButton:)];
    [_spriteReloadButton registerTouchEndedObserver:self selector:@selector(touchEndedReloadButton:)];
}

/*
-(id)init
{
	if( (self=[super init])) {
        instances++;
        
        _loaderPause = [[LevelHelperLoader alloc] initWithContentOfFile:@"pauseLayer1"];
        [_loaderPause addSpritesToLayer:self];
        
        _spriteBackButton = [_loaderPause spriteWithUniqueName:@"buttonBack"];
        [_spriteBackButton registerTouchBeganObserver:self selector:@selector(touchBeganBackButton:)];
        [_spriteBackButton registerTouchEndedObserver:self selector:@selector(touchEndedBackButton:)];
        
        _spriteResumeButton = [_loaderPause spriteWithUniqueName:@"buttonResume"];
        [_spriteResumeButton registerTouchBeganObserver:self selector:@selector(touchBeganResumeButton:)];
        [_spriteResumeButton registerTouchEndedObserver:self selector:@selector(touchEndedResumeButton:)];
        
        _spriteReloadButton = [_loaderPause spriteWithUniqueName:@"buttonReload"];
        [_spriteReloadButton registerTouchBeganObserver:self selector:@selector(touchBeganReloadButton:)];
        [_spriteReloadButton registerTouchEndedObserver:self selector:@selector(touchEndedReloadButton:)];
        
	}
	return self;
}

-(void)pauseLevel:(LHLayer*)mainLayer withLevel:(id)level_{
    [[CCDirector sharedDirector] pause];
    
}
 */

-(void)disableTouchesWithLoader:(LevelHelperLoader*)loader {
    //workaround because self.isTouchEnabled = NO; doesn't work for cocos2d 2.0
    //and setTouchesEnabled is only available on cocos2d 2.x
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
    [self.scheduler unscheduleAllSelectorsForTarget:self];
}

-(void)touchBeganBackButton:(LHTouchInfo*)info{
    if(info.sprite) {
    }
}

/*
 -(void)touchEndedBackButton:(LHTouchInfo*)info{
 if(info.sprite) {
 [[CCDirector sharedDirector] resume];
 [[GameManager sharedGameManager] runSceneWithID:kLevelChooser];
 [self release];
 }
 }
 
 -(void)touchEndedReloadButton:(LHTouchInfo*)info{
 if(info.sprite) {
 [[CCDirector sharedDirector] resume];
 [[GameManager sharedGameManager] runSceneWithID:[[GameManager sharedGameManager] currentScene]];
 [self release];
 }
 }
 */

-(void)touchEndedBackButton:(LHTouchInfo*)info{
    if(info.sprite) {
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"backLevel" object:nil];
        //        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"backLevel" object:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"backLevel" object:nil];
        
        //[[CCDirector sharedDirector] resume];
        [self removeFromParentAndCleanup:YES];
        [self release];
    }
}

-(void)touchBeganResumeButton:(LHTouchInfo*)info{
    if(info.sprite) {
    }
}

-(void)touchEndedResumeButton:(LHTouchInfo*)info{
    if(info.sprite) {
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"resumeLevel" object:nil];
        //        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"resumeLevel" object:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resumeLevel" object:nil];
        [[CCDirector sharedDirector] resume];
        [self removeFromParentAndCleanup:YES];
        [self release];
    }
}

-(void)touchBeganReloadButton:(LHTouchInfo*)info{
    if(info.sprite) {
        //[self.scheduler unscheduleAllSelectorsForTarget:self];
    }
}

-(void)touchEndedReloadButton:(LHTouchInfo*)info{
    if(info.sprite) {
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLevel" object:nil];
        //[self scheduleOnce:@selector(sendNotificationReloadLevel:) delay:0.25];
        //[self.scheduler unscheduleAllSelectorsForTarget:self];
        NSLog(@"... touch Ended");
        
        
//        [self.scheduler scheduleSelector:@selector(sendNotificationReloadLevel:)
//                               forTarget:self
//                                interval:-1
//                                  paused:NO
//                                  repeat:1
//                                   delay:0.25];
        

        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLevel" object:nil];
        //[[CCDirector sharedDirector] resume];
        //[self release];
        [self removeFromParentAndCleanup:YES];
        [self release];
    }
}

/*
-(void)sendNotificationReloadLevel:(ccTime)dt {
    NSLog(@"... send Notif");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLevel" object:nil];
}
 */

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
    instances--;
    [self enableTouchesForAllLoaders];
    [_loaderPause release];
    _loaderPause = nil;
    [super dealloc];
}
@end
