//
//  QQSpriteBarShaker.m
//  FunnyBunnyJump
//
//  Created by Que on 27.11.12.
//
//

#import "QQSpriteBarShaker.h"

@implementation QQSpriteBarShaker

////////////////////////////////////////////////////////////////////////////////
-(void)ownSpriteBarShakerInit{
    //initialize your member variabled here
    
    //_touchCount = 3;
    //_scaleFactor = 90;
    //_repeat = 20;
}
//------------------------------------------------------------------------------
-(id)init{
    self = [super init];
    if (self != nil){
        [self ownSpriteBarShakerInit];
    }
    return self;
}
//------------------------------------------------------------------------------
-(void)postInit{
    //do whatever you need here - at this point you will have all the info
}
//------------------------------------------------------------------------------
+(id)spriteWithDictionary:(NSDictionary*)dictionary{
    return [[self alloc] initWithDictionary:dictionary];
}
//------------------------------------------------------------------------------
+(id)batchSpriteWithDictionary:(NSDictionary*)dictionary batch:(LHBatch*)batch{
    return [[self alloc] initBatchSpriteWithDictionary:dictionary batch:batch];
}
//------------------------------------------------------------------------------
-(id)initWithDictionary:(NSDictionary*)dictionary{
    self = [super initWithDictionary:dictionary];
    if (self != nil){
        [self ownSpriteBarShakerInit];
    }
    return self;
}
//------------------------------------------------------------------------------
-(id)initBatchSpriteWithDictionary:(NSDictionary*)dictionary batch:(LHBatch*)batch{
    self = [super initBatchSpriteWithDictionary:dictionary batch:batch];
    if (self != nil){
        [self ownSpriteBarShakerInit];
    }
    return self;
}
//------------------------------------------------------------------------------
+(bool) isSpriteBarShaker:(id)object{
    if(nil == object)
        return false;
    return [object isKindOfClass:[QQSpriteBarShaker class]];
}

-(void)startMovingWithDelay:(int)delay {
    float interval = 1.0f;
    //[self schedule: @selector(tick:) interval:interval];
    [self schedule: @selector(tick:) interval:interval repeat:-1 delay:delay];
    _moveLeft = YES;
}

-(void)tick:(ccTime)dt {
    b2Vec2 vel = body->GetLinearVelocity();
    float desiredVel = 0;
    float acceleration = 15.0f;
    float startVelocity = 1.9f;
    
    if(_moveLeft) {
        //move ballon left
        _moveLeft = NO;
        desiredVel = b2Max( vel.x - startVelocity, acceleration * -1 );
        
    } else {
        //move ballon right
        desiredVel = b2Min( vel.x + startVelocity,  acceleration );
        _moveLeft = YES;
    }
    float velChange = desiredVel - vel.x;
    float impulse = body->GetMass() * velChange; //disregard time factor
    body->SetLinearDamping(1.0f);
    body->ApplyLinearImpulse( b2Vec2(impulse,0), body->GetWorldCenter() );
}

-(void)setToSensor:(BOOL)active {
    for (b2Fixture* f = [self body]->GetFixtureList(); f; f = f->GetNext()) {
        f->SetSensor(active);
    }
}

@end
