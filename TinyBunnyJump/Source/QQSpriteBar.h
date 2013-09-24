//
//  QQSpriteBar.h
//  Acrobat_g7003
//
//  Created by Que on 11.09.12.
//
//

#import "LHSprite.h"

@interface QQSpriteBar : LHSprite {

    BOOL blink;
    ccTime _dt;
    int _blinkDelay;
    BOOL _active;
}

@property BOOL blink;

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
+(bool) isBarSprite:(id)object;

//------------------------------------------------------------------------------
//create your own custom methods here
-(void)updateBar:(ccTime)dt;
-(void)setToSensor:(BOOL)active;

@end
