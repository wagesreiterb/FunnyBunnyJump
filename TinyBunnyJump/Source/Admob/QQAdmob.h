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
#import "Constants.h"

@class QQAdmob;

@protocol QQAdmobDelegate
-(void)admobAdReceived:(QQAdmob *)sender;
@end


@interface QQAdmob : CCLayer <GADBannerViewDelegate> {
    GADBannerView *mBannerView;
    
}

@property (nonatomic, weak) id <QQAdmobDelegate> delegate;

-(CGFloat)bannerHeight;
-(void)showBannerView;
-(void)hideBannerView;
-(void)dismissAdView;
@end

