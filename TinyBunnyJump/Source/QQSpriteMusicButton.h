//
//  QQSpriteMusicButton.h
//  FunnyBunnyJump
//
//  Created by Que on 27.11.12.
//
//

#import "LHSprite.h"
#import "CCParticleSystemQuad.h"
#import "SimpleAudioEngine.h"
#import "LevelHelperLoader.h"

@interface QQSpriteMusicButton : LHSprite {
    int _repeat;
    int _scaleFactor;
}

@property BOOL wasTouched;

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

-(void)reactToTouchWithLoader:(LevelHelperLoader*)loader;
-(void)showBalloonMusicButtonWithLayer:(CCLayer*)layer;


@end
