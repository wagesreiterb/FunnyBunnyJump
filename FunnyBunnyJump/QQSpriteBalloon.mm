//
//  QQSpriteBalloon.m
//  Acrobat_g7003
//
//  Created by Que on 29.08.12.
//
//

#import "QQSpriteBalloon.h"

@implementation QQSpriteBalloon

@synthesize wasTouched;
@synthesize currentToDo;

-(void) dealloc{
    //[_particle release];
	[super dealloc];
}
////////////////////////////////////////////////////////////////////////////////
-(void) ownSpriteBalloonlineInit{
    //initialize your member variabled here
}
//------------------------------------------------------------------------------
-(id) init{
    self = [super init];
    if (self != nil){
        [self ownSpriteBalloonlineInit];
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

-(id)removeMe {
    [self removeSelf];
    
    return self;
}

@end




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