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

////////////////////////////////////////////////////////////////////////////////
-(void) ownSpriteBalloonThreetimestoucherInit{
    //initialize your member variabled here
    _touchCount = 3;
    _scaleFactor = 90;
    _repeat = 20;
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

-(void)reactToTouchWithWorld:(b2World*)world withLayer:(CCLayer*)layer {
    
    if(reactToCollision == YES) {
        [self body]->SetActive(true);
    } else {
        [self body]->SetActive(false);
    }
    
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
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
    }
}

-(void)startInflateBalloon {
    //[self schedule: @selector(tick:) interval:0.05 repeat:20];
    [self schedule:@selector(tick:) interval:0.05f repeat:_repeat delay:0];
}

-(void)tick:(ccTime)dt {    
    [self transformScale:[self scale] * 100 / _scaleFactor];
    //if(_repeat == 0) {
    //    [self setTouchesDisabled:NO];
    //    _repeat--;
    //}
}

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
