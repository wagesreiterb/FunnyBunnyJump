//
//  QQLevel.mm
//  presentation
//
//  Created by Bogdan Vladu on 15.03.2011.
//
// Import the interfaces
#define MOVE_POINTS_PER_SECOND 80.0

#import "QQSeasonsScreen.h"
#import "QQLevelChooser.h"

const float32 FIXED_TIMESTEP = 1.0f / 60.0f;
const float32 MINIMUM_TIMESTEP = 1.0f / 600.0f;
const int32 VELOCITY_ITERATIONS = 8;
const int32 POSITION_ITERATIONS = 8;
const int32 MAXIMUM_NUMBER_OF_STEPS = 25;

static CCScrollLayer *myScroller;

@implementation QQSeasonsScreen

//@synthesize name;

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
		//[self afterStep:dt]; // process collisions and result from callbacks called by the step
	}
}

////////////////////////////////////////////////////////////////////////////////
+(id) scene
{
    NSLog(@"####### QQSeasonsScreen Scroller");

    
    CCScene *scene = [CCScene node];    // 'scene' is an autorelease object.
    QQSeasonsScreen *layerSpring = [QQSeasonsScreen node];    // 'layer' is an autorelease object.
    [layerSpring setupLevelHelper:@"seasonSpring"];
    
    QQSeasonsScreen *layerSummer = [QQSeasonsScreen node];
    [layerSummer setupLevelHelper:@"seasonSummer"];
    
    QQSeasonsScreen *layerFall = [QQSeasonsScreen node];
    [layerFall setupLevelHelper:@"seasonFall"];
    
    QQSeasonsScreen *layerWinter = [QQSeasonsScreen node];
    [layerWinter setupLevelHelper:@"seasonWinter"];
    
    QQSeasonsScreen *layerBackground = [QQSeasonsScreen node];
    [layerBackground setupLevelHelper:@"seasonBackground"];
    [scene addChild:layerBackground];
    
    
    //QQLevel *layerBackground = [QQLevel node];
    //[scene addChild:layerBackground];
	
    // iPad: 1024 x 768  4:3
    // iPad 3: 2048 * 1536  4:3
    // iPhone, iPod: 480 x 320  3:2
    // iPhone 4: 960 x 640  3:2
    // iPhone 5: 1136 x 640 16:9

    int scrollerOffset = 1024 / 6.0f;
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        CGSize screenSize = [CCDirector sharedDirector].winSizeInPixels;
        if(screenSize.width == 960.0f) {
            //iPhone4 retina
            //For any reason, CCScrollerLayer show the display width = 480 - Fotze
            scrollerOffset = 480 / 6.0f;
        } else {
            //iPhone4 non-retina
            scrollerOffset = 480 / 6.0f;
        }
    }
    
    //scrollerOffset = 100 / 6;
    scrollerOffset = 220;
    // now create the scroller and pass-in the pages (set widthOffset to 0 for fullscreen pages)
    CCScrollLayer *scroller = [[CCScrollLayer alloc] initWithLayers:[NSMutableArray arrayWithObjects: layerSpring, layerSummer, layerFall, layerWinter, nil]
                                                        widthOffset:scrollerOffset];

    [scroller selectPage:[[GameManager sharedGameManager] seasonPage]];
    
    // finally add the scroller to your scene
    [scene addChild:scroller];
    
    [scroller release];
    
    myScroller = scroller;
    
    //[[CCDirector sharedDirector] resume];
    //[LevelHelperLoader setPaused:NO];

    //[scene addChild: layer];    // add layer as a child to scene
	return scene; 	// return the scene
}
////////////////////////////////////////////////////////////////////////////////
// initialize your instance here
-(id) init
{
	if( (self=[super init])) {
        [self setupWorld];
        //[self setupLevelHelper];
        [self setupDebugDraw];
        self.isTouchEnabled = YES;  // Add at bottom of init
	}
	return self;
}

-(void) setupWorld {
    b2Vec2 gravity;
    gravity.Set(0.0f, -2.5f);
    _world = new b2World(gravity);
    _world->SetContinuousPhysics(true);
}


-(void) setupLevelHelper:(NSString*)withLevel {
    self.isTouchEnabled = YES;
    self.isAccelerometerEnabled = YES;
    //[[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:YES];
    [self schedule: @selector(tick:) interval:1.0f/70.0f];

    
    //loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"levelChooser001"];
    loader = [[LevelHelperLoader alloc] initWithContentOfFile:withLevel];
    [loader addObjectsToWorld:_world cocos2dLayer:self]; //creating the objects
    
    if([loader hasPhysicBoundaries])
        [loader createPhysicBoundaries:_world];

    
    _emptySeason = [loader spriteWithUniqueName:@"empty_season"];
    [_emptySeason registerTouchBeganObserver:self selector:@selector(touchBeganEmptySeason:)];
    [_emptySeason registerTouchEndedObserver:self selector:@selector(touchEndedEmptySeason:)];
    
    _backButton = [loader spriteWithUniqueName:@"buttonBack"];
    [_backButton registerTouchBeganObserver:self selector:@selector(touchBeganBackButton:)];
    [_backButton registerTouchEndedObserver:self selector:@selector(touchEndedBackButton:)];
    
    
    //CCLOG(@"SETUP LEVEL HELPER");
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

-(void)touchBeganEmptySeason:(LHTouchInfo*)info{
    //if(info.sprite)
    //    NSLog(@"Touch BEGIN on sprite %@", [info.sprite uniqueName]);
}

-(void)touchEndedEmptySeason:(LHTouchInfo*)info{
    switch ([myScroller currentScreen]) {
        case 0:
            [[GameManager sharedGameManager] setSeason:spring];
            [[GameManager sharedGameManager] setSeasonName:@"Spring"];
            [[GameManager sharedGameManager] setSeasonPage:spring];
            [[GameManager sharedGameManager] runSceneWithID:kLevelChooser];
            break;
            
        case 1:
            [[GameManager sharedGameManager] setSeason:summer];
            [[GameManager sharedGameManager] setSeasonName:@"Summer"];
            [[GameManager sharedGameManager] setSeasonPage:summer];
            [[GameManager sharedGameManager] runSceneWithID:kLevelChooser];
            break;
            
        case 2:
            [[GameManager sharedGameManager] setSeason:fall];
            [[GameManager sharedGameManager] setSeasonName:@"Fall"];
            [[GameManager sharedGameManager] setSeasonPage:fall];
            [[GameManager sharedGameManager] runSceneWithID:kLevelChooser];
            break;
            
        case 3:
            [[GameManager sharedGameManager] setSeason:winter];
            [[GameManager sharedGameManager] setSeasonName:@"Winter"];
            [[GameManager sharedGameManager] setSeasonPage:winter];
            [[GameManager sharedGameManager] runSceneWithID:kLevelChooser];
            break;
            
        default:
            break;
    }
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //CCLOG(@"touch down %d", [myScroller currentScreen]);
}

////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

}
////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

////////////////////////////////////////////////////////////////////////////////
// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    if(nil != loader) {
        [loader release];
        loader = nil;
    }
    
    if(nil != _loader1) {
        [_loader1 release];
        _loader1 = nil;
    }
    
	delete _world;
	_world = NULL;
	
  	delete m_debugDraw;
    
	[super dealloc];    // don't forget to call "super dealloc"
}
@end
////////////////////////////////////////////////////////////////////////////////



/*
 -(void)touchBeginSpring:(LHTouchInfo*)info{
 if(info.sprite)
 NSLog(@"Touch BEGIN on sprite %@", [info.sprite uniqueName]);
 }
 
 -(void)touchBeginSummer:(LHTouchInfo*)info{
 if(info.sprite)
 NSLog(@"Touch BEGIN on sprite %@", [info.sprite uniqueName]);
 }
 
 -(void)touchBeginFall:(LHTouchInfo*)info{
 if(info.sprite)
 NSLog(@"Touch BEGIN on sprite %@", [info.sprite uniqueName]);
 }
 
 -(void)touchBeginWinter:(LHTouchInfo*)info{
 if(info.sprite)
 NSLog(@"Touch BEGIN on sprite %@", [info.sprite uniqueName]);
 }
 */



/*
 _spriteSeasonSpring = [loader spriteWithUniqueName:@"season_spring"];
 [_spriteSeasonSpring registerTouchBeginObserver:self selector:@selector(touchBeginSpring:)];
 
 _spriteSeasonSummer = [loader spriteWithUniqueName:@"season_summer"];
 [_spriteSeasonSummer registerTouchBeginObserver:self selector:@selector(touchBeginSummer:)];
 
 _spriteSeasonFall = [loader spriteWithUniqueName:@"season_fall"];
 [_spriteSeasonFall registerTouchBeginObserver:self selector:@selector(touchBeginFall:)];
 
 _spriteSeasonWinter = [loader spriteWithUniqueName:@"season_winter"];
 [_spriteSeasonWinter registerTouchBeginObserver:self selector:@selector(touchBeginWinter:)];
 */



