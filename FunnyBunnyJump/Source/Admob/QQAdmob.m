//
//  QQAdmob.m
//  FunnyBunnyJump
//
//  Created by Que on 03.05.13.
//
//

#import "QQAdmob.h"

@implementation QQAdmob
-(void)onEnter
{
    [super onEnter];
    
    NSLog(@"QQAdmob");
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

    //frame.origin.y = s.height - frame.size.height;
    frame.origin.y = 0;
    frame.origin.x = (s.width/2.0f - frame.size.width/2.0f);
    
    mBannerView.frame = frame;
    [UIView commitAnimations];
    
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
    NSLog(@"1.....hideBannerView");
    if (mBannerView)
    {
        NSLog(@"2.....hideBannerView");

        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationCurveEaseOut
                         animations:^
         {
             CGSize s = [[CCDirector sharedDirector] winSize];
             
             CGRect frame = mBannerView.frame;
             frame.origin.y = frame.origin.y +  frame.size.height;
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
             frame.origin.y = frame.origin.y + frame.size.height ;
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
