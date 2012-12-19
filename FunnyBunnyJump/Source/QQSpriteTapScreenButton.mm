//
//  QQSpriteTapScreenButton.m
//  FunnyBunnyJump
//
//  Created by Que on 25.11.12.
//
//

#import "QQSpriteTapScreenButton.h"

@implementation QQSpriteTapScreenButton

-(void) dealloc{
	[super dealloc];
}
////////////////////////////////////////////////////////////////////////////////
-(void) ownSpriteTapScreenButtonInit{
    //initialize your member variabled here
}
//------------------------------------------------------------------------------
-(id) init{
    self = [super init];
    if (self != nil){
        [self ownSpriteTapScreenButtonInit];
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
        [self ownSpriteTapScreenButtonInit];
    }
    return self;
}
//------------------------------------------------------------------------------
-(id)initBatchSpriteWithDictionary:(NSDictionary*)dictionary batch:(LHBatch*)batch{
    self = [super initBatchSpriteWithDictionary:dictionary batch:batch];
    if (self != nil){
        [self ownSpriteTapScreenButtonInit];
    }
    return self;
}
//------------------------------------------------------------------------------
+(bool) isTapScreenButtonSprite:(id)object{
    if(nil == object)
        return false;
    return [object isKindOfClass:[QQSpriteTapScreenButton class]];
}

//Que
-(void)startWithInterval:(float)interval {
    //interval good choice is 0.05f
    [self schedule: @selector(tick:) interval:interval];
    _changeToBigger = YES;
    _count = 0;
            NSLog(@"_______ startWithInterval");
}

-(void)tick:(ccTime)dt {
    int maxCount = 60;
    float scaleFactor = 101;
    
    if(_count >= 0 && _count < maxCount/2) {
        [self transformScale:[self scale] * scaleFactor / 100];
    } else if (_count >= maxCount/2 && _count < maxCount) {
        [self transformScale:[self scale] * 100 / scaleFactor];
    }
    _count++;
    if(_count == maxCount) _count = 0;
                NSLog(@"_______ tick");
}

@end
