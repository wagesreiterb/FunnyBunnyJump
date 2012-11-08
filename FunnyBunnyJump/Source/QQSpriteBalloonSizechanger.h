//
//  QQSpriteBalloonSizechanger.h
//  FunnyBunnyJump
//
//  Created by Que on 04.11.12.
//
//

#import "QQSpriteBalloon.h"

@interface QQSpriteBalloonSizechanger : QQSpriteBalloon {
    BOOL _changeToBigger;
    int _count;
}

-(void)start:(float)interval;
-(void)tick:(ccTime)dt;

@end
