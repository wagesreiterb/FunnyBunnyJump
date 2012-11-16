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
@synthesize lifes;
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
    //life = 100;
    //magic= 20;
    lifes = 3;
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

-(void)whichDirection {
    CGPoint oldLocation = location;
    location = [self position];
    
    if(balloonTouched) {
        //CGPoint oldLocation = location;
        //location = [self position];
        
        float desiredVelocity = 0.8f;
        
        if(oldLocation.x < location.x) {
            //CCLOG(@"right");
            desiredVelocity *= -1;
        } else {
            //CCLOG(@"left");
        }
        
        //reduce velocity to 0
        //b2Vec2 velocity = [self body]->GetLinearVelocity();
        float impulse = [self body]->GetMass() * desiredVelocity;
        [self body]->ApplyLinearImpulse(b2Vec2(impulse, 0), [self body]->GetWorldCenter());
        //[self body]->SetLinearDamping(1);
        
        //CCLOG(@"%f %f", velocity.x, velocity.y);
        balloonTouched = NO;
    }
    
    /*
    if(oldLocation.y < location.y) {
        CCLOG(@"------- UP");
    } else {
        CCLOG(@"------- DOWN");
        [_leftEar body]->SetGravityScale(3.0);
        [_rightEar body]->SetGravityScale(3.0);
    }
     */
}

-(void)applyStartJump {
    if([self startJumpFinished] == FALSE) {
        [self scheduleOnce:@selector(applyStartJumpAfterTick:) delay:2.0f];
        //[self body]->ApplyLinearImpulse( b2Vec2(0.15,0.35), body->GetWorldCenter() );
        [self setStartJumpFinished:TRUE];
    }
}

-(void)applyStartJumpAfterTick:(ccTime)dt {
    [self body]->ApplyLinearImpulse( b2Vec2(0.15,0.35), body->GetWorldCenter() );
}

-(void)resetPosition {
    if(shallResetPosition) {
        [self transformPosition:CGPointMake(240, 160)];
        shallResetPosition = NO;
    }
}

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

-(void)beam {
    if(shallBeam) {
        [self transformPosition:beamPosition];
        
        [self body]->SetLinearVelocity(b2Vec2(0,0));
        shallBeam = FALSE;
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

@end















