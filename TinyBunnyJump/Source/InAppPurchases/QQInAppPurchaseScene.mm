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

@implementation QQInAppPurchaseScene

-(void)afterStep {
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
		//_world->Step(deltaTime,VELOCITY_ITERATIONS,POSITION_ITERATIONS);
		stepsPerformed++;
		[self afterStep]; // process collisions and result from callbacks called by the step
	}
}

////////////////////////////////////////////////////////////////////////////////
+(id)scene
{
    CCScene *scene = [CCScene node];    // 'scene' is an autorelease object.
    QQInAppPurchaseScene *layer = [QQInAppPurchaseScene node];    // 'layer' is an autorelease object.
    
    [scene addChild: layer];    // add layer as a child to scene
    
	return scene; 	// return the scene
}
////////////////////////////////////////////////////////////////////////////////
// initialize your instance here
-(id)init
{
	if( (self=[super init])) {
        //[self setupWorld];
        [self setupLevelHelper];
        //[self setupDebugDraw];
        [self setTouchEnabled:YES];
        
        [[QQInAppPurchaseLayer sharedInstance] showIAPStoreFromHomescreen:self];
	}
	return self;
}

-(void) setupLevelHelper {
    [self schedule: @selector(tick:) interval:1.0f/70.0f];

    if([[LHSettings sharedInstance] isIphone5]) {
        _loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"inAppPurchase"];
    }
    
    //TODO: load correct files
    else if ([[LHSettings sharedInstance] isIpad]) {
        _loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"credits"];
    } else {
        _loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"credits"];
    }

    //[_loader addObjectsToWorld:_world cocos2dLayer:self];
    [_loader addSpritesToLayer:self];
    
    _buttonBackBalloon = [_loader spriteWithUniqueName:@"buttonBack"];
    [_buttonBackBalloon registerTouchBeganObserver:self selector:@selector(touchBeganBackButton:)];
    [_buttonBackBalloon registerTouchEndedObserver:self selector:@selector(touchEndedBackButton:)];
    
//    if([_loader hasPhysicBoundaries])
//        [_loader createPhysicBoundaries:_world];
}


-(void)touchBeganBackButton:(LHTouchInfo*)info {
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



////////////////////////////////////////////////////////////////////////////////
//FIX TIME STEPT------------>>>>>>>>>>>>>>>>>>
-(void)tick: (ccTime) dt
{
	[self step:dt];
    //[self update:dt];
}
//FIX TIME STEPT<<<<<<<<<<<<<<<----------------------
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    _loader = nil;
    
	//delete _world;
	//_world = NULL;
	
  	//delete m_debugDraw;
    
	    // don't forget to call "super dealloc"
}

@end
////////////////////////////////////////////////////////////////////////////////



//-(void)setupDebugDraw {
//    m_debugDraw = new GLESDebugDraw();
//    _world->SetDebugDraw(m_debugDraw);
//    uint32 flags = 0;
//    flags += b2Draw::e_shapeBit;
//    flags += b2Draw::e_jointBit;
//    m_debugDraw->SetFlags(flags);
//}
//
//-(void)updateSprites:(ccTime)dt {
//    //Iterate over the bodies in the physics world
//	for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext())
//	{
//		if (b->GetUserData() != NULL)
//        {
//			//Synchronize the AtlasSprites position and rotation with the corresponding body
//			CCSprite *myActor = (__bridge CCSprite*)b->GetUserData();
//
//            if(myActor != 0)
//            {
//                //THIS IS VERY IMPORTANT - GETTING THE POSITION FROM BOX2D TO COCOS2D
//                myActor.position = [LevelHelperLoader metersToPoints:b->GetPosition()];
//                myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
//            }
//
//        }
//	}
//}


//- (void)updateBox2D:(ccTime)dt {
//    _world->Step(dt, 1, 1);
//    _world->ClearForces();
//}

//- (void)update:(ccTime)dt {
//    //[self updateBox2D:dt];
//    //[self updateSprites:dt];
//}


//-(void)setupWorld {
//    b2Vec2 gravity;
//    gravity.Set(0.0f, -2.5f);
//    _world = new b2World(gravity);
//    _world->SetContinuousPhysics(true);
//}

