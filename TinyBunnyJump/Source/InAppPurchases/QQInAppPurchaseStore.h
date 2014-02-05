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


@class QQInAppPurchaseStore;

@protocol QQInAppPurchaseStoreDelegate   //define delegate protocol
//-(void)productsRequest:(QQInAppPurchaseStore*)response;  //define delegate method to be implemented within another class
-(void)productsRequest;
-(void)showPleaseWait;
-(void)showConfirmAlert:(NSString *)title withMessage:(NSString *)message;
-(void)removePleaseWait;
@end //end protocol

@interface QQInAppPurchaseStore : NSObject {
    BOOL _purchaseInProgress;
    NSNumberFormatter* _priceFormatter;
}

@property (nonatomic, strong) NSString * chosenProductIdentifier;
@property (nonatomic) NSArray *myProducts;
@property (nonatomic) NSMutableArray *myQQProducts;
@property (nonatomic) NSArray *arrayOfProductIdentifiers;
@property (nonatomic, weak) id <QQInAppPurchaseStoreDelegate> delegate; //define MyClassDelegate as delegate

+(id)sharedInstance;
-(void)openIAPStore;


@end
