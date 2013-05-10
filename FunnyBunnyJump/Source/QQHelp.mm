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


-(void)afterStep:(ccTime)dt {
    
    //if(_actionCompleted == NO && _drawDots) {
    if(_drawDots) {
        if(counter < 0.05f) {
            counter += dt;
        } else {
            LHSprite* dot = [LHSprite spriteWithName:@"dot"
                                                 fromSheet:@"assets"
                                                    SHFile:@"objects"];
            CGPoint positionStarEmpty;
            positionStarEmpty.x = [_player position].x;
            positionStarEmpty.y = [_player position].y;
            [dot setPosition:positionStarEmpty];
            [dot setTag:TAG_DOTS];
            [dot setOpacity:128];
            [self addChild:dot];
            counter = 0;
        }
    }
    
    if(_removeAllDots) {
        NSLog(@"__________ remove All dots");
        NSArray *dots = [self spritesWithTag:TAG_DOTS]; //[loader spritesWithTag:TAG_DOTS];
        for(LHSprite *dot in dots) {
            [dot removeSelf];
        }
        _removeAllDots = NO;
    }
    
    
    
    [_player applyForce];
    [_player deflect];   //give the bunny a force when a balloon is touched
    [_player upOrDownActionWithLoader:loader];
    [_player restoreInitialPosition:loader];
    
    
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
    
    
    //level completed
    if(balloonsLeft == 0 && _gameOverLevelPassed == NO) {
    //if(balloonsLeft == 0) {
        NSLog(@"___ balloonsLeft==0");
        _gameOverLevelPassed = YES;
    }
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
        }
    }
}

-(void)beginEndCollisionBetweenBalloonShakerAndPlayer:(LHContactInfo*)contact{
    if([contact contactType]) {
        QQSpriteBalloonShake *touchedBalloon = (QQSpriteBalloonShake*)[contact bodyA]->GetUserData();
        [touchedBalloon setWasTouched:TRUE];
        [_player setBalloonTouched:TRUE];
        //[[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
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
        }
    }
}

-(void)beginEndCollisionBetweenBalloonThreetimestoucherAndPlayer:(LHContactInfo*)contact{
    if([contact contactType]) {
        QQSpriteBalloonThreetimestoucher *touchedBalloon = (QQSpriteBalloonThreetimestoucher*)[contact bodyA]->GetUserData();
        if(touchedBalloon._balloonCompletelyInflated == YES) {
            [touchedBalloon setWasTouched:TRUE];
            [_player setBalloonTouched:TRUE];
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

        [_player setAcceptForces:TRUE];
        
        alreadyFired = NO;
        
    } else {
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
        NSLog(@"_________ Collision Player And Floor");
        _actionCompleted = YES;
        [_player setRestoreInitialPostitionRequired:YES];
        
        LHSprite* positionRightJump = [loader spriteWithUniqueName:@"positionRightJump"];
        [_player setPositionWithLoader:loader position:[positionRightJump position]];

        
        
        
        if(action == kActionLeftJump) {
            action = kActionRightJump;
            _removeAllDots = YES;
            LHSprite* textJumpLeft = [loader spriteWithUniqueName:@"textJumpRight"];
            [_labelHelpText removeFromParentAndCleanup:YES];
            [self drawHelpTextWithText:@"the more right on the on the trampoline, the more right the bunny jumps! Doesn't it?" withSprite:textJumpLeft];
        } else if (action == kActionRightJump) {
            action = kActionMoveLeft;
            _removeAllDots = YES;
            
            LHSprite* positionLeftMove = [loader spriteWithUniqueName:@"positionLeftMove"];
            [_player setPositionWithLoader:loader position:[positionLeftMove position]];
            
            
            //[self scheduleOnce:@selector(tickMoveTrampolineLeft:) delay:0.9f];
            //[self scheduleOnce:@selector(tickMoveTrampolineRight:) delay:3.1f];
            //[self scheduleOnce:@selector(tickMoveTrampolineLeft2:) delay:3.5f];
            //[self scheduleOnce:@selector(tickMoveTrampolineRight2:) delay:4.1f];
        }
    }
}

-(void)beginEndCollisionBetweenPlayerAndTrampolineSensor:(LHContactInfo*)contact{
	if([contact contactType]) {

    } else {
        NSLog(@"--- Player And TrampolineSensor");
        if(action == kActionMoveLeft) {
            [_trampoline setCurrentMoveState:MS_LEFT];
        }
    }
}



-(void)tickMoveTrampolineLeft:(ccTime)dt {
    [_trampoline setCurrentMoveState:MS_LEFT];
}

-(void)tickMoveTrampolineRight:(ccTime)dt {
    [_trampoline setCurrentMoveState:MS_RIGHT];
}

-(void)tickMoveTrampolineLeft2:(ccTime)dt {
    [_trampoline setCurrentMoveState:MS_LEFT];
}

-(void)tickMoveTrampolineRight2:(ccTime)dt {
    [_trampoline setCurrentMoveState:MS_RIGHT];
}

-(void)drawHelpTextWithText:(NSString*)text_ withSprite:(LHSprite*)sprite_{
    //LHSprite* spriteHelpText = [loader spriteWithUniqueName:@"textJumpLeft"];
     //dimensions:CGSizeMake([spriteHelpText contentSize].width, [spriteHelpText contentSize].height)
    
    _labelHelpText = [CCLabelTTF labelWithString:text_
                                       dimensions:CGSizeMake(100, 100)
                                       hAlignment:kCCTextAlignmentLeft
                                       vAlignment:kCCVerticalTextAlignmentCenter
                                         fontName:@"Marker Felt"
                                         fontSize:16];
    [_labelHelpText setColor:ccc3(0,0,0)];
    [_labelHelpText setPosition:sprite_.position];
    [self addChild:_labelHelpText];
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
    
    [_player setInitialPositionWithLoader:loader];
    
    
    [self startLeftJumpAction];
    action = kActionLeftJump;
}

-(void)startLeftJumpAction {
    
    [self disableTouches];
    [_player makeDynamic];
    LHSprite* textJumpLeft = [loader spriteWithUniqueName:@"textJumpLeft"];
    [self drawHelpTextWithText:@"the more left the bunny on the trampoline, the more left it jumps" withSprite:textJumpLeft];
    _drawDots = YES;
    
    
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
    
    [loader registerBeginOrEndCollisionCallbackBetweenTagA:TAG_PLAYER
                                                   andTagB:TAG_TRAMPOLINE_SENSOR
                                                idListener:self
                                               selListener:@selector(beginEndCollisionBetweenPlayerAndTrampolineSensor:)];
    
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
    [_tapScreenButton removeSelf];
    LHSprite* life1 = [loaderJoystick spriteWithUniqueName:@"bunny_lifes_1"];
    [life1 removeSelf];
    LHSprite* life2 = [loaderJoystick spriteWithUniqueName:@"bunny_lifes_2"];
    [life2 removeSelf];
    LHSprite* life3 = [loaderJoystick spriteWithUniqueName:@"bunny_lifes_3"];
    [life3 removeSelf];
    LHSprite* lifeLost = [loaderJoystick spriteWithUniqueName:@"bunny_life_lost"];
    [lifeLost removeSelf];
    LHSprite* lifeLost1 = [loaderJoystick spriteWithUniqueName:@"bunny_life_lost_1"];
    [lifeLost1 removeSelf];
    LHSprite* lifeLost2 = [loaderJoystick spriteWithUniqueName:@"bunny_life_lost_2"];
    [lifeLost2 removeSelf];
    LHSprite* stopWatch = [loaderJoystick spriteWithUniqueName:@"stopWatch"];
    [stopWatch removeSelf];
    LHSprite* tapScreenBorder = [loaderJoystick spriteWithUniqueName:@"tapScreenBorder"];
    [tapScreenBorder removeSelf];
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

    [_player setInitialPositionWithLoader:loader];
    [_player makeStatic];
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
