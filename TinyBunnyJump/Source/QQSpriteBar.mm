//
//  QQSpriteBar.m
//  Acrobat_g7003
//
//  Created by Que on 11.09.12.
//
//

#import "QQSpriteBar.h"

@implementation QQSpriteBar

@synthesize blink;

////////////////////////////////////////////////////////////////////////////////
-(void) ownSpriteBarInit{
    //initialize your member variabled here
}
//------------------------------------------------------------------------------
-(id) init{
    self = [super init];
    if (self != nil){
        [self ownSpriteBarInit];
    }
    return self;
}
//------------------------------------------------------------------------------
-(void)postInit{
    //do whatever you need here - at this point you will have all the info
    _blinkDelay = 7;
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
        [self ownSpriteBarInit];
    }
    return self;
}
//------------------------------------------------------------------------------
-(id)initBatchSpriteWithDictionary:(NSDictionary*)dictionary batch:(LHBatch*)batch{
    self = [super initBatchSpriteWithDictionary:dictionary batch:batch];
    if (self != nil){
        [self ownSpriteBarInit];
    }
    return self;
}
//------------------------------------------------------------------------------
+(bool) isBarSprite:(id)object{
    if(nil == object)
        return false;
    return [object isKindOfClass:[QQSpriteBar class]];
}

-(void)updateBar:(ccTime)dt {
    if(_active) {
        _dt += dt;
        if(_dt > _blinkDelay/2) {
            blink = FALSE;
        }else {
            blink = TRUE;
        }
        if(_dt > _blinkDelay) _dt = 0;

        [self setVisible:blink];
        for (b2Fixture* f = [self body]->GetFixtureList(); f; f = f->GetNext()) {
            f->SetSensor(!blink);
        }
    }

}

-(void)setToSensor:(BOOL)active {
    for (b2Fixture* f = [self body]->GetFixtureList(); f; f = f->GetNext()) {
        f->SetSensor(!active);
    }
}

@end





