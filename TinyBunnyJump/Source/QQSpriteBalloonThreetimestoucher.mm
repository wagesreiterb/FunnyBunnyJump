//
//  QQSpriteBalloonThreetimestoucher.m
//  FunnyBunnyJump
//
//  Created by Que on 04.11.12.
//
//

#import "QQSpriteBalloonThreetimestoucher.h"

@implementation QQSpriteBalloonThreetimestoucher

@synthesize reactToCollision;
@synthesize _balloonCompletelyInflated;

////////////////////////////////////////////////////////////////////////////////
-(void) ownSpriteBalloonThreetimestoucherInit{
    //initialize your member variabled here
    _touchCount = 2;
    _scaleFactor = 90;
    _repeat = 20;
    _balloonCompletelyInflated = YES;
    reactToCollision = YES;
}
//------------------------------------------------------------------------------
-(id) init{
    self = [super init];
    if (self != nil){
        [self ownSpriteBalloonThreetimestoucherInit];
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
        [self ownSpriteBalloonThreetimestoucherInit];
    }
    return self;
}
//------------------------------------------------------------------------------
-(id)initBatchSpriteWithDictionary:(NSDictionary*)dictionary batch:(LHBatch*)batch{
    self = [super initBatchSpriteWithDictionary:dictionary batch:batch];
    if (self != nil){
        [self ownSpriteBalloonThreetimestoucherInit];
    }
    return self;
}
//------------------------------------------------------------------------------
+(bool) isBalloonSprite:(id)object{
    if(nil == object)
        return false;
    return [object isKindOfClass:[QQSpriteBalloon class]];
}

-(NSInteger)reactToTouch:(b2World*)world
               withLayer:(CCLayer*)layer
               withScore:(NSInteger)score_
           withCountdown:(float)countdown_{
    
    if(reactToCollision == NO) {
        [self body]->SetActive(false);
    } else if(_balloonCompletelyInflated == YES && reactToCollision == YES) {
        [self body]->SetActive(true);
        int explodingEffect = 0;
        CCParticleSystem *particle;
        if(self.wasTouched && _touchCount == 0) {
            QQBalloonClass* myInfo = (QQBalloonClass*)[self userInfo];
            if(myInfo != nil){
                explodingEffect = [myInfo explodingEffect];
                if(explodingEffect == 1) {
                    particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon2.plist"];
                    [[SimpleAudioEngine sharedEngine] playEffect:@"balloon_big.wav"];
                    [[SimpleAudioEngine sharedEngine] playEffect:@"fireball.mp3"];
                } else {
                    particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
                    [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
                }
            } else {
                particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
                [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
            }

            [particle setPosition:CGPointMake([self position].x, [self position].y)];
            [layer addChild:particle];
            
            self.wasTouched = FALSE;
            [self body]->SetActive(false);
            [self removeSelf];

            float scoreMultiplier = 1;
            QQBalloonClass* myScoreInfo = (QQBalloonClass*)[self userInfo];
            if(myScoreInfo != nil){
                scoreMultiplier = [myScoreInfo scoreMultiplier];
            }
            score_ += countdown_ * scoreMultiplier;
        } else if (self.wasTouched) {
            [self setReactToCollision:NO];
            self.wasTouched = FALSE;
            _touchCount--;
            for(int i = 0; i <= _repeat; i++) {
                [self transformScale:[self scale] * _scaleFactor / 100];
            }
            [self startInflateBalloon];
            
            QQBalloonClass* myInfo = (QQBalloonClass*)[self userInfo];
            if(myInfo != nil){
                explodingEffect = [myInfo explodingEffect];
                if(explodingEffect == 1) {
                    particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon2.plist"];
                    [[SimpleAudioEngine sharedEngine] playEffect:@"balloon_big.wav"];
                    [[SimpleAudioEngine sharedEngine] playEffect:@"fireball.mp3"];
                } else {
                    particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
                    [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
                }
            } else {
                particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
                [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
            }
            
            [particle setPosition:CGPointMake([self position].x, [self position].y)];
            [layer addChild:particle];
            
            int scoreMultiplier = 1;
            QQBalloonClass* myScoreInfo = (QQBalloonClass*)[self userInfo];
            if(myScoreInfo != nil){
                scoreMultiplier = [myScoreInfo scoreMultiplier];
            }
            score_ += countdown_ * scoreMultiplier;
        }
    }
    
    return score_;
}

//-(void)reactToTouchWithWorld:(b2World*)world withLayer:(CCLayer*)layer {
//    
//    if(reactToCollision == NO) {
//        [self body]->SetActive(false);
//    } else if(_balloonCompletelyInflated == YES && reactToCollision == YES) {
//        [self body]->SetActive(true);
//        if(wasTouched && _touchCount == 0) {
//            _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
//            [_particle setPosition:CGPointMake([self position].x, [self position].y)];
//            [layer addChild:_particle];
//            [_particle release];
//            
//            wasTouched = FALSE;
//            
//            [self body]->SetActive(false);
//            [self removeSelf];
//            [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
//        } else if (wasTouched) {
//            [self setReactToCollision:NO];
//            wasTouched = FALSE;
//            _touchCount--;
//            for(int i = 0; i <= _repeat; i++) {
//                [self transformScale:[self scale] * _scaleFactor / 100];
//            }
//            [self startInflateBalloon];
//            
//            _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
//            [_particle setPosition:CGPointMake([self position].x, [self position].y)];
//            [layer addChild:_particle];
//            [_particle release];
//            [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
//        }
//    }
//}

-(void)startInflateBalloon {
    //[self schedule: @selector(tick:) interval:0.05 repeat:20];
    _balloonCompletelyInflated = NO;
    [[SimpleAudioEngine sharedEngine] playEffect:@"balloon_inflate.wav"];
    [self schedule:@selector(tick:) interval:0.05f repeat:_repeat delay:0];
}

-(void)tick:(ccTime)dt {
    [self transformScale:[self scale] * 100 / _scaleFactor];

    if([self scale] >= 0.999f) {
        _balloonCompletelyInflated = YES;
        reactToCollision = YES;
        //NSLog(@"__ IF");
    } else {
        //NSLog(@"__ ELSE");
    }
    //NSLog(@"__ balloon scale: %f, %d", [self scale], _balloonCompletelyInflated);
}


/*
-(void)reactToTouchWithWorld:(b2World*)world withLayer:(CCLayer*)layer {
    
    //if(reactToCollision == YES) {
    if(reactToCollision == YES) {
        [self body]->SetActive(true);
    } else {
        [self body]->SetActive(false);
    }
    
    if(_balloonCompletelyInflated == YES) {
        if(wasTouched && _touchCount == 0) {
            _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
            [_particle setPosition:CGPointMake([self position].x, [self position].y)];
            [layer addChild:_particle];
            [_particle release];
            
            wasTouched = FALSE;
            
            [self body]->SetActive(false);
            [self removeSelf];
            [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
        } else if (wasTouched) {
            [self setReactToCollision:NO];
            wasTouched = FALSE;
            _touchCount--;
            for(int i = 0; i <= _repeat; i++) {
                [self transformScale:[self scale] * _scaleFactor / 100];
            }
            [self startInflateBalloon];
            
            _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
            [_particle setPosition:CGPointMake([self position].x, [self position].y)];
            [layer addChild:_particle];
            [_particle release];
            [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
        }
    }
}
*/

/*
-(QQSpriteBalloonThreetimestoucher*)reactToTouch:(QQSpriteBalloonThreetimestoucher*)balloon
                                       withWorld:(b2World*)world
                                       withLayer:(CCLayer*)layer {
    
    if(reactToCollision == YES) {
        [self body]->SetActive(true);
    } else {
        [self body]->SetActive(false);
    }
    
    if(wasTouched && _touchCount == 0) {
        _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
        [_particle setPosition:CGPointMake([balloon position].x, [balloon position].y)];
        [layer addChild:_particle];
        [_particle release];
        
        wasTouched = FALSE;
        
        [self body]->SetActive(false);
        [self removeSelf];
        [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
        
        return nil;
    } else if (wasTouched) {
        [self setReactToCollision:NO];
        wasTouched = FALSE;
        _touchCount--;
        for(int i = 0; i <= _repeat; i++) {
            [self transformScale:[self scale] * _scaleFactor / 100];
        }
        [self startInflateBalloon];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
    }
    return balloon;
}
 */

@end
