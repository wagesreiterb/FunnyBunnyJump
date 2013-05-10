//
//  Facebook.m
//  FunnyBunnyJump
//
//  Created by Que on 05.05.13.
//
//

#import "Facebook.h"

@implementation Facebook

-(id)init {
    self = [super init];
    if(self != nil) {
        NSLog(@"Facebook::init");
        self.accountStore = [[ACAccountStore alloc] init];
        [self getFacebookAccount];
    }
    return self;
}

//TODO: correct error messages - something with funny bunny

- (void)getFacebookAccount
{
    // 1
    ACAccountType *facebookAccountType = [self.accountStore
                                          accountTypeWithAccountTypeIdentifier:
                                          ACAccountTypeIdentifierFacebook];
    
    // 2
    dispatch_async(dispatch_get_global_queue(
                                             DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 3
        NSDictionary *facebookOptions = @{
                                          ACFacebookAppIdKey : @"476517252421701",
                                          ACFacebookPermissionsKey : @[@"email", @"read_stream",
                                                                       @"user_relationships", @"user_website", @"publish_stream"],
                                          ACFacebookAudienceKey : ACFacebookAudienceEveryone };
        // 4
        [self.accountStore
         requestAccessToAccountsWithType:facebookAccountType
         options:facebookOptions completion:^(BOOL granted,
                                              NSError *error) {
             // 5
             if (granted)
             {
                 //[self getPublishStream];
                 NSLog(@"Facebook access granted");
             }
             // 6
             else
             {
                 // 7
                 if (error)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook"
                                                                             message:@"There was an error retrieving your Facebook account, make sure you have an account setup in Settings and that access is granted for iSocial"
                                                                            delegate:nil
                                                                   cancelButtonTitle:@"Dismiss"
                                                                   otherButtonTitles:nil];
                         [alertView show];
                     });
                 }
                 // 8
                 else
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook"
                                                                             message:@"Access to Facebook was not granted. Please go to the device settings and allow access for iSocial"
                                                                            delegate:nil
                                                                   cancelButtonTitle:@"Dismiss"
                                                                   otherButtonTitles:nil];
                         [alertView show];
                     });
                 }
             }
         }];
    });
    

    

}

-(CCSprite*)showFBPicture {
    //NSString *facebookId = @"100002611713534";
    NSString *facebookId = @"erika.todor.52";
    
    int width = 200;
    int height = 200;
    NSString *https = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%i&height=%i", facebookId, width, height];
    //NSString *https = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", facebookId];
    //https://graph.facebook.com/100002611713534/picture?width=150&height=150	

    NSURL *url = [NSURL URLWithString:https];
    NSAssert(url, @"URL is malformed: %@", https);
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    CCSpriteFrame *frame;
    if (data && !error) {
        // Download the image to the Cache directory of our App.
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[facebookId stringByAppendingString:@".jpg"]];
        [data writeToFile:path options:NSDataWritingAtomic error:&error];
        if (!error) {
            // It worked!
            // 1. Load the texture in from the Cache directory.
            CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:path];
            // 2. Create the sprite frame with appropriate dimensions.
            frame = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(0, 0, 100, 100)];

            // 3. Golden.
            NSLog(@"SUCCESS");
        } else {
            // Error, Could not save downloaded file!
            NSLog(@"ERROR 1");
        }
    } else {
        // Error, Could not download file!
        NSLog(@"ERROR 2");
    }
    

    
    
    return [CCSprite spriteWithSpriteFrame:frame];
}

//-(void)getListOfFriends {
//    NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
//    ACAccount *facebookAccount = [accounts lastObject];
//    NSString *acessToken = [NSString stringWithFormat:@"%@",facebookAccount.credential.oauthToken];
//    NSDictionary *parameters = @{@"access_token": acessToken};
//    NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/friends"];
//    SLRequest *feedRequest = [SLRequest
//                              requestForServiceType:SLServiceTypeFacebook
//                              requestMethod:SLRequestMethodGET
//                              URL:feedURL
//                              parameters:parameters];
//    feedRequest.account = facebookAccount;
//    [feedRequest performRequestWithHandler:^(NSData *responseData,
//                                             NSHTTPURLResponse *urlResponse, NSError *error)
//     {
//         NSLog(@"%@",[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
//     }];
//    } else
//    {
//        // Handle Failure
//    }
//}


//- (void)getPublishStream {
//
//    // 1
//    ACAccountType *facebookAccountType = [self.accountStore
//                                          accountTypeWithAccountTypeIdentifier:
//                                          ACAccountTypeIdentifierFacebook];
//    
//    // 2
//    dispatch_async(dispatch_get_global_queue(
//                                             DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        // 3
//        NSDictionary *facebookOptions = @{
//                                          ACFacebookAppIdKey : @"476517252421701",
//                                          ACFacebookPermissionsKey : @[@"publish_stream"],
//                                          ACFacebookAudienceKey : ACFacebookAudienceEveryone };
//        // 4
//        [self.accountStore
//         requestAccessToAccountsWithType:facebookAccountType
//         options:facebookOptions completion:^(BOOL granted,
//                                              NSError *error) {
//             // 5
//             if (granted)
//             {
//                 self.facebookAccount = [[self.accountStore
//                                          accountsWithAccountType:facebookAccountType]
//                                         lastObject];
//                 
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     [[NSNotificationCenter defaultCenter]
//                      postNotificationName:
//                      @"FacebookAccountAccessGranted"
//                      object:nil];
//                 });
//             }
//             // 6
//             else
//             {
//                 // 7
//                 if (error)
//                 {
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook"
//                                                                             message:@"There was an error retrieving your Facebook account, make sure you have an account setup in Settings and that access is granted for iSocial"
//                                                                            delegate:nil
//                                                                   cancelButtonTitle:@"Dismiss"
//                                                                   otherButtonTitles:nil];
//                         [alertView show];
//                     });
//                 }
//                 // 8
//                 else
//                 {
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook"
//                                                                             message:@"Access to Facebook was not granted. Please go to the device settings and allow access for iSocial"
//                                                                            delegate:nil
//                                                                   cancelButtonTitle:@"Dismiss"
//                                                                   otherButtonTitles:nil];
//                         [alertView show];
//                     });
//                 }
//             }
//         }];
//    });
//}


@end
