//
//  QQSpriteBalloonThreetimestoucher.h
//  FunnyBunnyJump
//
//  Created by Que on 04.11.12.
//
//

#import "QQSpriteBalloon.h"
#import "SimpleAudioEngine.h"

@interface QQSpriteBalloonThreetimestoucher : QQSpriteBalloon {
    int _touchCount;
    float _scaleFactor;
    int _repeat;
    BOOL reactToCollision;
}

@property BOOL reactToCollision;

@end
