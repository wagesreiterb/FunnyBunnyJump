//
//  QQLevel.mm
//  presentation
//
//  Created by Bogdan Vladu on 15.03.2011.
//
// Import the interfaces
#define MOVE_POINTS_PER_SECOND 80.0

#import "QQHomeScreen.h"

const float32 FIXED_TIMESTEP = 1.0f / 60.0f;
const float32 MINIMUM_TIMESTEP = 1.0f / 600.0f;
const int32 VELOCITY_ITERATIONS = 8;
const int32 POSITION_ITERATIONS = 8;
const int32 MAXIMUM_NUMBER_OF_STEPS = 25;

//static NSString* _level;

@implementation QQHomeScreen

-(void)afterStep {
    // process collisions and result from callbacks called by the step
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
		[self afterStep]; // process collisions and result from callbacks called by the step
	}
}

////////////////////////////////////////////////////////////////////////////////
+(id)scene
{
    CCScene *scene = [CCScene node];    // 'scene' is an autorelease object.
    QQHomeScreen *layer = [QQHomeScreen node];    // 'layer' is an autorelease object.
    
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
        _repeat = 10;
        _scaleFactor = 90;
        _balloonMusicButtonCompletelyInflated = YES;
        _balloonSoundButtonCompletelyInflated = YES;
	}
	return self;
}

-(void)setupWorld {
    b2Vec2 gravity;
    gravity.Set(0.0f, -2.5f);
    _world = new b2World(gravity);
    _world->SetContinuousPhysics(true);
}

-(void) setupLevelHelper {
    [LevelHelperLoader dontStretchArt];
    
    //[LevelHelperLoader useHDonIpad:YES];
    self.isTouchEnabled = YES;
    //self.isAccelerometerEnabled = YES;
    //[[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:YES];
    [self schedule: @selector(tick:) interval:1.0f/70.0f];
    
    //TODO: brauch is des do unten überhaupts nu?
    [[LHCustomSpriteMgr sharedInstance] registerCustomSpriteClass:[QQSpriteStar class]
                                                           forTag:TAG_STAR];
    
    loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"homeScreen"];
    [loader addObjectsToWorld:_world cocos2dLayer:self];
    
    if([loader hasPhysicBoundaries])
        [loader createPhysicBoundaries:_world];
    
    //if(![lh isGravityZero])
    //  [lh createGravity:world];
    //TODO: set Gravity from LH
    
    _spritePlay = [loader spriteWithUniqueName:@"playButton"];
    [_spritePlay registerTouchBeganObserver:self selector:@selector(touchBeganPlayButton:)];
    [_spritePlay registerTouchEndedObserver:self selector:@selector(touchEndedPlayButton:)];
    
    _spriteFacebookButton = [loader spriteWithUniqueName:@"facebookButton"];
    [_spriteFacebookButton registerTouchBeganObserver:self selector:@selector(touchBeganFacebookButton:)];
    [_spriteFacebookButton registerTouchEndedObserver:self selector:@selector(touchEndedFacebookButton:)];
    
    _spriteTwitterButton = [loader spriteWithUniqueName:@"twitterButton"];
    [_spriteTwitterButton registerTouchBeganObserver:self selector:@selector(touchBeganTwitterButton:)];
    [_spriteTwitterButton registerTouchEndedObserver:self selector:@selector(touchEndedTwitterButton:)];
    
    _creditsButton = [loader spriteWithUniqueName:@"creditsButton"];
    [_creditsButton registerTouchBeganObserver:self selector:@selector(touchBeganCreditsButton:)];
    [_creditsButton registerTouchEndedObserver:self selector:@selector(touchEndedCreditsButton:)];
    
    _inAppStoreButton = [loader spriteWithUniqueName:@"inAppStoreButton"];
    [_inAppStoreButton registerTouchBeganObserver:self selector:@selector(touchBeganInAppStoreButtonButton:)];
    [_inAppStoreButton registerTouchEndedObserver:self selector:@selector(touchEndedInAppStoreButtonButton:)];
    
    [self setupGameCenter];
    [self setupMusic];
    [self setupSound];
    
    //geht
    //TODO: stürzt am Emulator ab
//    Facebook *facebook = [[Facebook alloc] init];
//    CCSprite *fbSprite = [facebook showFBPicture];
//    ccBlendFunc bf={GL_ONE,GL_ZERO};
//    [fbSprite setBlendFunc:bf];
//    [self addChild:fbSprite];
//    [fbSprite setPosition:CGPointMake(150, 150)];
    //---geht
    
    
//    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:path];
//    CCSpriteFrame *temp = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(0, 0, 100, 100)];
//    CCFBProfilePicture *pic = [CCFBProfilePicture profilePictureWithId:@"bernhard.wagesreiter"
//                                                           accessToken:@"476517252421701"
//                                                           contentSize:CGSizeMake(100, 100)
//                                                                cached:YES
//                                                           placeholder:temp];
//    [self addChild:pic];
    
}

-(void)touchBeganInAppStoreButtonButton:(LHTouchInfo*)info {
    
}

-(void)touchEndedInAppStoreButtonButton:(LHTouchInfo*)info {
    NSLog(@"touchEndedInAppStoreButtonButton");
    if(info.sprite) {
        [self showShadeForTransition];
        [[GameManager sharedGameManager] runSceneWithID:kInAppStore];
    }
}

-(void)setupGameCenter {
    _spriteAchievements = [loader spriteWithUniqueName:@"achievementsButton"];
    [_spriteAchievements registerTouchBeganObserver:self selector:@selector(touchBeganShowAchievementsButton:)];
    _spriteLeaderBoard = [loader spriteWithUniqueName:@"leaderBoardButton"];
    [_spriteLeaderBoard registerTouchBeganObserver:self selector:@selector(touchBeganShowLeaderBoardButton:)];
}

//-(void)touchBeganHelpButton:(LHTouchInfo*)info{
//    NSLog(@"touchBeganHelpButton");
//}

//-(void)touchEndedHelpButton:(LHTouchInfo*)info{
//    //open Facebook Page
//    NSLog(@"touchEndedHelpButton");
//    if(info.sprite) {
//        [self showShadeForTransition];
//        [[GameManager sharedGameManager] runSceneWithID:kHelpScreen];
//    }
//}

-(void)showShadeForTransition {
    LHSprite *shade = [LHSprite spriteWithName:@"blackRectangle"    //blende für transitions
                                     fromSheet:@"assets"
                                        SHFile:@"objects"];
    CGSize size = [[CCDirector sharedDirector] winSize];
    [shade setPosition:ccp(size.width/2, size.height/2)];
    [shade setOpacity:OPACITY_OF_SHADE];
    [shade setScale:SCALE_OF_SHADE];
    [self addChild:shade];
}

-(void)touchBeganCreditsButton:(LHTouchInfo*)info{
    NSLog(@"touchBeganCreditsButton");
}

-(void)touchEndedCreditsButton:(LHTouchInfo*)info{
    //open Facebook Page
    NSLog(@"touchEndedCreditskButton");
    if(info.sprite) {
        [self showShadeForTransition];
        [[GameManager sharedGameManager] runSceneWithID:kCreditsScreen];
    }
}

-(void)touchBeganFacebookButton:(LHTouchInfo*)info{
    NSLog(@"touchBeganFacebookButton");
}

-(void)touchEndedFacebookButton:(LHTouchInfo*)info{
    //open Facebook Page
    NSLog(@"touchEndedFacebookButton");
    if(info.sprite) {
        [[GameManager sharedGameManager] openSiteWithLinkType:kLinkTypeFacebook];
    }
}

-(void)touchBeganTwitterButton:(LHTouchInfo*)info{}

-(void)touchEndedTwitterButton:(LHTouchInfo*)info{
    //open Twitter Page
    if(info.sprite) {
        [[GameManager sharedGameManager] openSiteWithLinkType:kLinkTypeTwitter];
    }
}

-(void)setupMusic {
    LHSprite *musicButtonPlaceholder = [loader spriteWithUniqueName:@"musicButtonPlaceholder"];
    if([[GameState sharedInstance] isMusicEnabled]) {
        _spriteMusic = [LHSprite spriteWithName:@"balloon_music_on"
                                        fromSheet:@"assets"
                                           SHFile:@"objects"];
    } else {
        _spriteMusic = [LHSprite spriteWithName:@"balloon_music_off"
                                      fromSheet:@"assets"
                                         SHFile:@"objects"];
    }
    [_spriteMusic setPosition:[musicButtonPlaceholder position]];
    [_spriteMusic registerTouchBeganObserver:self selector:@selector(touchBeganMusicButton:)];
    [_spriteMusic registerTouchEndedObserver:self selector:@selector(touchEndedMusicButton:)];
    [[GameManager sharedGameManager] playOrNotMusic];
    [self addChild:_spriteMusic];
}

-(void)touchBeganMusicButton:(LHTouchInfo*)info{}

-(void)touchEndedMusicButton:(LHTouchInfo*)info{
    //toggle soundEffects (on/off)
    if(info.sprite) {
        if(_balloonMusicButtonCompletelyInflated == YES) {
            _balloonMusicButtonCompletelyInflated = NO;
            [[GameManager sharedGameManager] toggleMusic];
            [_spriteMusic removeSelf];
            
            
            LHSprite *musicButtonPlaceholder = [loader spriteWithUniqueName:@"musicButtonPlaceholder"];
            if([[GameState sharedInstance] isMusicEnabled]) {
                _spriteMusic = [LHSprite spriteWithName:@"balloon_music_on"
                                              fromSheet:@"assets"
                                                 SHFile:@"objects"];
            } else {
                _spriteMusic = [LHSprite spriteWithName:@"balloon_music_off"
                                              fromSheet:@"assets"
                                                 SHFile:@"objects"];
            }
            CCParticleSystemQuad* particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
            [particle setPosition:CGPointMake([musicButtonPlaceholder position].x, [musicButtonPlaceholder position].y)];
            [self addChild:particle];
            [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
            
            [_spriteMusic setPosition:[musicButtonPlaceholder position]];
            [_spriteMusic registerTouchBeganObserver:self selector:@selector(touchBeganMusicButton:)];
            [_spriteMusic registerTouchEndedObserver:self selector:@selector(touchEndedMusicButton:)];
            [[GameManager sharedGameManager] playOrNotMusic];
            [self addChild:_spriteMusic];
            for(int i = 0; i <= _repeat; i++) {
                [_spriteMusic transformScale:[_spriteMusic scaleX] * _scaleFactor / 100];
            }
            [self startInflateMusicButton:_spriteMusic];
        }
    }
}

/*
-(void)startInflateWithSprite:(LHSprite*)sprite_ {
    _spriteToScale = sprite_;
    
    [self schedule:@selector(tickInflate:) interval:0.05f repeat:_repeat delay:0];
}
*/
/*
-(void)tickInflate:(ccTime)dt {
    [_spriteToScale transformScale:[_spriteToScale scale] * 100 / _scaleFactor];
}
*/

-(void)startInflateMusicButton:(LHSprite*)sprite_ {
    _spriteToScaleMusicButton = sprite_;
    [self schedule:@selector(tickInflateMusicButton:) interval:0.05f repeat:_repeat delay:0];
}

-(void)tickInflateMusicButton:(ccTime)dt {
    [_spriteToScaleMusicButton transformScale:[_spriteToScaleMusicButton scale] * 100 / _scaleFactor];
        if([_spriteToScaleMusicButton scale] >= 0.999f) {
        _balloonMusicButtonCompletelyInflated = YES;
    }
}

-(void)startInflateSoundButton:(LHSprite*)sprite_ {
    _spriteToScaleSoundButton = sprite_;
    [self schedule:@selector(tickInflateSoundButton:) interval:0.05f repeat:_repeat delay:0];
}

-(void)tickInflateSoundButton:(ccTime)dt {
    [_spriteToScaleSoundButton transformScale:[_spriteToScaleSoundButton scale] * 100 / _scaleFactor];
    if([_spriteToScaleSoundButton scale] >= 0.999f) {
        _balloonSoundButtonCompletelyInflated = YES;
    }
    NSLog(@"___ tickInflateSoundButton: scale: %f, %d", [_spriteToScaleSoundButton scale], _balloonSoundButtonCompletelyInflated);
}

-(void)setupSound {
    LHSprite *soundButtonPlaceholder = [loader spriteWithUniqueName:@"soundButtonPlaceholder"];
    if([[GameState sharedInstance] isSoundEnabled]) {
        _spriteSound = [LHSprite spriteWithName:@"balloon_sound_on"
                                      fromSheet:@"assets"
                                         SHFile:@"objects"];
    } else {
        _spriteSound = [LHSprite spriteWithName:@"balloon_sound_off"
                                      fromSheet:@"assets"
                                         SHFile:@"objects"];
    }
    [_spriteSound setPosition:[soundButtonPlaceholder position]];
    [_spriteSound registerTouchBeganObserver:self selector:@selector(touchBeganSoundButton:)];
    [_spriteSound registerTouchEndedObserver:self selector:@selector(touchEndedSoundButton:)];
    [[GameManager sharedGameManager] playOrNotSound];
    [self addChild:_spriteSound];
}

-(void)touchEndedSoundButton:(LHTouchInfo*)info{
    //toggle soundEffects (on/off)
    if(info.sprite) {
        if(_balloonSoundButtonCompletelyInflated == YES) {
            _balloonSoundButtonCompletelyInflated = NO;
            [[GameManager sharedGameManager] toggleSound];
            [_spriteSound removeSelf];
            
            LHSprite *soundButtonPlaceholder = [loader spriteWithUniqueName:@"soundButtonPlaceholder"];
            if([[GameState sharedInstance] isSoundEnabled]) {
                _spriteSound = [LHSprite spriteWithName:@"balloon_sound_on"
                                              fromSheet:@"assets"
                                                 SHFile:@"objects"];
            } else {
                _spriteSound = [LHSprite spriteWithName:@"balloon_sound_off"
                                              fromSheet:@"assets"
                                                 SHFile:@"objects"];
            }
            
            CCParticleSystemQuad* particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
            [particle setPosition:CGPointMake([soundButtonPlaceholder position].x, [soundButtonPlaceholder position].y)];
            [self addChild:particle];
            [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
            
            [_spriteSound setPosition:[soundButtonPlaceholder position]];
            [_spriteSound registerTouchBeganObserver:self selector:@selector(touchBeganSoundButton:)];
            [_spriteSound registerTouchEndedObserver:self selector:@selector(touchEndedSoundButton:)];
            [[GameManager sharedGameManager] playOrNotSound];
            [self addChild:_spriteSound];
            for(int i = 0; i <= _repeat; i++) {
                [_spriteSound transformScale:[_spriteSound scaleX] * _scaleFactor / 100];
            }
            [self startInflateSoundButton:_spriteSound];
        }
    }
}

#pragma mark GameKit delegate

-(void)touchBeganShowLeaderBoardButton:(LHTouchInfo*)info {
    // Leaderboard Menu Item using blocks

        GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
        leaderboardViewController.leaderboardDelegate = self;
            
        AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
            
        [[app navController] presentModalViewController:leaderboardViewController animated:YES];


}

-(void)touchBeganShowAchievementsButton:(LHTouchInfo*)info {
	// Achievement Menu Item using blocks

        GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
        achivementViewController.achievementDelegate = self;
		
        AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
        [[app navController] presentModalViewController:achivementViewController animated:YES];

}

-(void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    CCLOG(@"Ende achievements!");
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    CCLOG(@"Ende LeaderBoard!");
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}




-(void)touchBeganSoundButton:(LHTouchInfo*)info{
}

-(void)touchBeganPlayButton:(LHTouchInfo*)info{
    if(info.sprite) {
        [self showShadeForTransition];
        [[GameManager sharedGameManager] runSceneWithID:kSeasonsScreen];
    }
}

-(void)touchEndedPlayButton:(LHTouchInfo*)info{
    if(info.sprite) {
    }
}

-(void)touchBeganPauseButton:(LHTouchInfo*)info{
    //NSLog(@"Touch BEGIN on sprite %@", [info.sprite uniqueName]);
    if(info.sprite) {
        //NSLog(@"aa Touch BEGIN on sprite %@", [info.sprite uniqueName]);
        //[[CCDirector sharedDirector] replaceScene: [QQLevelChooser scene]];
        //[loader setPaused:true];
    }
}

-(void)setupTrampoline {
    _trampoline = (QQSpriteTrampoline*)[loader spriteWithUniqueName:@"trampoline"];
    [_trampoline setInitialRestitution];    
}


-(void)setupPlayer {
    _player = (QQSpritePlayer*)[loader spriteWithUniqueName:@"player"];
    [_player prepareAnimationNamed:@"moul" fromSHScene:@"objects"];
    [_player playAnimation];
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
            //CCSprite *myActor = (CCSprite*)b->GetUserData();
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


- (void)updateBox2D:(ccTime)dt {
    _world->Step(dt, 1, 1);
    _world->ClearForces();
}

- (void)update:(ccTime)dt {
    [self updateBox2D:dt];
    [self updateSprites:dt];
}

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
    //UITouch *touch = [touches anyObject];
    //CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
}

////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //CCLOG(@"ccTouchesMoved");
}
////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

}

////////////////////////////////////////////////////////////////////////////////
// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    
    //[[GameState sharedInstance] load];

    //[_player stopAnimation];
    //[_particle release];
    //[_particle2 release];
    
    //[_balloons release];
    //_balloons = nil;
    //[_stars release];
    
    loader = nil;

	delete _world;
	_world = NULL;
	
  	delete m_debugDraw;
    
	    // don't forget to call "super dealloc"
}

@end
////////////////////////////////////////////////////////////////////////////////


/*
 -(void)setupMusic {
 _spriteMusicOn = [loader spriteWithUniqueName:@"buttonMusicOn"];
 [_spriteMusicOn registerTouchBeganObserver:self selector:@selector(touchBeganMusicButton:)];
 [_spriteMusicOn registerTouchEndedObserver:self selector:@selector(touchEndedMusicButton:)];
 _spriteMusicOff = [loader spriteWithUniqueName:@"buttonMusicOff"];
 [_spriteMusicOff registerTouchBeganObserver:self selector:@selector(touchBeganMusicButton:)];
 [_spriteMusicOff registerTouchEndedObserver:self selector:@selector(touchEndedMusicButton:)];
 
 //if([[GameManager sharedGameManager] isMusicOn]) {
 if([[GameState sharedInstance] isMusicEnabled]) {
 [_spriteMusicOn setVisible:YES];
 [_spriteMusicOn setTouchesDisabled:NO];
 [_spriteMusicOff setVisible:NO];
 [_spriteMusicOff setTouchesDisabled:YES];
 [[GameManager sharedGameManager] playOrNotMusic];
 } else {
 [_spriteMusicOn setVisible:NO];
 [_spriteMusicOn setTouchesDisabled:YES];
 [_spriteMusicOff setVisible:YES];
 [_spriteMusicOff setTouchesDisabled:NO];
 [[GameManager sharedGameManager] playOrNotMusic];
 }
 }
 */


/*
 -(void)touchEndedMusicButton:(LHTouchInfo*)info{
 //toggle soundEffects (on/off)
 if(info.sprite) {
 //if([[GameManager sharedGameManager] isMusicOn]) {
 if([[GameState sharedInstance] isMusicEnabled]) {
 [_spriteMusicOn setVisible:NO];
 [_spriteMusicOn setTouchesDisabled:YES];
 [_spriteMusicOff setVisible:YES];
 [_spriteMusicOff setTouchesDisabled:NO];
 [[GameManager sharedGameManager] toggleMusic];
 } else {
 [_spriteMusicOn setVisible:YES];
 [_spriteMusicOn setTouchesDisabled:NO];
 [_spriteMusicOff setVisible:NO];
 [_spriteMusicOff setTouchesDisabled:YES];
 [[GameManager sharedGameManager] toggleMusic];
 }
 }
 }
 */


/*
 -(void)setupSound {
 _spriteSoundEffectsOn = [loader spriteWithUniqueName:@"buttonSoundeffectsOn"];
 [_spriteSoundEffectsOn registerTouchBeganObserver:self selector:@selector(touchBeganSoundEffectsButton:)];
 [_spriteSoundEffectsOn registerTouchEndedObserver:self selector:@selector(touchEndedSoundEffectsButton:)];
 _spriteSoundEffectsOff = [loader spriteWithUniqueName:@"buttonSoundeffectsOff"];
 [_spriteSoundEffectsOff registerTouchBeganObserver:self selector:@selector(touchBeganSoundEffectsButton:)];
 [_spriteSoundEffectsOff registerTouchEndedObserver:self selector:@selector(touchEndedSoundEffectsButton:)];
 
 //if([[GameManager sharedGameManager] isSoundEffectsOn]) {
 if([[GameState sharedInstance] isSoundEnabled]) {
 [_spriteSoundEffectsOn setVisible:YES];
 [_spriteSoundEffectsOn setTouchesDisabled:NO];
 [_spriteSoundEffectsOff setVisible:NO];
 [_spriteSoundEffectsOff setTouchesDisabled:YES];
 [[GameManager sharedGameManager] playOrNotSound];
 } else {
 [_spriteSoundEffectsOn setVisible:NO];
 [_spriteSoundEffectsOn setTouchesDisabled:YES];
 [_spriteSoundEffectsOff setVisible:YES];
 [_spriteSoundEffectsOff setTouchesDisabled:NO];
 [[GameManager sharedGameManager] playOrNotSound];
 }
 }
 */


/*
 -(void)touchEndedSoundButton:(LHTouchInfo*)info{
 //toggle soundEffects (on/off)
 if(info.sprite) {
 if([[GameState sharedInstance] isSoundEnabled]) {
 //if([[GameManager sharedGameManager] isSoundEffectsOn]) {
 [_spriteSoundEffectsOn setVisible:NO];
 [_spriteSoundEffectsOn setTouchesDisabled:YES];
 [_spriteSoundEffectsOff setVisible:YES];
 [_spriteSoundEffectsOff setTouchesDisabled:NO];
 [[GameManager sharedGameManager] toggleSoundEffects];
 } else {
 [_spriteSoundEffectsOn setVisible:YES];
 [_spriteSoundEffectsOn setTouchesDisabled:NO];
 [_spriteSoundEffectsOff setVisible:NO];
 [_spriteSoundEffectsOff setTouchesDisabled:YES];
 [[GameManager sharedGameManager] toggleSoundEffects];
 }
 }
 }
 */

