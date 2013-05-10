//
//  QQSpritePlayer.m
//  Acrobat_g7003
//
//  Created by Que on 25.08.12.
//
//

#import "QQSpritePlayer.h"

@implementation QQSpritePlayer

@synthesize dead;
@synthesize jumping;
@synthesize acceptForces;
@synthesize balloonTouched;
@synthesize force;
@synthesize shallBeam;
@synthesize allowBeaming;
@synthesize location;
@synthesize shallResetPosition;


-(void) dealloc{
	[super dealloc];
}
////////////////////////////////////////////////////////////////////////////////
-(void) ownPlayerSpriteInit{
    //initialize your member variabled here
    _lifes = LIFES;
    allowBeaming = YES;
}
//------------------------------------------------------------------------------
-(id) init{
    self = [super init];
    if (self != nil){
        [self ownPlayerSpriteInit];
    }
    return self;
}
//------------------------------------------------------------------------------
-(void)postInit{
    //do whatever you need here - at this point you will have all the info
}
//------------------------------------------------------------------------------
+(id)spriteWithDictionary:(NSDictionary*)dictionary{
    return [[[self alloc] initWithDictionary:dictionary] autorelease];
}
//------------------------------------------------------------------------------
+(id)batchSpriteWithDictionary:(NSDictionary*)dictionary batch:(LHBatch*)batch{
    return [[[self alloc] initBatchSpriteWithDictionary:dictionary batch:batch] autorelease];
}
//------------------------------------------------------------------------------
-(id)initWithDictionary:(NSDictionary*)dictionary{
    self = [super initWithDictionary:dictionary];
    if (self != nil){
        [self ownPlayerSpriteInit];
    }
    return self;
}
//------------------------------------------------------------------------------
-(id)initBatchSpriteWithDictionary:(NSDictionary*)dictionary batch:(LHBatch*)batch{
    self = [super initBatchSpriteWithDictionary:dictionary batch:batch];
    if (self != nil){
        [self ownPlayerSpriteInit];
    }
    return self;
}
//------------------------------------------------------------------------------
+(bool) isPlayerSprite:(id)object{
    if(nil == object)
        return false;
    return [object isKindOfClass:[QQSpritePlayer class]];
}

-(void)applyForce {
    if([self acceptForces] == TRUE) {
        b2Vec2 velocity = [self body]->GetLinearVelocity();
        NSLog(@"..... applyForce, velocity: %f", velocity.y );
        //if(velocity.y > 6.3f) {
        if(velocity.y > 5.3f) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"hui_que.mp3"];
        }
        [self body]->ApplyForce(b2Vec2([self force],0), [self body]->GetWorldCenter());
        [self setAcceptForces:FALSE];
    }
}

-(void)upOrDownAction:(LHSprite*)earLeft withEarRight:(LHSprite*)earRight
         withHandLeft:(LHSprite*)handLeft withHandRight:(LHSprite*)handRight {
    CGPoint oldLocation = _locationY;
    _locationY = [self position];
    
    if(oldLocation.y < location.y) {
        //CCLOG(@"------- UP");
        [earLeft body]->SetGravityScale(3.0);
        [earRight body]->SetGravityScale(3.0);
        [handLeft body]->SetGravityScale(3.0);
        [handRight body]->SetGravityScale(3.0);
    } else {
        //CCLOG(@"------- DOWN");
        [earLeft body]->SetGravityScale(0.3);
        [earRight body]->SetGravityScale(0.3);
        [handLeft body]->SetGravityScale(0.3);
        [handRight body]->SetGravityScale(0.3);
    }
}

-(void)upOrDownActionWithLoader:(LevelHelperLoader*)loader_ {
    CGPoint oldLocation = _locationY;
    _locationY = [self position];
    LHSprite* earLeft = [loader_ spriteWithUniqueName:@"bunny_ear_left"];
    LHSprite* earRight = [loader_ spriteWithUniqueName:@"bunny_ear_right"];
    LHSprite* handLeft = [loader_ spriteWithUniqueName:@"bunny_hand_left"];
    LHSprite* handRight = [loader_ spriteWithUniqueName:@"bunny_hand_right"];
    
    if(oldLocation.y < location.y) {
        //CCLOG(@"------- UP");
        if(earLeft!=nil) [earLeft body]->SetGravityScale(3.0);
        if(earRight!=nil) [earRight body]->SetGravityScale(3.0);
        if(handLeft!=nil) [handLeft body]->SetGravityScale(3.0);
        if(handRight!=nil) [handRight body]->SetGravityScale(3.0);
    } else {
        //CCLOG(@"------- DOWN");
        if(earLeft!=nil) [earLeft body]->SetGravityScale(0.3);
        if(earRight!=nil) [earRight body]->SetGravityScale(0.3);
        if(handLeft!=nil) [handLeft body]->SetGravityScale(0.3);
        if(handRight!=nil) [handRight body]->SetGravityScale(0.3);
    }
}

-(void)deflect {   //ablenken
    CGPoint oldLocation = location;
    location = [self position];
    
    if(balloonTouched) {
        float desiredVelocity = 0.8f;
        
        if(oldLocation.x < location.x) {
            desiredVelocity *= -1;
        }

        float impulse = [self body]->GetMass() * desiredVelocity;
        [self body]->ApplyLinearImpulse(b2Vec2(impulse, 0), [self body]->GetWorldCenter());
        
        balloonTouched = NO;
    }
}

/*
-(void)applyStartJump {
    if([self startJumpFinished] == FALSE) {
        [self scheduleOnce:@selector(applyStartJumpAfterTick:) delay:0.0f];
        [self setStartJumpFinished:TRUE];
        [self scheduleOnce:@selector(playYippyWithDelay) delay:0.3f];
    }
}

-(void)applyStartJumpWithGravity:(b2Vec2)gravity_ {
    _gravity = gravity_;
    if([self startJumpFinished] == FALSE) {
        [self scheduleOnce:@selector(applyStartJumpAfterTick:) delay:0.0f];
        [self setStartJumpFinished:TRUE];
        [self scheduleOnce:@selector(playYippyWithDelay) delay:0.3f];
    }
}
*/

-(void)applyStartJumpWithImpulseX:(double)impulseX_ withImpulseY:(double)impulseY_ {
    _startImpulseX = impulseX_;
    _startImpulseY = impulseY_;
    if([self startJumpFinished] == FALSE) {
        [self scheduleOnce:@selector(applyStartJumpAfterTick:) delay:0.0f];
        [self setStartJumpFinished:TRUE];
        [self scheduleOnce:@selector(playYippyWithDelay) delay:0.3f];
    }
}

-(void)applyStartJumpAfterTick:(ccTime)dt {
    [self body]->ApplyLinearImpulse( b2Vec2(_startImpulseX, _startImpulseY), body->GetWorldCenter() );
    
}
 
-(void)playYippyWithDelay {
    [[SimpleAudioEngine sharedEngine] playEffect:@"yippy_que.mp3"];
}

/*
-(void)applyStartJumpAfterTick:(ccTime)dt {
    [self body]->ApplyLinearImpulse( b2Vec2(0.12,0.18), body->GetWorldCenter() );

}
*/

/*
-(void)applyStartJumpAfterTick:(ccTime)dt {
    //[self body]->ApplyLinearImpulse( b2Vec2(0.15,0.25), body->GetWorldCenter() );
    NSLog(@"GRAVITY: %f", _gravity.y);
    if(_gravity.y == -1.75) {
        [self body]->ApplyLinearImpulse( b2Vec2(0.12,0.18), body->GetWorldCenter() );
    } else if (_gravity.y == -2.5) {
        [self body]->ApplyLinearImpulse( b2Vec2(0.15,0.25), body->GetWorldCenter() );
    }
}
*/

/*
-(void)resetPosition {
    if(shallResetPosition) {
        [self transformPosition:CGPointMake(240, 160)];
        shallResetPosition = NO;
    }
}

-(void)resetPosition:(LHLayer*)layer {
    if(shallResetPosition) {
        [self transformPosition:CGPointMake(240, 160)];
        shallResetPosition = NO;
        
        NSLog(@"------------- resetPosition");
        CCParticleSystemQuad *particle = [[CCParticleSystemQuad alloc] initWithFile:@"bunnyAppears.plist"];
        [particle setPosition:CGPointMake([self position].x, [self position].y)];
        [layer addChild:particle];
        [particle release];
    }
}
*/
 
-(void)beamPlayer:(LHSprite*)beamContact fromBeamObject:(LHSprite*)beam1 toBeamObject:(LHSprite*)beam2 {
    CGPoint beam1Position;
    beam1Position.x = [beam1 position].x;
    beam1Position.y = [beam1 position].y;

    CGPoint beam2Position;
    beam2Position.x = [beam2 position].x;
    beam2Position.y = [beam2 position].y;
    
    if([@"beam2" isEqualToString:[beamContact uniqueName]]) {
        beamPosition = beam1Position;
    } else {
        beamPosition = beam2Position;
    }
    shallBeam = TRUE;
}

/*
-(void)beam {
    if(shallBeam) {
        NSLog(@"IM LOADER!!!");
        [self transformPosition:beamPosition];
        
        [self body]->SetLinearVelocity(b2Vec2(0,0));
        shallBeam = FALSE;
    }
}
*/

-(void)beamWithLoader:(LevelHelperLoader*)loader_ {
    if(shallBeam) {
        //LHSprite* earLeft = [loader_ spriteWithUniqueName:@"bunny_ear_left"];
        //float earLeftDiffX = self.position.x - earLeft.position.x;
        //float earLeftDiffY = self.position.y - earLeft.position.y;
        //NSLog(@"bunny x: %f, y: %f", self.position.x, self.position.x);
        //NSLog(@"earLe x: %f, y: %f", earLeft.position.y, earLeft.position.y);
        //[earLeft transformPosition:CGPointMake(beamPosition.x + 50.344, beamPosition.y - 66.02)];
        //[earLeft transformPosition:CGPointMake(beamPosition.x - earLeftDiffX, beamPosition.y + earLeftDiffY)];
        //)[earLeft transformPosition:CGPointMake(50, 66)];
        //NSLog(@"bunny x: %f, y: %f", self.position.x, self.position.x);
        //NSLog(@"earLe x: %f, y: %f", earLeft.position.y, earLeft.position.y);
        
        [self transformPosition:beamPosition];
        LHSprite* leftRight = [loader_ spriteWithUniqueName:@"bunny_ear_left"];
        [leftRight transformPosition:beamPosition];
        LHSprite* earRight = [loader_ spriteWithUniqueName:@"bunny_ear_right"];
        [earRight transformPosition:beamPosition];
        LHSprite* handLeft = [loader_ spriteWithUniqueName:@"bunny_hand_left"];
        [handLeft transformPosition:beamPosition];
        LHSprite* handRight = [loader_ spriteWithUniqueName:@"bunny_hand_right"];
        [handRight transformPosition:beamPosition];
        
        [self body]->SetLinearVelocity(b2Vec2(0,0));
        shallBeam = FALSE;
    }
}

-(void)stopPlayer {
    if(_playerStopped) {
        [self makeStatic];
        _playerStopped = NO;
    }
}

-(void)setPause:(BOOL)pause {
    if(pause == YES) {
        //[self pauseAnimation];
        [self makeStatic];
    } else {
        //[self playAnimation];
        [self makeDynamic];
    }
}

-(void)makeInvisibleAndStaitc:(LevelHelperLoader*)loader_ {
    [self makeStatic];
    [self setOpacity:0];
    LHSprite* earLeft = [loader_ spriteWithUniqueName:@"bunny_ear_left"];
    [earLeft setOpacity:0];
    LHSprite* earRight = [loader_ spriteWithUniqueName:@"bunny_ear_right"];
    [earRight setOpacity:0];
    LHSprite* handLeft = [loader_ spriteWithUniqueName:@"bunny_hand_left"];
    [handLeft setOpacity:0];
    LHSprite* handRight = [loader_ spriteWithUniqueName:@"bunny_hand_right"];
    [handRight setOpacity:0];
}

-(void)removeSelfWithLoader:(LevelHelperLoader*)loader_ {
    [self removeSelf];
    LHSprite* earLeft = [loader_ spriteWithUniqueName:@"bunny_ear_left"];
    [earLeft removeSelf];
    LHSprite* earRight = [loader_ spriteWithUniqueName:@"bunny_ear_right"];
    [earRight removeSelf];
    LHSprite* handLeft = [loader_ spriteWithUniqueName:@"bunny_hand_left"];
    [handLeft removeSelf];
    LHSprite* handRight = [loader_ spriteWithUniqueName:@"bunny_hand_right"];
    [handRight removeSelf];
}

-(void)setPositionWithLoader:(LevelHelperLoader*)loader_ position:(CGPoint)position__{
    NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
    _initialPositionBunny.x = position__.x;
    _initialPositionBunny.y = position__.y;
    
    _initialPositionBunny = position__;
    //_initialPositionEarLeft = position_;
    //_initialPositionEarRight = position_;
    //_initialPositionHandLeft = [handLeft position];
    //_initialPositionHandRight = [handRight position];
}

-(void)setInitialPositionWithLoader:(LevelHelperLoader*)loader_ withLayer:(LHLayer*)layer {
    LHSprite* earLeft = [loader_ spriteWithUniqueName:@"bunny_ear_left"];
    LHSprite* earRight = [loader_ spriteWithUniqueName:@"bunny_ear_right"];
    LHSprite* handLeft = [loader_ spriteWithUniqueName:@"bunny_hand_left"];
    LHSprite* handRight = [loader_ spriteWithUniqueName:@"bunny_hand_right"];
    
    _initialPositionBunny = [self position];
    _initialPositionEarLeft = [earLeft position];
    _initialPositionEarRight = [earRight position];
    _initialPositionHandLeft = [handLeft position];
    _initialPositionHandRight = [handRight position];
    
    CCParticleSystemQuad *particle = [[CCParticleSystemQuad alloc] initWithFile:@"bunnyAppears.plist"];
    [particle setPosition:CGPointMake([self position].x, [self position].y)];
    [layer addChild:particle];
    [particle release];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"twinkle.wav"];
}

-(void)setInitialPositionWithLoader:(LevelHelperLoader*)loader_ {
    LHSprite* earLeft = [loader_ spriteWithUniqueName:@"bunny_ear_left"];
    LHSprite* earRight = [loader_ spriteWithUniqueName:@"bunny_ear_right"];
    LHSprite* handLeft = [loader_ spriteWithUniqueName:@"bunny_hand_left"];
    LHSprite* handRight = [loader_ spriteWithUniqueName:@"bunny_hand_right"];
    
    _initialPositionBunny = [self position];
    _initialPositionEarLeft = [earLeft position];
    _initialPositionEarRight = [earRight position];
    _initialPositionHandLeft = [handLeft position];
    _initialPositionHandRight = [handRight position];
}

-(void)restoreInitialPosition:(LevelHelperLoader*)loader_ {
    
    if(_restoreInitialPostitionRequired) {
        NSLog(@"+++++++++++++++  IF restoreInitialPosition");
        LHSprite* earLeft = [loader_ spriteWithUniqueName:@"bunny_ear_left"];
        LHSprite* earRight = [loader_ spriteWithUniqueName:@"bunny_ear_right"];
        LHSprite* handLeft = [loader_ spriteWithUniqueName:@"bunny_hand_left"];
        LHSprite* handRight = [loader_ spriteWithUniqueName:@"bunny_hand_right"];
        
        [self transformPosition:_initialPositionBunny];
        [earLeft transformPosition:_initialPositionEarLeft];
        [earRight transformPosition:_initialPositionEarRight];
        [handLeft transformPosition:_initialPositionHandLeft];
        [handRight transformPosition:_initialPositionHandRight];
        _restoreInitialPostitionRequired = NO;
        
        [self body]->SetLinearVelocity(b2Vec2(0,0));
        
        _startJumpFinished = NO;
    }
}

-(void)restoreInitialPosition:(LevelHelperLoader*)loader_ withLayer:(LHLayer*)layer {

    if(_restoreInitialPostitionRequired) {
        NSLog(@"_______________ IF restoreInitialPosition");
        LHSprite* earLeft = [loader_ spriteWithUniqueName:@"bunny_ear_left"];
        LHSprite* earRight = [loader_ spriteWithUniqueName:@"bunny_ear_right"];
        LHSprite* handLeft = [loader_ spriteWithUniqueName:@"bunny_hand_left"];
        LHSprite* handRight = [loader_ spriteWithUniqueName:@"bunny_hand_right"];
        
        [self transformPosition:_initialPositionBunny];
        [earLeft transformPosition:_initialPositionEarLeft];
        [earRight transformPosition:_initialPositionEarRight];
        [handLeft transformPosition:_initialPositionHandLeft];
        [handRight transformPosition:_initialPositionHandRight];
        _restoreInitialPostitionRequired = NO;
        
        [self body]->SetLinearVelocity(b2Vec2(0,0));
        
        _startJumpFinished = NO;
        
        _layer = layer;
        //[self scheduleOnce:@selector(bunnyAppearsAfterTick:) delay:0.3f];

        CCParticleSystemQuad *particle = [[CCParticleSystemQuad alloc] initWithFile:@"bunnyAppears.plist"];
        [particle setPosition:CGPointMake([self position].x, [self position].y)];
        [layer addChild:particle];
        [particle release];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"twinkle.wav"];

    }
}

//-(void)bunnyAppearsAfterTick:(ccTime)dt {
//        CCParticleSystemQuad *particle = [[CCParticleSystemQuad alloc] initWithFile:@"bunnyAppears.plist"];
//        [particle setPosition:CGPointMake([self position].x, [self position].y)];
//        [_layer addChild:particle];
//        [particle release];
//}

/*
-(void)saveInitialSettingsWithLoader:(LevelHelperLoader*)loader_ {
    LHSprite* earLeft = [loader_ spriteWithUniqueName:@"bunny_ear_left"];
    LHSprite* earRight = [loader_ spriteWithUniqueName:@"bunny_ear_right"];
    LHSprite* handLeft = [loader_ spriteWithUniqueName:@"bunny_hand_left"];
    LHSprite* handRight = [loader_ spriteWithUniqueName:@"bunny_hand_right"];
    _earLeftDensity = [earLeft body]->GetFixtureList()->GetDensity();
    _earRightDensity = [earRight body]->GetFixtureList()->GetDensity();
    _handLeftDensity = [handLeft body]->GetFixtureList()->GetDensity();
    _handRightDensity = [handRight body]->GetFixtureList()->GetDensity();
    _bunnyDensity = [self body]->GetFixtureList()->GetDensity();
}

-(void)setGravityToZeroWithLoader:(LevelHelperLoader*)loader_ {
    LHSprite* earLeft = [loader_ spriteWithUniqueName:@"bunny_ear_left"];
    LHSprite* earRight = [loader_ spriteWithUniqueName:@"bunny_ear_right"];
    LHSprite* handLeft = [loader_ spriteWithUniqueName:@"bunny_hand_left"];
    LHSprite* handRight = [loader_ spriteWithUniqueName:@"bunny_hand_right"];
    [earLeft body]->SetGravityScale(0);
    [earRight body]->SetGravityScale(0);
    [handLeft body]->SetGravityScale(0);
    [handRight body]->SetGravityScale(0);
    [self body]->SetGravityScale(0);
}
*/

@end















