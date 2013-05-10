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

@implementation QQCreditsScene

-(void)afterStep {
    if(_scrolling) {
        CGPoint parallaxPosition = [_parallaxCredits position];
        [_parallaxCredits setPosition:ccp(parallaxPosition.x, parallaxPosition.y + 0.5f)];
        
        if(parallaxPosition.y > 1080)
        {
            [_parallaxCredits setPosition:ccp(parallaxPosition.x, -220)];
        }
        if(parallaxPosition.y < -220)
        {
            [_parallaxCredits setPosition:ccp(parallaxPosition.x, 1080)];
        }
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
		[self afterStep]; // process collisions and result from callbacks called by the step
	}
}

////////////////////////////////////////////////////////////////////////////////
+(id)scene
{
    CCScene *scene = [CCScene node];    // 'scene' is an autorelease object.
    QQCreditsScene *layer = [QQCreditsScene node];    // 'layer' is an autorelease object.
    
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
    //[LevelHelperLoader dontStretchArt];
    
    //[LevelHelperLoader useHDonIpad:YES];
    self.isTouchEnabled = YES;
    //self.isAccelerometerEnabled = YES;
    //[[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:YES];
    [self schedule: @selector(tick:) interval:1.0f/70.0f];

    if([[LHSettings sharedInstance] isIphone5]) {
        _loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"credits_iPhone5"];
    } else if ([[LHSettings sharedInstance] isIpad]) {
        _loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"credits"];
    } else {
        _loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"credits"];
    }
    //_loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"credits"];
    [_loader addObjectsToWorld:_world cocos2dLayer:self];
    
    _parallaxCredits = [_loader parallaxNodeWithUniqueName:@"parallaxCredits"];
    
    _buttonBackBalloon = [_loader spriteWithUniqueName:@"buttonBackBalloon"];
    [_buttonBackBalloon registerTouchBeganObserver:self selector:@selector(touchBeganBackButton:)];
    [_buttonBackBalloon registerTouchEndedObserver:self selector:@selector(touchEndedBackButton:)];
    
    if([_loader hasPhysicBoundaries])
        [_loader createPhysicBoundaries:_world];
    
    //[self.scheduler scheduleSelector:@selector(tickStartScrolling:) forTarget:self interval:-1 paused:NO repeat:1 delay:3];
    [self scheduleOnce:@selector(tickStartScrolling:) delay:1.5f];
}

-(void)tickStartScrolling:(ccTime)dt {
    _scrolling = YES;
}

-(void)touchBeganBackButton:(LHTouchInfo*)info {
    //NSLog(@"Touch BEGIN on sprite %@", [info.sprite uniqueName]);
    //if(info.sprite) {
    //    [[GameManager sharedGameManager] runSceneWithID:kHomeScreen];
    //}
}


-(void)touchEndedBackButton:(LHTouchInfo*)info {
    //NSLog(@"Touch Ended on sprite %@", [info.sprite uniqueName]);
    if(info.sprite) {
        LHSprite *shade = [LHSprite spriteWithName:@"blackRectangle"    //blende für transitions
                                         fromSheet:@"assets"
                                            SHFile:@"objects"];
        CGSize size = [[CCDirector sharedDirector] winSize];
        [shade setPosition:ccp(size.width/2, size.height/2)];
        [shade setOpacity:OPACITY_OF_SHADE];
        [shade setScale:SCALE_OF_SHADE];
        [self addChild:shade];
        [[GameManager sharedGameManager] runSceneWithID:kHomeScreen];
    }
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
    //UITouch *touch = [touches anyObject];
    //CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    //[_parallaxCredits isContinuous]
}

////////////////////////////////////////////////////////////////////////////////
// - (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
// {
    //CCLOG(@"ccTouchesMoved");
// }

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //NSLog(@"Credits::ccTouchesMoved");
    for( UITouch *touch in touches ) {
		
        CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];
        
        CGPoint prevLocation = [touch previousLocationInView:[touch view]];
        prevLocation = [[CCDirector sharedDirector] convertToGL:prevLocation];
        
        CGPoint touchDelta = ccpSub(location,prevLocation);
        
        
        if(nil != _parallaxCredits)
        {
            //NSLog(@"Credits::ccTouchesMoved - IF");
            CGPoint parallaxPosition = [_parallaxCredits position];
            //NSLog(@"Credits::ccTouchesMoved - %f, %f", parallaxPosition.x, parallaxPosition.y);
            [_parallaxCredits setPosition:ccp(parallaxPosition.x + touchDelta.x, parallaxPosition.y + touchDelta.y)];
            //[_parallaxCredits setPosition:ccp(22, 22)];

        }
    }
}
////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

////////////////////////////////////////////////////////////////////////////////
// on "dealloc" you need to release all your retained objects
- (void) dealloc
{    
    if(nil != _loader)
        [_loader release];
    
	delete _world;
	_world = NULL;
	
  	delete m_debugDraw;
    
	[super dealloc];    // don't forget to call "super dealloc"
}

@end
////////////////////////////////////////////////////////////////////////////////

