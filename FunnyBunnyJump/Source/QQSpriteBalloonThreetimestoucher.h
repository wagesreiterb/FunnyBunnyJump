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
    BOOL _balloonCompletelyInflated;
}

@property BOOL reactToCollision;
@property BOOL _balloonCompletelyInflated;

-(void)reactToTouchWithWorld:(b2World*)world withLayer:(CCLayer*)layer;

@end
