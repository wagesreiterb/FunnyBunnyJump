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

@implementation QQLevel

//@synthesize pause;

-(void)afterStep {
    // process collisions and result from callbacks called by the step
}

-(void)afterStep:(ccTime)dt {
	// process collisions and result from callbacks called by the step
    
    if(_countDown >= 0) {
        _countDown -= dt;
    }
    
    [self updateLifes];
    [self updateScore];
    [self updateHighScore];
    
    [_bar updateBar:dt];
    
    [_player applyForce];
    [_player whichDirection];
    [_player resetPosition];
    //[_player applyStartJump];
    [_player beam];
    //[_player upOrDownAction:_earLeft withEarRight:_earRight];
    [_player upOrDownAction:_earLeft withEarRight:_earRight withHandLeft:_handLeft withHandRight:_handRight];
    
    [_trampoline move:dt];
    [_trampoline setRestitutionAtTick];
    
    NSInteger balloonsLeft = 0;

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
        [balloon reactToTouchWithWorld:_world withLayer:self];
        balloonsLeft++;
    }
     
     
    
    //level completed    
    if(balloonsLeft == 0) {
        [self gameOverWithLevelPassed:YES];
        //[self levelCompleted];
    }
}

-(void)gameOverWithLevelPassed:(BOOL)levelPassed {
    if(levelPassed) {
        //TODO: save score
        [self showOverlayGameOver];
    } else {
        if([_player lifes] > 0) {
            //TODO: pause
            //[[CCDirector sharedDirector] pause];
            
            [self scheduleOnce:@selector(pauseLevelAtSchedule:) delay:0.3f];
            
            _levelStarted = NO;
            [_player setShallResetPosition:YES];
            [_player setVisible:NO];
            
            //[_player transformPosition:[_player position]];
            
            //move player to original positiony
        } else {
            [self showOverlayGameOver];
        }
    }
}

-(void)pauseLevelAtSchedule:(ccTime)dt {
    [[CCDirector sharedDirector] pause];
    [_player setVisible:YES];
}

-(void)showOverlayGameOver {
    _loaderOverlayGameOver = [[LevelHelperLoader alloc] initWithContentOfFile:@"overlayGameOver"];
    [_loaderOverlayGameOver addSpritesToLayer:self];
    
}

/*
-(void)levelCompleted {
    //save score
    //halt physics
    //[[CCDirector sharedDirector] pause];
    //show popup screen with current score, high score
    
}
*/

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
	}
	return self;
}

-(void)setupWorld {
    b2Vec2 gravity;
    gravity.Set(0.0f, -2.5f);
    _world = new b2World(gravity);
    _world->SetContinuousPhysics(true);
}
 
-(void)beginEndCollisionBetweenBalloonShakerAndPlayer:(LHContactInfo*)contact{
    if([contact contactType]) {
        QQSpriteBalloonShake *touchedBalloon = (QQSpriteBalloonShake*)[contact bodyA]->GetUserData();
        [touchedBalloon setWasTouched:TRUE];
        [_player setBalloonTouched:TRUE];
        [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
        _score += _countDown;
    } else {
        //CCLOG(@"touch ended");
    }
}

-(void)beginEndCollisionBetweenBalloonThreetimestoucherAndPlayer:(LHContactInfo*)contact{
    if([contact contactType]) {
        QQSpriteBalloonThreetimestoucher *touchedBalloon = (QQSpriteBalloonThreetimestoucher*)[contact bodyA]->GetUserData();
        [touchedBalloon setWasTouched:TRUE];
        [_player setBalloonTouched:TRUE];
        [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
        _score += _countDown;
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
            [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
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
    } else {
        
        //[[GameManager sharedGameManager] runSceneWithID:[[GameManager sharedGameManager] currentScene]];
        //[self pauseLevelAtStart:YES];

        [_player setLifes:[_player lifes] - 1];
        [[SimpleAudioEngine sharedEngine] playEffect:@"ouch.mp3"];
        [self gameOverWithLevelPassed:NO];
        
        /*
        if([_player isDead]) {
            CCLOG(@"IF IF IF");
        } else {
            CCLOG(@"ELSE ELSE");
            [_player setLifes:[_player lifes] - 1];
            [[SimpleAudioEngine sharedEngine] playEffect:@"ouch.mp3"];
            [_player setDead:YES];
            [self pauseLevelAtStart:YES];
        }
        */
    }
}

-(void)beginEndCollisionBetweenPlayerAndStar:(LHContactInfo*)contact{
	if([contact contactType]) {

        [[SimpleAudioEngine sharedEngine] playEffect:@"franticDataShimmer.mp3"];
        
        QQSpriteStar *touchedStar = (QQSpriteStar*)[contact bodyB]->GetUserData();
        [touchedStar setWasTouched:TRUE];
        
        LHSprite *star;
        CGPoint destination;
        switch (_starsCollected) {
            case 0: {
                star = [loader spriteWithUniqueName:@"starBack_0"];
                CCLOG(@"############ STAR 1");
                break;
            }
            case 1: {
                star = [loader spriteWithUniqueName:@"starBack_1"];
                CCLOG(@"############ STAR 2");
                break;
            }
            case 2: {
                star = [loader spriteWithUniqueName:@"starBack_2"];
                CCLOG(@"############ STAR 3");
                break;
            }
            default: {
                CCLOG(@"beginEndCollisionBetweenPlayerAndStar: something is wrong!");
                break;
            }
        }
        destination.x = [star position].x;
        destination.y = [star position].y;
        [touchedStar setStarDestination:destination];
        _starsCollected++;
        
    } else {
    }
}


/*
-(void)setupLevel:(NSString*) level {
    //[LevelHelperLoader dontStretchArtOnIpad];
    //[LevelHelperLoader dontStretchArt];
    //loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"level001"];
    //[loader addObjectsToWorld:_world cocos2dLayer:self]; //creating the objects
    
    //[LevelHelperLoader dontStretchArtOnIpad];
    loader = [[LevelHelperLoader alloc] initWithContentOfFile:level];
    [loader addObjectsToWorld:_world cocos2dLayer:self]; //creating the objects
}*/


#pragma mark setupLevelHelper
-(void) setupLevelHelper {
    //[LevelHelperLoader dontStretchArt];
    self.isTouchEnabled = YES;
    //TODO: remove all isAccelerometerEnabled
    //self.isAccelerometerEnabled = YES;
    //[[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:YES];
    [self schedule: @selector(tick:) interval:1.0f/70.0f];
    
    [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[QQSpritePlayer class]
                                                           forTag:TAG_PLAYER];
    [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[QQSpriteTrampoline class]
                                                           forTag:TAG_TRAMPOLINE];

    [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[QQSpriteBalloonShake class]
                                                           forTag:TAG_BALLOON_SHAKER];
    
    [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[QQSpriteBalloonSizechanger class]
                                                           forTag:TAG_BALLOON_SIZECHANGER];
    
    [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[QQSpriteBalloonThreetimestoucher class]
                                                           forTag:TAG_BALLOON_THREETIMESTOUCHER];
    
    [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[QQSpriteBar class]
                                                           forTag:TAG_BAR];
    [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[QQSpriteStar class]
                                                           forTag:TAG_STAR];

    
    loader = [[LevelHelperLoader alloc] initWithContentOfFile:[[GameManager sharedGameManager] levelToRun]];
    //loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"levelWinter2012003"];
    [loader addObjectsToWorld:_world cocos2dLayer:self]; //creating the objects
    
    if([loader hasPhysicBoundaries])
        [loader createPhysicBoundaries:_world];
    
    //if(![lh isGravityZero])
      //  [lh createGravity:world];
    //TODO: set Gravity from LH

    

    [self setupBalloon];
    //[self setupStar];
    //[self setupAudio];
    [self setupPlayer];
    [self setupEffect];
    [self setupTrampoline];
    [self setupBeam];
    [self setupBar];
    [self setupJoystick];
    [self setupLifes];
    [self setupScore];
    [self setupHighScore];
    [self setupRegisterForCollision];
    
    
    //TODO
    _countDown = COUNTDOWN;
    

    _spritePauseButton = [loaderJoystick spriteWithUniqueName:@"buttonPause"];
    [_spritePauseButton registerTouchBeganObserver:self selector:@selector(touchBeganPauseButton:)];
    
    [self pauseLevelAtStart:YES];

}

-(void)setupRegisterForCollision {
    [loader useLevelHelperCollisionHandling];//necessary or else collision in LevelHelper will not be performed
    
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




-(void)pauseLevelAtStart:(BOOL)pause_ {
    if(pause_) {
        [[CCDirector sharedDirector] pause];
        //CCLOG(@"YES PAUSE");
    }
    else {
        LHSprite* tapScreenButton = [loaderJoystick spriteWithUniqueName:@"tapScreenButton"];
        [tapScreenButton removeSelf];
        [[CCDirector sharedDirector] resume];
        //CCLOG(@"YES RESUME");
    }
}

#pragma mark Pause
// Pause
-(void)touchBeganPauseButton:(LHTouchInfo*)info{
    //NSLog(@"Touch BEGIN on sprite %@", [info.sprite uniqueName]);
    if(info.sprite) {
        //NSLog(@"aa Touch BEGIN on sprite %@", [info.sprite uniqueName]);
        [self pauseLevel:YES];
    }
}

-(void)pauseLevel:(BOOL)pause_ {
    [LevelHelperLoader setPaused:pause_];
    if(pause_) {
        [[CCDirector sharedDirector] pause];
        [self setupPauseLayer];
        _spritePlayButton = [loaderPause spriteWithUniqueName:@"buttonPlay"];
        [_spritePlayButton registerTouchBeganObserver:self selector:@selector(touchBeganPlayButton:)];
        
        _spriteBackButton = [loaderPause spriteWithUniqueName:@"buttonBack"];
        [_spriteBackButton registerTouchBeganObserver:self selector:@selector(touchBeganBackButton:)];
        _spriteReloadButton = [loaderPause spriteWithUniqueName:@"buttonReload"];
        [_spriteReloadButton registerTouchBeganObserver:self selector:@selector(touchBeganReloadButton:)];
        [_spritePauseButton setVisible:NO];
        [_spritePauseButton setTouchesDisabled:YES];

        [_joystickLeft setTouchesDisabled:YES];
        [_joystickRight setTouchesDisabled:YES];
    }
    else {
        [[CCDirector sharedDirector] resume];
        if(nil != loaderPause) {
            NSArray* allLayers = [loaderPause allLayers];
            for(LHLayer* myLayer in allLayers)
            {
                [myLayer removeSelf];
            }
            [loaderPause release];
        }
    }
}

-(void)enableJoystick:(ccTime)dt {
    [_joystickLeft setTouchesDisabled:NO];
    [_joystickRight setTouchesDisabled:NO];
}

//layerPause
-(void)touchBeganPlayButton:(LHTouchInfo*)info{
    //NSLog(@"Touch BEGIN on sprite %@", [info.sprite uniqueName]);
    if(info.sprite) {
        //NSLog(@"aa Touch BEGIN on sprite %@", [info.sprite uniqueName]);
        [_spritePauseButton setVisible:YES];
        [_spritePauseButton setTouchesDisabled:NO];
        [self pauseLevel:NO];
        [self scheduleOnce:@selector(enableJoystick:) delay:0.1];
        
    }
}


-(void)touchBeganBackButton:(LHTouchInfo*)info{
    //NSLog(@"Touch BEGIN on sprite %@", [info.sprite uniqueName]);
    if(info.sprite) {
        //NSLog(@"aa Touch BEGIN on sprite %@", [info.sprite uniqueName]);
        [self pauseLevel:NO];
        [[GameManager sharedGameManager] runSceneWithID:kLevelChooser];
    }
}

//layerPause
-(void)touchBeganReloadButton:(LHTouchInfo*)info{
    if(info.sprite) {
        [[GameManager sharedGameManager] runSceneWithID:[[GameManager sharedGameManager] currentScene]];
        //_levelStarted = NO;
        //[self pauseLevelAtStart:YES];
        //[self pauseLevel:NO];
        NSLog(@"--- Reload");
    }
}

-(void)setupPauseLayer {
    loaderPause = [[LevelHelperLoader alloc] initWithContentOfFile:@"pauseLayer"];
    [loaderPause addSpritesToLayer:self];
}
//----- Pause

#pragma mark Joystick
-(void)setupJoystick {
    loaderJoystick = [[LevelHelperLoader alloc] initWithContentOfFile:@"levelJoystick"];
    [loaderJoystick addSpritesToLayer:self];
    _joystickLeft = [loaderJoystick spriteWithUniqueName:@"joystickLeft"];
    [_joystickLeft registerTouchBeganObserver:self selector:@selector(touchBeganJoystickLeftButton:)];
    _joystickRight = [loaderJoystick spriteWithUniqueName:@"joystickRight"];
    [_joystickRight registerTouchBeganObserver:self selector:@selector(touchBeganJoystickRightButton:)];
}

-(void)touchBeganJoystickLeftButton:(LHTouchInfo*)info{
    if(info.sprite) {
        [_trampoline setCurrentMoveState:MS_LEFT];
    }
}

-(void)touchBeganJoystickRightButton:(LHTouchInfo*)info{
    if(info.sprite) {
        [_trampoline setCurrentMoveState:MS_RIGHT];
    }
}

#pragma mark setupXXX

-(void)setupEffect {   
    LHSprite* snow = [loader spriteWithUniqueName:@EFFECT_SNOW];
    if(snow != nil) {
        _particleSnow = [[CCParticleSystemQuad alloc] initWithFile:@"snow.plist"];
        [self addChild:_particleSnow];
    }
    
    LHSprite* leaves = [loader spriteWithUniqueName:@EFFECT_LEAVES];
    if(leaves != nil) {
        _particleLeaves = [[CCParticleSystemQuad alloc] initWithFile:@"fallingLeaves.plist"];
        [self addChild:_particleLeaves];
    }
    
    LHSprite* sun = [loader spriteWithUniqueName:@EFFECT_SUN];
    if(sun != nil) {
        _particleSun = [[CCParticleSystemQuad alloc] initWithFile:@"sun.plist"];
        [self addChild:_particleSun];
    }
    
    LHSprite* rain = [loader spriteWithUniqueName:@EFFECT_RAIN];
    if(rain != nil) {
        _particleRain = [[CCParticleSystemQuad alloc] initWithFile:@"rain.plist"];
        [self addChild:_particleRain];
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
}


-(void)setupStar {
    //_stars = [loader spritesWithTag:TAG_STAR];
    //[_stars retain];
}

-(void)setupTrampoline {
    _trampoline = (QQSpriteTrampoline*)[loader spriteWithUniqueName:@"trampoline"];
    [_trampoline setInitialRestitution];
    
    //CCLabelTTF *score = [CCLabelTTF labelWithString:@"Score: 0" fontName:@"Verdana" fontSize:[self convertFontSize:20.0]];
    //[self addChild:score z:10];
}

-(void)setupBar {
    _bar = (QQSpriteBar*)[loader spriteWithUniqueName:@"bar"];
}

-(void)setupBeam {
    LHSprite *beam1 = [loader spriteWithUniqueName:@"beam1"];
    LHSprite *beam2 = [loader spriteWithUniqueName:@"beam2"];
    
    if(nil != beam1 && nil != beam2) {
        //CCLOG(@"BEAM IS in the level");
        
        _particleBeam1 = [[CCParticleSystemQuad alloc] initWithFile:@"particleBeam.plist"];
        CGPoint particlePosition;
        particlePosition.x = [beam1 position].x;
        particlePosition.y = [beam1 position].y;
        //particlePosition.x = 40;
        //particlePosition.y = 320 - 60;
        [_particleBeam1 setPosition:particlePosition];
        [self addChild:_particleBeam1];
        
        _particleBeam2 = [[CCParticleSystemQuad alloc] initWithFile:@"particleBeam.plist"];
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
    _handLeft = [loader spriteWithUniqueName:@"hand_left"];
    _handRight = [loader spriteWithUniqueName:@"hand_right"];
    
    [_player setLifes:LIFES];
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

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_levelStarted == NO) {
        [self pauseLevelAtStart:NO];
        _levelStarted = YES;
    }
}

////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //CCLOG(@"ccTouchesMoved");
}
////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_trampoline setCurrentMoveState:MS_STOP];
}

-(void)setupLifes {
    LHSprite* spriteLifes = [loaderJoystick spriteWithUniqueName:@"lifes"];
    
    NSString* stringLifes = [NSString stringWithFormat:@"%d", [_player lifes]];
    
    //_labelLifes = [CCLabelTTF labelWithString:stringLifes fontName:@"Marker Felt" fontSize:16];
    _labelLifes = [CCLabelTTF labelWithString:stringLifes
                                   dimensions:CGSizeMake(50, 50)
                                   hAlignment:kCCTextAlignmentRight
                                     fontName:@"Marker Felt"
                                     fontSize:16];
    [_labelLifes setColor:ccc3(0,0,0)];
    [_labelLifes setPosition:[spriteLifes position]];
    [self addChild:_labelLifes];
}

-(void)setupScore {
    LHSprite* spriteScore = [loaderJoystick spriteWithUniqueName:@"score"];
    NSString* stringScore = [NSString stringWithFormat:@"%d", _score];
    
    //_labelScore = [CCLabelTTF labelWithString:stringScore fontName:@"Marker Felt" fontSize:16];
    _labelScore = [CCLabelTTF labelWithString:stringScore
                                       dimensions:CGSizeMake(50, 50)
                                       hAlignment:kCCTextAlignmentRight
                                         fontName:@"Marker Felt"
                                         fontSize:16];
    [_labelScore setColor:ccc3(0,0,0)];
    [_labelScore setPosition:[spriteScore position]];
    [self addChild:_labelScore];
}

-(void)setupHighScore {
    //_highScore = [[[[GameState sharedInstance] tempHighScore] objectForKey:@"seasonWinter2012004"] intValue];
    _highScore = [[[[GameState sharedInstance] tempHighScore] objectForKey:[[GameManager sharedGameManager] levelToRun]] intValue];

    //_highScore = [[[GameState sharedInstance] tempHighScore] objectForKey:[[GameManager sharedGameManager] levelToRun]] intValue];
    LHSprite* spriteScoreOld = [loaderJoystick spriteWithUniqueName:@"scoreOld"];
    NSString* stringHighScore = [NSString stringWithFormat:@"%d", _highScore];
    
    //_labelHighScore = [CCLabelTTF labelWithString:stringScoreOld fontName:@"Marker Felt" fontSize:16];
    _labelHighScore = [CCLabelTTF labelWithString:stringHighScore
                                       dimensions:CGSizeMake(50, 50)
                                       hAlignment:kCCTextAlignmentRight
                                         fontName:@"Marker Felt"
                                         fontSize:16];

    [_labelHighScore setColor:ccc3(0,0,0)];
    [_labelHighScore setPosition:[spriteScoreOld position]];
    [self addChild:_labelHighScore];
}

-(void)saveHighScore {
    //[[[GameState sharedInstance] tempHighScore] setObject:[NSNumber numberWithInt:_highScore] forKey:@"seasonWinter2012004"];
    [[[GameState sharedInstance] tempHighScore] setObject:[NSNumber numberWithInt:_highScore] forKey:[[GameManager sharedGameManager] levelToRun]];
    NSLog(@"- saveHighScore %@", [[GameState sharedInstance] tempHighScore]);
}


-(void)updateLifes {
    [_labelLifes setString:[NSString stringWithFormat:@"%d", [_player lifes]]];
}

-(void)updateScore {
    [_labelScore setString:[NSString stringWithFormat:@"%d", _score]];
}

-(void)updateHighScore {
    if(_highScore < _score) {
        _highScore = _score;
        [_labelHighScore setString:[NSString stringWithFormat:@"%d", _highScore]];
        [self saveHighScore];
    } else {
        [_labelHighScore setString:[NSString stringWithFormat:@"%d", _highScore]];
    }
}

-(void)saveGameState {
    
    //save gameCenter
    [GameState sharedInstance].completedSeasonSpring2012 = true;
    [[GCHelper sharedInstance] reportAchievements:kAchievementSeasonSpring2012 percentComplete:100.0];
    
    //reset Achievements
    //[[GCHelper sharedInstance] resetAchievements];
    
    int timeSoFar = 15;
    [[GCHelper sharedInstance] reportScore:kLeaderBoard score:(int)timeSoFar];


    [self saveHighScore];
    
    [[GameState sharedInstance] save];
     

}

-(void)gameOver {
    //save highScore
    //save level as passed
    //show gameOver Layer
}

////////////////////////////////////////////////////////////////////////////////
// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    if(nil != _particleLeaves) [_particleLeaves release];
    if(nil != _particleSnow) [_particleSnow release];
    if(nil != _particleSun) [_particleSun release];
    if(nil != _particleRain) [_particleRain release];
    if(nil != _particleBeam1) [_particleBeam1 release];
    if(nil != _particleBeam2) [_particleBeam2 release];
    
    NSLog(@"Level::dealloc");
    [self saveGameState];
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

	[super dealloc];    // don't forget to call "super dealloc"

}
@end
////////////////////////////////////////////////////////////////////////////////


/*
 +(id)scene:(NSString*)level
 {
 _level = level;
 CCScene *scene = [CCScene node];    // 'scene' is an autorelease object.
 QQLevel *layer = [QQLevel node];    // 'layer' is an autorelease object.
 
 [scene addChild: layer];    // add layer as a child to scene
 
 return scene; 	// return the scene
 }
 */


/*
 -(void)draw
 {
 
 // Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
 // Needed states:  GL_VERTEX_ARRAY,
 // Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
 glDisable(GL_TEXTURE_2D);
 glDisableClientState(GL_COLOR_ARRAY);
 glDisableClientState(GL_TEXTURE_COORD_ARRAY);
 _world->DrawDebugData();
 // restore default GL states
 glEnable(GL_TEXTURE_2D);
 glEnableClientState(GL_COLOR_ARRAY);
 glEnableClientState(GL_TEXTURE_COORD_ARRAY);
 
 }
 */

/*
-(void)afterStep:(ccTime)dt {
	// process collisions and result from callbacks called by the step
    [_bar updateBar:dt];
    
    [_player applyForce];
    
    [_player whichDirection];
    
    
    [_player applyStartJump];
    [_trampoline move:dt];
    [_trampoline setRestitutionAtTick];
    
    //NSLog(@"afterStep balloons: %d", [_balloons retainCount]);
    
    
 
     //balloons = [loader spritesWithTag:TAG_BALLOON];
     //for(QQSpriteBalloon *balloon in balloons) {
     //[balloon reactToTouch:balloon withWorld:_world withLayer:self];
     //}
     
     //stars = [loader spritesWithTag:TAG_STAR];
     //for(QQSpriteStar *star in stars) {
     //[star reactToTouch:star withWorld:_world withLayer:self];
     //}
 
    
    
    
    
    NSArray *balloons = [loader spritesWithTag:TAG_BALLOON];
    for(QQSpriteBalloon *balloon in balloons) {
        //balloon = [balloon reactToTouch:balloon withWorld:_world withLayer:self];
        [balloon reactToTouch:balloon withWorld:_world withLayer:self];
    }
    //[balloons retain];
    
    NSArray *stars = [loader spritesWithTag:TAG_STAR];
    for(QQSpriteStar *star in stars) {
        //star = [star reactToTouch:star withWorld:_world withLayer:self];
        [star reactToTouch:star withWorld:_world withLayer:self];
        
    }
    //[stars retain];
    
    
    
    
    [_player beam];
    
    
    
    
    //_testinger = [loader spritesWithTag:TAG_BALLOON];
    //for(LHSprite *balloon in _testinger) {
    //    CCLOG(@"FOR FOR FOR");
    //[balloon reactToTouch:balloon withWorld:_world withLayer:self];
    //}
    

     //for(NSString *stringTanga in myColors) {
     //NSLog(@"afterStep - %@", stringTanga);
     //}
}
*/

/*
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    
    //UITouch *touch = [touches anyObject];
    //CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    
     [_trampoline setShallMove:TRUE];
     if(touchLocation.x < 240){
     [_trampoline setCurrentMoveState:MS_LEFT];
     }
     else {
     [_trampoline setCurrentMoveState:MS_RIGHT];
     }
     
 
}*/


//_labelTimer = [QQLabelTimer labelWithString:@"label" fontName:@"Marker Felt" fontSize:32];
//[_labelTimer startTimer];
//[self addChild:_labelTimer];



/*
 LHSprite* balloon = [loader spriteWithUniqueName:@"balloonPurple"];
 if(balloon == nil) {
 NSLog(@"BALLOON IS NIL");
 } else {
 NSLog(@"WE HAVE A BALLOON");
 }
 NSString* classInfo = [balloon userInfoClassName];
 NSLog(@"classInfo %@", classInfo);
 
 QQBalloonClass* myInfo = (QQBalloonClass*)[balloon userInfo];
 
 if(myInfo != nil){
 //notice how the method name is exactly as the variable defined inside LH on the PlayerInfo class
 int score = [myInfo score];
 int movingStartDelay = [myInfo movingStartDelay];
 NSLog(@"score: %d", score);
 NSLog(@"score: %d", movingStartDelay);
 } else {
 NSLog(@"don't work!");
 }
 */

//Frühling
//Butterfly
//if([[GameManager sharedGameManager] effectRaining]) {
//    CCParticleSystemQuad *particleRain = [[CCParticleSystemQuad alloc] initWithFile:@"rain.plist"];
//    [self addChild:particleRain];
//}

/*
 if([[GameManager sharedGameManager] effectFallingLeaves]) {
 _particleLeave = [[CCParticleSystemQuad alloc] initWithFile:@"fallingLeaves.plist"];
 [self addChild:_particleLeave];
 }
 
 if([[GameManager sharedGameManager] effectSnowing]) {
 _particleSnow = [[CCParticleSystemQuad alloc] initWithFile:@"snow.plist"];
 [self addChild:_particleSnow];
 }
 
 if([[GameManager sharedGameManager] effectSunShining]) {
 _particleSun = [[CCParticleSystemQuad alloc] initWithFile:@"sun.plist"];
 [self addChild:_particleSun];
 }
 */


/*
 -(void)beginEndCollisionBetweenBalloonYellowAndPlayer:(LHContactInfo*)contact{
 if([contact contactType]) {
 QQSpriteBalloon *touchedBalloon = (QQSpriteBalloon*)[contact bodyA]->GetUserData();
 [touchedBalloon setWasTouched:TRUE];
 
 [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
 } else {
 }
 }
 */

/*
 -(void)beginEndCollisionBetweenBalloonYellowAndPlayer:(LHContactInfo*)contact{
 if([contact contactType]) {
 QQSpriteBalloon *touchedBalloon = (QQSpriteBalloon*)[contact bodyA]->GetUserData();
 [touchedBalloon setWasTouched:TRUE];
 
 [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
 
 alreadyFiredBallon = NO;
 } else {
 if(alreadyFiredBallon) {
 CCLOG(@"YES BBB");
 } else {
 CCLOG(@"NO BBB");
 
 QQSpriteBalloonShake *touchedBalloon = (QQSpriteBalloonShake*)[contact bodyA]->GetUserData();
 [touchedBalloon setWasTouched:TRUE];
 
 [_player setBalloonTouched:TRUE];
 [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
 
 _points += _countDown;
 
 alreadyFiredBallon = YES;
 }
 }
 }
 */

/*
 -(void)beginEndCollisionBetweenBalloonPurpleAndPlayer:(LHContactInfo*)contact{
 if([contact contactType]) {
 QQSpriteBalloonShake *touchedBalloon = (QQSpriteBalloonShake*)[contact bodyA]->GetUserData();
 [touchedBalloon setWasTouched:TRUE];
 
 [_player setBalloonTouched:TRUE];
 
 [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
 
 _points += _countDown;
 } else {
 }
 }
 */





//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

/*
 LHSprite* balloon = [loader spriteWithUniqueName:@"balloonPurple"];
 if(balloon == nil) {
 NSLog(@"BALLOON IS NIL");
 } else {
 NSLog(@"WE HAVE A BALLOON");
 }
 [balloon makeDynamic];
 NSString* classInfo = [balloon userInfoClassName];
 NSLog(@"classInfo %@", classInfo);
 
 QQBalloonClass* myInfo = (QQBalloonClass*)[balloon userInfo];
 
 if(myInfo != nil){
 //notice how the method name is exactly as the variable defined inside LH on the PlayerInfo class
 int score = [myInfo score];
 int movingStartDelay = [myInfo movingStartDelay];
 NSLog(@"score: %d", score);
 NSLog(@"score: %d", movingStartDelay);
 } else {
 NSLog(@"don't work!");
 }
 */


//NSLog(@"LevelName: %@", [[GameManager sharedGameManager] levelToRun]);



/*
 NSArray *balloonsYellow = [loader spritesWithTag:TAG_BALLOON_YELLOW];
 for(QQSpriteBalloon *balloonYellow in balloonsYellow) {
 [balloonYellow reactToTouch:balloonYellow withWorld:_world withLayer:self];
 balloonsLeft++;
 }
 
 NSArray *balloonsPurple = [loader spritesWithTag:TAG_BALLOON_PURPLE];
 for(QQSpriteBalloonShake *balloonPurple in balloonsPurple) {
 [balloonPurple reactToTouch:balloonPurple withWorld:_world withLayer:self];
 balloonsLeft++;
 }
 
 NSArray *balloonsShaker = [loader spritesWithTag:TAG_BALLOON_SHAKER];
 for(QQSpriteBalloonShake *balloon in balloonsShaker) {
 [balloon reactToTouch:balloon withWorld:_world withLayer:self];
 balloonsLeft++;
 }
 
 NSArray *balloonsOrange = [loader spritesWithTag:TAG_BALLOON_ORANGE];
 for(QQSpriteBalloonShake *balloonOrange in balloonsOrange) {
 [balloonOrange reactToTouch:balloonOrange withWorld:_world withLayer:self];
 balloonsLeft++;
 }
 
 NSArray *balloonsSizechanger = [loader spritesWithTag:TAG_BALLOON_SIZECHANGER];
 for(QQSpriteBalloonShake *balloon in balloonsSizechanger) {
 [balloon reactToTouch:balloon withWorld:_world withLayer:self];
 balloonsLeft++;
 }
 
 NSArray *balloonsThreetimestoucher = [loader spritesWithTag:TAG_BALLOON_THREETIMESTOUCHER];
 for(QQSpriteBalloonThreetimestoucher *balloon in balloonsThreetimestoucher) {
 [balloon reactToTouch:balloon withWorld:_world withLayer:self];
 balloonsLeft++;
 }
 */


/*
 -(void)beginEndCollisionBetweenBalloonOrangeAndPlayer:(LHContactInfo*)contact{
 if([contact contactType]) {
 alreadyFiredBallon = NO;
 } else {
 if(alreadyFiredBallon) {
 CCLOG(@"YES BBB");
 } else {
 CCLOG(@"NO BBB");
 
 QQSpriteBalloonShake *touchedBalloon = (QQSpriteBalloonShake*)[contact bodyA]->GetUserData();
 [touchedBalloon setWasTouched:TRUE];
 
 [_player setBalloonTouched:TRUE];
 [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
 
 alreadyFiredBallon = YES;
 }
 }
 }
 */

/*
 -(void)beginEndCollisionBetweenBalloonAndPlayer:(LHContactInfo*)contact{
 if([contact contactType]) {
 QQSpriteBalloon *touchedBalloon = (QQSpriteBalloon*)[contact bodyA]->GetUserData();
 [touchedBalloon setWasTouched:TRUE];
 
 [_player setBalloonTouched:TRUE];
 
 [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
 } else {
 }
 }
 */


//[_player prepareAnimationNamed:@"jumper" fromSHScene:@"objects"];
//[_player prepareAnimationNamed:@"moul" fromSHScene:@"objects"];
//[_player prepareAnimationNamed:@"bunny_jump_up" fromSHScene:@"objects"];
//[_player playAnimation];


/*
 -(void)setupHighScore {
 //setup High Score
 _dictionaryHighScore = [NSMutableDictionary dictionaryWithDictionary:[[GameState sharedInstance] highScore]];
 [_dictionaryHighScore retain];
 _highScore = [[_dictionaryHighScore objectForKey:@"seasonWinter2012004"] intValue];
 NSLog(@"--- setupHighScore: %@", [[GameManager sharedGameManager] levelToRun]);
 NSLog(@"--- setupHighScore - _highScore: %d", _highScore);
 //_highScore = [[_dictionaryHighScore objectForKey:[[GameManager sharedGameManager] levelToRun]] intValue];
 
 
 NSLog(@"--- setupHighScore - retain Count: %d", [_dictionaryHighScore retainCount]);
 
 LHSprite* spriteScoreOld = [loaderJoystick spriteWithUniqueName:@"scoreOld"];
 NSString* stringScoreOld = [NSString stringWithFormat:@"%d", _highScore];
 
 _labelHighScore = [CCLabelTTF labelWithString:stringScoreOld fontName:@"Marker Felt" fontSize:16];
 [_labelHighScore setColor:ccc3(0,0,0)];
 [_labelHighScore setPosition:[spriteScoreOld position]];
 [self addChild:_labelHighScore];
 }
 
 -(void)saveHighScore {
 NSLog(@"--- saveHighScore - retain Count: %d", [_dictionaryHighScore retainCount]);
 [_dictionaryHighScore setObject:[NSNumber numberWithInt:_highScore] forKey:@"seasonWinter2012004"];
 NSLog(@"--- saveHighScore: %@", [[GameManager sharedGameManager] levelToRun]);
 //[_dictionaryHighScore setObject:[NSNumber numberWithInt:_highScore] forKey:[[GameManager sharedGameManager] levelToRun]];
 
 //convert from NSMutableDictionary to NSDictionary used for GameState
 NSDictionary *temporaryDictionary = [NSDictionary dictionaryWithDictionary:_dictionaryHighScore];
 [[GameState sharedInstance] setHighScore: temporaryDictionary];
 [_dictionaryHighScore release];
 }
 */

