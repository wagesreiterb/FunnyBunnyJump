//
//  Facebook.h
//  FunnyBunnyJump
//
//  Created by Que on 05.05.13.
//
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "cocos2d.h"

@interface Facebook : NSObject {

    
}

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount *facebookAccount;
//@property (strong, nonatomic) ACAccount *twitterAccount;

- (void)getFacebookAccount;
-(CCSprite*)showFBPicture;
//- (void)getTwitterAccount;

@end

