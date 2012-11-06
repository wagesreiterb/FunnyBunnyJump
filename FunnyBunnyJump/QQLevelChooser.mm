//
//  QQLevelChooser.m
//  Acrobat_g7003
//
//  Created by Que on 24.09.12.
//
//

#import "QQLevelChooser.h"

const float32 FIXED_TIMESTEP = 1.0f / 60.0f;
const float32 MINIMUM_TIMESTEP = 1.0f / 600.0f;
const int32 VELOCITY_ITERATIONS = 8;
const int32 POSITION_ITERATIONS = 8;
const int32 MAXIMUM_NUMBER_OF_STEPS = 25;

@implementation QQLevelChooser

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
    QQLevelChooser *layer = [QQLevelChooser node];    // 'layer' is an autorelease object.
    
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
    self.isTouchEnabled = YES;
    self.isAccelerometerEnabled = YES;
    [[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:YES];
    [self schedule: @selector(tick:) interval:1.0f/70.0f];
 
    //[LevelHelperLoader dontStretchArtOnIpad];
    loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"levelChooser"];
    [loader addObjectsToWorld:_world cocos2dLayer:self]; //creating the objects

    if([loader hasPhysicBoundaries])
        [loader createPhysicBoundaries:_world];
    
    //_sprite = [loader spriteWithUniqueName:@"balloon_purple_0"];
    //[_sprite registerTouchBeginObserver:self selector:@selector(touchBegin:)];
    
    _levelChooserIcons = [loader spritesWithTag:TAG_LEVELCHOOSER];
    for(LHSprite* mySprite in _levelChooserIcons)
    {
        [mySprite registerTouchBeginObserver:self selector:@selector(touchBegin:)];
    }

    //[self setupAudio];
}

/*
-(void)setupAudio {
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.2f];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"zippy.mp3"];
}
 */

-(void)touchBegin:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"Touch BEGIN on sprite %@", [info.sprite uniqueName]);
    
        switch ([[info.sprite uniqueName] intValue]) {
            case 1: {
                [[GameManager sharedGameManager] runSceneWithID:kLevel001];
                break;
            }
            case 2:
                [[GameManager sharedGameManager] runSceneWithID:kLevel002];
                break;
            case 3:
                NSLog(@"3");
                break;
                
            case 1001:
                NSLog(@"BACK BUTTON");
                //[[CCDirector sharedDirector] replaceScene: [CCTransitionTurnOffTiles transitionWithDuration:0.3f
                //scene:[QQLevelMainScreen scene]]];
                [[GameManager sharedGameManager] runSceneWithID:kSeasonsScreen];
                break;
                
            default:
                break;
        }
    
    }
    
    if(info.bezier)
        NSLog(@"Touch BEGIN on bezier %@", [info.bezier uniqueName]);
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
}*/

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
    if(nil != loader)
        [loader release];
    
	delete _world;
	_world = NULL;
	
  	delete m_debugDraw;
    
	[super dealloc];    // don't forget to call "super dealloc"
}
@end
////////////////////////////////////////////////////////////////////////////////

