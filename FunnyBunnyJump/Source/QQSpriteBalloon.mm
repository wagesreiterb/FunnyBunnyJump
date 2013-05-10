//
//  QQSpriteBalloon.m
//  Acrobat_g7003
//
//  Created by Que on 29.08.12.
//
//

#import "QQSpriteBalloon.h"

static NSUInteger instances = 0;

@implementation QQSpriteBalloon

+(NSUInteger)numberOfInstances {
    return instances;
}

@synthesize wasTouched;
@synthesize currentToDo;

-(void) dealloc{
    //[_particle release];

    NSLog(@"QQSpriteBallon::release:1 %@", self);
    [super dealloc];
    instances--;
    NSLog(@"QQSpriteBallon::release:2 %@", self);
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
    instances++;
    NSLog(@"xxxxxxxxxxxxxxxxxxxx");
    //do whatever you need here - at this point you will have all the info
    //[[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"incObjectsToBeRemoved" object:nil];
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
               withScore:(NSInteger)score_
           withCountdown:(float)countdown_{
    
    if(wasTouched) {
        int explodingEffect = 0;
        QQBalloonClass* myInfo = (QQBalloonClass*)[self userInfo];
        if(myInfo != nil){
            explodingEffect = [myInfo explodingEffect];
            if(explodingEffect == 1) {
                _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon2.plist"];
                [[SimpleAudioEngine sharedEngine] playEffect:@"balloon_big.wav"];
                [[SimpleAudioEngine sharedEngine] playEffect:@"fireball.mp3"];
            } else {
                _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
                [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
            }
        } else {
            _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
            [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
        }

        [_particle setPosition:CGPointMake([self position].x, [self position].y)];
        [layer addChild:_particle];
        [_particle release];
                
        wasTouched = FALSE;
        [self body]->SetActive(false);
        [self removeSelf];
        
        int scoreMultiplier = 1;
        QQBalloonClass* myScoreInfo = (QQBalloonClass*)[self userInfo];
        if(myScoreInfo != nil){
            scoreMultiplier = [myScoreInfo scoreMultiplier];
        }
        score_ += countdown_ * scoreMultiplier;
    }
    return score_;
}

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

//TODO: is this method required at all?
-(id)removeMe {
    [self removeSelf];
    
    return self;
}

@end




/*
 -(QQSpriteBalloon*)reactToTouch:(QQSpriteBalloon*)balloon withWorld:(b2World*)world withLayer:(CCLayer*)layer {
 //CCLOG(@"reactToTouch");
 if(wasTouched) {
 _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
 [_particle setPosition:CGPointMake([balloon position].x, [balloon position].y)];
 [layer addChild:_particle];
 [_particle release];
 
 wasTouched = FALSE;
 
 [balloon body]->SetActive(false);
 [self removeSelf];
 
 return nil;
 }
 return balloon;
 }
 */


/*
 -(id) initWithDuration: (ccTime) t opacity: (GLubyte) o
 {
 if( (self=[super initWithDuration: t] ) )
 toOpacity_ = o;
 
 return self;
 }
 */


/*
 -(QQSpriteBalloon*)reactToTouch:(QQSpriteBalloon*)balloon withWorld:(b2World*)world {
 CCLOG(@"react To Touch");
 
 return nil;
 }
 */

/*
 -(QQSpriteBalloon*)reactToTouch:(QQSpriteBalloon*)balloon withWorld:(b2World*)world withLayer:(CCLayer*)layer {
 NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
 
 return balloon;
 }
 */

/*
 -(QQSpriteBalloon*)reactToTouch:(QQSpriteBalloon*)balloon withWorld:(b2World*)world withLayer:(CCLayer*)layer {
 //CCLOG(@"reactToTouch");
 if(wasTouched) {
 CCLOG(@"reactToTouch:wasTouched");
 switch (currentToDo) {
 case REMOVE:
 CCLOG(@"reactToTouch:remove");
 _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
 [_particle setPosition:CGPointMake([balloon position].x, [balloon position].y)];
 [layer addChild:_particle];
 
 wasTouched = FALSE;
 [self removeSelf];
 
 return nil;
 break;
 
 case EXPLODE:
 if(nil != balloon) {
 CCLOG(@"QQSpriteBalloon::reactToTouch EXPLODE");
 [balloon body]->SetType(b2_dynamicBody);
 //[[LHCuttingEngineMgr sharedInstance] splitSprite:balloon
 //                                         atPoint:balloon.position];
 
 [[LHCuttingEngineMgr sharedInstance] cutSpritesFromPoint:balloon.position
 inRadius:30
 cuts:6
 fromWorld:world];
 
 [[LHCuttingEngineMgr sharedInstance] explodeSpritesInRadius:30
 withForce:2
 position:balloon.position
 inWorld:world];
 [self removeSelf];
 wasTouched = FALSE;
 return nil;
 }
 break;
 
 case FADEOUT:
 
 CCAction* fadeOut = [balloon runAction:[CCFadeTo actionWithDuration:0.5f opacity:0]];
 
 
 id actionRemoveSelf = [CCCallFuncN actionWithTarget:self
 selector:@selector(removeMe)];
 [self runAction:[CCSequence actions:fadeOut, actionRemoveSelf, nil]];
 
 
 
 //id action = [CCSequence actions:
 //             fadeOut,
 //             nil];
 //[self runAction:action];
 
 
 
 //[self removeSelf];
 wasTouched = FALSE;
 return nil;
 break;
 }
 }
 return balloon;
 }
 */