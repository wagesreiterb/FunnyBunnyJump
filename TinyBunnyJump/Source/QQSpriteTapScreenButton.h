//
//  QQSpriteTapScreenButton.h
//  FunnyBunnyJump
//
//  Created by Que on 25.11.12.
//
//

#import "LHSprite.h"

@interface QQSpriteTapScreenButton : LHSprite {
    BOOL _changeToBigger;
    int _count;
}

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
+(bool) isTapScreenButtonSprite:(id)object;

-(void)startWithInterval:(float)interval;
-(void)tick:(ccTime)dt;

@end
