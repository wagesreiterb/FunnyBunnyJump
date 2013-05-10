//
//  NSNotificationCenter+Utils.h
//  FunnyBunnyJump
//
//  Created by Que on 29.01.13.
//
//

#import <Foundation/Foundation.h>
#import "NSInvocation+Utils.h"

@interface NSNotificationCenter (Utils)

-(void)postNotificationOnMainThread:(NSNotification *)notification;
-(void)postNotificationNameOnMainThread:(NSString *)aName object:(id)anObject;
-(void)postNotificationNameOnMainThread:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

@end
