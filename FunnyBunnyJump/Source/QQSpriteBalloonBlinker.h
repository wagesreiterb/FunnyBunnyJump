//
//  QQSpriteBalloonBlinker.h
//  FunnyBunnyJump
//
//  Created by Que on 27.11.12.
//
//

#import "QQSpriteBalloon.h"

@interface QQSpriteBalloonBlinker : QQSpriteBalloon {
    BOOL _visible;
    int _counter;
    int _modulo;
}

-(void)startBlinkingWithDelay:(ccTime)delay andWithInterval:(ccTime)interval;
-(void)startBlinkingWithDelay:(ccTime)delay andWithInterval:(ccTime)interval andWithModulo:(int)counter;
-(NSInteger)reactToTouch:(b2World*)world
               withLayer:(CCLayer*)layer
               withScore:(NSInteger)score_
           withCountdown:(float)countdown_;
@end
