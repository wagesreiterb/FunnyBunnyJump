//
//  QQSpriteTrampolin.h
//  Acrobat_g7003
//
//  Created by Que on 28.08.12.
//
//

#import "LHSprite.h"
#import "LHFixture.h"

@interface QQSpriteTrampoline : LHSprite {
    float restitution;
    float initialRestitution;
    BOOL changeRestitution;
    BOOL shallMove;
    float velocity;
    //enum direction {LEFT, RIGHT};
    //enum direction currentDirection;
    

    enum moveState {MS_LEFT, MS_STOP, MS_RIGHT};
    enum moveState currentMoveState;
}
@property float velocity;
@property BOOL shallMove;
@property moveState currentMoveState;
@property float restitution;
@property (setter=shallChangeRestitution:) BOOL changeRestitution;
//@property direction currentDirection;

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
+(bool) isPlayerSprite:(id)object;

//------------------------------------------------------------------------------
//create your own custom methods here
//-(void)setVelocity:(b2Vec2)velo;
//-(void)moveLeft:(ccTime)dt;
//-(void)moveRight:(ccTime)dt;
-(void)setInitialRestitution;
-(float)initialRestitution;
-(void)setRestitution:(float)resti;
-(void)move:(ccTime)dt;
-(void)setRestitutionAtTick;
@end
