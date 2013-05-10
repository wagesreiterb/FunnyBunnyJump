//
//  QQLevel.mm
//  presentation
//
//  Created by Bogdan Vladu on 15.03.2011.
//
// Import the interfaces
#define MOVE_POINTS_PER_SECOND 80.0

#import "QQLevel.h"

const float32 FIXED_TIMESTEP = 1.0f / 60.0f;
const float32 MINIMUM_TIMESTEP = 1.0f / 600.0f;  
const int32 VELOCITY_ITERATIONS = 8;
const int32 POSITION_ITERATIONS = 8;
const int32 MAXIMUM_NUMBER_OF_STEPS = 25;

@implementation QQLevel

-(void)afterStep {
    // process collisions and result from callbacks called by the step
}

-(void)makeObjectsStatic {
    LHSprite *shade = [LHSprite spriteWithName:@"blackRectangle"    //blende für transitions
                                  fromSheet:@"assets"
                                     SHFile:@"objects"];
    CGSize size = [[CCDirector sharedDirector] winSize];
    [shade setPosition:ccp(size.width/2, size.height/2)];
    [shade setOpacity:OPACITY_OF_SHADE];
    [shade setScale:SCALE_OF_SHADE];
    [self addChild:shade];
    
    
    [_player makeStatic];
    [_trampoline makeStatic];
    
    NSArray *bars = [loader spritesWithTag:TAG_BAR];
    for(QQSpriteBar *bar in bars) {
        [bar makeStatic];
    }
    
    NSArray *balloonsNormal = [loader spritesWithTag:TAG_BALLOON];
    for(QQSpriteBalloon *balloon in balloonsNormal) {
        [balloon makeStatic];
    }
    
    NSArray *balloonsShaker = [loader spritesWithTag:TAG_BALLOON_SHAKER];
    for(QQSpriteBalloonShake *balloon in balloonsShaker) {
        [balloon makeStatic];
    }
    
    NSArray *balloonsSizechanger = [loader spritesWithTag:TAG_BALLOON_SIZECHANGER];
    for(QQSpriteBalloonShake *balloon in balloonsSizechanger) {
        [balloon makeStatic];
    }
    
    NSArray *balloonsThreetimestoucher = [loader spritesWithTag:TAG_BALLOON_THREETIMESTOUCHER];
    for(QQSpriteBalloonThreetimestoucher *balloon in balloonsThreetimestoucher) {
        [balloon unscheduleAllSelectors];
        [balloon makeStatic];
    }
    
    NSArray *balloonsBlinker = [loader spritesWithTag:TAG_BALLOON_BLINKER];
    for(QQSpriteBalloonBlinker *balloon in balloonsBlinker) {
        [balloon unscheduleAllSelectors];
        [balloon makeStatic];
    }
    
    [_particleBeam1 removeFromParentAndCleanup:YES];
    [_particleBeam2 removeFromParentAndCleanup:YES];
}

-(void)makeObjectsInvisibleAndStatic {
    if(_shallObejctsBeRemoved) {
        [_player makeInvisibleAndStaitc:loader];
        [_trampoline makeStatic];
        [_trampoline setVisible:NO];
        
        NSArray *bars = [loader spritesWithTag:TAG_BAR];
        for(QQSpriteBar *bar in bars) {
            [bar makeStatic];
            [bar setVisible:NO];
        }
                
        NSArray *balloonsNormal = [loader spritesWithTag:TAG_BALLOON];
        for(QQSpriteBalloon *balloon in balloonsNormal) {
            [balloon makeStatic];
            [balloon setVisible:NO];
        }
        
        NSArray *balloonsShaker = [loader spritesWithTag:TAG_BALLOON_SHAKER];
        for(QQSpriteBalloonShake *balloon in balloonsShaker) {
            [balloon makeStatic];
            [balloon setVisible:NO];
        }
        
        NSArray *balloonsSizechanger = [loader spritesWithTag:TAG_BALLOON_SIZECHANGER];
        for(QQSpriteBalloonShake *balloon in balloonsSizechanger) {
            [balloon makeStatic];
            [balloon setVisible:NO];
        }
        
        NSArray *balloonsThreetimestoucher = [loader spritesWithTag:TAG_BALLOON_THREETIMESTOUCHER];
        for(QQSpriteBalloonThreetimestoucher *balloon in balloonsThreetimestoucher) {
            [balloon unscheduleAllSelectors];
            [balloon makeStatic];
            [balloon setVisible:NO];
        }
        
        NSArray *balloonsBlinker = [loader spritesWithTag:TAG_BALLOON_BLINKER];
        for(QQSpriteBalloonBlinker *balloon in balloonsBlinker) {
            [balloon unscheduleAllSelectors];
            [balloon makeStatic];
            [balloon setVisible:NO];
        }
        
        [_particleBeam1 removeFromParentAndCleanup:YES];
        [_particleBeam2 removeFromParentAndCleanup:YES];
    }
}

-(void)afterStep:(ccTime)dt {
	// process collisions and result from callbacks called by the step
    
    //NSLog(@".................... .. numberOfInstacnes: %d", [QQSpriteBalloon numberOfInstances]);

    [self makeObjectsInvisibleAndStatic];

    //if(nil == _pauseLayer && [[GameState sharedInstance] gamePausedByTurnOff] == YES) {
    //    NSLog(@"************************ here I am!");
    //    _pauseLayer = [[QQPauseLayer alloc] init];
    //    [_pauseLayer disableTouchesWithLoader:loader];
    //}
    
    
    if(_levelState == levelRunning && _countDown > 0) {
        _countDown -= dt;
    }
    if(_countDown < 0) _countDown = 0;
    
    [self updateLabelCountdown];
    [self updateLabelScore];
    [self updateLabelHighScore];
    //[self updateEffectHighScore];
       
    [_player applyForce];
    [_player deflect];   //give the bunny a force when a balloon is touched
    //[_player resetPosition];
    //[_player resetPosition:self];
    if(_levelState == levelRunning) {
        //[_player applyStartJump];
        //[_player applyStartJumpWithGravity:_gravity];
        [_player applyStartJumpWithImpulseX:_startImpulseX withImpulseY:_startImpulseY];
    }
    
    
    //[_player restoreInitialPosition:loader];
    [_player restoreInitialPosition:loader withLayer:self];
    
    
    [_player stopPlayer];
    //[_player beam];
    [_player beamWithLoader:loader];
    //[_player upOrDownAction:_earLeft withEarRight:_earRight withHandLeft:_handLeft withHandRight:_handRight];
    [_player upOrDownActionWithLoader:loader];
    
    [_trampoline move:dt];
    [_trampoline setRestitutionAtTick];
    
    //[_bar updateBar:dt];
    NSArray *bars = [loader spritesWithTag:TAG_BAR];
    for(QQSpriteBar *bar in bars) {
            [bar updateBar:dt];
    }
    
    NSInteger balloonsLeft = 0;
    
//    NSArray *balloonsNormal = [loader spritesWithTag:TAG_BALLOON];
//    for(QQSpriteBalloon *balloon in balloonsNormal) {
//        [balloon reactToTouch:_world withLayer:self];
//        balloonsLeft++;
//        if([balloon myDirty] == YES) {
//            NSLog(@"IF removeSelf");
//            _balloonsDestroyed++;
//            [balloon removeSelf];
//        }
//    }
//    NSArray *balloonsShaker = [loader spritesWithTag:TAG_BALLOON_SHAKER];
//    for(QQSpriteBalloonShake *balloon in balloonsShaker) {
//        [balloon reactToTouch:_world withLayer:self];
//        balloonsLeft++;
//        if([balloon myDirty] == YES) {
//            _balloonsDestroyed++;
//            [balloon removeSelf];
//        }
//    }
    
    NSArray *balloonsNormal = [loader spritesWithTag:TAG_BALLOON];
    for(QQSpriteBalloon *balloon in balloonsNormal) {
        //[balloon reactToTouch:_world withLayer:self];
        _score = [balloon reactToTouch:_world withLayer:self withScore:_score withCountdown:_countDown];
        balloonsLeft++;
    }

    NSArray *balloonsShaker = [loader spritesWithTag:TAG_BALLOON_SHAKER];
    for(QQSpriteBalloonShake *balloon in balloonsShaker) {
        //[balloon reactToTouch:_world withLayer:self];
        _score = [balloon reactToTouch:_world withLayer:self withScore:_score withCountdown:_countDown];
        balloonsLeft++;
    }
    
    NSArray *balloonsSizechanger = [loader spritesWithTag:TAG_BALLOON_SIZECHANGER];
    for(QQSpriteBalloonShake *balloon in balloonsSizechanger) {
        //[balloon reactToTouch:_world withLayer:self];
        _score = [balloon reactToTouch:_world withLayer:self withScore:_score withCountdown:_countDown];
        balloonsLeft++;
    }
    
    NSArray *balloonsThreetimestoucher = [loader spritesWithTag:TAG_BALLOON_THREETIMESTOUCHER];
    for(QQSpriteBalloonThreetimestoucher *balloon in balloonsThreetimestoucher) {
        if(balloon._balloonCompletelyInflated == YES) {
            //[balloon reactToTouchWithWorld:_world withLayer:self];
            _score = [balloon reactToTouch:_world withLayer:self withScore:_score withCountdown:_countDown];
        }
        balloonsLeft++;
    }
    
    NSArray *balloonsBlinker = [loader spritesWithTag:TAG_BALLOON_BLINKER];
    for(QQSpriteBalloonBlinker *balloon in balloonsBlinker) {
        //[balloon reactToTouch:_world withLayer:self];
        _score = [balloon reactToTouch:_world withLayer:self withScore:_score withCountdown:_countDown];
        //_score += _countDown;
        balloonsLeft++;
    }
    
    if(_tapScreenButtonMakeDynamicRequired) {
        [_tapScreenButton transformPosition:_tapScreenButtonInitialPosition];
        [_tapScreenButton makeDynamic];
        _tapScreenButtonMakeDynamicRequired = NO;
    }
     
    
    //level completed
    if(balloonsLeft == 0 && _gameOverLevelPassed == NO) {
    //if(balloonsLeft == 0) {
        NSLog(@"___ balloonsLeft==0");
        _gameOverLevelPassed = YES;
        [self changeLevelStatus:levelGameOver];
    }
    
    
    if(_backLevel == YES) {
        NSLog(@"_backLevel");
        [[GameManager sharedGameManager] runSceneWithID:kLevelChooser];
        _backLevel = NO;
    }
    
    if(_reloadLevel == YES) {
        NSLog(@"_reloadLevel");
        [[GameManager sharedGameManager] runSceneWithID:[[GameManager sharedGameManager] currentScene]];
        _reloadLevel = NO;
    }
    
    LHSprite* fireBar = [loader spriteWithUniqueName:@EFFECT_FIREBAR];
    if(_particleFireBar != nil) {
        //_particleFireBar = [[CCParticleSystemQuad alloc] initWithFile:@"particleFireBar.plist"];
        
        CGPoint particleFireBarPosition;
        particleFireBarPosition.x = [fireBar position].x;
        particleFireBarPosition.y = [fireBar position].y;
        [_particleFireBar setPosition:particleFireBarPosition];
    }
}

- (void)backLevel:(NSNotification *)note {
    NSLog(@"||||||||||   Received Notification - backLevel");
    [[CCDirector sharedDirector] resume];
    [self makeObjectsStatic];
    _backLevel = YES;
}

- (void)reloadLevel:(NSNotification *)note {
    NSLog(@"||||||||||   Received Notification - reloadLevel");
    

    [[CCDirector sharedDirector] resume];
    [self makeObjectsStatic];
    _reloadLevel = YES;
}

- (void)resumeLevel:(NSNotification *)note {
    NSLog(@"||||||||||   Received Notification - resumeLevel");
    [self enableTouches];
}
/*
- (void)pauseLevel:(NSNotification *)note {
    NSLog(@"||||||||||   Received Notification - pauseLevel");
    NSLog(@"||||||||||   numberOfInstances: %d", [QQPauseLayer numberOfInstances]);
    
    QQPauseLayer* pause = [[[QQPauseLayer alloc] init] autorelease];
    [self addChild:pause z:100];
    [pause pauseLevel:self withLevel:self];
    
    [[CCDirector sharedDirector] pause];
    [self disableTouches];
    NSLog(@"||||||||||   numberOfInstances: %d", [QQPauseLayer numberOfInstances]);
}

-(void)touchBeganPauseButton:(LHTouchInfo*)info{
    if(info.sprite) {
        QQPauseLayer* pause = [[[QQPauseLayer alloc] init] autorelease];
        [self addChild:pause z:100];
        [pause pauseLevel:self withLevel:self];
        [self disableTouches];
    }
}
 */

- (void)pauseLevel:(NSNotification *)note {
    NSLog(@"||||||||||   Received Notification - pauseLevel");
    NSLog(@"||||||||||   numberOfInstances: %d", [QQPauseLayer numberOfInstances]);
    if([QQPauseLayer numberOfInstances] == 0) {
        _pauseLayer = [[QQPauseLayer alloc] init];
        [_pauseLayer pauseLevel:self withLevel:self];
    }
    [[CCDirector sharedDirector] pause];
    [self disableTouches];
    NSLog(@"||||||||||   numberOfInstances: %d", [QQPauseLayer numberOfInstances]);
}
 
-(void)touchBeganPauseButton:(LHTouchInfo*)info{
    if(info.sprite) {
        _pauseLayer = [[QQPauseLayer alloc] init];
        [_pauseLayer pauseLevel:self withLevel:self];
        [self disableTouches];
    }
}
 
-(void)touchEndedPauseButton:(LHTouchInfo*)info{
    if(info.sprite) {
    }
}

-(void)changeLevelStatus:(levelStates)levelStatus_ {
    switch (levelStatus_) {
        case levelNotStarted: {
            //level has not started unit now
            _levelState = levelNotStarted;

            NSLog(@"_______ levelNotStarted: %@", self);

            
            //QQQ[[CCDirector sharedDirector] resume];
            _gameOverLevelPassed = NO;
            _highScore = [[[[GameState sharedInstance] tempHighScore] objectForKey:[[GameManager sharedGameManager] levelToRun]] intValue];
            break;
        }
            
        case levelRunning: {
            //the level is currently running
            NSLog(@"################### isRunning level: %d", [self isRunning]);
            if(![[GameState sharedInstance] isPayingUser]) {
                [_myAdmob dismissAdView];
            }
            
            [_player makeDynamic];
            _levelState = levelRunning; //TODO: was soll das bitte???

            [_tapScreenButton setTouchesDisabled:YES];
            [_tapScreenButton setVisible:NO];

            NSArray *barsShaker = [loader spritesWithTag:TAG_BAR_SHAKER];
            for(QQSpriteBarShaker *bar in barsShaker) {
                [bar setToSensor:NO];
            }
            
            NSArray *balloonsBlack = [loader spritesWithTag:TAG_OBSTACLE];
            for(QQSpriteBar *balloonBlack in balloonsBlack) {
                for (b2Fixture* f = [balloonBlack body]->GetFixtureList(); f; f = f->GetNext()) {
                    f->SetSensor(false);
                }
            }
            
            break;
        }
            
        case levelGameOver: {
            //player has finished the game
            //ether he won or he lost
            _levelState = levelGameOver;
            if(_gameOverLevelPassed) {
                NSLog(@"_______ _gameOverLevelPassed: %@", self);
                
                //[[CCDirector sharedDirector] pause];
                [[GameState sharedInstance] unlockNextLevel];
                
                BOOL levelPassedInTime;
                if(_countDown > 0) {
                    levelPassedInTime = YES;
                } else {
                    levelPassedInTime = NO;
                }
                
                [self disableTouches];
                //[_player makeStatic];
                //[_player setOpacity:0];
                [_player makeInvisibleAndStaitc:loader];
                
                _levelState = levelNotStarted;
                
                //_gameOverLayer = [[[QQGameOver alloc] init] autorelease];
                //TODO: alloc init -  but no release?!?
                _gameOverLayer = [[QQGameOver alloc] init];
                [_gameOverLayer showGameOverLayer:self
                                  withLevelPassed:YES
                            withLevelPassedInTime:levelPassedInTime
                                  withPlayerLives:_player.lifes
                                        withScore:_score
                                    withHighScore:_highScore];
                
                _shallObejctsBeRemoved = YES;
                [self saveGameState];
                
            } else {
                //[[CCDirector sharedDirector] pause];

                [self disableTouches];
                
                
                //_gameOverLayer = [[[QQGameOver alloc] init] autorelease];
                _gameOverLayer = [[QQGameOver alloc] init];
                [_gameOverLayer showGameOverLayer:self
                                  withLevelPassed:NO
                            withLevelPassedInTime:NO
                                  withPlayerLives:_player.lifes
                                        withScore:_score
                                    withHighScore:_highScore];
                
                //[_player makeInvisibleAndStaitc:loader];
                _shallObejctsBeRemoved = YES;
                
            }
            [self removeLife];
            
            break;
        }
            
        case levelPausedLifeLost: {
            NSLog(@"_______________ levelPausedLifeLost");
            
            if(![[GameState sharedInstance] isPayingUser]) {
                _myAdmob = [QQAdmob node];
                [self addChild:_myAdmob];
            }

            _levelState = levelPausedLifeLost;
            [_player setRestoreInitialPostitionRequired:YES];
            [_player setPlayerStopped:YES];

            [_tapScreenButton setTouchesDisabled:NO];
            [_tapScreenButton setVisible:YES];
            _tapScreenButtonMakeDynamicRequired = YES;
            
            NSArray *balloonsBlack = [loader spritesWithTag:TAG_OBSTACLE];
            for(QQSpriteBar *balloonBlack in balloonsBlack) {
                for (b2Fixture* f = [balloonBlack body]->GetFixtureList(); f; f = f->GetNext()) {
                    f->SetSensor(true);
                }
            }

            NSArray *barsShaker = [loader spritesWithTag:TAG_BAR_SHAKER];
            for(QQSpriteBarShaker *bar in barsShaker) {
                [bar setToSensor:YES];
            }

            
            [self removeLife];
            
        }
            break;
            
        case levelPaused:
            //level is pause, what else?
            _levelState = levelPaused;
            break;
            
        default:
            break;
    }
}

/*
-(void)disableTouches {
    [_tapScreenButton setTouchesDisabled:YES];
    [_spritePauseButton setTouchesDisabled:YES];
}
 */

-(void)disableTouches {
    //workaround because self.isTouchEnabled = NO; doesn't work for cocos2d 2.0
    //and setTouchesEnabled is only available on cocos2d 2.irgendwas
    NSArray *sprites = [loader allSprites];
    for(LHSprite *sprite in sprites) {
        [sprite setTouchesDisabled:YES];
    }
    NSArray *spritesJoystick = [loaderJoystick allSprites];
    for(LHSprite *sprite in spritesJoystick) {
        [sprite setTouchesDisabled:YES];
    }
    
    //NSLog(@"__--__ 2.pauseLevel");
    //[self enableTouches];
}

-(void)enableTouches {
    //workaround because self.isTouchEnabled = NO; doesn't work for cocos2d 2.0
    //and setTouchesEnabled is only available on cocos2d 2.irgendwas
    NSLog(@"__--__ 2.pauseLevel");
    NSArray *sprites = [loader allSprites];
    for(LHSprite *sprite in sprites) {
        [sprite setTouchesDisabled:NO];
    }
    NSArray *spritesJoystick = [loaderJoystick allSprites];
    for(LHSprite *sprite in spritesJoystick) {
        [sprite setTouchesDisabled:NO];
    }
}

-(void)removeLife {
    
    switch (_player.lifes) {
        case 2: {
            LHSprite* life = [loaderJoystick spriteWithUniqueName:@"bunny_lifes_3"];
            [life removeSelf];
            break;
        }
        case 1: {
            LHSprite* life = [loaderJoystick spriteWithUniqueName:@"bunny_lifes_2"];
            [life removeSelf];
            break;
        }
        case 0: {
            LHSprite* life = [loaderJoystick spriteWithUniqueName:@"bunny_lifes_1"];
            [life removeSelf];
            break;
        }
 
        default:
            break;
    }
}

-(void)touchEndedTapScreenButton:(LHTouchInfo*)info{
    if(info.sprite) {
    }
}

-(void)touchBeganTapScreenButton:(LHTouchInfo*)info{
    if(info.sprite) {
        if(_levelStarted == NO) {
            _levelStarted = YES;
        }
    }
    [self changeLevelStatus:levelRunning];
    
    CCParticleSystemQuad* particle1 = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
    [particle1 setPosition:CGPointMake([_tapScreenButton position].x - _tapScreenButton.contentSize.width/2, [_tapScreenButton position].y)];
    [self addChild:particle1];
    [particle1 release];
    CCParticleSystemQuad* particle2 = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
    [particle2 setPosition:CGPointMake([_tapScreenButton position].x, [_tapScreenButton position].y)];
    [self addChild:particle2];
    [particle2 release];
    CCParticleSystemQuad* particle3 = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
    [particle3 setPosition:CGPointMake([_tapScreenButton position].x + _tapScreenButton.contentSize.width/2, [_tapScreenButton position].y)];
    [self addChild:particle3];
    [particle3 release];
    [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
    
    NSLog(@"tapscreenButton");
    //[_myAdmob hideBannerView];
    //[_myAdmob dismissAdView];
}

/*
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_levelStarted == NO) {
        //[self pauseLevelAtStart:NO];
        [self changeLevelStatus:levelRunning];
        _levelStarted = YES;
    }
    
    if(_levelState == levelPausedLifeLost) {
        [self changeLevelStatus:levelRunning];
    }
}
 */

-(void)saveGameState {
    NSLog(@"--- saveGameState");
    //save gameCenter
    //[GameState sharedInstance].completedSeasonSpring2012 = true;
    //[[GCHelper sharedInstance] reportAchievements:kAchievementSeasonSpring2012 percentComplete:25.0f];
    [[GCHelper sharedInstance] reportAchievements:kAchievementSeasonSummer2012 percentComplete:1.0f];
    
    NSLog(@"--- current Scene %d", [[GameManager sharedGameManager] currentScene] - 2012000);
    

    
    int currentLevelAsInt = [[GameManager sharedGameManager] currentScene] - 2012000;
    float percentComplete = currentLevelAsInt * 100 / 26;
 

    if([[GameManager sharedGameManager] season] == spring)
    {
        NSLog(@"--- current Season: Spring");
        [[GCHelper sharedInstance] reportAchievements:kAchievementSeasonSpring2012 percentComplete:percentComplete];   
    } else if([[GameManager sharedGameManager] season] == summer)
    {
        NSLog(@"--- current Season: Summer");
        [[GCHelper sharedInstance] reportAchievements:kAchievementSeasonSummer2012 percentComplete:percentComplete];
    } else if([[GameManager sharedGameManager] season] == fall)
    {
        NSLog(@"--- current Season: Fall");
        [[GCHelper sharedInstance] reportAchievements:kAchievementSeasonFall2012 percentComplete:percentComplete];
    } else if([[GameManager sharedGameManager] season] == winter)
    {
        NSLog(@"--- current Season: Winter");
        [[GCHelper sharedInstance] reportAchievements:kAchievementSeasonWinter2012 percentComplete:percentComplete];
    } else {
        NSLog(@"QQLevel: something is wrong in saveGameState!");
    }
    
    //reset Achievements
    //[[GCHelper sharedInstance] resetAchievements];
    

    
    NSLog(@"____ _score: %d", _score);
    NSLog(@"____ _highScore: %d", _highScore);
    
    //save HighScore if needed
    if(_score > _highScore) {
        [[[GameState sharedInstance] tempHighScore] setObject:[NSNumber numberWithInt:_score] forKey:[[GameManager sharedGameManager] levelToRun]];
        NSLog(@"- saveHighScore %@", [[GameState sharedInstance] tempHighScore]);
    }
    //--- save HighScore
    
    //[[GameState sharedInstance] save];
    
    [self saveLeaderboard];
}

-(void)saveLeaderboard {
    //report Leaderboard to iTunes Connect

    int sumHighscoreAllLevels = 0;
    int sumHighscoreSpring2012 = 0;
    int sumHighscoreSummer2012 = 0;
    int sumHighscoreFall2012 = 0;
    int sumHighscoreWinter2012 = 0;
    for(id key in [[GameState sharedInstance] tempHighScore]) {
        NSNumber *value = [[[GameState sharedInstance] tempHighScore] objectForKey:key];
        sumHighscoreAllLevels += [value intValue];
        //NSLog(@"value: %@", value);
        NSLog(@"sumHighscoreAllLevels: %d", sumHighscoreAllLevels);
        
        //summer
        if([key hasPrefix:@"levelSpring2012"]) {
            sumHighscoreSpring2012 += [value intValue];
        } else if ([key hasPrefix:@"levelSummer2012"]) {
            sumHighscoreSummer2012 += [value intValue];
        } else if ([key hasPrefix:@"levelFall2012"]) {
            sumHighscoreFall2012 += [value intValue];
        } else if ([key hasPrefix:@"levelWinter2012"]) {
            sumHighscoreWinter2012 += [value intValue];
        }
    }
    NSLog(@"sumHighscoreAllLevels: %d", sumHighscoreAllLevels);
    NSLog(@"sumHighscoreSpring: %d", sumHighscoreSpring2012);
    NSLog(@"sumHighscoreSummer: %d", sumHighscoreSummer2012);
    NSLog(@"sumHighscoreFall: %d", sumHighscoreFall2012);
    NSLog(@"sumHighscoreWinter: %d", sumHighscoreWinter2012);
    
    //int scoreAllLevels = 20;
    NSLog(@"-- QQLevel::saveLeaderboard");
    [[GCHelper sharedInstance] reportScore:kLeaderBoard score:(int)sumHighscoreAllLevels];
    [[GCHelper sharedInstance] reportScore:kLeaderBoardSpring2012 score:(int)sumHighscoreSpring2012];
    [[GCHelper sharedInstance] reportScore:kLeaderBoardSummer2012 score:(int)sumHighscoreSummer2012];
    [[GCHelper sharedInstance] reportScore:kLeaderBoardFall2012 score:(int)sumHighscoreFall2012];
    [[GCHelper sharedInstance] reportScore:kLeaderBoardWinter2012 score:(int)sumHighscoreWinter2012];
}

-(void)showOverlayGameOver {
    _loaderOverlayGameOver = [[LevelHelperLoader alloc] initWithContentOfFile:@"overlayGameOver"];
    [_loaderOverlayGameOver addSpritesToLayer:self];
    
}

////////////////////////////////////////////////////////////////////////////////
-(void)step:(ccTime)dt {
	float32 frameTime = dt;
	int stepsPerformed = 0;
	while ( (frameTime > 0.0) && (stepsPerformed < MAXIMUM_NUMBER_OF_STEPS) ){
		float32 deltaTime = std::min( frameTime, FIXED_TIMESTEP );
		frameTime -= deltaTime;
		if (frameTime < MINIMUM_TIMESTEP) {
			deltaTime += frameTime;
			frameTime = 0.0f;
		}
		_world->Step(deltaTime,VELOCITY_ITERATIONS,POSITION_ITERATIONS);
		stepsPerformed++;
		[self afterStep:dt]; // process collisions and result from callbacks called by the step
	}
}

////////////////////////////////////////////////////////////////////////////////
+(id)scene
{
    CCScene *scene = [CCScene node];    // 'scene' is an autorelease object.
    QQLevel *layer = [QQLevel node];    // 'layer' is an autorelease object.
    [scene addChild: layer];    // add layer as a child to scene

	return scene; 	// return the scene
}
////////////////////////////////////////////////////////////////////////////////
// initialize your instance here
-(id)init
{
	if( (self=[super init])) {
        [self setupWorld];
        [self setupLevelHelper];
        [self setupDebugDraw];
        self.isTouchEnabled = YES;  // Add at bottom of init
        //[[GameState sharedInstance] setCurrnetSceneIsLevel:YES];
        
        if(![[GameState sharedInstance] isPayingUser]) {
            _myAdmob = [QQAdmob node];
            [self addChild:_myAdmob];
        }
	}
	return self;
}

-(void)setupWorld {
    b2Vec2 gravity;
    //gravity.Set(0.0f, -1.75f);   //original 2.5f
    gravity.Set(0.0f, -2.5f);    //beginner 1.75f
    _world = new b2World(gravity);
    _world->SetContinuousPhysics(true);
}

-(void)beginEndCollisionBetweenBalloonAndPlayer:(LHContactInfo*)contact{
    if(_noMoreCollisionHandling)return;
    if([contact contactType]) {
        QQSpriteBalloon *touchedBalloon = (QQSpriteBalloon*)[contact bodyA]->GetUserData();
        //if([touchedBalloon visible]) {
            [touchedBalloon setWasTouched:TRUE];
            [_player setBalloonTouched:TRUE];
            //_score += _countDown;
        //}
    }
}

-(void)beginEndCollisionBetweenBalloonShakerAndPlayer:(LHContactInfo*)contact{
    if(_noMoreCollisionHandling)return;
    if([contact contactType]) {
        QQSpriteBalloonShake *touchedBalloon = (QQSpriteBalloonShake*)[contact bodyA]->GetUserData();
        [touchedBalloon setWasTouched:TRUE];
        [_player setBalloonTouched:TRUE];
        //[[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
        //_score += _countDown;
    }
}

-(void)beginEndCollisionBetweenBalloonBlinkerAndPlayer:(LHContactInfo*)contact{
    if(_noMoreCollisionHandling)return;
    if([contact contactType]) {
        QQSpriteBalloonBlinker *touchedBalloon = (QQSpriteBalloonBlinker*)[contact bodyA]->GetUserData();

        if([touchedBalloon visible]) {
            [_player setBalloonTouched:TRUE];
        }
   
        //if([touchedBalloon visible]) {
            [touchedBalloon setWasTouched:TRUE];
            //[_player setBalloonTouched:TRUE];
            //_score += _countDown;
        //}
    } else {
        QQSpriteBalloonBlinker *touchedBalloon = (QQSpriteBalloonBlinker*)[contact bodyA]->GetUserData();
        [touchedBalloon setWasTouched:FALSE];
        [_player setBalloonTouched:FALSE];
    }
}

-(void)beginEndCollisionBetweenBalloonThreetimestoucherAndPlayer:(LHContactInfo*)contact{
    if(_noMoreCollisionHandling)return;
    if([contact contactType]) {
        QQSpriteBalloonThreetimestoucher *touchedBalloon = (QQSpriteBalloonThreetimestoucher*)[contact bodyA]->GetUserData();
        if(touchedBalloon._balloonCompletelyInflated == YES) {
            [touchedBalloon setWasTouched:TRUE];
            [_player setBalloonTouched:TRUE];
            //_score += _countDown;
        }
    } else {

    }
}

-(void)beginEndCollisionBetweenBalloonSizechangerAndPlayer:(LHContactInfo*)contact{
    if(_noMoreCollisionHandling)return;
    if([contact contactType]) {
        alreadyFiredBallon = NO;
    } else {
        if(alreadyFiredBallon) {
        } else {
            QQSpriteBalloonSizechanger *touchedBalloon = (QQSpriteBalloonSizechanger*)[contact bodyA]->GetUserData();
            [touchedBalloon setWasTouched:TRUE];
            [_player setBalloonTouched:TRUE];
            //[[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
            alreadyFiredBallon = YES;
            //_score += _countDown;
        }
    }
}

-(void)beginEndCollisionBetweenTrampolineAndPlayer:(LHContactInfo*)contact{
    if(_noMoreCollisionHandling)return;
	if([contact contactType]) {
        //TRAMPOLINE
        b2Vec2 posA = [contact bodyA]->GetPosition();
        CGPoint posInMeterA = [LevelHelperLoader metersToPoints:posA];
        
        //PLAYER
        b2Vec2 posB = [contact bodyB]->GetPosition();
        CGPoint posInMeterB = [LevelHelperLoader metersToPoints:posB];

        float trampolineWidhtHalf = [_trampoline contentSize].width;
        float forceX = (posInMeterB.x - posInMeterA.x) / trampolineWidhtHalf * 10;
                 
        float trampolineVelocity = [contact bodyA]->GetLinearVelocity().x;
        //CCLOG(@"%f", trampolineVelocity);
        
        float finalForce;
        if(trampolineVelocity <= 0.1f && trampolineVelocity >= -0.1) {    //sometimes the velocity is not 0 although the player thinks it is 0 already, therefore 0.1f
            finalForce = forceX;
        } else {
            finalForce = trampolineVelocity * 1.5f; // 1.5f
        }
        [_player setForce:finalForce];
        
        //[_player setForce:forceX + trampolineVelocity * 1.5f];
        //[_player setForce:forceX];
        [_player setAcceptForces:TRUE];
        
        //NSLog(@"trampoline: %f", [contact bodyA]->GetFixtureList()->GetFriction());
        //NSLog(@"player: %f", [contact bodyB]->GetFixtureList()->GetFriction());
        
        alreadyFired = NO;
        
    } else {
        //[_trampoline setRestitution:[_trampoline initialRestitution]];
        //CCLOG(@"Trampoline and Player touch");
        
        if(alreadyFired) {
            //CCLOG(@"YES");
        } else {
            //CCLOG(@"NO");
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"boink.wav"];
            [_trampoline shallChangeRestitution: TRUE];
            //[_trampoline setRestitution:1.15f];  //1.1f
            
            
            if(_trampoline.redTrampolineActive) {
                [_trampoline setRestitution:1.3f];
            } else {
                [_trampoline setRestitution:1.15f];
            }
            
            
            [_player setAllowBeaming:TRUE];
            
            alreadyFired = YES;
            
            //NSArray *balloonsThreetimestoucher = [loader spritesWithTag:TAG_BALLOON_THREETIMESTOUCHER];
            //for(QQSpriteBalloonThreetimestoucher *balloon in balloonsThreetimestoucher) {
            //    [balloon setReactToCollision:YES];
            //}
        }
    }
}

-(void)beginEndCollisionBetweenMaxHeightAndPlayer:(LHContactInfo*)contact{
    if(_noMoreCollisionHandling)return;
	if([contact contactType]) {
    } else {
        [_trampoline shallChangeRestitution: TRUE];
        [_trampoline setRestitution:1.0f];
    }
}

-(void)beginEndCollisionBetweenPlayerAndBeam:(LHContactInfo*)contact{
    if(_noMoreCollisionHandling)return;
	if([contact contactType]) {
        if([_player allowBeaming]) {
            LHSprite *beam1 = [loader spriteWithUniqueName:@"beam1"];
            LHSprite *beam2 = [loader spriteWithUniqueName:@"beam2"];
            LHSprite *beamerContact = (LHSprite*)[contact bodyB]->GetUserData();
            [_player beamPlayer:beamerContact fromBeamObject:beam1 toBeamObject:beam2];
            [_player setAllowBeaming:FALSE];
            [[SimpleAudioEngine sharedEngine] playEffect:@"heavyLaserBeam.mp3"];
        }
    } else {
    }
}

-(void)beginEndCollisionBetweenPlayerAndFloor:(LHContactInfo*)contact{
    if(_noMoreCollisionHandling)return;
	if([contact contactType]) {
        
        //[_player setLifes:[_player lifes] - 1];
        _player.lifes--;
        NSLog(@"___ CollisionPlayerAndFloor");
        [[SimpleAudioEngine sharedEngine] playEffect:@"ouch_que.mp3"];
        
        //[self gameOverWithLevelPassed:NO];
        if([_player lifes] == 0) {
            NSLog(@"___ if");
            _gameOverLevelPassed = NO;
            [self changeLevelStatus:levelGameOver];

        } else {
            NSLog(@"___ else");
            [self changeLevelStatus:levelPausedLifeLost];
        }
    }
}

//-(void)beginEndCollisionBetweenPlayerAndStar:(LHContactInfo*)contact{
//    if(_noMoreCollisionHandling)return;
//	if([contact contactType]) {
//
//        [[SimpleAudioEngine sharedEngine] playEffect:@"franticDataShimmer.mp3"];
//        
//        QQSpriteStar *touchedStar = (QQSpriteStar*)[contact bodyB]->GetUserData();
//        [touchedStar setWasTouched:TRUE];
//        
//        LHSprite *star;
//        CGPoint destination;
//        switch (_starsCollected) {
//            case 0: {
//                star = [loaderJoystick spriteWithUniqueName:@"starBack_0"];
//                CCLOG(@"############ STAR 1");
//                break;
//            }
//            case 1: {
//                star = [loaderJoystick spriteWithUniqueName:@"starBack_1"];
//                CCLOG(@"############ STAR 2");
//                break;
//            }
//            case 2: {
//                star = [loaderJoystick spriteWithUniqueName:@"starBack_2"];
//                CCLOG(@"############ STAR 3");
//                break;
//            }
//            default: {
//                CCLOG(@"beginEndCollisionBetweenPlayerAndStar: something is wrong!");
//                break;
//            }
//        }
//        destination.x = [star position].x;
//        destination.y = [star position].y;
//        [touchedStar setStarDestination:destination];
//        _starsCollected++;
//        
//    } else {
//    }
//}

#pragma mark setupLevelHelper
-(void) setupLevelHelper {
    [LevelHelperLoader dontStretchArt];
    //[[LHSettings sharedInstance] setStretchArt:YES]; bolbok sylinapot
    
    self.isTouchEnabled = YES;
    //TODO: remove all isAccelerometerEnabled
    //self.isAccelerometerEnabled = YES;
    //[[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:YES];
    [self schedule: @selector(tick:) interval:1.0f/70.0f];
    
    [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[QQSpritePlayer class]
                                                           forTag:TAG_PLAYER];
    [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[QQSpriteTrampoline class]
                                                           forTag:TAG_TRAMPOLINE];
    
    [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[QQSpriteBalloon class]
                                                           forTag:TAG_BALLOON];

    [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[QQSpriteBalloonShake class]
                                                           forTag:TAG_BALLOON_SHAKER];
    
    [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[QQSpriteBalloonSizechanger class]
                                                           forTag:TAG_BALLOON_SIZECHANGER];
    
    [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[QQSpriteBalloonThreetimestoucher class]
                                                           forTag:TAG_BALLOON_THREETIMESTOUCHER];
    
    [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[QQSpriteBalloonBlinker class]
                                                           forTag:TAG_BALLOON_BLINKER];
    
    [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[QQSpriteBar class]
                                                           forTag:TAG_BAR];
    
    [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[QQSpriteBarShaker class]
                                                           forTag:TAG_BAR_SHAKER];
    
    [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[QQSpriteStar class]
                                                           forTag:TAG_STAR];
    
    //loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"levelWinter2012003"];
    loader = [[LevelHelperLoader alloc] initWithContentOfFile:[[GameManager sharedGameManager] levelToRun]];
    NSLog(@"########## %@", [[GameManager sharedGameManager] levelToRun]);
        

    [loader addObjectsToWorld:_world cocos2dLayer:self]; //creating the objects
    
    if([loader hasPhysicBoundaries])
        [loader createPhysicBoundaries:_world];
    
    //if(![loader isGravityZero]) {
    //    [loader createGravity:_world];
    //}
    //TODO: set Gravity from LH

    [self changeLevelStatus:levelNotStarted];

    [self setupBalloon];
    //[self setupStar];
    //[self setupAudio];
    [self setupPlayer];

    
    
    [self setupEffect];
    [self setupTrampoline];
    [self setupBeam];
    [self setupBarShaker];
    [self setupJoystick];
    [self setupLabelCountdown];
    [self setupLabelScore];
    [self setupLabelHighScore];
    [self setupRegisterForCollision];
    [self setupHelpLabel];
    [self setupRedTrampolineButton];
    
    // Add an observer that will respond to loginComplete
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resumeLevel:)
                                                 name:@"resumeLevel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pauseLevel:)
                                                 name:@"pauseLevel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backLevel:)
                                                 name:@"backLevel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadLevel:)
                                                 name:@"reloadLevel" object:nil];
    
    b2Vec2 gravity;
    LHSprite* spriteCustomProperties = [loader spriteWithUniqueName:@"spriteCustomProperties"];
    [spriteCustomProperties setVisible:YES];
    QQLevelClass* myInfo = (QQLevelClass*)[spriteCustomProperties userInfo];
    if(myInfo != nil) {
        gravity.Set(0.0f, [myInfo gravity]);
        _countDown = [myInfo countdown];
        _startImpulseX = [myInfo startImpulseX];
        _startImpulseY = [myInfo startImpulseY];
    }
    _world->SetGravity(gravity);
    _gravity = gravity;
    
    NSLog(@".................... 1.numberOfInstacnes: %d", [QQSpriteBalloon numberOfInstances]);
    
    //_countDown = [[GameState sharedInstance] countDown]; //xxxxx
}

// HELP LABEL
-(void)setupHelpLabel {
    _loaderHelpLabel = [[LevelHelperLoader alloc] initWithContentOfFile:@"helpLabels"];
    [_loaderHelpLabel addObjectsToWorld:_world cocos2dLayer:self];
    
    NSString *labelName = [[[GameManager sharedGameManager] levelToRun] stringByAppendingString:@"_1"];
    _helpLabel = [_loaderHelpLabel spriteWithUniqueName:labelName];
    
    if(_helpLabel != nil) {
        //if([@"levelSpring2012001_1" isEqualToString:labelName]) {
            [_helpLabel setVisible:YES];
            [_tapScreenButton setVisible:NO];
            [_tapScreenButton setTouchesDisabled:YES];
            
            [_helpLabel registerTouchBeganObserver:self selector:@selector(touchBeganHelpLabel_1:)];
            [_helpLabel registerTouchEndedObserver:self selector:@selector(touchEndedHelpLabel_1:)];
        //}
    }
}

-(void)touchBeganHelpLabel_1:(LHTouchInfo*)info{
    if(info.sprite) {
    }
}

-(void)touchEndedHelpLabel_1:(LHTouchInfo*)info{
    if(info.sprite) {
        [_helpLabel setVisible:NO];
        [_helpLabel setTouchesDisabled:YES];
        
        NSString *labelName = [[[GameManager sharedGameManager] levelToRun] stringByAppendingString:@"_2"];
        _helpLabel = [_loaderHelpLabel spriteWithUniqueName:labelName];
        
        if(_helpLabel != nil) {
            [_helpLabel setVisible:YES];
            [_helpLabel registerTouchBeganObserver:self selector:@selector(touchBeganHelpLabel_2:)];
            [_helpLabel registerTouchEndedObserver:self selector:@selector(touchEndedHelpLabel_2:)];
        } else {
            [_tapScreenButton setVisible:YES];
            [_tapScreenButton setTouchesDisabled:NO];
        }
    }
}

-(void)touchBeganHelpLabel_2:(LHTouchInfo*)info{
    if(info.sprite) {
    }
}

-(void)touchEndedHelpLabel_2:(LHTouchInfo*)info{
    if(info.sprite) {
        [_helpLabel setVisible:NO];
        [_helpLabel setTouchesDisabled:YES];
        
        NSString *labelName = [[[GameManager sharedGameManager] levelToRun] stringByAppendingString:@"_3"];
        _helpLabel = [_loaderHelpLabel spriteWithUniqueName:labelName];
        
        if(_helpLabel != nil) {
            [_helpLabel setVisible:YES];
            [_helpLabel registerTouchBeganObserver:self selector:@selector(touchBeganHelpLabel_3:)];
            [_helpLabel registerTouchEndedObserver:self selector:@selector(touchEndedHelpLabel_3:)];
        } else {
            [_tapScreenButton setVisible:YES];
            [_tapScreenButton setTouchesDisabled:NO];
        }
    }
}

-(void)touchBeganHelpLabel_3:(LHTouchInfo*)info{
    if(info.sprite) {
    }
}

-(void)touchEndedHelpLabel_3:(LHTouchInfo*)info{
    if(info.sprite) {
        [_helpLabel setVisible:NO];
        [_helpLabel setTouchesDisabled:YES];
        [_tapScreenButton setVisible:YES];
        [_tapScreenButton setTouchesDisabled:NO];
    }
}

//--- HELP LABEL

-(void)setupRegisterForCollision {
    [loader useLevelHelperCollisionHandling];//necessary or else collision in LevelHelper will not be performed
    
    [loader registerBeginOrEndCollisionCallbackBetweenTagA:TAG_BALLOON
                                                   andTagB:TAG_PLAYER
                                                idListener:self
                                               selListener:@selector(beginEndCollisionBetweenBalloonAndPlayer:)];
    
    [loader registerBeginOrEndCollisionCallbackBetweenTagA:TAG_BALLOON_SIZECHANGER
                                                   andTagB:TAG_PLAYER
                                                idListener:self
                                               selListener:@selector(beginEndCollisionBetweenBalloonSizechangerAndPlayer:)];
    
    [loader registerBeginOrEndCollisionCallbackBetweenTagA:TAG_BALLOON_SHAKER
                                                   andTagB:TAG_PLAYER
                                                idListener:self
                                               selListener:@selector(beginEndCollisionBetweenBalloonShakerAndPlayer:)];
    
    [loader registerBeginOrEndCollisionCallbackBetweenTagA:TAG_BALLOON_THREETIMESTOUCHER
                                                   andTagB:TAG_PLAYER
                                                idListener:self
                                               selListener:@selector(beginEndCollisionBetweenBalloonThreetimestoucherAndPlayer:)];
    
    [loader registerBeginOrEndCollisionCallbackBetweenTagA:TAG_BALLOON_BLINKER
                                                   andTagB:TAG_PLAYER
                                                idListener:self
                                               selListener:@selector(beginEndCollisionBetweenBalloonBlinkerAndPlayer:)];
    
    [loader registerBeginOrEndCollisionCallbackBetweenTagA:TAG_MAX_HEIGHT
                                                   andTagB:TAG_PLAYER
                                                idListener:self
                                               selListener:@selector(beginEndCollisionBetweenMaxHeightAndPlayer:)];
    
    [loader registerBeginOrEndCollisionCallbackBetweenTagA:TAG_TRAMPOLINE
                                                   andTagB:TAG_PLAYER
                                                idListener:self
                                               selListener:@selector(beginEndCollisionBetweenTrampolineAndPlayer:)];
    
    [loader registerBeginOrEndCollisionCallbackBetweenTagA:TAG_PLAYER
                                                   andTagB:TAG_BEAM
                                                idListener:self
                                               selListener:@selector(beginEndCollisionBetweenPlayerAndBeam:)];
    
    [loader registerBeginOrEndCollisionCallbackBetweenTagA:TAG_PLAYER
                                                   andTagB:TAG_FLOOR
                                                idListener:self
                                               selListener:@selector(beginEndCollisionBetweenPlayerAndFloor:)];
    
    [loader registerBeginOrEndCollisionCallbackBetweenTagA:TAG_PLAYER
                                                   andTagB:TAG_STAR
                                                idListener:self
                                               selListener:@selector(beginEndCollisionBetweenPlayerAndStar:)];
}



-(void)setupRedTrampolineButton {
    _redTrampolineButton = [loaderJoystick spriteWithUniqueName:@"redTrampolineButton"];
    [_redTrampolineButton registerTouchBeganObserver:self selector:@selector(touchBeganRedTrampolineButton:)];
    [_redTrampolineButton registerTouchEndedObserver:self selector:@selector(touchEndedRedTrampolineButton:)];
}


#pragma mark Joystick
-(void)setupJoystick {
    
    if([[LHSettings sharedInstance] isIphone5]) {
        loaderJoystick = [[LevelHelperLoader alloc] initWithContentOfFile:@"levelJoystick_iPhone5"];
    } else if ([[LHSettings sharedInstance] isIpad]) {
        loaderJoystick = [[LevelHelperLoader alloc] initWithContentOfFile:@"levelJoystick"];        
    } else {
        loaderJoystick = [[LevelHelperLoader alloc] initWithContentOfFile:@"levelJoystick"];
    }
    
    //[loaderJoystick addSpritesToLayer:self];
    [loaderJoystick addObjectsToWorld:_world cocos2dLayer:self];
    
    _joystickLeft = [loaderJoystick spriteWithUniqueName:@"joystickLeft"];
    _joystickLeftGlow = [loaderJoystick spriteWithUniqueName:@"joystickLeftGlow"];
    [_joystickLeft registerTouchBeganObserver:self selector:@selector(touchBeganJoystickLeftButton:)];
    [_joystickLeft registerTouchEndedObserver:self selector:@selector(touchEndedJoystickLeftButton:)];
    
    _joystickRight = [loaderJoystick spriteWithUniqueName:@"joystickRight"];
    _joystickRightGlow = [loaderJoystick spriteWithUniqueName:@"joystickRightGlow"];
    [_joystickRight registerTouchBeganObserver:self selector:@selector(touchBeganJoystickRightButton:)];
    [_joystickRight registerTouchEndedObserver:self selector:@selector(touchEndedJoystickRightButton:)];
    
    _spritePauseButton = [loaderJoystick spriteWithUniqueName:@"buttonPause"];
    [_spritePauseButton registerTouchBeganObserver:self selector:@selector(touchBeganPauseButton:)];
    [_spritePauseButton registerTouchEndedObserver:self selector:@selector(touchEndedPauseButton:)];
    
    _tapScreenButton = [loaderJoystick spriteWithUniqueName:@"tapScreenButton"];
    _tapScreenButtonInitialPosition = [_tapScreenButton position];
    [_tapScreenButton registerTouchBeganObserver:self selector:@selector(touchBeganTapScreenButton:)];
    [_tapScreenButton registerTouchEndedObserver:self selector:@selector(touchEndedTapScreenButton:)];
}

-(void)touchBeganRedTrampolineButton:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"touchBeganRedTrampolineButton");
    }
}

-(void)touchEndedRedTrampolineButton:(LHTouchInfo*)info{
    if(info.sprite) {
        if(!_trampoline.redTrampolineActive) {
            NSLog(@"touchEndedRedTrampolineButton");
            QQSpriteTrampoline *trampoline = (QQSpriteTrampoline*)[loader spriteWithUniqueName:@"trampoline"];
            CGPoint position = [trampoline position];
            [trampoline removeSelf];
            
            LHBatch *batch = [loader batchWithUniqueName:@"assets"];
            
            _trampoline = (QQSpriteTrampoline*)[loader createSpriteWithName:@"trampoline_red"
                                                                  fromSheet:@"assets"
                                                                 fromSHFile:@"objects"
                                                                        tag:TAG_TRAMPOLINE
                                                                     parent:batch];
            [_trampoline transformPosition:position];
            [_trampoline setZOrder:40];
            
            b2Joint* joint;
            b2Body* bodyTrampoline = [_trampoline body];
            LHSprite *floor = [loader spriteWithUniqueName:@"floor_neu"];
            b2Body* bodyFloor = [floor body];
            if(0 != bodyTrampoline && 0 != bodyFloor) {
                b2PrismaticJointDef jointDef;
                
                b2Vec2 axis(1, 0);
                axis.Normalize();
                
                b2Vec2 posA = bodyFloor->GetWorldCenter();
                jointDef.Initialize(bodyTrampoline, bodyFloor, posA, axis);
                
                if(0 != _world){
                    joint = (b2PrismaticJoint*)_world->CreateJoint(&jointDef);
                }
                
            }
            _trampoline.redTrampolineActive = YES;
        }
    }
}


-(void)touchBeganJoystickLeftButton:(LHTouchInfo*)info{
    if(info.sprite) {
        [_trampoline setCurrentMoveState:MS_LEFT];
        [_joystickLeftGlow setVisible:YES];
    }
}

-(void)touchEndedJoystickLeftButton:(LHTouchInfo*)info{
    if(info.sprite) {
        [_joystickLeftGlow setVisible:NO];
    }
}

-(void)touchBeganJoystickRightButton:(LHTouchInfo*)info{
    if(info.sprite) {
        [_trampoline setCurrentMoveState:MS_RIGHT];
        [_joystickRightGlow setVisible:YES];
    }
}
-(void)touchEndedJoystickRightButton:(LHTouchInfo*)info{
    if(info.sprite) {
        [_joystickRightGlow setVisible:NO];
    }
}

#pragma mark setupXXX

-(void)setupEffect {   
    LHSprite* snow = [loader spriteWithUniqueName:@EFFECT_SNOW];
    if(snow != nil) {
        _particleSnow = [[CCParticleSystemQuad alloc] initWithFile:@"snow.plist"];
        
        //[_particleSnow setStartSize:6.0f];  //original 12
        //[_particleSnow setEndSize:6.0f];      //original 20
        //NSLog(@"+++ emissionRate: %f", [_particleSnow emissionRate]);
        
        //[_particleSnow setEmissionRate:50];    //original 133
        //NSLog(@"+++ life: %f", [_particleSnow life]);
        
        //[_particleSnow setLife:2.5f];
        //NSLog(@"+++ lifeVar: %f", [_particleSnow lifeVar]);
        
        //[_particleSnow setLifeVar:0];
        
        //iPhone 4S
        //[_particleSnow setSourcePosition:CGPointMake(0, -300)];
        
        //original
        //sourcePositionX: 413
        //sourcePositionY: 832
        //sourcePositionVariancex: 557
        //sourcePositionVariancey: -64
        //paritcleLifespan: 3.75
        //paritcleLifespanVariance: 9
        //finishParticleSize: 20
        //finishParticleSizeVariance: 0
        
        
        [self addChild:_particleSnow];
    }
    
    LHSprite* spring = [loader spriteWithUniqueName:@EFFECT_SPRING];
    if(spring != nil) {
        _particleSpring = [[CCParticleSystemQuad alloc] initWithFile:@"particleSpring.plist"];
        [self addChild:_particleSpring];
    }
    
    LHSprite* leaves = [loader spriteWithUniqueName:@EFFECT_LEAVES];
    if(leaves != nil) {
        _particleLeaves = [[CCParticleSystemQuad alloc] initWithFile:@"fallingLeaves2.plist"];
        [self addChild:_particleLeaves];
    }
    
    LHSprite* sun = [loader spriteWithUniqueName:@EFFECT_SUN];
    if(sun != nil) {
        _particleSun = [[CCParticleSystemQuad alloc] initWithFile:@"sun.plist"];
        
        LHSprite* particleSunSprite = [loader spriteWithUniqueName:@"sun"];
        CGPoint particleSunPosition;
        particleSunPosition.x = [particleSunSprite position].x;
        particleSunPosition.y = [particleSunSprite position].y;
        [_particleSun setPosition:particleSunPosition];
        //[_particleSun setPosition:CGPointMake(100, 100)];
        
        [self addChild:_particleSun];
    }
    
    LHSprite* rain = [loader spriteWithUniqueName:@EFFECT_RAIN];
    if(rain != nil) {
        _particleRain = [[CCParticleSystemQuad alloc] initWithFile:@"rain.plist"];
        [self addChild:_particleRain];
    }
    
    LHSprite* fireBar = [loader spriteWithUniqueName:@EFFECT_FIREBAR];
    if(fireBar != nil) {
        _particleFireBar = [[CCParticleSystemQuad alloc] initWithFile:@"particleFireBar.plist"];
        
        CGPoint particleFireBarPosition;
        particleFireBarPosition.x = [fireBar position].x;
        particleFireBarPosition.y = [fireBar position].y;
        [_particleFireBar setPosition:particleFireBarPosition];
        NSLog(@"--- zOder: %d", [_particleFireBar zOrder]);
        [_particleFireBar setZOrder:0];
        NSLog(@"+++ zOder: %d", [_particleFireBar zOrder]);
        
        [self addChild:_particleFireBar];
    }
}


-(void)setupBalloon {
    NSArray *balloonsShaker = [loader spritesWithTag:TAG_BALLOON_SHAKER];
    int movingStartDelay = 0;
    for(QQSpriteBalloonShake *balloon in balloonsShaker) {
        if(balloon != nil) {
            QQBalloonClass* myInfo = (QQBalloonClass*)[balloon userInfo];
            if(myInfo != nil){
                //notice how the method name is exactly as the variable defined inside LH on the PlayerInfo class
                movingStartDelay = [myInfo movingStartDelay];
            } 
            [balloon startMovingWithDelay:movingStartDelay];
        }
    }
    
    NSArray *balloonsSizechanger = [loader spritesWithTag:TAG_BALLOON_SIZECHANGER];
    for(QQSpriteBalloonSizechanger *balloon in balloonsSizechanger) {
        [balloon startWithInterval:0.05f];
    }
    
    NSArray *balloonsBlinker = [loader spritesWithTag:TAG_BALLOON_BLINKER];
    for(QQSpriteBalloonBlinker *balloon in balloonsBlinker) {
        //[balloon startBlinkingWithDelay:1.0f andWithInterval:2.0f];
        QQBalloonClass* myInfo = (QQBalloonClass*)[balloon userInfo];
        float blinkInterval = 0;
        float blinkDelay = 0;
        int blinkModulo = 0;
        if(myInfo != nil){
            //notice how the method name is exactly as the variable defined inside LH on the PlayerInfo class
            blinkInterval = [myInfo blinkInterval];
            blinkDelay = [myInfo blinkDelay];
            blinkModulo = [myInfo blinkModulo];
            if(blinkModulo == 0) {
                [balloon startBlinkingWithDelay:blinkDelay andWithInterval:blinkInterval];
            } else {
                [balloon startBlinkingWithDelay:blinkDelay andWithInterval:blinkInterval andWithModulo:blinkModulo];
            }
        } else {
            [balloon startBlinkingWithDelay:[self randomFloatBetween:0.0f andWith:2.0f] andWithInterval:[self randomFloatBetween:1.0f andWith:2.0f]];
        }
    }
}

- (float)randomFloatBetween:(float)smallNumber andWith:(float)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}


-(void)setupStar {
    //_stars = [loader spritesWithTag:TAG_STAR];
    //[_stars retain];
}

//-(void)setupTrampoline {
//    
//    //QQSpriteTrampoline *trampoline;
//    //objPlayer = (PlayerSprite*)[loader createSpriteWithName:@"robo_anim_01_03" fromSheet:@"RobotAnimation" fromSHFile:@"RoboWorld" tag:PLAYER];
//    //trampoline = (QQSpriteTrampoline*)[loader createSpriteWithName:@"trampoline_red"
//    //                            fromSheet:@"assets"
//    //                               SHFile:@"objects"
//    //                                tag:TAG_TRAMPOLINE];
//    
//    //_trampoline = (QQSpriteTrampoline*)[loader createSpriteWithName:@"trampoline_red" fromSheet:@"assets" fromSHFile:@"objects" tag:TAG_TRAMPOLINE];
//    //[self addChild:_trampoline];
//    
//    
//    BOOL inAppPurchase = NO;
//    
//    QQSpriteTrampoline *trampoline = (QQSpriteTrampoline*)[loader spriteWithUniqueName:@"trampoline"];
//    QQSpriteTrampoline *trampoline_red = (QQSpriteTrampoline*)[loader spriteWithUniqueName:@"trampoline_red"];
//    
//    if(inAppPurchase == YES) {
//        [trampoline removeSelf];
//        _trampoline = trampoline_red;
//    } else {
//        [trampoline_red removeSelf];
//        _trampoline = trampoline;
//    }
//    
//    [_trampoline setInitialRestitution];
//}

-(void)setupTrampoline {
    _trampoline = (QQSpriteTrampoline*)[loader spriteWithUniqueName:@"trampoline"];
    [_trampoline setInitialRestitution];
}

//-(void)setupTrampoline {
//    QQSpriteTrampoline *trampoline = (QQSpriteTrampoline*)[loader spriteWithUniqueName:@"trampoline"];
//    CGPoint position = [trampoline position];
//    [trampoline removeSelf];
//
//    _trampoline = (QQSpriteTrampoline*)[loader createSpriteWithName:@"trampoline"
//                                                          fromSheet:@"assets"
//                                                         fromSHFile:@"objects"
//                                                                tag:TAG_TRAMPOLINE
//                                                             parent:self];
//    [_trampoline transformPosition:position];
//    [_trampoline setZOrder:0];
//    
//    b2Joint* joint;
//    b2Body* bodyTrampoline = [_trampoline body];
//    LHSprite *floor = [loader spriteWithUniqueName:@"floor"];
//    b2Body* bodyFloor = [floor body];
//	if(0 != bodyTrampoline && 0 != bodyFloor) {
//        b2PrismaticJointDef jointDef;
//
//        b2Vec2 axis(1, 0);
//        axis.Normalize();
//    
//        b2Vec2 posA = bodyFloor->GetWorldCenter();
//        jointDef.Initialize(bodyTrampoline, bodyFloor, posA, axis);
//        
//        if(0 != _world){
//            joint = (b2PrismaticJoint*)_world->CreateJoint(&jointDef);
//        }
//    
//    }
//	
//    [_trampoline setInitialRestitution];
//}

-(void)setupBarShaker {
    NSArray *barsShaker = [loader spritesWithTag:TAG_BAR_SHAKER];
    for(QQSpriteBarShaker *bar in barsShaker) {
        [bar startMovingWithDelay:1];
        [bar setToSensor:YES];
    }
}

-(void)setupBeam {
    LHSprite *beam1 = [loader spriteWithUniqueName:@"beam1"];
    LHSprite *beam2 = [loader spriteWithUniqueName:@"beam2"];
    
    if(nil != beam1 && nil != beam2) {
        //CCLOG(@"BEAM IS in the level");
        
        _particleBeam1 = [[CCParticleSystemQuad alloc] initWithFile:@"particleBeam4.plist"];
        CGPoint particlePosition;
        particlePosition.x = [beam1 position].x;
        particlePosition.y = [beam1 position].y;
        //particlePosition.x = 40;
        //particlePosition.y = 320 - 60;
        [_particleBeam1 setPosition:particlePosition];
        [self addChild:_particleBeam1];
        
        _particleBeam2 = [[CCParticleSystemQuad alloc] initWithFile:@"particleBeam4.plist"];
        CGPoint particlePosition2;
        particlePosition2.x = [beam2 position].x;
        particlePosition2.y = [beam2 position].y;
        [_particleBeam2 setPosition:particlePosition2];
        [self addChild:_particleBeam2];
    }
}

-(void)setupPlayer {
    _player = (QQSpritePlayer*)[loader spriteWithUniqueName:@"bunny"];
    [_player setLocation:[_player position]];
    

    _earLeft = [loader spriteWithUniqueName:@"bunny_ear_left"];
    _earRight = [loader spriteWithUniqueName:@"bunny_ear_right"];
    _handLeft = [loader spriteWithUniqueName:@"bunny_hand_left"];
    _handRight = [loader spriteWithUniqueName:@"bunny_hand_right"];
    
    /*
    [_earLeft body]->SetGravityScale(0);
    [_earRight body]->SetGravityScale(0);
    [_handLeft body]->SetGravityScale(0);
    [_handRight body]->SetGravityScale(0);
    [_player body]->SetGravityScale(0);
    [_earLeft body]->GetFixtureList()->SetDensity(0);
    [_earRight body]->GetFixtureList()->SetDensity(0);
    [_handLeft body]->GetFixtureList()->SetDensity(0);
    [_handRight body]->GetFixtureList()->SetDensity(0);
    [_player body]->GetFixtureList()->SetDensity(0);
     */
    
    [_player makeStatic];
    [_player setInitialPositionWithLoader:loader withLayer:self];
}

-(void)setupDebugDraw {
    m_debugDraw = new GLESDebugDraw();
    _world->SetDebugDraw(m_debugDraw);
    uint32 flags = 0;
    flags += b2Draw::e_shapeBit;
    flags += b2Draw::e_jointBit;
    m_debugDraw->SetFlags(flags);
}


-(void)updateSprites:(ccTime)dt {
    //Iterate over the bodies in the physics world
	for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL)
        {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
            
            if(myActor != 0)
            {
                //THIS IS VERY IMPORTANT - GETTING THE POSITION FROM BOX2D TO COCOS2D
                myActor.position = [LevelHelperLoader metersToPoints:b->GetPosition()];
                myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            }
            
        }
	}
}

- (void)updateBox2D:(ccTime)dt {
    _world->Step(dt, 1, 1);
    _world->ClearForces();
}

- (void)update:(ccTime)dt {
    [self updateBox2D:dt];
    [self updateSprites:dt];
}

////////////////////////////////////////////////////////////////////////////////
//FIX TIME STEPT------------>>>>>>>>>>>>>>>>>>
-(void)tick: (ccTime) dt
{
	[self step:dt];
    [self update:dt];
}
//FIX TIME STEPT<<<<<<<<<<<<<<<----------------------
////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //CCLOG(@"ccTouchesMoved");
}
////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [_trampoline setCurrentMoveState:MS_STOP];
}

-(void)setupLabelCountdown {
    LHSprite* spriteCountdown = [loaderJoystick spriteWithUniqueName:@"countDown"];
    _spriteWatch = [loaderJoystick spriteWithUniqueName:@"stopWatch"];
    
    double countdown = COUNTDOWN;
    NSString* stringCountdown = [NSString stringWithFormat:@"%0.1f", countdown];

    _labelCountdown = [CCLabelTTF labelWithString:stringCountdown
                                   dimensions:CGSizeMake(50, 50)
                                   hAlignment:kCCTextAlignmentRight
                                   vAlignment:kCCVerticalTextAlignmentCenter
                                     fontName:@"Marker Felt"
                                     fontSize:16];
    [_labelCountdown setColor:ccc3(0,0,0)];
    [_labelCountdown setPosition:spriteCountdown.position];
    [_labelCountdown setOpacity:200];
    [_spriteWatch setOpacity:200];
    [self addChild:_labelCountdown];
}

-(void)updateLabelCountdown {
    //[_spriteWatch setPosition:[_labelLifes position]];
    //[_spriteWatch setPosition:CGPointMake([_labelCountdown position].x - _labelCountdown.contentSize.width/2, [_labelCountdown position].y)];
    
    CGFloat positionWidth;
    if(_countDown >= 100) { positionWidth = 3 * 16; }
    else if (_countDown > 10) { positionWidth = 2 * 16; }
    else { positionWidth = 1 * 16; }
    
    [_spriteWatch setPosition:CGPointMake([_labelCountdown position].x - positionWidth / 2, [_labelCountdown position].y)];
    [_labelCountdown setString:[NSString stringWithFormat:@"%0.1f", _countDown]];
}

-(void)setupLabelScore {
    LHSprite* spriteScore = [loaderJoystick spriteWithUniqueName:@"score"];
    NSString* stringScore = [NSString stringWithFormat:@"%d", _score];
    
    //_labelScore = [CCLabelTTF labelWithString:stringScore fontName:@"Marker Felt" fontSize:16];
    _labelScore = [CCLabelTTF labelWithString:stringScore
                                   dimensions:CGSizeMake(50, 50)
                                   hAlignment:kCCTextAlignmentRight
                                   vAlignment:kCCVerticalTextAlignmentCenter
                                     fontName:@"Marker Felt"
                                     fontSize:16];
    [_labelScore setColor:ccc3(0,0,0)];
    [_labelScore setPosition:[spriteScore position]];
    [_labelScore setOpacity:200];
    [self addChild:_labelScore];
}

-(void)setupLabelHighScore {
    //_highScore = [[[[GameState sharedInstance] tempHighScore] objectForKey:[[GameManager sharedGameManager] levelToRun]] intValue];
    
    LHSprite* spriteScoreOld = [loaderJoystick spriteWithUniqueName:@"scoreOld"];
    NSString* stringHighScore = [NSString stringWithFormat:@"%d", _highScore];
    _labelHighScore = [CCLabelTTF labelWithString:stringHighScore
                                       dimensions:CGSizeMake(50, 50)
                                       hAlignment:kCCTextAlignmentRight
                                       vAlignment:kCCVerticalTextAlignmentCenter
                                         fontName:@"Marker Felt"
                                         fontSize:16];
    [_labelHighScore setColor:ccc3(0,0,0)];
    [_labelHighScore setPosition:[spriteScoreOld position]];
    [self addChild:_labelHighScore];
}

-(void)updateLabelScore {
    [_labelScore setString:[NSString stringWithFormat:@"%d", _score]];
}

-(void)updateLabelHighScore {
    if(_highScore < _score) {
        //_highScore = _score;
        [_labelHighScore setString:[NSString stringWithFormat:@"%d", _highScore]];
        //[self saveHighScore];
    } else {
        [_labelHighScore setString:[NSString stringWithFormat:@"%d", _highScore]];
    }
}



////////////////////////////////////////////////////////////////////////////////
// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [_trampoline removeSelf];
    //[_myAdmob dismissAdView];
    //[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self
    //                                         selector:@selector(resumeLevel:)
    //                                             name:@"resumeLevel" object:nil];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self
    //name:@"resumeLevel" object:nil];
        
    _noMoreCollisionHandling = true;

    if(nil != _particleSpring) [_particleSpring release];
    if(nil != _particleLeaves) [_particleLeaves release];
    if(nil != _particleSnow) [_particleSnow release];
    if(nil != _particleSun) [_particleSun release];
    if(nil != _particleRain) [_particleRain release];
    if(nil != _particleBeam1) [_particleBeam1 release];
    if(nil != _particleBeam2) [_particleBeam2 release];

    
    NSLog(@"loaderJoystick: %@", loaderJoystick);
    if(nil != loaderJoystick) {
        [loaderJoystick removeAllPhysics];
        [loaderJoystick release];
    }
    
    

    
    if(nil != loader) {
        //NSArray* allSprites = [loader allSprites];
        //for (LHSprite* aSprite in allSprites) {
        //    NSLog(@"_ makeNoPhysics");
            //[aSprite makeNoPhysics];
        //    [aSprite removeSelf];
        //}
        
        //NSArray *balloonsNormal = [loader spritesWithTag:TAG_BALLOON];
        //for(QQSpriteBalloon *balloon in balloonsNormal) {
        //    [balloon removeSelf];
        //}
        
        [loader removeAllPhysics];
        [loader release];
        
        [_loaderHelpLabel release];
    }
    
    NSLog(@".................... 2. numberOfInstacnes: %d", [QQSpriteBalloon numberOfInstances]);
    
    //while ([QQSpriteBalloon numberOfInstances] != 3 + (3 - _balloonsDestroyed)) {
    //    NSLog(@".................... .. numberOfInstacnes: %d, _balloonsDestroyed: %d", [QQSpriteBalloon numberOfInstances], _balloonsDestroyed);
    //}


	delete _world;
	_world = NULL;
	
  	delete m_debugDraw;
    
    //[_gameOverLayer release];
    
    //QQQ[[CCDirector sharedDirector] resume];
    
    //[[GameState sharedInstance] setCurrnetSceneIsLevel:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];    // don't forget to call "super dealloc"
    NSLog(@"___ ENDE");
    NSLog(@".................... 3. numberOfInstacnes: %d", [QQSpriteBalloon numberOfInstances]);
}


@end
////////////////////////////////////////////////////////////////////////////////


