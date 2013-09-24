//
//  QQSpriteStar.h
//  Acrobat_g7003
//
//  Created by Que on 12.09.12.
//
//

#import "LHSprite.h"
#import "SimpleAudioEngine.h"

@interface QQSpriteStar : LHSprite {
    BOOL wasTouched;
    CCParticleSystemQuad *_particle;
    CGPoint starDestination;
}
//add your own properties here
@property BOOL wasTouched;
@property CGPoint starDestination;

//------------------------------------------------------------------------------
//the following are required in order for the custom sprite to work properly
+(id)batchSpriteWithDictionary:(NSDictionary*)dictionary batch:(LHBatch*)batch;//render by batch node
+(id)spriteWithDictionary:(NSDictionary*)dictionary;//self render

-(id)initWithDictionary:(NSDictionary*)dictionary;
-(id)initBatchSpriteWithDictionary:(NSDictionary*)dictionary batch:(LHBatch*)batch;

//called by LevelHelper after the sprite has been created - all info from LevelHelper will be available at this stage
-(void)postInit;

//------------------------------------------------------------------------------
//the following method will test if a sprite object is really of PlayerSprite type
+(bool) isStarSprite:(id)object;

//------------------------------------------------------------------------------
//create your own custom methods here
-(QQSpriteStar*)reactToTouch:(QQSpriteStar*)star withWorld:(b2World*)world withLayer:(CCLayer*)layer;
@end
