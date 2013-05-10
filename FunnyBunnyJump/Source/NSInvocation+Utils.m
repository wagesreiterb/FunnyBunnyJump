//
//  NSInvocation+Utils.m
//  FunnyBunnyJump
//
//  Created by Que on 29.01.13.
//
//

#import "NSInvocation+Utils.h"

@implementation NSInvocation (Utils)

-(void)invokeOnMainThreadWaitUntilDone:(BOOL)wait
{
    [self performSelectorOnMainThread:@selector(invoke)
                           withObject:nil
                        waitUntilDone:wait];
}

@end
