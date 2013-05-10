//
//  NSInvocation+Utils.h
//  FunnyBunnyJump
//
//  Created by Que on 29.01.13.
//
//

#import <Foundation/Foundation.h>

@interface NSInvocation (Utils)

-(void)invokeOnMainThreadWaitUntilDone:(BOOL)wait;

@end
