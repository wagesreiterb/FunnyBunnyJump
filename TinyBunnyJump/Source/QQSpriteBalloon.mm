//
//  QQSpriteBalloon.m
//  Acrobat_g7003
//
//  Created by Que on 29.08.12.
//
//

#import "QQSpriteBalloon.h"

//static NSUInteger instances = 0;

@implementation QQSpriteBalloon

//+(NSUInteger)numberOfInstances {
//    return instances;
//}

//@synthesize wasTouched;
@synthesize currentToDo;

-(void) dealloc{
    //[_particle release];

//    NSLog(@"QQSpriteBallon-::release:1 %@", self);
//    instances--;
//    NSLog(@"QQSpriteBallon--::release:2 %@", self);
}
////////////////////////////////////////////////////////////////////////////////
-(void) ownSpriteBalloonlineInit{
    //initialize your member variabled here
}
//------------------------------------------------------------------------------
-(id) init{
	if( (self=[super init])) {
        [self ownSpriteBalloonlineInit];
    }
    return self;
}
//------------------------------------------------------------------------------
-(void)postInit{
    //instances++;
    //NSLog(@"xxxxxxxxxxxxxxxxxxxx");
    //do whatever you need here - at this point you will have all the info
    //[[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"incObjectsToBeRemoved" object:nil];
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
        [self ownSpriteBalloonlineInit];
    }
    return self;
}
//------------------------------------------------------------------------------
-(id)initBatchSpriteWithDictionary:(NSDictionary*)dictionary batch:(LHBatch*)batch{
    self = [super initBatchSpriteWithDictionary:dictionary batch:batch];
    if (self != nil){
        [self ownSpriteBalloonlineInit];
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
               withScore: (NSInteger)score_
           withCountdown:(float)countdown_{
    
    if(_wasTouched) {
        int explodingEffect = 0;
        CCParticleSystem *particle;
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
                
        _wasTouched = FALSE;
        [self body]->SetActive(false);
        [self removeSelf];
        
        float scoreMultiplier = 1;
        QQBalloonClass* myScoreInfo = (QQBalloonClass*)[self userInfo];
        if(myScoreInfo != nil){
            scoreMultiplier = [myScoreInfo scoreMultiplier];
        }
        score_ += countdown_ * scoreMultiplier;
    }
    return score_;
}

//TODO: is this method required at all?
-(id)removeMe {
    [self removeSelf];
    
    return self;
}

@end


//-(void)reactToTouch:(b2World*)world withLayer:(CCLayer*)layer {
//    //CCLOG(@"reactToTouch");
//    if(wasTouched) {
//
//
//        int explodingEffect = 0;
//        QQBalloonClass* myInfo = (QQBalloonClass*)[self userInfo];
//        if(myInfo != nil){
//            explodingEffect = [myInfo explodingEffect];
//            if(explodingEffect == 1) {
//                _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon2.plist"];
//                [[SimpleAudioEngine sharedEngine] playEffect:@"balloon_big.wav"];
//                [[SimpleAudioEngine sharedEngine] playEffect:@"fireball.mp3"];
//            } else {
//                _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
//                [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
//            }
//        } else {
//            _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
//            [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
//        }
//
//        [_particle setPosition:CGPointMake([self position].x, [self position].y)];
//        [layer addChild:_particle];
//        [_particle release];
//
//        wasTouched = FALSE;
//        [self body]->SetActive(false);
//
//        [self removeSelf];
//    }
//}

/*
 -(void)setToSensor:(BOOL)sensor {
 for (b2Fixture* f = [self body]->GetFixtureList(); f; f = f->GetNext()) {
 f->SetSensor(sensor);
 }
 }
 */
