//
//  QQSpriteBalloonBlinker.m
//  FunnyBunnyJump
//
//  Created by Que on 27.11.12.
//
//

#import "QQSpriteBalloonBlinker.h"

@implementation QQSpriteBalloonBlinker

-(void)startBlinkingWithDelay:(ccTime)delay andWithInterval:(ccTime)interval andWithModulo:(int)modulo {
    _modulo = modulo;
    [self schedule: @selector(tickTack:) interval:interval repeat:-1 delay:delay];
}

-(void)tickTack:(ccTime)dt {
    if(_counter++ % _modulo == 0) {
        [self setVisible:NO];
    } else {
        [self setVisible:YES];
    }
    if(_counter == _modulo) _counter=0;
}

-(void)startBlinkingWithDelay:(ccTime)delay andWithInterval:(ccTime)interval {
    [self schedule: @selector(tick:) interval:interval repeat:-1 delay:delay];
}

-(void)tick:(ccTime)dt {
    [self setVisible:_visible];
    _visible = !_visible;
}

-(NSInteger)reactToTouch:(b2World*)world
               withLayer:(CCLayer*)layer
               withScore:(NSInteger)score_
           withCountdown:(float)countdown_{
    
    if([self wasTouched]) {
        if(!_visible) {
            int explodingEffect = 0;
            QQBalloonClass* myInfo = (QQBalloonClass*)[self userInfo];
            CCParticleSystem *particle;
            if(myInfo != nil){
                explodingEffect = [myInfo explodingEffect];
                if(explodingEffect == 1) {
                    particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon2.plist"];
                    [[SimpleAudioEngine sharedEngine] playEffect:@"balloon_big.wav"];
                    [[SimpleAudioEngine sharedEngine] playEffect:@"fireball.wav"];
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
            
            //_wasTouched = FALSE;
            [self setWasTouched:FALSE];
            [self body]->SetActive(false);
            [self removeSelf];
            
            
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

@end

//-(void)reactToTouch:(b2World*)world withLayer:(CCLayer*)layer {
//    if(wasTouched) {
//        CCLOG(@"aaa reactToTouch");
//
//        if(!_visible) {
//            int explodingEffect = 0;
//            QQBalloonClass* myInfo = (QQBalloonClass*)[self userInfo];
//            if(myInfo != nil){
//                explodingEffect = [myInfo explodingEffect];
//                if(explodingEffect == 1) {
//                    CCLOG(@"----- 1");
//                    _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon2.plist"];
//                    [[SimpleAudioEngine sharedEngine] playEffect:@"balloon_big.wav"];
//                } else {
//                    CCLOG(@"----- 2");
//                    _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
//                    [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
//                }
//            } else {
//                CCLOG(@"----- 3");
//                _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
//                [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
//            }
//            [_particle setPosition:CGPointMake([self position].x, [self position].y)];
//            [layer addChild:_particle];
//            [_particle release];
//
//            wasTouched = FALSE;
//            [self body]->SetActive(false);
//
//            [self removeSelf];
//        }
//    }
//}

//-(void)reactToTouch:(b2World*)world withLayer:(CCLayer*)layer {
//    //CCLOG(@"reactToTouch");
//    if(wasTouched) {
//        if(!_visible) {
//            _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
//            [_particle setPosition:CGPointMake([self position].x, [self position].y)];
//            [layer addChild:_particle];
//            [_particle release];
//            [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
//
//            wasTouched = FALSE;
//            [self body]->SetActive(false);
//
//            [self removeSelf];
//        }
//    }
//}

//-(NSInteger)reactToTouch:(b2World*)world
//               withLayer:(CCLayer*)layer
//               withScore:(NSInteger)score_
//           withCountdown:(float)countdown_{
//    
//    if(wasTouched) {
//        if(!_visible) {
//            CCLOG(@"xxx reactToTouch");
//            
//            _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
//            [_particle setPosition:CGPointMake([self position].x, [self position].y)];
//            [layer addChild:_particle];
//            [_particle release];
//            [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
//            
//            wasTouched = FALSE;
//            [self body]->SetActive(false);
//            
//            [self removeSelf];
//            score_ += countdown_;
//        }
//    }
//    return score_;
//}


