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
    //[[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:YES];
    //[self schedule: @selector(tick:) interval:1.0f/70.0f];
 
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
        [mySprite registerTouchBeganObserver:self selector:@selector(touchBegan:)];
    }
    
    LHSprite* background;
    switch ([[GameManager sharedGameManager] season]) {
        case spring:
            background = [LHSprite spriteWithName:@"backgroundSpring"
                                        fromSheet:@"backgrounds3"
                                           SHFile:@"objects"];
            break;
        case summer:
            background = [LHSprite spriteWithName:@"backgroundSummer"
                                        fromSheet:@"backgrounds2"
                                           SHFile:@"objects"];
            break;
            
        case fall:
            background = [LHSprite spriteWithName:@"backgroundFall"
                                        fromSheet:@"backgrounds2"
                                           SHFile:@"objects"];
            break;
            
        case winter:
            background = [LHSprite spriteWithName:@"backgroundWinter"
                                        fromSheet:@"backgrounds3"
                                           SHFile:@"objects"];
            break;
            
        default:
            NSLog(@"Something is wrong in QQLevelChosser::setupLevelHelper!");
            break;
    }
    [self addChild:background];

    [background setPosition:CGPointMake([[CCDirector sharedDirector] winSize].width / 2,
                                        [[CCDirector sharedDirector] winSize].height / 2)];
    [background setZOrder:-1];
    
    [self initLocks];
}

-(void)initLocks {
    NSArray *balloons = [loader spritesWithTag:TAG_LEVELCHOOSER];
    for(LHSprite *balloon in balloons) {
        if([balloon uniqueName].intValue < 1000) {
            //draw locks
            NSString* keyForLock = @"level";
            keyForLock = [keyForLock stringByAppendingString:[[GameManager sharedGameManager] seasonName]];
            keyForLock = [keyForLock stringByAppendingString:@"2012"];
            keyForLock = [keyForLock stringByAppendingString:[balloon uniqueName]];
            
            if([[[[GameState sharedInstance] tempLevelLocked] objectForKey:keyForLock] boolValue] == YES) {
                LHSprite* lock = [LHSprite spriteWithName:@"lock"
                                                fromSheet:@"assets"
                                                   SHFile:@"objects"];
                CGPoint position;
                position.x = [balloon position].x;
                position.y = [balloon position].y + [balloon contentSize].height / 8;
                [lock setPosition:position];
                [lock setOpacity:180];
                [self addChild:lock];
            } else {
                //draw numbers
                NSString* numberString = @"number";
                numberString = [numberString stringByAppendingString:[balloon uniqueName]];
                LHSprite* number = [LHSprite spriteWithName:numberString
                                                fromSheet:@"assets"
                                                   SHFile:@"objects"];
                CGPoint position;
                position.x = [balloon position].x;
                position.y = [balloon position].y + [balloon contentSize].height / 8;
                [number setPosition:position];
                [number setOpacity:180];
                [self addChild:number];
            }
        }
    }
}

-(void)runSceneWithIDkLevel2012001:(ccTime)dt {
    [[GameManager sharedGameManager] runSceneWithID:kLevel2012001];
}

-(void)touchBegan:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"Touch BEGIN on sprite %@", [info.sprite uniqueName]);
    
        switch ([[info.sprite uniqueName] intValue]) {
            case 1: {
                if(![[GameState sharedInstance] isLevelLockedWithSeason:[[GameManager sharedGameManager] seasonName]
                                                               andLevel:2012001]) {
                    LHSprite* sprite = [loader spriteWithUniqueName:@"1"];
                    [sprite removeSelf];
                    LHSprite* number = [loader spriteWithUniqueName:@"number_1"];
                    [number removeSelf];
                    
                    [[CCDirector sharedDirector] resume];
                    
                    CCParticleSystemQuad* particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
                    [particle setPosition:CGPointMake([sprite position].x, [sprite position].y)];
                    [self addChild:particle];
                    [particle release];
                    
                    [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
                    
                    [self scheduleOnce:@selector(runSceneWithIDkLevel2012001:) delay:0.5f];
                }
                break;
            }
            case 2:
                if(![[GameState sharedInstance] isLevelLockedWithSeason:[[GameManager sharedGameManager] seasonName]
                                                               andLevel:2012002]) {
                    [[GameManager sharedGameManager] runSceneWithID:kLevel2012002];
                }
                break;
            case 3:
                if(![[GameState sharedInstance] isLevelLockedWithSeason:[[GameManager sharedGameManager] seasonName]
                                                               andLevel:2012003]) {
                    [[GameManager sharedGameManager] runSceneWithID:kLevel2012003];
                }
                break;
            case 4:
                if(![[GameState sharedInstance] isLevelLockedWithSeason:[[GameManager sharedGameManager] seasonName]
                                                               andLevel:2012004]) {
                    [[GameManager sharedGameManager] runSceneWithID:kLevel2012004];
                }
                break;
            case 5:
                [[GameManager sharedGameManager] runSceneWithID:kLevel2012005];
                break;
            case 6:
                [[GameManager sharedGameManager] runSceneWithID:kLevel2012006];
                break;
            case 7:
                [[GameManager sharedGameManager] runSceneWithID:kLevel2012007];
                break;
            case 8:
                [[GameManager sharedGameManager] runSceneWithID:kLevel2012008];
                break;
            case 9:
                [[GameManager sharedGameManager] runSceneWithID:kLevel2012009];
                break;
            case 10:
                [[GameManager sharedGameManager] runSceneWithID:kLevel2012010];
                break;
            case 11:
                [[GameManager sharedGameManager] runSceneWithID:kLevel2012011];
                break;
            case 12:
                [[GameManager sharedGameManager] runSceneWithID:kLevel2012012];
                break;
            case 13:
                [[GameManager sharedGameManager] runSceneWithID:kLevel2012013];
                break;
            case 14:
                [[GameManager sharedGameManager] runSceneWithID:kLevel2012014];
                break;
            case 15:
                [[GameManager sharedGameManager] runSceneWithID:kLevel2012015];
                break;
            case 16:
                [[GameManager sharedGameManager] runSceneWithID:kLevel2012016];
                break;
            case 17:
                [[GameManager sharedGameManager] runSceneWithID:kLevel2012017];
                break;
            case 18:
                [[GameManager sharedGameManager] runSceneWithID:kLevel2012018];
                break;
            case 19:
                [[GameManager sharedGameManager] runSceneWithID:kLevel2012019];
                break;
            case 20:
                [[GameManager sharedGameManager] runSceneWithID:kLevel2012020];
                break;
            case 21:
                [[GameManager sharedGameManager] runSceneWithID:kLevel2012021];
                break;
            case 22:
                [[GameManager sharedGameManager] runSceneWithID:kLevel2012022];
                break;

            case 1001:
                //BackButton
                [[GameManager sharedGameManager] runSceneWithID:kSeasonsScreen];
                break;
                
            default:
                NSLog(@"Something is wrong in QQLevelChooser::touchBegan!");
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
    //[self unschedule:@selector(runSceneWithIDkLevel2012001)];
    
    if(nil != loader)
        [loader release];
    
	delete _world;
	_world = NULL;
	
  	delete m_debugDraw;
    
	[super dealloc];    // don't forget to call "super dealloc"
}
@end
////////////////////////////////////////////////////////////////////////////////

