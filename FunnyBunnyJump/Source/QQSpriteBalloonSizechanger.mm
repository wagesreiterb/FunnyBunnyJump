//
//  QQSpriteBalloonSizechanger.m
//  FunnyBunnyJump
//
//  Created by Que on 04.11.12.
//
//

#import "QQSpriteBalloonSizechanger.h"

@implementation QQSpriteBalloonSizechanger

-(void)start:(float)interval {
    //interval good choice is 0.05f
    [self schedule: @selector(tick:) interval:interval];
    _changeToBigger = YES;
    _count = 0;
}

-(void)tick:(ccTime)dt {
    int maxCount = 60;
    float scaleFactor = 101;
    
    if(_count >= 0 && _count < maxCount/2) {
        [self transformScale:[self scale] * scaleFactor / 100];
    } else if (_count >= maxCount/2 && _count < maxCount) {
        [self transformScale:[self scale] * 100 / scaleFactor];
    }
    _count++;
    if(_count == maxCount) _count = 0;
}

/*
-(void)tick:(ccTime)dt {
    int maxCount = 60;
    float scalefFactor = 101;
    
    if(_count >= 0 && _count < maxCount/2) {
        [self setScale:[self scale] * scalefFactor / 100];
    } else if (_count >= maxCount/2 && _count < maxCount) {
        [self setScale:[self scale] * 100 / scalefFactor];
    }
    _count++;
    if(_count == maxCount) _count = 0;
}
 */

@end
