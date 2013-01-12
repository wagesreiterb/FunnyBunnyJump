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

//static NSString* _level;

@implementation QQHelp

//@synthesize pause;

-(void)afterStep {
    // process collisions and result from callbacks called by the step
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
    

    [self makeObjectsInvisibleAndStatic];

       
    [_player applyForce];
    [_player deflect];   //give the bunny a force when a balloon is touched
    [_player resetPosition];
    [_player applyStartJump];
    [_player restoreInitialPosition:loader];
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
    
    NSArray *balloonsNormal = [loader spritesWithTag:TAG_BALLOON];
    for(QQSpriteBalloon *balloon in balloonsNormal) {
        [balloon reactToTouch:_world withLayer:self];
        balloonsLeft++;
    }

    NSArray *balloonsShaker = [loader spritesWithTag:TAG_BALLOON_SHAKER];
    for(QQSpriteBalloonShake *balloon in balloonsShaker) {
        [balloon reactToTouch:_world withLayer:self];
        balloonsLeft++;
    }
    
    NSArray *balloonsSizechanger = [loader spritesWithTag:TAG_BALLOON_SIZECHANGER];
    for(QQSpriteBalloonShake *balloon in balloonsSizechanger) {
        [balloon reactToTouch:_world withLayer:self];
        balloonsLeft++;
    }
    
    NSArray *balloonsThreetimestoucher = [loader spritesWithTag:TAG_BALLOON_THREETIMESTOUCHER];
    for(QQSpriteBalloonThreetimestoucher *balloon in balloonsThreetimestoucher) {
        if(balloon._balloonCompletelyInflated == YES) {
            [balloon reactToTouchWithWorld:_world withLayer:self];
            balloonsLeft++;
        }
    }
    
    NSArray *balloonsBlinker = [loader spritesWithTag:TAG_BALLOON_BLINKER];
    for(QQSpriteBalloonBlinker *balloon in balloonsBlinker) {
        [balloon reactToTouch:_world withLayer:self];
        balloonsLeft++;
    }
    
    if(_tapScreenButtonMakeDynamicRequired) {
        //NSLog(@"IIIIIIIHHHHHHHH!");
        //LHSprite* tapScreenButton = [loaderJoystick spriteWithUniqueName:@"tapScreenButton"];
        [_tapScreenButton transformPosition:_tapScreenButtonInitialPosition];
        [_tapScreenButton makeDynamic];
        _tapScreenButtonMakeDynamicRequired = NO;
    }
     
    
    //level completed
    if(balloonsLeft == 0 && _gameOverLevelPassed == NO) {
    //if(balloonsLeft == 0) {
        NSLog(@"___ balloonsLeft==0");
        _gameOverLevelPassed = YES;
    }
}

- (void)resumeLevel:(NSNotification *)note {
    NSLog(@"||||||||||   Received Notification - resumeLevel");
    [self enableTouches];
}

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
            //[self changeLevelStatus:levelRunning];
            _levelStarted = YES;
        }
        
        //if(_levelState == levelPausedLifeLost) {
        //[self changeLevelStatus:levelRunning];
        //}
    }
    
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
    QQHelp *layer = [QQHelp node];    // 'layer' is an autorelease object.
    [scene addChild: layer];    // add layer as a child to scene

	return scene; 	// return the scene
}
////////////////////////////////////////////////////////////////////////////////
// initialize your instance here
-(id)init
{
    NSLog(@"--- init");
	if( (self=[super init])) {
        [self setupWorld];
        [self setupLevelHelper];
        [self setupDebugDraw];
        self.isTouchEnabled = YES;  // Add at bottom of init
        //[[GameState sharedInstance] setCurrnetSceneIsLevel:YES];
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
    if([contact contactType]) {
        QQSpriteBalloon *touchedBalloon = (QQSpriteBalloon*)[contact bodyA]->GetUserData();
        if([touchedBalloon visible]) {
            [touchedBalloon setWasTouched:TRUE];
            [_player setBalloonTouched:TRUE];
            _score += _countDown;
        }
    }
}

-(void)beginEndCollisionBetweenBalloonShakerAndPlayer:(LHContactInfo*)contact{
    if([contact contactType]) {
        QQSpriteBalloonShake *touchedBalloon = (QQSpriteBalloonShake*)[contact bodyA]->GetUserData();
        [touchedBalloon setWasTouched:TRUE];
        [_player setBalloonTouched:TRUE];
        //[[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
        _score += _countDown;
    } else {
        //CCLOG(@"touch ended");
    }
}

-(void)beginEndCollisionBetweenBalloonBlinkerAndPlayer:(LHContactInfo*)contact{
    if([contact contactType]) {
        QQSpriteBalloonBlinker *touchedBalloon = (QQSpriteBalloonBlinker*)[contact bodyA]->GetUserData();
            if([touchedBalloon visible]) {
            [touchedBalloon setWasTouched:TRUE];
            [_player setBalloonTouched:TRUE];
            _score += _countDown;
        }
    }
}

-(void)beginEndCollisionBetweenBalloonThreetimestoucherAndPlayer:(LHContactInfo*)contact{
    if([contact contactType]) {
        QQSpriteBalloonThreetimestoucher *touchedBalloon = (QQSpriteBalloonThreetimestoucher*)[contact bodyA]->GetUserData();
        if(touchedBalloon._balloonCompletelyInflated == YES) {
            [touchedBalloon setWasTouched:TRUE];
            [_player setBalloonTouched:TRUE];
            _score += _countDown;
        }
    } else {

    }
}

-(void)beginEndCollisionBetweenBalloonSizechangerAndPlayer:(LHContactInfo*)contact{
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
            _score += _countDown;
        }
    }
}

-(void)beginEndCollisionBetweenTrampolineAndPlayer:(LHContactInfo*)contact{
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
            finalForce = trampolineVelocity * 1.5f;
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
            [_trampoline setRestitution:1.1f];
            [_player setAllowBeaming:TRUE];
            
            alreadyFired = YES;
            
            NSArray *balloonsThreetimestoucher = [loader spritesWithTag:TAG_BALLOON_THREETIMESTOUCHER];
            for(QQSpriteBalloonThreetimestoucher *balloon in balloonsThreetimestoucher) {
                [balloon setReactToCollision:YES];
            }
        }
    }
}

-(void)beginEndCollisionBetweenMaxHeightAndPlayer:(LHContactInfo*)contact{
	if([contact contactType]) {
    } else {
        [_trampoline shallChangeRestitution: TRUE];
        [_trampoline setRestitution:1.0f];
    }
}

-(void)beginEndCollisionBetweenPlayerAndBeam:(LHContactInfo*)contact{
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
	if([contact contactType]) {
        
        //[_player setLifes:[_player lifes] - 1];
        _player.lifes--;
        NSLog(@"___ CollisionPlayerAndFloor");
        [[SimpleAudioEngine sharedEngine] playEffect:@"ouch_que.mp3"];
        
        //[self gameOverWithLevelPassed:NO];
        if([_player lifes] == 0) {
            NSLog(@"___ if");
            _gameOverLevelPassed = NO;

        } else {
            NSLog(@"___ else");

        }
    }
}


#pragma mark setupLevelHelper
-(void) setupLevelHelper {
    //[LevelHelperLoader dontStretchArt];
    [[LHSettings sharedInstance] setStretchArt:YES];
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
    
    loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"help"];
    [loader addObjectsToWorld:_world cocos2dLayer:self]; //creating the objects
    
    if([loader hasPhysicBoundaries])
        [loader createPhysicBoundaries:_world];


    [self setupBalloon];
    [self setupPlayer];
    [self setupTrampoline];
    [self setupBarShaker];
    [self setupJoystick];
    [self setupRegisterForCollision];
    
    // Add an observer that will respond to loginComplete
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resumeLevel:)
                                                 name:@"resumeLevel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pauseLevel:)
                                                 name:@"pauseLevel" object:nil];
    
    b2Vec2 gravity;
    LHSprite* spriteCustomProperties = [loader spriteWithUniqueName:@"spriteCustomProperties"];
    [spriteCustomProperties setVisible:YES];
    QQLevelClass* myInfo = (QQLevelClass*)[spriteCustomProperties userInfo];
    if(myInfo != nil) {
        gravity.Set(0.0f, [myInfo gravity]);
        NSLog(@"|-|-|-| gravity: %f", [myInfo gravity]);
    }
    _world->SetGravity(gravity);
    
    
    _countDown = [[GameState sharedInstance] countDown];
}

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






#pragma mark Joystick
-(void)setupJoystick {
    loaderJoystick = [[LevelHelperLoader alloc] initWithContentOfFile:@"levelJoystick"];
    [loaderJoystick addSpritesToLayer:self];
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
        [balloon startBlinkingWithDelay:[self randomFloatBetween:0.0f andWith:2.0f] andWithInterval:[self randomFloatBetween:1.0f andWith:2.0f]];

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

-(void)setupTrampoline {
    _trampoline = (QQSpriteTrampoline*)[loader spriteWithUniqueName:@"trampoline"];
    [_trampoline setInitialRestitution];
}

-(void)setupBarShaker {
    NSArray *barsShaker = [loader spritesWithTag:TAG_BAR_SHAKER];
    for(QQSpriteBarShaker *bar in barsShaker) {
        [bar startMovingWithDelay:1];
        [bar setToSensor:YES];
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
    [_player setInitialPositionWithLoader:loader];
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





////////////////////////////////////////////////////////////////////////////////
// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    //[[NSNotificationCenter defaultCenter] addObserver:self
    //                                         selector:@selector(resumeLevel:)
    //                                             name:@"resumeLevel" object:nil];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self
    //name:@"resumeLevel" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if(nil != _particleLeaves) [_particleLeaves release];
    if(nil != _particleSnow) [_particleSnow release];
    if(nil != _particleSun) [_particleSun release];
    if(nil != _particleRain) [_particleRain release];
    if(nil != _particleBeam1) [_particleBeam1 release];
    if(nil != _particleBeam2) [_particleBeam2 release];
    //if(nil != _pauseLayer) [_pauseLayer release];
    
    NSLog(@"Level::dealloc");
    //[self saveGameState];
    //[_dictionaryHighScore release];
     
    if(nil != loader) {
        //NSArray* allSprites = [loader allSprites];
        //for (LHSprite* aSprite in allSprites) {
        //    [aSprite makeNoPhysics];
        //}
        [loader removeAllPhysics];
        [loader release];
    }
    
    if(nil != loaderJoystick)
        [loaderJoystick release];

	delete _world;
	_world = NULL;
	
  	delete m_debugDraw;
    
    //[_gameOverLayer release];
    
    //QQQ[[CCDirector sharedDirector] resume];
    
    //[[GameState sharedInstance] setCurrnetSceneIsLevel:NO];

	[super dealloc];    // don't forget to call "super dealloc"

}
@end
////////////////////////////////////////////////////////////////////////////////
