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
}

-(void)startBlinkingWithDelay:(ccTime)delay andWithInterval:(ccTime)interval;

@end
