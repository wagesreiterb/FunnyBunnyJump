//
//  QQSpriteBalloonShake.h
//  FunnyBunnyJump
//
//  Created by Que on 26.10.12.
//
//

#import "QQSpriteBalloon.h"

@interface QQSpriteBalloonShake : QQSpriteBalloon {

    BOOL _moveLeft;
}

-(void)startMoving;
-(void)tick:(ccTime)dt;

@end
