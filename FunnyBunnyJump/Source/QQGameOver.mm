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

-(void) onEnter
{
	[super onEnter];
}

-(void)showGameOverLayer:(LHLayer*)mainLayer
         withLevelPassed:(BOOL)levelPassed_
   withLevelPassedInTime:(BOOL)levelPassedInTime_
withPlayerLives:(int)playerLives_
               withScore:(int)score_
           withHighScore:(int)highScore_ {
    
    NSLog(@"------------------ 1. score: %d", score_);
    
    _mainLayer = mainLayer;
    _durationOfStarMove = 0.4f;
    _delayOfStarMove = 0.4f;
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0];
    
    [[GameState sharedInstance] setGamePausedGameOver:YES];
    
    _loaderGameOver = [[LevelHelperLoader alloc] initWithContentOfFile:@"overlayGameOver"];
    [_loaderGameOver addSpritesToLayer:mainLayer];
    
    _spriteBackButton = [_loaderGameOver spriteWithUniqueName:@"buttonBackBalloon"];
    [_spriteBackButton registerTouchBeganObserver:self selector:@selector(touchBeganBackButton:)];
    
    _spriteReloadButton = [_loaderGameOver spriteWithUniqueName:@"buttonReloadBalloon"];
    [_spriteReloadButton registerTouchBeganObserver:self selector:@selector(touchBeganReloadButton:)];
    
    _spriteNextButton = [_loaderGameOver spriteWithUniqueName:@"buttonNextBalloon"];
    if([[GameState sharedInstance] isNextLevelUnlocked] == NO || [[GameManager sharedGameManager] currentScene] == LAST_LEVEL) {
        [_spriteNextButton removeSelf];
    } else {
        [_spriteNextButton registerTouchBeganObserver:self selector:@selector(touchBeganNextButton:)];
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
    
    //draw all-time high
    [self drawAllTimeHigh:mainLayer];
    if(levelPassed_ == YES) [self drawScore:mainLayer withScore:score_];
    [self drawHighScore:mainLayer withScore:highScore_];
    
    //save records in GameCenter
    if([[GameState sharedInstance] isLevelPassed] == NO && levelPassed_ == YES) {
        [[GameState sharedInstance] setLevelPassed];
    }
    if([[GameState sharedInstance] isLevelPassedInTime] == NO && levelPassedInTime_ == YES) {
        [[GameState sharedInstance] setLevelPassedInTime];
    }
    if([[GameState sharedInstance] isLevelPassedWithNoLivesLost] == NO && playerLives_ == LIFES) {
        [[GameState sharedInstance] setLevelPassedWithNoLivesLost];
    }
    

    if(levelPassed_ == YES && score_ > highScore_) {
        //[self performSelector:@selector(tickNewHighScore:) withObject:nil afterDelay:_delayOfStarMove * 6];
        [self.scheduler scheduleSelector:@selector(tickNewHighScore:) forTarget:self interval:-1 paused:NO repeat:1 delay:_delayOfStarMove * 6];
    }
    
    //level Passed
    //show star for levelPassed
    if(levelPassed_ == YES) {
        //[[CCDirector sharedDirector] resume];
        //[LevelHelperLoader setPaused:NO];
        //[[CCDirector sharedDirector] startAnimation];
        //[[GameState sharedInstance] setGamePausedGameOver:NO];
        //[[GameState sharedInstance] setGamePausedByTurnOff:NO];
        
        LHSprite* starLevelPassed = [_loaderGameOver spriteWithUniqueName:@"starLevelPassed"];
        LHSprite* levelPassed = [_loaderGameOver spriteWithUniqueName:@"levelPassed"];
        [starLevelPassed setOpacity:255];
        _levelPassedPosition = [levelPassed position];

        
        
        //[self performSelector:@selector(tickLevelPassed:) withObject:nil afterDelay:_delayOfStarMove];
        //[[CCScheduler sharedScheduler] scheduleSelector:@selector(tickLevelPassed:) forTarget:self interval:0.0 paused:NO];
        //[self scheduleOnce:@selector(tickLevelPassed:) delay:_delayOfStarMove];
        
        //[self.scheduler scheduleSelector:(SEL) forTarget:(id) interval:(ccTime) paused:(BOOL) repeat:(uint) delay:(ccTime)];
        [self.scheduler scheduleSelector:@selector(tickLevelPassed:) forTarget:self interval:-1 paused:NO repeat:1 delay:_delayOfStarMove];
        
        NSLog(@"################### isRunning: %d", [self isRunning]);
        
        
        [starLevelPassed setUsesOverloadedTransformations:YES];
        id actionMove = [CCMoveTo actionWithDuration:_durationOfStarMove position:[levelPassed position]];
        [starLevelPassed runAction:actionMove];

        //[self scheduleOnce:@selector(tickLevelPassed:) delay:2];
        //[self schedule:@selector(tick:) interval:0.1f repeat:10 delay:0];

    }
    
    //In Time
    //show star for levelPassed
    if(levelPassedInTime_ == YES) {
        LHSprite* starLevelPassedInTime = [_loaderGameOver spriteWithUniqueName:@"starLevelPassedInTime"];
        [starLevelPassedInTime setOpacity:255];
        LHSprite* levelPassedInTime = [_loaderGameOver spriteWithUniqueName:@"passedWithinTime"];
        _levelPassedInTimePosition = [levelPassedInTime position];
        //[self performSelector:@selector(tickLevelPassedInTimeMoveStar:) withObject:nil afterDelay:_delayOfStarMove];
        //[self performSelector:@selector(tickLevelPassedInTime:) withObject:nil afterDelay:_delayOfStarMove + _durationOfStarMove];
        [self.scheduler scheduleSelector:@selector(tickLevelPassedInTimeMoveStar:) forTarget:self interval:-1 paused:NO repeat:1 delay:_delayOfStarMove];
        [self.scheduler scheduleSelector:@selector(tickLevelPassedInTime:) forTarget:self interval:-1 paused:NO repeat:1 delay:_delayOfStarMove + _durationOfStarMove];
    }
    
    //No Lives Lost
    if(playerLives_ == LIFES) {
        LHSprite* starLevelPassedWithNoLivesLost = [_loaderGameOver spriteWithUniqueName:@"starLevelPassedWithNoLivesLost"];
        [starLevelPassedWithNoLivesLost setOpacity:255];
        LHSprite* levelPassedWithNoLivesLost = [_loaderGameOver spriteWithUniqueName:@"passedWithNoLivesLost"];
        _levelPassedNoLivesLostPosition = [levelPassedWithNoLivesLost position];
        //[self performSelector:@selector(tickLevelPassedNoLivesLostMoveStar:) withObject:nil afterDelay:_delayOfStarMove * 2];
        //[self performSelector:@selector(tickLevelPassedNoLivesLost:) withObject:nil afterDelay:_delayOfStarMove * 2 + _durationOfStarMove];
        [self.scheduler scheduleSelector:@selector(tickLevelPassedNoLivesLostMoveStar:) forTarget:self interval:-1 paused:NO repeat:1 delay:_delayOfStarMove * 2];
        [self.scheduler scheduleSelector:@selector(tickLevelPassedNoLivesLost:) forTarget:self interval:-1 paused:NO repeat:1 delay:_delayOfStarMove * 2 + _durationOfStarMove];
    }
    

    if(levelPassed_) {
        [_labelLevelCleared setString:@"Level Cleared!"];
    } else {
        [_labelLevelCleared setString:@"Level Failed!"];
        //[self performSelector:@selector(tickLevelFailed:) withObject:nil afterDelay:_delayOfStarMove * 2];
        [self.scheduler scheduleSelector:@selector(tickLevelFailed:) forTarget:self interval:-1 paused:NO repeat:1 delay:_delayOfStarMove * 2];
    }
    
    [mainLayer addChild:_labelLevelCleared];
    
    //[LevelHelperLoader setPaused:YES];
    //[[CCDirector sharedDirector] pause];
}

-(void)drawScore:(LHLayer*)mainLayer withScore:(NSInteger)score_ {
    
    LHSprite* labelScoreSprite = [_loaderGameOver spriteWithUniqueName:@"labelScore"];
    
    NSString* textScore = @"";
    textScore = [textScore stringByAppendingString: [NSString stringWithFormat:@"%d", score_]];
    
    
    //CCLabelTTF *labelScore = [CCLabelTTF labelWithString:textScore fontName:@"Marker Felt" fontSize:16];
    CCLabelTTF *labelScore = [CCLabelTTF labelWithString:textScore
                                                  dimensions:CGSizeMake(480, 50)
                                                  hAlignment:kCCTextAlignmentCenter
                                                  vAlignment:kCCVerticalTextAlignmentCenter
                                                    fontName:@"Marker Felt"
                                                    fontSize:48];
    
    [labelScore setColor:ccc3(0,0,0)];
    [labelScore setPosition:labelScoreSprite.position];
    //[labelScore setVerticalAlignment:kCCVerticalTextAlignmentCenter];
    //[labelScore setHorizontalAlignment:kCCTextAlignmentLeft];
    [mainLayer addChild:labelScore];
}

-(void)drawHighScore:(LHLayer*)mainLayer withScore:(NSInteger)highScore_ {
    
    LHSprite* labelHighScoreSprite = [_loaderGameOver spriteWithUniqueName:@"labelHighScore"];
    
    NSString* textHighScore = @"best: ";
    textHighScore = [textHighScore stringByAppendingString: [NSString stringWithFormat:@"%d", highScore_]];
    
    //CCLabelTTF *labelHighScore = [CCLabelTTF labelWithString:textHighScore fontName:@"Marker Felt" fontSize:16];
    CCLabelTTF *labelHighScore = [CCLabelTTF labelWithString:textHighScore
                                                  dimensions:CGSizeMake(200, 50)
                                                  hAlignment:kCCTextAlignmentLeft
                                                  vAlignment:kCCVerticalTextAlignmentCenter
                                                    fontName:@"Marker Felt"
                                                    fontSize:16];
    
    [labelHighScore setColor:ccc3(0,0,0)];
    [labelHighScore setPosition:labelHighScoreSprite.position];
    [mainLayer addChild:labelHighScore ];
}

-(void)drawAllTimeHigh:(LHLayer*)mainLayer {
    
    /*
    LHSprite* allTimeHighTextSprite = [_loaderGameOver spriteWithUniqueName:@"allTimeHighText"];

//    CCLabelTTF *allTimeHighText = [CCLabelTTF labelWithString:@"all-time high"
//                                                      dimensions:CGSizeMake(200, 50)
//                                                      hAlignment:kCCTextAlignmentLeft
//                                                      vAlignment:kCCVerticalTextAlignmentCenter
//                                                        fontName:@"Marker Felt"
//                                                        fontSize:16];

    CCLabelTTF *allTimeHighText = [CCLabelTTF labelWithString:@"all-time high" fontName:@"Marker Felt" fontSize:16];
    
    NSLog(@"%f,  %f", allTimeHighText.texture.contentSize.width, allTimeHighText.texture.contentSize.height);
    
    [allTimeHighText setColor:ccc3(0,0,0)];
    [allTimeHighText setPosition:allTimeHighTextSprite.position];
    [allTimeHighText setVerticalAlignment:kCCVerticalTextAlignmentCenter];
    [allTimeHighText setHorizontalAlignment:kCCTextAlignmentRight];
    [mainLayer addChild:allTimeHighText];
    */
     
    //show all-time high stars - or not
    if([[GameState sharedInstance] isLevelPassed] == YES) {
        LHSprite* starAllTimeHighLevelPassed = [_loaderGameOver spriteWithUniqueName:@"starAllTimeHighLevelPassed"];
        [starAllTimeHighLevelPassed setVisible:YES];
    }
    if([[GameState sharedInstance] isLevelPassedInTime] == YES) {
        LHSprite* starAllTimeHighLevelPassedInTime = [_loaderGameOver spriteWithUniqueName:@"starAllTimeHighLevelPassedInTime"];
        [starAllTimeHighLevelPassedInTime setVisible:YES];
    }
    if([[GameState sharedInstance] isLevelPassedWithNoLivesLost] == YES) {
        LHSprite* starAllTimeHighLevelPassedNoLivesLost = [_loaderGameOver spriteWithUniqueName:@"starAllTimeHighLevelPassedNoLivesLost"];
        [starAllTimeHighLevelPassedNoLivesLost setVisible:YES];
    }
}


-(void)tickNewHighScore:(ccTime)dt {
    NSLog(@"__ tickNewHighScore");
    LHSprite* newHighScore = [_loaderGameOver spriteWithUniqueName:@"newHighScore"];
    [newHighScore setVisible:YES];
    [[SimpleAudioEngine sharedEngine] playEffect:@"jubilant-fanfare-3.mp3"];
}


-(void)tickLevelFailed:(ccTime)dt {
        [[SimpleAudioEngine sharedEngine] playEffect:@"cartoonFailure2.mp3"];
}

-(void)tickLevelPassed:(ccTime)dt {
    NSLog(@"__ tickLevelPassed");
    CCParticleSystemQuad* particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingStar5.plist"];
    [particle setPosition:_levelPassedPosition];
    [_mainLayer addChild:particle];
    [particle release];
    [[SimpleAudioEngine sharedEngine] playEffect:@"explosive-orchestra.mp3"];
}
-(void)tickLevelPassedInTime:(ccTime)dt {
    NSLog(@"__ tickLevelPassedInTime");
    CCParticleSystemQuad* particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingStar5.plist"];
    [particle setPosition:_levelPassedInTimePosition];
    [_mainLayer addChild:particle];
    [particle release];
    [[SimpleAudioEngine sharedEngine] playEffect:@"explosive-orchestra.mp3"];
}
-(void)tickLevelPassedNoLivesLost:(ccTime)dt {
    NSLog(@"__ tickLevelPassedNoLivesLost");
    CCParticleSystemQuad* particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingStar5.plist"];
    [particle setPosition:_levelPassedNoLivesLostPosition];
    [_mainLayer addChild:particle];
    [particle release];
    [[SimpleAudioEngine sharedEngine] playEffect:@"explosive-orchestra.mp3"];
}

-(void)tickLevelPassedInTimeMoveStar:(ccTime)dt {
    LHSprite* starLevelPassed = [_loaderGameOver spriteWithUniqueName:@"starLevelPassedInTime"];
    [starLevelPassed setUsesOverloadedTransformations:YES];
    id actionMove = [CCMoveTo actionWithDuration:_durationOfStarMove position:_levelPassedInTimePosition];
    [starLevelPassed runAction:actionMove];
}

-(void)tickLevelPassedNoLivesLostMoveStar:(ccTime)dt {
    LHSprite* starLevelPassed = [_loaderGameOver spriteWithUniqueName:@"starLevelPassedWithNoLivesLost"];
    [starLevelPassed setUsesOverloadedTransformations:YES];
    id actionMove = [CCMoveTo actionWithDuration:_durationOfStarMove position:_levelPassedNoLivesLostPosition];
    [starLevelPassed runAction:actionMove];
}

-(void)touchBeganBackButton:(LHTouchInfo*)info{
    if(info.sprite) {
        //NSLog(@"***** touchBeganBackButton");
        [[GameState sharedInstance] setGamePausedGameOver:NO];
        [[GameState sharedInstance] setGamePausedByTurnOff:NO];
        [[GameManager sharedGameManager] runSceneWithID:kLevelChooser];
        [self release];
    }
}

-(void)touchBeganReloadButton:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"***** touchBeganReloadButton");
        [[GameState sharedInstance] setGamePausedGameOver:NO];
        [[GameState sharedInstance] setGamePausedByTurnOff:NO];
        [[GameManager sharedGameManager] runSceneWithID:[[GameManager sharedGameManager] currentScene]];
        [self release];
    }
}

-(void)touchBeganNextButton:(LHTouchInfo*)info{
    if(info.sprite) {
        //NSLog(@"***** touchBeganNextButton");
        
        //NSString *nextSceneAsString = [NSString stringWithFormat:@"%d", [[GameManager sharedGameManager] currentScene] + 1];
        
        [[GameState sharedInstance] setGamePausedGameOver:NO];
        [[GameState sharedInstance] setGamePausedByTurnOff:NO];
        SceneTypes nextLevel = [[GameManager sharedGameManager] currentScene];
        nextLevel++;
        
        [[GameManager sharedGameManager] runSceneWithID:nextLevel];
        [self release];
    }
}

-(void)dealloc {
    NSLog(@"__GameOver::dealloc");
    //[self.scheduler scheduleSelector:@selector(tickNewHighScore:) forTarget:self interval:-1 paused:NO repeat:1 delay:_delayOfStarMove * 6];
    [self.scheduler unscheduleAllSelectors];
    
    [_loaderGameOver release];
    _loaderGameOver = nil;
    
    [[GameState sharedInstance] save];
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:volumeBackgroundMusic];
    
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
