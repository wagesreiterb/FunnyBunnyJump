//
//  QQSpriteBalloonBlinker.m
//  FunnyBunnyJump
//
//  Created by Que on 27.11.12.
//
//

#import "QQSpriteBalloonBlinker.h"

@implementation QQSpriteBalloonBlinker

-(void)startBlinkingWithDelay:(ccTime)delay andWithInterval:(ccTime)interval {
    [self schedule: @selector(tick:) interval:interval repeat:-1 delay:delay];
}

-(void)tick:(ccTime)dt {
    [self setVisible:_visible];
    if(_visible) [self swallowTouches];
    for (b2Fixture* f = [self body]->GetFixtureList(); f; f = f->GetNext()) {
        //f->SetSensor(_visible);
        //[self makeKinematic];
    }
    _visible = !_visible;
}

-(void)reactToTouch:(b2World*)world withLayer:(CCLayer*)layer {
    //CCLOG(@"reactToTouch");
    if(wasTouched) {
        if(!_visible) {
            _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
            [_particle setPosition:CGPointMake([self position].x, [self position].y)];
            [layer addChild:_particle];
            [_particle release];
            [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
            
            wasTouched = FALSE;
            [self body]->SetActive(false);
            
            [self removeSelf];
        }
    }
}

@end
