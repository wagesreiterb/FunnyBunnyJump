//
//  QQAdmob.m
//  FunnyBunnyJump
//
//  Created by Que on 03.05.13.
//
//

#import "QQAdmob.h"

#ifndef ANDROID

@implementation QQAdmob
-(void)onEnter
{
    [super onEnter];
    [self createAdmobAds];
}

-(void)createAdmobAds
{
    AppController *app =  (AppController*)[[UIApplication sharedApplication] delegate];
    // Create a view of the standard size at the bottom of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    
    //TODO: alloc, aber wo ist das dealloc?!?
    mBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
    
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    //mBannerView.adUnitID = MY_BANNER_UNIT_ID;
    mBannerView.adUnitID = @"a15183975d47575";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    
    mBannerView.rootViewController = app.navController;
    [app.navController.view addSubview:mBannerView];
    
    // Initiate a generic request to load it with an ad.
    //[mBannerView loadRequest:[GADRequest request]];
    
    GADRequest *request = [GADRequest request];
    request.testDevices = [NSArray arrayWithObjects:@"472355166b3b7f28298b0377739ca67a", nil];
    [mBannerView loadRequest:request];
    
    CGSize s = [[CCDirector sharedDirector] winSize];
    
    CGRect frame = mBannerView.frame;
    
    frame.origin.y = s.height;
    
    frame.origin.x = (s.width/2.0f - frame.size.width/2.0f);
    
    mBannerView.frame = frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    frame = mBannerView.frame;

    if(bannerPosition == kTop) {
        frame.origin.y = 0;
    } else {
        frame.origin.y = s.height - frame.size.height;
    }
    frame.origin.x = (s.width/2.0f - frame.size.width/2.0f);
    
    mBannerView.frame = frame;
    [UIView commitAnimations];

    [mBannerView setDelegate:self];
}

-(CGFloat)bannerHeight {
    return mBannerView.frame.size.height;
}

- (void)adViewDidReceiveAd:(GADBannerView *)view {
    [self.delegate admobAdReceived:self];
}

- (void)adView:(GADBannerView *)view
        didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"x-x-x-x-x-x QQAdmob::didFailToReceiveAdWithError");    
}

-(void)showBannerView
{
    if (mBannerView)
    {
        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationCurveEaseOut
                         animations:^
         {
             CGSize s = [[CCDirector sharedDirector] winSize];
             
             CGRect frame = mBannerView.frame;
             frame.origin.y = s.height - frame.size.height;
             frame.origin.x = (s.width/2.0f - frame.size.width/2.0f);
             
             mBannerView.frame = frame;
         }
                         completion:^(BOOL finished)
         {
         }];
    }
    
}


-(void)hideBannerView
{
    if (mBannerView)
    {
        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationCurveEaseOut
                         animations:^
         {
             CGSize s = [[CCDirector sharedDirector] winSize];
             
             CGRect frame = mBannerView.frame;
             if(bannerPosition == kTop) {
                 frame.origin.y = frame.origin.y -  frame.size.height;
             } else {
                 frame.origin.y = frame.origin.y +  frame.size.height;
             }
             frame.origin.x = (s.width/2.0f - frame.size.width/2.0f);
         }
             completion:^(BOOL finished)
         {
         }];
    }
}


-(void)dismissAdView
{
    if (mBannerView)
    {
        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationCurveEaseOut
                         animations:^
         {
             CGSize s = [[CCDirector sharedDirector] winSize];
             
             CGRect frame = mBannerView.frame;
             if(bannerPosition == kTop) {
                 frame.origin.y = frame.origin.y - frame.size.height;
             } else {
                 frame.origin.y = frame.origin.y + frame.size.height;
             }
             frame.origin.x = (s.width/2.0f - frame.size.width/2.0f);
             mBannerView.frame = frame;
         }
                         completion:^(BOOL finished)
         {
             [mBannerView setDelegate:nil];
             [mBannerView removeFromSuperview];
             mBannerView = nil;
             
         }];
    }
}

@end

#endif
