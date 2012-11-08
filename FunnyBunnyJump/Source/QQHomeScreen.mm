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
    
    //[[GameManager sharedGameManager] setLevelToRun:@"levelWinter2012003"];
    //[[GameManager sharedGameManager] runSceneWithID:kLevel003];
    

    
    //[LevelHelperLoader dontStretchArt];
    //[LevelHelperLoader useHDonIpad:YES];
    self.isTouchEnabled = YES;
    //self.isAccelerometerEnabled = YES;
    //[[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:YES];
    [self schedule: @selector(tick:) interval:1.0f/70.0f];    
    
    loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"homeScreen"];
    [loader addObjectsToWorld:_world cocos2dLayer:self];
    
    if([loader hasPhysicBoundaries])
        [loader createPhysicBoundaries:_world];
    
    //if(![lh isGravityZero])
    //  [lh createGravity:world];
    //TODO: set Gravity from LH
    
    
    //[self setupPlayer];
    //[self setupTrampoline];
    
    _spritePlay = [loader spriteWithUniqueName:@"playButton"];
    [_spritePlay registerTouchBeganObserver:self selector:@selector(touchBeganPlayButton:)];
    
    [self setupGameCenter];

    [self setupAudio];
    [self setupMusic];
    
    //CGSize size = [[CCDirector sharedDirector] winSize];

    //self.position = ccp(size.width/2, size.height/2);
    //[self setPosition:CGPointMake(0, -160)];

    /*
     Que Que for teset the score
    NSString* stringPukte = [NSString stringWithFormat:@"%d", [GameState sharedInstance].punkte];
    CCLOG(@"---Punkte: %d", [GameState sharedInstance].punkte);
    LHSprite* spriteLifes = [loader spriteWithUniqueName:@"lifes"];
    CCLabelTTF *score = [CCLabelTTF labelWithString:stringPukte fontName:@"Verdana" fontSize:20.0];
    [score setColor:ccc3(0,0,0)];
    [score setPosition:[spriteLifes position]];
    [self addChild:score];
     */

}


-(void)setupGameCenter {
    _spriteAchievements = [loader spriteWithUniqueName:@"achievementsButton"];
    [_spriteAchievements registerTouchBeganObserver:self selector:@selector(touchBeganShowAchievementsButton:)];
    _spriteLeaderBoard = [loader spriteWithUniqueName:@"leaderBoardButton"];
    [_spriteLeaderBoard registerTouchBeganObserver:self selector:@selector(touchBeganShowLeaderBoardButton:)];
}

-(void)setupMusic {
    _spriteMusicOn = [loader spriteWithUniqueName:@"buttonMusicOn"];
    [_spriteMusicOn registerTouchBeganObserver:self selector:@selector(touchBeganMusicButton:)];
    [_spriteMusicOn registerTouchEndedObserver:self selector:@selector(touchEndedMusicButton:)];
    _spriteMusicOff = [loader spriteWithUniqueName:@"buttonMusicOff"];
    [_spriteMusicOff registerTouchBeganObserver:self selector:@selector(touchBeganMusicButton:)];
    [_spriteMusicOff registerTouchEndedObserver:self selector:@selector(touchEndedMusicButton:)];
    
    if([[GameManager sharedGameManager] isMusicOn]) {
        [_spriteMusicOn setVisible:YES];
        [_spriteMusicOn setTouchesDisabled:NO];
        [_spriteMusicOff setVisible:NO];
        [_spriteMusicOff setTouchesDisabled:YES];
    } else {
        [_spriteMusicOn setVisible:NO];
        [_spriteMusicOn setTouchesDisabled:YES];
        [_spriteMusicOff setVisible:YES];
        [_spriteMusicOff setTouchesDisabled:NO];
    }
}

-(void)touchBeganMusicButton:(LHTouchInfo*)info{
}

-(void)touchEndedMusicButton:(LHTouchInfo*)info{
    //toggle soundEffects (on/off)
    if(info.sprite) {
        if([[GameManager sharedGameManager] isMusicOn]) {
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

-(void)setupAudio {
    _spriteSoundEffectsOn = [loader spriteWithUniqueName:@"buttonSoundeffectsOn"];
    [_spriteSoundEffectsOn registerTouchBeganObserver:self selector:@selector(touchBeganSoundEffectsButton:)];
    [_spriteSoundEffectsOn registerTouchEndedObserver:self selector:@selector(touchEndedSoundEffectsButton:)];
    _spriteSoundEffectsOff = [loader spriteWithUniqueName:@"buttonSoundeffectsOff"];
    [_spriteSoundEffectsOff registerTouchBeganObserver:self selector:@selector(touchBeganSoundEffectsButton:)];
    [_spriteSoundEffectsOff registerTouchEndedObserver:self selector:@selector(touchEndedSoundEffectsButton:)];
    
    if([[GameManager sharedGameManager] isSoundEffectsOn]) {
        CCLOG(@"YES YES");
        [_spriteSoundEffectsOn setVisible:YES];
        [_spriteSoundEffectsOn setTouchesDisabled:NO];
        [_spriteSoundEffectsOff setVisible:NO];
        [_spriteSoundEffectsOff setTouchesDisabled:YES];
    } else {
        CCLOG(@"NO NO");
        [_spriteSoundEffectsOn setVisible:NO];
        [_spriteSoundEffectsOn setTouchesDisabled:YES];
        [_spriteSoundEffectsOff setVisible:YES];
        [_spriteSoundEffectsOff setTouchesDisabled:NO];
    }
}


#pragma mark GameKit delegate

-(void)touchBeganShowLeaderBoardButton:(LHTouchInfo*)info {
    // Leaderboard Menu Item using blocks
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    leaderboardViewController.leaderboardDelegate = self;
		
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
    [[app navController] presentModalViewController:leaderboardViewController animated:YES];
    [leaderboardViewController release];

}

-(void)touchBeganShowAchievementsButton:(LHTouchInfo*)info {
	// Achievement Menu Item using blocks
		
    GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
	achivementViewController.achievementDelegate = self;
		
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
	[[app navController] presentModalViewController:achivementViewController animated:YES];
	[achivementViewController release];
}

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    CCLOG(@"Ende achievements!");
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    CCLOG(@"Ende LeaderBoard!");
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}




-(void)touchBeganSoundEffectsButton:(LHTouchInfo*)info{
}

-(void)touchEndedSoundEffectsButton:(LHTouchInfo*)info{
    //toggle soundEffects (on/off)
    if(info.sprite) {
        if([[GameManager sharedGameManager] isSoundEffectsOn]) {
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

-(void)touchBeganPlayButton:(LHTouchInfo*)info{
    //NSLog(@"Touch BEGIN on sprite %@", [info.sprite uniqueName]);
    if(info.sprite) {
        [[GameManager sharedGameManager] runSceneWithID:kSeasonsScreen];
        //[[CCDirector sharedDirector] replaceScene: [QQLevelChooser scene]];
        //[loader setPaused:true];
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
    
    if(nil != loader)
        [loader release];

	delete _world;
	_world = NULL;
	
  	delete m_debugDraw;
    
	[super dealloc];    // don't forget to call "super dealloc"
}

@end
////////////////////////////////////////////////////////////////////////////////
