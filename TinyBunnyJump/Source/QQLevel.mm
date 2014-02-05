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

+(id)scene
{
    CCScene *scene = [CCScene node];    // 'scene' is an autorelease object.
    QQLevel *layer = [QQLevel node];    // 'layer' is an autorelease object.
    [scene addChild: layer];    // add layer as a child to scene
    
	return scene; 	// return the scene
}

#pragma mark

# pragma mark collisionHandling
-(void)beginEndCollisionBetweenBalloonAndPlayer:(LHContactInfo*)contact {
    if(_noMoreCollisionHandling)return;
    if([contact contactType]) {
        QQSpriteBalloon *touchedBalloon = (__bridge QQSpriteBalloon*)[contact bodyA]->GetUserData();
        //if([touchedBalloon visible]) {
            [touchedBalloon setWasTouched:TRUE];
            [_player setBalloonTouched:TRUE];
            //_score += _countDown;
        //}
    }
}

-(void)beginEndCollisionBetweenBalloonShakerAndPlayer:(LHContactInfo*)contact {
    if(_noMoreCollisionHandling)return;
    if([contact contactType]) {
        QQSpriteBalloonShake *touchedBalloon = (__bridge QQSpriteBalloonShake*)[contact bodyA]->GetUserData();
        [touchedBalloon setWasTouched:TRUE];
        [_player setBalloonTouched:TRUE];
    }
}

-(void)beginEndCollisionBetweenBalloonBlinkerAndPlayer:(LHContactInfo*)contact {
    if(_noMoreCollisionHandling)return;
    if([contact contactType]) {
        QQSpriteBalloonBlinker *touchedBalloon = (__bridge QQSpriteBalloonBlinker*)[contact bodyA]->GetUserData();

        if([touchedBalloon visible]) {
            [_player setBalloonTouched:TRUE];
        }
   
        //if([touchedBalloon visible]) {
            [touchedBalloon setWasTouched:TRUE];
            //[_player setBalloonTouched:TRUE];
            //_score += _countDown;
        //}
    } else {
        QQSpriteBalloonBlinker *touchedBalloon = (__bridge QQSpriteBalloonBlinker*)[contact bodyA]->GetUserData();
        [touchedBalloon setWasTouched:FALSE];
        [_player setBalloonTouched:FALSE];
    }
}

-(void)beginEndCollisionBetweenBalloonThreetimestoucherAndPlayer:(LHContactInfo*)contact {
    if(_noMoreCollisionHandling)return;
    if([contact contactType]) {
        QQSpriteBalloonThreetimestoucher *touchedBalloon = (__bridge QQSpriteBalloonThreetimestoucher*)[contact bodyA]->GetUserData();
        if(touchedBalloon._balloonCompletelyInflated == YES) {
            [touchedBalloon setWasTouched:TRUE];
            [_player setBalloonTouched:TRUE];
        }
    } else {

    }
}

-(void)beginEndCollisionBetweenBalloonSizechangerAndPlayer:(LHContactInfo*)contact {
    if(_noMoreCollisionHandling)return;
    if([contact contactType]) {
        alreadyFiredBallon = NO;
    } else {
        if(alreadyFiredBallon) {
        } else {
            QQSpriteBalloonSizechanger *touchedBalloon = (__bridge QQSpriteBalloonSizechanger*)[contact bodyA]->GetUserData();
            [touchedBalloon setWasTouched:TRUE];
            [_player setBalloonTouched:TRUE];
            alreadyFiredBallon = YES;
        }
    }
}

-(void)beginEndCollisionBetweenTrampolineAndPlayer:(LHContactInfo*)contact {
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
        
        float finalForce;
        if(trampolineVelocity <= 0.1f && trampolineVelocity >= -0.1) {    //sometimes the velocity is not 0 although the player thinks it is 0 already, therefore 0.1f
            finalForce = forceX;
        } else {
            finalForce = trampolineVelocity * 1.5; // 1.5f
        }
        [_player setForce:finalForce];
        [_player setAcceptForces:TRUE];
        
        alreadyFired = NO;
        
        if(_joystickUpActive == YES) {
            [_joystickUpGlow setVisible:NO];
            _joystickUpActive = NO;
        }
        
    } else {
        //TODO: is alreadyFired required
        // the problem is, that the Trampoline consists of more than one physical object
        // and every object is firing, isn't it?
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
                [_trampoline setRestitution:1.15f]; //1.15f
            }
            
            [_player setAllowBeaming:TRUE];
            alreadyFired = YES;
        }
    }
}

-(void)beginEndCollisionBetweenMaxHeightAndPlayer:(LHContactInfo*)contact {
    NSLog(@"--- not active 1");
    if(_noMoreCollisionHandling)return;
	if([contact contactType]) {
    } else {
        if(!_joystickUpActive) {
            NSLog(@"--- not active 2");
            [_trampoline shallChangeRestitution: TRUE];
            [_trampoline setRestitution:1.00f];  //orig 1.0f
        }
    }
}

-(void)beginEndCollisionBetweenPlayerAndBeam:(LHContactInfo*)contact{
    if(_noMoreCollisionHandling)return;
	if([contact contactType]) {
        if([_player allowBeaming]) {
            LHSprite *beam1 = [loader spriteWithUniqueName:@"beam1"];
            LHSprite *beam2 = [loader spriteWithUniqueName:@"beam2"];
            LHSprite *beamerContact = (__bridge LHSprite*)[contact bodyB]->GetUserData();
            [_player beamPlayer:beamerContact fromBeamObject:beam1 toBeamObject:beam2];
            [_player setAllowBeaming:FALSE];
            [[SimpleAudioEngine sharedEngine] playEffect:@"heavyLaserBeam.mp3"];
        }
    } else {
    }
}

//-(void)beginEndCollisionBetweenPlayerAndFloor:(LHContactInfo*)contact {
//    if(_noMoreCollisionHandling)return;
//	if([contact contactType]) {
//        //Querika
//        
//        //        [[GameManager sharedGameManager] runSceneWithID:kLevelChooser];
//        //        NSArray *balloonsNormal = [loader spritesWithTag:TAG_BALLOON];
//        //        for(QQSpriteBalloon *balloon in balloonsNormal) {
//        //            NSLog(@"##### cleanup: %@", [balloon description]);
//        //        }
//        //        _myCleanUp = YES;
//        
//        //_reloadLevel = YES;
//        _player.lifes--;
//        [[SimpleAudioEngine sharedEngine] playEffect:@"ouch_que.mp3"];
//        if([_player lifes] == 0) {
//            _gameOverLevelPassed = NO;
//            [self changeLevelStatus:levelGameOver];
//            
//        } else {
//            [self changeLevelStatus:levelPausedLifeLost];
//        }
//    }
//}

-(void)beginEndCollisionBetweenPlayerAndFloor:(LHContactInfo*)contact {
    if(_noMoreCollisionHandling)return;
	if([contact contactType]) {
        _player.lifes--;
        [[SimpleAudioEngine sharedEngine] playEffect:@"ouch_que.mp3"];
        [self changeLevelStatus:liveLost withActionRequired:YES];
    }
}
#pragma mark


# pragma mark helpLabel
// HELP LABEL
-(void)setupHelpLabel {
    _loaderHelpLabel = [[LevelHelperLoader alloc] initWithContentOfFile:@"helpLabels"];
    [_loaderHelpLabel addObjectsToWorld:_world cocos2dLayer:self];
    
    NSString *labelName = [[[GameManager sharedGameManager] levelToRun] stringByAppendingString:@"_1"];
    _helpLabel = [_loaderHelpLabel spriteWithUniqueName:labelName];
    
    if(_helpLabel != nil) {
        [_helpLabel setVisible:YES];
        [_tapScreenButton setVisible:NO];
        [_tapScreenButton setTouchesDisabled:YES];
        //[_spritePauseButton setTouchesDisabled:YES];
        
        [_helpLabel registerTouchBeganObserver:self selector:@selector(touchBeganHelpLabel_1:)];
        [_helpLabel registerTouchEndedObserver:self selector:@selector(touchEndedHelpLabel_1:)];
    }
}

-(void)touchEndedHelpLabel_1:(LHTouchInfo*)info {
    if(info.sprite) {
//        [_helpLabel setVisible:NO];
//        [_helpLabel setTouchesDisabled:YES];
        [_helpLabel removeSelf];
        
        NSString *labelName = [[[GameManager sharedGameManager] levelToRun] stringByAppendingString:@"_2"];
        _helpLabel = [_loaderHelpLabel spriteWithUniqueName:labelName];
        
        if(_helpLabel != nil) {
            [_helpLabel setVisible:YES];
            [_helpLabel registerTouchBeganObserver:self selector:@selector(touchBeganHelpLabel_2:)];
            [_helpLabel registerTouchEndedObserver:self selector:@selector(touchEndedHelpLabel_2:)];
        } else {
            [_tapScreenButton setVisible:YES];
            [_tapScreenButton setTouchesDisabled:NO];
            [self changeLevelStatus:tapScreen withActionRequired:YES];
            //[_spritePauseButton setTouchesDisabled:NO];
        }
    }
}

-(void)touchEndedHelpLabel_2:(LHTouchInfo*)info {
    if(info.sprite) {
//        [_helpLabel setVisible:NO];
//        [_helpLabel setTouchesDisabled:YES];
        [_helpLabel removeSelf];
        
        NSString *labelName = [[[GameManager sharedGameManager] levelToRun] stringByAppendingString:@"_3"];
        _helpLabel = [_loaderHelpLabel spriteWithUniqueName:labelName];
        
        if(_helpLabel != nil) {
            [_helpLabel setVisible:YES];
            [_helpLabel registerTouchBeganObserver:self selector:@selector(touchBeganHelpLabel_3:)];
            [_helpLabel registerTouchEndedObserver:self selector:@selector(touchEndedHelpLabel_3:)];
        } else {
            [_tapScreenButton setVisible:YES];
            [_tapScreenButton setTouchesDisabled:NO];
            [self changeLevelStatus:tapScreen withActionRequired:YES];
            //[_spritePauseButton setTouchesDisabled:NO];
        }
    }
}

-(void)touchEndedHelpLabel_3:(LHTouchInfo*)info {
    if(info.sprite) {
//        [_helpLabel setVisible:NO];
//        [_helpLabel setTouchesDisabled:YES];
        
        [_helpLabel removeSelf];
        [_tapScreenButton setVisible:YES];
        [_tapScreenButton setTouchesDisabled:NO];
        [self changeLevelStatus:tapScreen withActionRequired:YES];
    }
}
//--- HELP LABEL
#pragma mark

#pragma mark setup
// initialize your instance here
-(id)init
{
	if( (self=[super init])) {
        [self setupWorld];
        [self setupLevelHelper];
        [self setupDebugDraw];
        [self setupBalloon];
        [self setupPlayer];
        [self setupEffect];
        [self setupTrampoline];
        [self setupBeam];
        [self setupBarShaker];
        [self setupJoystick];
        [self setupLabelCountdown];
        [self setupLabelScore];
        [self setupLabelHighScore];
        [self setupLabelBuyTrampoline];
        [self setupLabelJumpButton];
        [self setupBuyLifeButton];
        [self setupRegisterForCollision];
        [self setupHelpLabel];
        [self setupRedTrampolineButton];
        [self setupGravity];
        [self setupNotifications];
        
        [self changeLevelStatus:init withActionRequired:YES];
	}
	return self;
}

-(void)didFailToReceiveAdWithError {
    NSLog(@"XXXXX no Internet");
}



-(void)setupWorld {
    b2Vec2 gravity;
    gravity.Set(0.0f, -1.75f);    //beginner 1.75f, original 2.5f
    _world = new b2World(gravity);
    _world->SetContinuousPhysics(true);
}

-(void)setupGravity {
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
}

-(void)setupLevelHelper {
    [LevelHelperLoader dontStretchArt];
    //[[LHSettings sharedInstance] setStretchArt:YES]; bolbok sylinapot
    
    //self.isTouchEnabled = YES;
    //[self setTouchEnabled:YES];
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
    [loader addObjectsToWorld:_world cocos2dLayer:self]; //creating the objects
    
    if([loader hasPhysicBoundaries])
        [loader createPhysicBoundaries:_world];
}

-(void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDelegateResume:)
                                                 name:@"appDelegateResume" object:nil];
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


-(void)setupJoystick {
    
    if([[LHSettings sharedInstance] isIphone5]) {
        loaderJoystick = [[LevelHelperLoader alloc] initWithContentOfFile:@"levelJoystick_iPhone5"];
    } else if ([[LHSettings sharedInstance] isIpad]) {
        loaderJoystick = [[LevelHelperLoader alloc] initWithContentOfFile:@"levelJoystick"];
    } else {
        loaderJoystick = [[LevelHelperLoader alloc] initWithContentOfFile:@"levelJoystick"];
    }
    [loaderJoystick addObjectsToWorld:_world cocos2dLayer:self];
    
    _joystickLeft = [loaderJoystick spriteWithUniqueName:@"joystickLeft"];
    _joystickLeftGlow = [loaderJoystick spriteWithUniqueName:@"joystickLeftGlow"];
    [_joystickLeft registerTouchBeganObserver:self selector:@selector(touchBeganJoystickLeftButton:)];
    [_joystickLeft registerTouchEndedObserver:self selector:@selector(touchEndedJoystickLeftButton:)];
    
    _joystickRight = [loaderJoystick spriteWithUniqueName:@"joystickRight"];
    _joystickRightGlow = [loaderJoystick spriteWithUniqueName:@"joystickRightGlow"];
    [_joystickRight registerTouchBeganObserver:self selector:@selector(touchBeganJoystickRightButton:)];
    [_joystickRight registerTouchEndedObserver:self selector:@selector(touchEndedJoystickRightButton:)];

    _joystickUp = [loaderJoystick spriteWithUniqueName:@"joystickUp"];
    _joystickUpGlow = [loaderJoystick spriteWithUniqueName:@"joystickUpGlow"];
    [_joystickUp registerTouchBeganObserver:self selector:@selector(touchBeganJoystickUpButton:)];
    [_joystickUp registerTouchEndedObserver:self selector:@selector(touchEndedJoystickUpButton:)];
    
    
    _spritePauseButton = [loaderJoystick spriteWithUniqueName:@"buttonPause"];
    [_spritePauseButton registerTouchBeganObserver:self selector:@selector(touchBeganPauseButton:)];
    [_spritePauseButton registerTouchEndedObserver:self selector:@selector(touchEndedPauseButton:)];
    
    _tapScreenButton = [loaderJoystick spriteWithUniqueName:@"tapScreenButton"];
    _tapScreenButtonInitialPosition = [_tapScreenButton position];
    [_tapScreenButton registerTouchBeganObserver:self selector:@selector(touchBeganTapScreenButton:)];
    [_tapScreenButton registerTouchEndedObserver:self selector:@selector(touchEndedTapScreenButton:)];
}


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
        [_particleFireBar setZOrder:0];
        
        [self addChild:_particleFireBar];
    }
}

-(void)setupBalloon {
    NSArray *balloonsShaker = [loader spritesWithTag:TAG_BALLOON_SHAKER];
    float movingStartDelay = 0;
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

-(void)setupBeam {
    LHSprite *beam1 = [loader spriteWithUniqueName:@"beam1"];
    LHSprite *beam2 = [loader spriteWithUniqueName:@"beam2"];
    
    if(nil != beam1 && nil != beam2) {
        _particleBeam1 = [[CCParticleSystemQuad alloc] initWithFile:@"particleBeam4.plist"];
        CGPoint particlePosition;
        particlePosition.x = [beam1 position].x;
        particlePosition.y = [beam1 position].y;
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
    [_player makeStatic];
    [_player setInitialPositionWithLoader:loader withLayer:self];
}

-(void)setupLabelCountdown {
    LHSprite* spriteCountdown = [loaderJoystick spriteWithUniqueName:@"countDown"];
    _spriteWatch = [loaderJoystick spriteWithUniqueName:@"stopWatch"];
    
    //TODO: COUNTDOWN is deprecated
    double countdown = COUNTDOWN;
    NSString* stringCountdown = [NSString stringWithFormat:@"%0.1f", countdown];
    
//    _labelCountdown = [CCLabelTTF labelWithString:stringCountdown
//                                       dimensions:CGSizeMake(50, 50)
//                                       hAlignment:kCCTextAlignmentRight
//                                       vAlignment:kCCVerticalTextAlignmentCenter
//                                         fontName:@"Marker Felt"
//                                         fontSize:16];
    
    _labelCountdown = [CCLabelTTF labelWithString:stringCountdown
                                         fontName:@"Marker Felt"
                                         fontSize:16
                                       dimensions:CGSizeMake(50, 50)
                                       hAlignment:kCCTextAlignmentRight
                                       vAlignment:kCCVerticalTextAlignmentCenter];
    
    
    [_labelCountdown setColor:ccc3(0,0,0)];
    [_labelCountdown setPosition:spriteCountdown.position];
    [_labelCountdown setOpacity:200];
    [_spriteWatch setOpacity:200];
    [self addChild:_labelCountdown];
}


-(void)setupLabelScore {
    LHSprite* spriteScore = [loaderJoystick spriteWithUniqueName:@"score"];
    NSString* stringScore = [NSString stringWithFormat:@"%d", _score];

    _labelScore = [CCLabelTTF labelWithString:stringScore
                                     fontName:@"Marker Felt"
                                     fontSize:16
                                   dimensions:CGSizeMake(50, 50)
                                   hAlignment:kCCTextAlignmentRight
                                   vAlignment:kCCVerticalTextAlignmentCenter];
    [_labelScore setColor:ccc3(0,0,0)];
    [_labelScore setPosition:[spriteScore position]];
    [_labelScore setOpacity:200];
    [self addChild:_labelScore];
}

-(void)setupLabelHighScore {
    LHSprite* spriteScoreOld = [loaderJoystick spriteWithUniqueName:@"scoreOld"];
    NSString* stringHighScore = [NSString stringWithFormat:@"%d", _highScore];
    
    _labelHighScore = [CCLabelTTF labelWithString:stringHighScore
                                     fontName:@"Marker Felt"
                                     fontSize:16
                                   dimensions:CGSizeMake(50, 50)
                                   hAlignment:kCCTextAlignmentRight
                                   vAlignment:kCCVerticalTextAlignmentCenter];
    
    
    [_labelHighScore setColor:ccc3(0,0,0)];
    [_labelHighScore setPosition:[spriteScoreOld position]];
    [self addChild:_labelHighScore];
}

#pragma mark handle Lifes
-(void)setupBuyLifeButton {
    _buttonBuyLife = [loaderJoystick spriteWithUniqueName:@"buyLifeButton"];
    [_buttonBuyLife registerTouchBeganObserver:self selector:@selector(touchBeganBuyLifeButton:)];
    [_buttonBuyLife registerTouchEndedObserver:self selector:@selector(touchEndedBuyLifeButton:)];
    
    LHSprite* spriteBuyLife = [loaderJoystick spriteWithUniqueName:@"buyLife"];
    
    NSString* stringBuyLife;
    if([[GameState sharedInstance] lifesLeft] == 0) {
        stringBuyLife = @"buy";
    } else {
        stringBuyLife = [NSString stringWithFormat:@"%d", [[GameState sharedInstance] lifesLeft]];
    }
    
    _labelBuyLifeButton = [CCLabelTTF labelWithString:stringBuyLife
                                             fontName:@"Marker Felt"
                                             fontSize:14
                                           dimensions:CGSizeMake(50, 50)
                                           hAlignment:kCCTextAlignmentCenter
                                           vAlignment:kCCVerticalTextAlignmentCenter];
    
    
    [_labelBuyLifeButton setColor:ccc3(0,0,0)];
    [_labelBuyLifeButton setPosition:[spriteBuyLife position]];
    [self addChild:_labelBuyLifeButton];
}

-(void)touchBeganBuyLifeButton:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"touchBeganBuyLifeButton");
    }
}

-(void)touchEndedBuyLifeButton:(LHTouchInfo*)info {
    if(info.sprite) {
        if(_player.lifes <= LIFES  && [[GameState sharedInstance] lifesLeft] > 0) {
            NSLog(@"touchEndedBuyLifeButton");

            [[GameState sharedInstance] setLifesLeft:[[GameState sharedInstance] lifesLeft] -1];
            [_labelBuyLifeButton setString:[NSString stringWithFormat:@"%d", [[GameState sharedInstance] lifesLeft]]];
            [self addLife];
            
            [[GameState sharedInstance] save];
            if([[GameState sharedInstance] lifesLeft] == 0) {
                [_labelBuyLifeButton setString:@"buy"];
            }
        } else if ([[GameState sharedInstance] lifesLeft] == 0) {
            NSLog(@"Open market");
            [self removeAd];
            if(_myLevelState == running) {
                [_player makeStatic];
                [[CCDirector sharedDirector] resume];
            }
            
            [[QQInAppPurchaseLayer sharedInstance] showIAPStoreFromLevel:self];
        }
    }
}

-(void)updateStringLifeButton {
    if([[GameState sharedInstance] lifesLeft] == 0) {
        [_labelBuyLifeButton setString:@"buy"];
    } else {
        [_labelBuyLifeButton setString:[NSString stringWithFormat:@"%d", [[GameState sharedInstance] lifesLeft]]];
    }
}

-(void)addLife {
    _player.lifes++;
    NSLog(@"...add lives: %d", _player.lifes);
    switch (_player.lifes) {
        case 2: {
            LHSprite* life = [loaderJoystick spriteWithUniqueName:@"bunny_lifes_2"];
            [life setVisible:YES];
            break;
        }
        case 3: {
            LHSprite* life = [loaderJoystick spriteWithUniqueName:@"bunny_lifes_3"];
            [life setVisible:YES];
            break;
        }
        case 4: {
            LHSprite* life = [loaderJoystick spriteWithUniqueName:@"bunny_lifes_4"];
            [life setVisible:YES];
            break;
        }
            
        default:
            break;
    }
}

-(void)removeLife {
    NSLog(@"...remove lives: %d", _player.lifes);
    switch (_player.lifes) {
        case 3: {
            LHSprite* life = [loaderJoystick spriteWithUniqueName:@"bunny_lifes_4"];
            //[life removeSelf];
            [life setVisible:NO];
            break;
        }
        case 2: {
            LHSprite* life = [loaderJoystick spriteWithUniqueName:@"bunny_lifes_3"];
            //[life removeSelf];
            [life setVisible:NO];
            break;
        }
        case 1: {
            LHSprite* life = [loaderJoystick spriteWithUniqueName:@"bunny_lifes_2"];
            //[life removeSelf];
            [life setVisible:NO];
            break;
        }
        case 0: {
            LHSprite* life = [loaderJoystick spriteWithUniqueName:@"bunny_lifes_1"];
            //[life removeSelf];
            [life setVisible:NO];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark JumpButton
-(void)setupLabelJumpButton {
    LHSprite* spriteBuyJump = [loaderJoystick spriteWithUniqueName:@"buyJump"];
    NSString* stringBuyJump;
    
    if([[GameState sharedInstance] redTrampolinesLeft] == 0) {
        stringBuyJump = @"buy";
    } else {
        stringBuyJump = [NSString stringWithFormat:@"%d", [[GameState sharedInstance] redTrampolinesLeft]];
    }
    
    _labelBuyJumpButton = [CCLabelTTF labelWithString:stringBuyJump
                                             fontName:@"Marker Felt"
                                             fontSize:14
                                           dimensions:CGSizeMake(50, 50)
                                           hAlignment:kCCTextAlignmentCenter
                                           vAlignment:kCCVerticalTextAlignmentCenter];
    
    
    //[_labelBuyJumpButton setColor:ccc3(0,0,0)];
    [_labelBuyJumpButton setColor:ccc3(255,255,255)];
    [_labelBuyJumpButton setPosition:[spriteBuyJump position]];
    [self addChild:_labelBuyJumpButton];
}

-(void)updateStringJumpButton {
    if([[GameState sharedInstance] jumpButtonsLeft] == 0) {
        [_labelBuyJumpButton setString:@"buy"];
    } else {
        [_labelBuyJumpButton setString:[NSString stringWithFormat:@"%d", [[GameState sharedInstance] jumpButtonsLeft]]];
    }
}

-(void)touchBeganJoystickUpButton:(LHTouchInfo*)info {
    if(info.sprite) {
        if(!_joystickUpActive && [[GameState sharedInstance] jumpButtonsLeft] > 0) {
            [_trampoline setRestitution:2.00f]; //1.15f
            [_trampoline shallChangeRestitution: TRUE];
            [_joystickUpGlow setVisible:YES];
            _joystickUpActive = YES;
            
            [[GameState sharedInstance] setJumpButtonsLeft:[[GameState sharedInstance] jumpButtonsLeft] - 1];
        } else if ([[GameState sharedInstance] jumpButtonsLeft] == 0) {
            NSLog(@"Open market");
            [self removeAd];
            if(_myLevelState == running) {
                [_player makeStatic];
                [[CCDirector sharedDirector] resume];
            }
            
            [[QQInAppPurchaseLayer sharedInstance] showIAPStoreFromLevel:self];
        }
    }
}

-(void)touchEndedJoystickUpButton:(LHTouchInfo*)info {
    if(info.sprite) {
    }
}

#pragma mark buyTrampoline
-(void)setupRedTrampolineButton {
    _redTrampolineButton = [loaderJoystick spriteWithUniqueName:@"buyTrampolineButton"];
    [_redTrampolineButton registerTouchBeganObserver:self selector:@selector(touchBeganRedTrampolineButton:)];
    [_redTrampolineButton registerTouchEndedObserver:self selector:@selector(touchEndedRedTrampolineButton:)];
}

-(void)setupLabelBuyTrampoline {
    //int redTrampolinesLeft = 33;
    
    
    LHSprite* spriteBuyTrampoline = [loaderJoystick spriteWithUniqueName:@"buyTrampoline"];
    NSString* stringBuyTrampoline;
    
    if([[GameState sharedInstance] redTrampolinesLeft] == 0) {
        stringBuyTrampoline = @"buy";
    } else {
        stringBuyTrampoline = [NSString stringWithFormat:@"%d", [[GameState sharedInstance] redTrampolinesLeft]];
    }
    
    _labelBuyTrampoline = [CCLabelTTF labelWithString:stringBuyTrampoline
                                         fontName:@"Marker Felt"
                                         fontSize:12
                                       dimensions:CGSizeMake(50, 50)
                                       hAlignment:kCCTextAlignmentCenter
                                       vAlignment:kCCVerticalTextAlignmentCenter];
    
    
    [_labelBuyTrampoline setColor:ccc3(0,0,0)];
    [_labelBuyTrampoline setPosition:[spriteBuyTrampoline position]];
    [self addChild:_labelBuyTrampoline];
}

-(void)updateStringRedTramplines {
    if([[GameState sharedInstance] redTrampolinesLeft] == 0) {
        [_labelBuyTrampoline setString:@"buy"];
    } else {
        [_labelBuyTrampoline setString:[NSString stringWithFormat:@"%d", [[GameState sharedInstance] redTrampolinesLeft]]];
    }
}


-(void)touchBeganRedTrampolineButton:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"touchBeganRedTrampolineButton");
    }
}

-(void)touchEndedRedTrampolineButton:(LHTouchInfo*)info {
    if(info.sprite) {
        if(!_trampoline.redTrampolineActive && [[GameState sharedInstance] redTrampolinesLeft] > 0) {
            NSLog(@"touchEndedRedTrampolineButton");
            //[[TBJIAPHelper sharedInstance] requestProducts];
            
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
            
            NSLog(@"1 touchEndedRedTrampolineButton: %d", [[GameState sharedInstance] redTrampolinesLeft]);
            [[GameState sharedInstance] setRedTrampolinesLeft:[[GameState sharedInstance] redTrampolinesLeft] -1];
            NSLog(@"2 touchEndedRedTrampolineButton %d", [[GameState sharedInstance] redTrampolinesLeft]);
            
            [_labelBuyTrampoline setString:[NSString stringWithFormat:@"%d", [[GameState sharedInstance] redTrampolinesLeft]]];
            
            [[GameState sharedInstance] save];
            if([[GameState sharedInstance] redTrampolinesLeft] == 0) {
                [_labelBuyTrampoline setString:@"buy"];
            }
        } else if ([[GameState sharedInstance] redTrampolinesLeft] == 0) {
            NSLog(@"Open market");
            [self removeAd];
            if(_myLevelState == running) {
                [_player makeStatic];
                [[CCDirector sharedDirector] resume];
            }
            
            [[QQInAppPurchaseLayer sharedInstance] showIAPStoreFromLevel:self];
        }
    }
}

#pragma mark
-(void)setupDebugDraw {
    m_debugDraw = new GLESDebugDraw();
    _world->SetDebugDraw(m_debugDraw);
    uint32 flags = 0;
    flags += b2Draw::e_shapeBit;
    flags += b2Draw::e_jointBit;
    m_debugDraw->SetFlags(flags);
}
# pragma mark

# pragma mark update
-(void)tick:(ccTime)dt {
    //FIX TIME STEPT
	[self step:dt];
    [self update:dt];
}

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

-(void)afterStep:(ccTime)dt {
    //printf(".");
	// process collisions and result from callbacks called by the step
    [self makeObjectsInvisibleAndStatic];
    [_player restoreInitialPosition:loader withLayer:self];
    [_player stopPlayer];


    
    [_player applyForce];
    [_player deflect];   //give the bunny a force when a balloon is touched
    [_player beamWithLoader:loader];
    [_player upOrDownActionWithLoader:loader];
    
    [_trampoline move:dt];
    [_trampoline setRestitutionAtTick];
    
    NSArray *bars = [loader spritesWithTag:TAG_BAR];
    for(QQSpriteBar *bar in bars) {
        [bar updateBar:dt];
    }
    


    [self updateLabelCountdown];
    [self updateLabelScore];
    [self updateLabelHighScore];
    [self updateLeveState:dt];
    



    if(_tapScreenButtonMakeDynamicRequired) {
        [_tapScreenButton transformPosition:_tapScreenButtonInitialPosition];
        [_tapScreenButton makeDynamic];
        _tapScreenButtonMakeDynamicRequired = NO;
    }
    
    if(_backLevel == YES) {
        [[GameManager sharedGameManager] runSceneWithID:kLevelChooser];
        //[self myCleanup];

        NSLog(@"+++++ _backLevel == YES");
        _backLevel = NO;
    }
    
    if(_reloadLevel == YES) {
        [[GameManager sharedGameManager] runSceneWithID:[[GameManager sharedGameManager] currentScene]];
        [self myCleanup];
        _reloadLevel = NO;
    }
    
    LHSprite* fireBar = [loader spriteWithUniqueName:@EFFECT_FIREBAR];
    if(_particleFireBar != nil) {
        CGPoint particleFireBarPosition;
        particleFireBarPosition.x = [fireBar position].x;
        particleFireBarPosition.y = [fireBar position].y;
        [_particleFireBar setPosition:particleFireBarPosition];
    }
    
    [self updateStringRedTramplines];
    [self updateStringJumpButton];
    [self updateStringLifeButton];
}

-(void)onExit {
    NSLog(@"xxxxx Level::onExit!");
    [super onExit];
    [self myCleanup];
}


-(void)update:(ccTime)dt {
    [self updateBox2D:dt];
    [self updateSprites:dt];
}

- (void)updateBox2D:(ccTime)dt {
    _world->Step(dt, 1, 1);
    _world->ClearForces();
}

-(void)updateSprites:(ccTime)dt {
    //Iterate over the bodies in the physics world
	for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL)
        {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (__bridge CCSprite*)b->GetUserData();
            
            if(myActor != 0)
            {
                //THIS IS VERY IMPORTANT - GETTING THE POSITION FROM BOX2D TO COCOS2D
                myActor.position = [LevelHelperLoader metersToPoints:b->GetPosition()];
                myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            }
            
        }
	}
}

-(void)updateLabelScore {
    [_labelScore setString:[NSString stringWithFormat:@"%d", _score]];
}

-(void)updateLabelHighScore {
    if(_highScore < _score) {
        [_labelHighScore setString:[NSString stringWithFormat:@"%d", _highScore]];
    } else {
        [_labelHighScore setString:[NSString stringWithFormat:@"%d", _highScore]];
    }
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

-(void)updateLeveState:(ccTime)dt {
    switch (_myLevelState) {
        case init: {
            
            break;
        }
            
        case helpLabels: {
            
            break;
        }
            
        case tapScreen: {
            break;
        }
            
        case bunnyJump: {
            break;
        }
            
        case running: {
            //printf(".");
            if(_countDown > 0) {
                _countDown -= dt;
            }
            if(_countDown < 0) _countDown = 0;
            
            NSInteger balloonsLeft = 0;
            
            NSArray *balloonsNormal = [loader spritesWithTag:TAG_BALLOON];
            for(QQSpriteBalloon *balloon in balloonsNormal) {
                _score = [balloon reactToTouch:_world withLayer:self withScore:_score withCountdown:_countDown];
                balloonsLeft++;
            }
            
            NSArray *balloonsShaker = [loader spritesWithTag:TAG_BALLOON_SHAKER];
            for(QQSpriteBalloonShake *balloon in balloonsShaker) {                
                _score = [balloon reactToTouch:_world withLayer:self withScore:_score withCountdown:_countDown];
                balloonsLeft++;
            }
            
            NSArray *balloonsSizechanger = [loader spritesWithTag:TAG_BALLOON_SIZECHANGER];
            for(QQSpriteBalloonShake *balloon in balloonsSizechanger) {
                _score = [balloon reactToTouch:_world withLayer:self withScore:_score withCountdown:_countDown];
                balloonsLeft++;
            }
            
            NSArray *balloonsThreetimestoucher = [loader spritesWithTag:TAG_BALLOON_THREETIMESTOUCHER];
            for(QQSpriteBalloonThreetimestoucher *balloon in balloonsThreetimestoucher) {
                if(balloon._balloonCompletelyInflated == YES) {
                    _score = [balloon reactToTouch:_world withLayer:self withScore:_score withCountdown:_countDown];
                }
                balloonsLeft++;
            }
            
            NSArray *balloonsBlinker = [loader spritesWithTag:TAG_BALLOON_BLINKER];
            for(QQSpriteBalloonBlinker *balloon in balloonsBlinker) {
                _score = [balloon reactToTouch:_world withLayer:self withScore:_score withCountdown:_countDown];
                balloonsLeft++;
            }
            
            if(balloonsLeft == 0) {
                _gameOverLevelPassed = YES;
                [self changeLevelStatus:gameOver withActionRequired:YES];
            }
            break;
        }
            
        case liveLost: {
            //[_player restoreInitialPosition:loader withLayer:self];
            break;
        }
            
        case gameOver: {
            
            break;
        }
            
        case paused: {

            break;
        }
            
        default:
            break;
    }

}
# pragma mark

#pragma mark touchHandler
//-(void)touchBeganTapScreenButton:(LHTouchInfo*)info {
//    if(info.sprite) {
//        if(_levelStarted == NO) {
//            _levelStarted = YES;
//            [_player makeDynamic];
//        }
//    }
//    [self changeLevelStatus:tapScreen withActionRequired:YES];
//    
//    CCParticleSystemQuad* particle1 = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
//    [particle1 setPosition:CGPointMake([_tapScreenButton position].x - _tapScreenButton.contentSize.width/2, [_tapScreenButton position].y)];
//    [self addChild:particle1];
//    CCParticleSystemQuad* particle2 = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
//    [particle2 setPosition:CGPointMake([_tapScreenButton position].x, [_tapScreenButton position].y)];
//    [self addChild:particle2];
//    CCParticleSystemQuad* particle3 = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
//    [particle3 setPosition:CGPointMake([_tapScreenButton position].x + _tapScreenButton.contentSize.width/2, [_tapScreenButton position].y)];
//    [self addChild:particle3];
//    [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
//    
//    NSLog(@"tapscreenButton");
//    //[_myAdmob hideBannerView];
//    //[_myAdmob dismissAdView];
//}

-(void)touchBeganTapScreenButton:(LHTouchInfo*)info {
    if(info.sprite) {
        CCParticleSystemQuad* particle1 = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
        [particle1 setPosition:CGPointMake([_tapScreenButton position].x - _tapScreenButton.contentSize.width/2, [_tapScreenButton position].y)];
        [self addChild:particle1];
        CCParticleSystemQuad* particle2 = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
        [particle2 setPosition:CGPointMake([_tapScreenButton position].x, [_tapScreenButton position].y)];
        [self addChild:particle2];
        CCParticleSystemQuad* particle3 = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
        [particle3 setPosition:CGPointMake([_tapScreenButton position].x + _tapScreenButton.contentSize.width/2, [_tapScreenButton position].y)];
        [self addChild:particle3];
        [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
        
        [self changeLevelStatus:bunnyJump withActionRequired:YES];
    }
}

-(void)touchBeganPauseButton:(LHTouchInfo*)info{
    if(info.sprite) {

    }
}
-(void)touchEndedPauseButton:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxx");
        [self changeLevelStatus:paused withActionRequired:YES];
    }
}

-(void)makePlayerDynamic {
    [_player makeDynamic];
}

-(void)touchBeganJoystickLeftButton:(LHTouchInfo*)info {
    if(info.sprite) {
        [_trampoline setCurrentMoveState:MS_LEFT];
        [_joystickLeftGlow setVisible:YES];
    }
}

-(void)touchEndedJoystickLeftButton:(LHTouchInfo*)info {
    if(info.sprite) {
        [_joystickLeftGlow setVisible:NO];
        [_trampoline setCurrentMoveState:MS_STOP];
    }
}

-(void)touchBeganJoystickRightButton:(LHTouchInfo*)info {
    if(info.sprite) {
        [_trampoline setCurrentMoveState:MS_RIGHT];
        [_joystickRightGlow setVisible:YES];
    }
}

-(void)touchEndedJoystickRightButton:(LHTouchInfo*)info {
    if(info.sprite) {
        [_joystickRightGlow setVisible:NO];
        [_trampoline setCurrentMoveState:MS_STOP];
    }
}

/*
 -(void)disableTouches {
 [_tapScreenButton setTouchesDisabled:YES];
 [_spritePauseButton setTouchesDisabled:YES];
 }
 */

-(void)disableTouchesForPause:(BOOL)touchEnabled {
    [super setTouchEnabled:!touchEnabled];
    NSArray *spritesJoystick = [loaderJoystick allSprites];
    for(LHSprite *sprite in spritesJoystick) {
        [sprite setTouchesDisabled:touchEnabled];
    }
    NSArray *spritesHelpLabel = [_loaderHelpLabel allSprites];
    for(LHSprite *sprite in spritesHelpLabel) {
        [sprite setTouchesDisabled:touchEnabled];
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
}

-(void)enableTouches {
    //workaround because self.isTouchEnabled = NO; doesn't work for cocos2d 2.0
    //and setTouchesEnabled is only available on cocos2d 2.irgendwas
    //NSLog(@"--- 2.pauseLevel");
    NSArray *sprites = [loader allSprites];
    for(LHSprite *sprite in sprites) {
        [sprite setTouchesDisabled:NO];
    }
    NSArray *spritesJoystick = [loaderJoystick allSprites];
    for(LHSprite *sprite in spritesJoystick) {
        [sprite setTouchesDisabled:NO];
    }
}
# pragma mark

# pragma mark cleanup
-(void)saveGameState {

    
    //NSLog(@"--- saveGameState");
    //save gameCenter
    //[GameState sharedInstance].completedSeasonSpring2012 = true;
    //[[GCHelper sharedInstance] reportAchievements:kAchievementSeasonSpring2012 percentComplete:25.0f];
    //[[GCHelper sharedInstance] reportAchievements:kAchievementSeasonSummer2012 percentComplete:1.0f];

    //TODO: current Scene is 2012000???
    //NSLog(@"--- current Scene %d", [[GameManager sharedGameManager] currentScene] - 2012000);

    int currentLevelAsInt = [[GameManager sharedGameManager] currentScene] - 2012000;
    float percentComplete = currentLevelAsInt * 100 / LEVELS_PER_SEASON;
    
    
    if([[GameManager sharedGameManager] season] == spring)
    {
        //NSLog(@"--- current Season: Spring");
        [[GCHelper sharedInstance] reportAchievements:kAchievementSeasonSpring2012 percentComplete:percentComplete];
    } else if([[GameManager sharedGameManager] season] == summer)
    {
        //NSLog(@"--- current Season: Summer");
        [[GCHelper sharedInstance] reportAchievements:kAchievementSeasonSummer2012 percentComplete:percentComplete];
    } else if([[GameManager sharedGameManager] season] == fall)
    {
        //NSLog(@"--- current Season: Fall");
        [[GCHelper sharedInstance] reportAchievements:kAchievementSeasonFall2012 percentComplete:percentComplete];
    } else if([[GameManager sharedGameManager] season] == winter)
    {
        //NSLog(@"--- current Season: Winter");
        [[GCHelper sharedInstance] reportAchievements:kAchievementSeasonWinter2012 percentComplete:percentComplete];
    } else {
        //NSLog(@"QQLevel: something is wrong in saveGameState!");
    }
    
    //reset Achievements
    //[[GCHelper sharedInstance] resetAchievements];
    
    
    //save HighScore if needed
    if(_score > _highScore) {
        [[[GameState sharedInstance] tempHighScore] setObject:[NSNumber numberWithInt:_score] forKey:[[GameManager sharedGameManager] levelToRun]];
        //NSLog(@"- saveHighScore %@", [[GameState sharedInstance] tempHighScore]);
    }
    //--- save HighScore
    
    [[GameState sharedInstance] save];
    
    [self saveLeaderboard];
}

-(void)saveLeaderboard {
    //report Leaderboard to iTunes Connect
    //int sumHighscoreAllLevels = 0;
    int sumHighscoreSpring2012 = 0;
    int sumHighscoreSummer2012 = 0;
    int sumHighscoreFall2012 = 0;
    int sumHighscoreWinter2012 = 0;
    for(id key in [[GameState sharedInstance] tempHighScore]) {
        NSNumber *value = [[[GameState sharedInstance] tempHighScore] objectForKey:key];
        //sumHighscoreAllLevels += [value intValue];
        //NSLog(@"sumHighscoreAllLevels: %d", sumHighscoreAllLevels);
        
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
    //NSLog(@"sumHighscoreAllLevels: %d", sumHighscoreAllLevels);
    //NSLog(@"sumHighscoreSpring: %d", sumHighscoreSpring2012);
    //NSLog(@"sumHighscoreSummer: %d", sumHighscoreSummer2012);
    //NSLog(@"sumHighscoreFall: %d", sumHighscoreFall2012);
    //NSLog(@"sumHighscoreWinter: %d", sumHighscoreWinter2012);
    
    //int scoreAllLevels = 20;
    //NSLog(@"-- QQLevel::saveLeaderboard");
    //[[GCHelper sharedInstance] reportScore:kLeaderBoard score:(int)sumHighscoreAllLevels];
    [[GCHelper sharedInstance] reportScore:kLeaderBoardSpring2012 score:(int)sumHighscoreSpring2012];
    [[GCHelper sharedInstance] reportScore:kLeaderBoardSummer2012 score:(int)sumHighscoreSummer2012];
    [[GCHelper sharedInstance] reportScore:kLeaderBoardFall2012 score:(int)sumHighscoreFall2012];
    [[GCHelper sharedInstance] reportScore:kLeaderBoardWinter2012 score:(int)sumHighscoreWinter2012];
}

#pragma mark AdMob
//in case of an AbMob AdBanner is shown, the pauseButton is moved down
-(void)admobAdReceived:(QQAdmob *)sender {
    NSLog(@"XXXXX admobAdReceived");
    NSLog(@"XXXXX 2.) height: %f", [_myAdmob bannerHeight]);
    [_spritePauseButton setPosition:
     CGPointMake([_spritePauseButton position].x, [_spritePauseButton position].y - [_myAdmob bannerHeight])];
}

-(void)requestAd {
    if(![[GameState sharedInstance] isPayingUser]) {
        _myAdmob = [QQAdmob node];
        [self addChild:_myAdmob];
        [_myAdmob setDelegate:self];
        NSLog(@"XXXXX 1.) height: %f", [_myAdmob bannerHeight]);
    }
}

-(void)removeAd {
    if(![[GameState sharedInstance] isPayingUser]) {
        [_spritePauseButton setPosition:
         CGPointMake([_spritePauseButton position].x, [_spritePauseButton position].y + [_myAdmob bannerHeight])];
        [_myAdmob dismissAdView];
    }
}

#pragma mark cleanup
-(void)myCleanup {
    //NSLog(@"####################################### QQLevel::myCleanup");
    //[self saveGameState];
    [self removeAd];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unscheduleAllSelectors];

    [_helpLabel removeSelf];
    [_myAdmob removeFromParentAndCleanup:YES];

    _noMoreCollisionHandling = true;

    if(nil != _loaderHelpLabel) {
        [_loaderHelpLabel removeAllPhysics];
        _loaderHelpLabel = nil;
    }
    if(nil != loaderJoystick) {
        [loaderJoystick removeAllPhysics];        
        loaderJoystick = nil;
    }
    
    if(nil != _loaderOverlayGameOver) {
        [_loaderOverlayGameOver removeAllPhysics];
        _loaderOverlayGameOver = nil;
    }
    _gameOverLayer = nil;
    
    if(nil != loader) {
        [loader removeAllPhysics];
        [_trampoline removeSelf];
        _trampoline = nil;
        [_player removeSelf];
        _player = nil;
        loader = nil;
    }
}

-(void)dealloc
{
    NSLog(@"####################################### QQLevel::dealloc");
    
    //[_trampoline removeSelf];
    //_gameOverLayer = nil;

    delete _world;
	_world = NULL;
  	delete m_debugDraw;
}

#pragma mark helper
-(void)changeLevelStatus:(stateMachine)levelStatus_ withActionRequired:(BOOL)actionRequired {
    _myLevelState = levelStatus_;
    if(actionRequired) {
        switch (levelStatus_) {
            case init: {
                NSLog(@"********** levelStatus::init - %d", _bled++);
                _highScore = [[[[GameState sharedInstance] tempHighScore] objectForKey:[[GameManager sharedGameManager] levelToRun]] intValue];


                [self changeLevelStatus:helpLabels withActionRequired:YES];
                break;
            }
                
            case helpLabels: {
                NSLog(@"********** levelStatus::helpLabels - %d", _bled++);
                if(_helpLabel == nil) {
                    [self changeLevelStatus:tapScreen withActionRequired:YES];
                }
                break;
            }
                
            case tapScreen: {
                NSLog(@"********** levelStatus::tapScreen - %d", _bled++);                
                
                [self requestAd];
                
                break;
            }
                
            case bunnyJump: {
                 NSLog(@"********** levelStatus::bunnyJump - %d", _bled++);
                
                
                [_player makeDynamic];
                [_player applyStartJumpWithImpulseX:_startImpulseX withImpulseY:_startImpulseY];


                [self changeLevelStatus:running withActionRequired:YES];
                break;
            }
                
            case running: {
                NSLog(@"********** levelStatus::running - %d", _bled++);
                [self removeAd];
                
                [_player makeDynamic];
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
                
            case liveLost: {
                NSLog(@"********** levelStatus::liveLost - %d", _bled++);
                
                
                if([_player lifes] == 0) {
                    //_gameOverLevelPassed = NO;
                    [self changeLevelStatus:gameOver withActionRequired:YES];
                } else {
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

                    [self changeLevelStatus:tapScreen withActionRequired:YES];
                }
                break;
                
            }
                
            case gameOver: {
                NSLog(@"********** levelStatus::gameOver - %d", _bled++);
                //player has finished the game
                //ether he won or he lost
                if(_gameOverLevelPassed) {
                    [[GameState sharedInstance] unlockNextLevel];
                    
                    BOOL levelPassedInTime;
                    if(_countDown > 0) {
                        levelPassedInTime = YES;
                    } else {
                        levelPassedInTime = NO;
                    }
                    
                    [self disableTouches];
                    [_player makeInvisibleAndStaitc:loader];

                    
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
                //[self myCleanup];
                //_myCleanUp = YES;

                break;
            }
                
            case paused: {
                NSLog(@"********** levelStatus::paused - %d", _bled++);
                
                
                [[QQPauseLayer sharedInstance] pauseLevel:self];
                [self disableTouches];
                break;
            }
                
            default:
                NSLog(@"********** levelStatus::default - %d", _bled++);
                
                
                break;
        }
    }
}

-(stateMachine)getLevelState {
    return _myLevelState;
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

- (void)appDelegateResume:(NSNotification *)note {
    //if(_levelState == levelPaused) {
//    if(_myLevelState == paused) {
//        [[CCDirector sharedDirector] pause];
//    }
//    else {
//        [self changeLevelStatus:paused withActionRequired:YES];
//    }
    if(!_inAppPurchaseStoreOpen) {
        if(_myLevelState == running) {
            [self changeLevelStatus:paused withActionRequired:YES];
        }
        else if (_myLevelState == paused) {
            [[CCDirector sharedDirector] pause];
        }
    }
}


-(void)showOverlayGameOver {
    _loaderOverlayGameOver = [[LevelHelperLoader alloc] initWithContentOfFile:@"overlayGameOver"];
    [_loaderOverlayGameOver addSpritesToLayer:self];
    
}

- (float)randomFloatBetween:(float)smallNumber andWith:(float)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

-(void) onEnter
{
	[super onEnter];
}
#pragma mark

#pragma mark empty
-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event { }
-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event { }
-(void)afterStep {
    // process collisions and result from callbacks called by the step
}
-(void)touchEndedTapScreenButton:(LHTouchInfo*)info {
    if(info.sprite) {
    }
}

-(void)touchBeganHelpLabel_1:(LHTouchInfo*)info{
    if(info.sprite) {
    }
}
-(void)touchBeganHelpLabel_2:(LHTouchInfo*)info{
    if(info.sprite) {
    }
}
-(void)touchBeganHelpLabel_3:(LHTouchInfo*)info{
    if(info.sprite) {
    }
}

@end
////////////////////////////////////////////////////////////////////////////////


