//
//  QQSpriteTrampolin.m
//  Acrobat_g7003
//
//  Created by Que on 28.08.12.
//
//

#import "QQSpriteTrampoline.h"

@implementation QQSpriteTrampoline

@synthesize velocity;
@synthesize shallMove;
@synthesize currentMoveState;
@synthesize restitution;
@synthesize changeRestitution;
//@synthesize currentDirection;

-(void) dealloc{
	[super dealloc];
}
////////////////////////////////////////////////////////////////////////////////
-(void) ownSpriteTrampolineInit{
    //initialize your member variabled here
    currentMoveState = MS_STOP;
}
//------------------------------------------------------------------------------
-(id) init{
    self = [super init];
    if (self != nil){
        [self ownSpriteTrampolineInit];
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
        [self ownSpriteTrampolineInit];
    }
    return self;
}
//------------------------------------------------------------------------------
-(id)initBatchSpriteWithDictionary:(NSDictionary*)dictionary batch:(LHBatch*)batch{
    self = [super initBatchSpriteWithDictionary:dictionary batch:batch];
    if (self != nil){
        [self ownSpriteTrampolineInit];
    }
    return self;
}
//------------------------------------------------------------------------------
+(bool) isPlayerSprite:(id)object{
    if(nil == object)
        return false;
    return [object isKindOfClass:[QQSpriteTrampoline class]];
}


-(void)setInitialRestitution {
    initialRestitution = [self body]->GetFixtureList()->GetRestitution();
}

-(float)initialRestitution {
    return initialRestitution;
}

/*
-(void)setRestitutionAtTick {
    if(changeRestitution) {
        
        for (b2Fixture* f = [self body]->GetFixtureList(); f; f = f->GetNext())
        {
            [self body]->GetFixtureList()->SetRestitution(restitution);
        }
        
        //LHFixture* fix = [self fixtureWithName:@"rectangle"];
    
        
        //[self body]->GetFixtureList()->SetRestitution(restitution);
        changeRestitution = FALSE;

    }
    //CCLOG(@"%f", [self body]->GetFixtureList()->GetRestitution());
}
 */

-(void)setRestitutionAtTick {
    if(changeRestitution) {
        b2Fixture* fix = body->GetFixtureList();
        
        while (fix) {
#ifndef LH_ARC_ENABLED
            LHFixture* lhFix = (LHFixture*)(fix->GetUserData());
#else
            LHFixture* lhFix = (__bridge LHFixture*)(fix->GetUserData());
#endif
            if([LHFixture isLHFixture:lhFix])
            {
                if([[lhFix fixtureName] isEqualToString:@"right"]){
                    fix->SetRestitution(0);
                }
                if([[lhFix fixtureName] isEqualToString:@"left"]){
                    fix->SetRestitution(0);
                }
                if([[lhFix fixtureName] isEqualToString:@"trampoline"]){
                    fix->SetRestitution(restitution);
                }
            }
            fix = fix->GetNext();
        }
        changeRestitution = FALSE;
    }
}


-(void)move:(ccTime)dt {
    b2Vec2 vel = body->GetLinearVelocity();
    //CCLOG(@"%f", vel.x);
    
    float desiredVel = 0;
    float startVelocity = 0.3f; //original 0.6f
    float stopPulse = 0.80f;    //original 0.85f
    float acceleration = 5.0f;
    switch ( currentMoveState )
    {
        case MS_LEFT:  desiredVel = b2Max( vel.x - startVelocity, acceleration * -1 );
            break;
        case MS_STOP:  desiredVel = vel.x * stopPulse; break;
        case MS_RIGHT: desiredVel = b2Min( vel.x + startVelocity,  acceleration );
            break;
    }
    float velChange = desiredVel - vel.x;
    float impulse = body->GetMass() * velChange; //disregard time factor
    body->ApplyLinearImpulse( b2Vec2(impulse,0), body->GetWorldCenter() );
    
    //CCLOG(@"%f", body->GetLinearVelocity());
    
}

@end



/*
 -(void)move:(ccTime)dt {
 if(shallMove == TRUE) {
 if(currentDirection == LEFT) {    //move left
 velocity.x = -1.0f;
 velocity.x -= dt*4;
 [self body]->SetLinearVelocity(velocity);
 } else {                          //move right
 velocity.x = 1.0f;
 velocity.x += dt*4;
 [self body]->SetLinearVelocity(velocity);
 }
 }
 }
 */


/*
 -(void)setVelocity:(b2Vec2)velo {
 //[self body]->SetLinearVelocity(velo);
 velocity = velo;
 }
 */

/*
 -(void)moveLeft:(ccTime)dt {
 velocity.x -= dt*4;
 CCLOG(@"++++++ move left %f", velocity.x);
 [self body]->SetLinearVelocity(velocity);
 }
 
 -(void)moveRight:(ccTime)dt {
 velocity.x += dt*4;
 CCLOG(@"++++++ move right %f", velocity.x);
 [self body]->SetLinearVelocity(velocity);
 }
 */
























