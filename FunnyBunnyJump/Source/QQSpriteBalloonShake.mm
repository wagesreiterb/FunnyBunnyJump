//
//  QQSpriteBalloonShake.m
//  FunnyBunnyJump
//
//  Created by Que on 26.10.12.
//
//

#import "QQSpriteBalloonShake.h"

@implementation QQSpriteBalloonShake

-(void)startMoving {
    float interval = 1.0f;
    [self schedule: @selector(tick:) interval:interval];
    _moveLeft = YES;
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

@end
