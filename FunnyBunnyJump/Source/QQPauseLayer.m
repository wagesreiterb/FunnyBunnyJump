//
//  QQPauseLayer.m
//  FunnyBunnyJump
//
//  Created by Que on 16.11.12.
//
//

#import "QQPauseLayer.h"

@implementation QQPauseLayer

-(void)pauseLevel:(CCLayer*)mainLayer {
    _loaderPause = [[LevelHelperLoader alloc] initWithContentOfFile:@"pauseLayer"];
    [_loaderPause addSpritesToLayer:self];
}

-(void)dealloc {
    [_loaderPause release];
    _loaderPause = nil;
    super dealloc;
}
@end
