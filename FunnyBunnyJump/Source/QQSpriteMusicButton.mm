//
//  QQSpriteMusicButton.m
//  FunnyBunnyJump
//
//  Created by Que on 27.11.12.
//
//

#import "QQSpriteMusicButton.h"

@implementation QQSpriteMusicButton

-(void) dealloc{
	[super dealloc];
}
////////////////////////////////////////////////////////////////////////////////
-(void) ownSpriteMusicButtonInit{
    //initialize your member variabled here
    _wasTouched = NO;
    _repeat = 20;
    _scaleFactor = 90;
}
//------------------------------------------------------------------------------
-(id) init{
    self = [super init];
    if (self != nil){
        [self ownSpriteMusicButtonInit];
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
        [self ownSpriteMusicButtonInit];
    }
    return self;
}
//------------------------------------------------------------------------------
-(id)initBatchSpriteWithDictionary:(NSDictionary*)dictionary batch:(LHBatch*)batch{
    self = [super initBatchSpriteWithDictionary:dictionary batch:batch];
    if (self != nil){
        [self ownSpriteMusicButtonInit];
    }
    return self;
}
//------------------------------------------------------------------------------
+(bool) isBalloonMusicButton:(id)object{
    if(nil == object)
        return false;
    return [object isKindOfClass:[QQSpriteMusicButton class]];
}

-(void)reactToTouchWithLoader:(LevelHelperLoader *)loader andWithLayer:(CCLayer*)layer{
    if(_wasTouched) {
        CCParticleSystemQuad* particle = [[CCParticleSystemQuad alloc] initWithFile:@"particleExplodingBalloon.plist"];
        [particle setPosition:CGPointMake([self position].x, [self position].y)];
        [layer addChild:particle];
        [particle release];
        
        LHSprite* balloonMusic = [loader spriteWithUniqueName:@"musicButton"];
        LHSprite* balloonMusicOn = [LHSprite spriteWithName:@"balloonMusicOn"
                                                  fromSheet:@"assets"
                                                     SHFile:@"objects"];
        
        [balloonMusicOn setPosition:[balloonMusic position]];
        
        
        for(int i = 0; i <= _repeat; i++) {
            [self transformScale:[self scale] * _scaleFactor / 100];
        }
        [[SimpleAudioEngine sharedEngine] playEffect:@"balloon.wav"];
    }
}

-(void)showBalloonMusicButtonWithLayer:(CCLayer*)layer {
    for(int i = 0; i <= _repeat; i++) {
        [self transformScale:[self scale] * _scaleFactor / 100];
    }
    [self startInflateBalloon];
}

-(void)startInflateBalloon {
    [self schedule:@selector(tick:) interval:0.05f repeat:_repeat delay:0];
}

-(void)tick:(ccTime)dt {
    [self transformScale:[self scale] * 100 / _scaleFactor];
}

@end
