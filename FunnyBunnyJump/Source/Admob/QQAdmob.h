//
//  QQAdmob.h
//  FunnyBunnyJump
//
//  Created by Que on 03.05.13.
//
//

#import "CCLayer.h"
#import "GADBannerView.h"
#import "AppDelegate.h"

@interface QQAdmob : CCLayer {
    GADBannerView *mBannerView;
    
}
-(void)showBannerView;
-(void)hideBannerView;
-(void)dismissAdView;
@end

