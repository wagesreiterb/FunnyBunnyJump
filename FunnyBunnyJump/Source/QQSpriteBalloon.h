//
//  QQSpriteBalloon.h
//  Acrobat_g7003
//
//  Created by Que on 29.08.12.
//
//

#import "LHSprite.h"
#import "LHCuttingEngineMgr.h"

@interface QQSpriteBalloon : LHSprite {
    BOOL wasTouched;
    enum whatToDo {REMOVE, EXPLODE, FADEOUT};
    enum whatToDo currentToDo;
    CCParticleSystem *_particle;
}

@property BOOL wasTouched;
@property enum whatToDo currentToDo;

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
+(bool) isBalloonSprite:(id)object;

//------------------------------------------------------------------------------
//create your own custom methods here
//-(QQSpriteBalloon*)reactToTouch:(QQSpriteBalloon*)balloon withWorld:(b2World*)world withLayer:(CCLayer*)layer;
-(void)reactToTouch:(b2World*)world withLayer:(CCLayer*)layer;
@end
