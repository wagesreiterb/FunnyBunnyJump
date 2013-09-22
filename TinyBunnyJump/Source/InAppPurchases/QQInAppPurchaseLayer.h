//
//  QQInAppPurchaseLayer.h
//  TinyBunnyJump
//
//  Created by Que on 04.09.13.
//
//

#import "CCLayer.h"
#import "LevelHelperLoader.h"
#import "NSNotificationCenter+Utils.h"
#import "TBJIAPHelper.h"
#import "IAPProduct.h"
#import <StoreKit/StoreKit.h>
#import "QQProduct.h"

@class QQLevel;

@interface QQInAppPurchaseLayer : LHLayer {
    LevelHelperLoader *_loaderIAP;
    QQLevel *_mainLayer;
    
    LHSprite* _spriteBackButton;
    LHSprite* _spritePleaseWait;
    LHSprite* _pleaseWaitBackground;
    
    int _rotation;
    BOOL _pleaseWaitActive;
    BOOL _purchaseInProgress;
    
    //LHSprite* _thirtyTrampolinesButton;
    //LHSprite* _eightyTrampolinesButton;
    
    NSNumberFormatter* _priceFormatter;
    NSArray *myProducts;
    
    //CCLabelTTF *_labelBuyTrampoline;
    //CCLabelTTF *_labelBuy80Trampoline;
    
    NSMutableArray *_myQQProducts;
}

@property (nonatomic, strong) NSString * chosenProductIdentifier;

+(id)sharedInstance;
-(void)openIAPStore:(QQLevel*)mainLayer;

@end
