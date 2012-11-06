//
//  QQSpritePlayer.h
//  Acrobat_g7003
//
//  Created by Que on 25.08.12.
//
//

#import "LHSprite.h"

@interface QQSpritePlayer : LHSprite
{
    //int life;
    //int magic;
    BOOL jumping;
    enum state {jumping_up, jumping_down, on_seesaw};
    BOOL acceptForces;
    BOOL balloonTouched;
    
    CGPoint beamPosition;
    BOOL shallBeam;
    BOOL allowBeaming; //needed to avoid PingPong Effect between the two beaming Objects
    
    float32 force;
    BOOL isPaused;
    
    CGPoint location;
    CGPoint _locationY;
    int lifes;
    BOOL dead;  //player is dead but still has lifes
    BOOL totallyDead;   //player has no more lifes left
}
//add your own properties here
@property (getter=isDead) BOOL dead;
@property CGPoint location;
@property BOOL acceptForces;
@property BOOL balloonTouched;
@property BOOL startJumpFinished;
@property float32 force;
//@property int life;
//@property int magic;
@property BOOL jumping;
@property BOOL shallBeam;
@property BOOL allowBeaming;
@property int lifes;
//add your own properties here

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
-(void)whichDirection;
-(void)applyForce;
-(void)applyStartJump;
-(void)applyStartJumpAfterTick:(ccTime)dt;
-(void)beamPlayer:(LHSprite*)beamContact fromBeamObject:(LHSprite*)beam1 toBeamObject:(LHSprite*)beam2;
-(void)beam;
-(void)setPause:(BOOL)pause;
-(void)upOrDownAction:(LHSprite*)earLeft withEarRight:(LHSprite*)earRight
         withHandLeft:(LHSprite*)handLeft withHandRight:(LHSprite*)handRight;

@end
