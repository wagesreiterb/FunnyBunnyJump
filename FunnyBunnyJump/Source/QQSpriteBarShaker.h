//
//  QQSpriteBarShaker.h
//  FunnyBunnyJump
//
//  Created by Que on 27.11.12.
//
//

#import "LHSprite.h"

@interface QQSpriteBarShaker : LHSprite {
    BOOL _moveLeft;
}

-(void)startMovingWithDelay:(int)delay;
-(void)setToSensor:(BOOL)active;

@end
