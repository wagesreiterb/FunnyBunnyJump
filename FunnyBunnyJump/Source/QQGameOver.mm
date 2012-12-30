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

-(void)showGameOverLayer:(LHLayer*)mainLayer
         withLevelPassed:(BOOL)levelPassed_
   withLevelPassedInTime:(BOOL)levelPassedInTime_{
    
    _loaderGameOver = [[LevelHelperLoader alloc] initWithContentOfFile:@"overlayGameOver"];
    [_loaderGameOver addSpritesToLayer:mainLayer];
    
    _spriteBackButton = [_loaderGameOver spriteWithUniqueName:@"buttonBackBalloon"];
    [_spriteBackButton registerTouchBeganObserver:self selector:@selector(touchBeganBackButton:)];
    
    _spriteReloadButton = [_loaderGameOver spriteWithUniqueName:@"buttonReloadBalloon"];
    [_spriteReloadButton registerTouchBeganObserver:self selector:@selector(touchBeganReloadButton:)];
    
    _spriteNextButton = [_loaderGameOver spriteWithUniqueName:@"buttonNextBalloon"];
    if([[GameState sharedInstance] isNextLevelUnlocked] || [[GameManager sharedGameManager] currentScene] != LAST_LEVEL) {
        [_spriteNextButton registerTouchBeganObserver:self selector:@selector(touchBeganNextButton:)];
    } else {
        [_spriteNextButton removeSelf];
    }
    
    //vAlignment:kCCVerticalTextAlignmentCenter
    LHSprite* spriteLevelCleared = [_loaderGameOver spriteWithUniqueName:@"labelLevelCleared"];
    CCLabelTTF *_labelLevelCleared = [CCLabelTTF labelWithString:@""
                                       dimensions:CGSizeMake(200, 50)
                                       hAlignment:kCCTextAlignmentCenter
                                       vAlignment:kCCVerticalTextAlignmentCenter
                                         fontName:@"Marker Felt"
                                         fontSize:32];
    [_labelLevelCleared setColor:ccc3(0,0,0)];
    [_labelLevelCleared setPosition:spriteLevelCleared.position];
    
    
    
    //level Passed
    //save new LevelPassed if level has been cleared
    if([[GameState sharedInstance] isLevelPassed] == NO && levelPassed_ == YES) {
        [[GameState sharedInstance] setLevelPassed];
        NSLog(@"__IF isLevelPassed");
        //[[GameState sharedInstance] save];
    } else {
        NSLog(@"__ELSE isLevelPassed");
    }
    //show star for levelPassed
    if([[GameState sharedInstance] isLevelPassed] == NO) {
        LHSprite* starLevelPassed = [_loaderGameOver spriteWithUniqueName:@"starLevelPassed"];
        [starLevelPassed setOpacity:0];
    }
    
    //In Time
    //save new LevelPassed if level has been cleared
    if([[GameState sharedInstance] isLevelPassedInTime] == NO && levelPassedInTime_ == YES) {
        [[GameState sharedInstance] setLevelPassedInTime];
         NSLog(@"__IF isLevelPassedInTime");
    } else {
         NSLog(@"__IF isLevelPassedInTime");
    }
    //show star for levelPassed
    if([[GameState sharedInstance] isLevelPassedInTime] == NO) {
        LHSprite* starLevelPassedInTime = [_loaderGameOver spriteWithUniqueName:@"starLevelPassedInTime"];
        [starLevelPassedInTime setOpacity:0];
    }
    

    if(levelPassed_) {
        [_labelLevelCleared setString:@"Level Cleared!"];
    } else {
        [_labelLevelCleared setString:@"Level Failed!"];
        
    }
    
    [mainLayer addChild:_labelLevelCleared];
    
    [LevelHelperLoader setPaused:YES];
    [[CCDirector sharedDirector] pause];

    //[[GameState sharedInstance] save];
}

-(void)touchBeganBackButton:(LHTouchInfo*)info{
    if(info.sprite) {
        //NSLog(@"***** touchBeganBackButton");
        [[GameManager sharedGameManager] runSceneWithID:kLevelChooser];
        [self release];
    }
}

-(void)touchBeganReloadButton:(LHTouchInfo*)info{
    if(info.sprite) {
        //NSLog(@"***** touchBeganReloadButton");
        [[GameManager sharedGameManager] runSceneWithID:[[GameManager sharedGameManager] currentScene]];
        [self release];
    }
}

-(void)touchBeganNextButton:(LHTouchInfo*)info{
    if(info.sprite) {
        //NSLog(@"***** touchBeganNextButton");
        
        //NSString *nextSceneAsString = [NSString stringWithFormat:@"%d", [[GameManager sharedGameManager] currentScene] + 1];
        
        SceneTypes nextLevel = [[GameManager sharedGameManager] currentScene];
        nextLevel++;
        
        [[GameManager sharedGameManager] runSceneWithID:nextLevel];
        [self release];
    }
}

-(void)dealloc {
    NSLog(@"__GameOver::dealloc");

    [_loaderGameOver release];
    _loaderGameOver = nil;
    
    [[GameState sharedInstance] save];
    
    [super dealloc];
}

@end



/*
 -(void)pauseLevel:(LHLayer*)mainLayer {
 _loaderGameOver = [[LevelHelperLoader alloc] initWithContentOfFile:@"overlayGameOver"];
 [_loaderGameOver addSpritesToLayer:mainLayer];
 
 _spriteBackButton = [_loaderGameOver spriteWithUniqueName:@"buttonBackBalloon"];
 [_spriteBackButton registerTouchBeganObserver:self selector:@selector(touchBeganBackButton:)];
 
 _spriteReloadButton = [_loaderGameOver spriteWithUniqueName:@"buttonReloadBalloon"];
 [_spriteReloadButton registerTouchBeganObserver:self selector:@selector(touchBeganReloadButton:)];
 
 _spriteNextButton = [_loaderGameOver spriteWithUniqueName:@"buttonNextBalloon"];
 if([[GameState sharedInstance] isNextLevelUnlocked] || [[GameManager sharedGameManager] currentScene] != LAST_LEVEL) {
 //if([[GameManager sharedGameManager] currentScene] != LAST_LEVEL) {
 [_spriteNextButton registerTouchBeganObserver:self selector:@selector(touchBeganNextButton:)];
 } else {
 [_spriteNextButton removeSelf];
 }
 
 [LevelHelperLoader setPaused:YES];
 [[CCDirector sharedDirector] pause];
 
 //NSLog(@"xxx --- %d", [[GameManager sharedGameManager] currentScene]);
 //NSLog(@"xxx --- %@", [[GameManager sharedGameManager] seasonName]);
 //[[GameState sharedInstance] unlockNextLevel];
 
 }
 */
