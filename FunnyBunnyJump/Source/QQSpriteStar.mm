//
//  QQSpriteStar.m
//  Acrobat_g7003
//
//  Created by Que on 12.09.12.
//
//

#import "QQSpriteStar.h"

@implementation QQSpriteStar

@synthesize wasTouched;
@synthesize starDestination;

////////////////////////////////////////////////////////////////////////////////
-(void) ownStarSpriteInit{
    //initialize your member variabled here
    _particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingStar5.plist"];
}
//------------------------------------------------------------------------------
-(id) init{
    self = [super init];
    if (self != nil){
        [self ownStarSpriteInit];
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
        [self ownStarSpriteInit];
    }
    return self;
}
//------------------------------------------------------------------------------
-(id)initBatchSpriteWithDictionary:(NSDictionary*)dictionary batch:(LHBatch*)batch{
    self = [super initBatchSpriteWithDictionary:dictionary batch:batch];
    if (self != nil){
        [self ownStarSpriteInit];
    }
    return self;
}
//------------------------------------------------------------------------------
+(bool) isStarSprite:(id)object{
    if(nil == object)
        return false;
    return [object isKindOfClass:[QQSpriteStar class]];
}

-(QQSpriteStar*)reactToTouch:(QQSpriteStar*)star withWorld:(b2World*)world withLayer:(CCLayer*)layer {
    if(wasTouched) {
        [_particle setPosition:CGPointMake([self position].x, [self position].y)];
        [layer addChild:_particle];

        [star setUsesOverloadedTransformations:YES];
        id actionMove = [CCMoveTo actionWithDuration:0.5 position:starDestination];
        [star runAction:actionMove];
        
        [star body]->SetActive(false);
        wasTouched = FALSE;
        return star;
    }
    return star;
}

@end
