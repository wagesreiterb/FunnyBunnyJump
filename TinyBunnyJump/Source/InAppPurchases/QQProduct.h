//
//  QQProduct.h
//  TinyBunnyJump
//
//  Created by Que on 15.09.13.
//
//

#import <Foundation/Foundation.h>
#import "CCLabelTTF.h"
#import "LHSprite.h"
#import "LHLayer.h"
#import "LevelHelperLoader.h"
#import <StoreKit/StoreKit.h>
#import "QQInAppPurchaseLayer.h"

//@class QQProduct;
//
//@protocol QQProductDelegate   //define delegate protocol
//-(void)touchBeganProductButton:(QQProduct *)sender;  //define delegate method to be implemented within another class
//@end //end protocol

@interface QQProduct : NSObject {
}

@property (nonatomic, strong) NSString * productIdentifier;
@property (nonatomic, strong) LHSprite * spriteProductButtonColor;
@property (nonatomic, strong) LHSprite * spriteProductButtonGray;

@property (nonatomic, strong) NSLocale * priceLocale;
@property (nonatomic, strong) NSDecimalNumber * price;
@property (nonatomic, strong) CCLabelTTF * labelPrice;

@property (nonatomic, assign) BOOL availableForPurchase;
//@property (nonatomic, weak) id <QQProductDelegate> delegate; //define MyClassDelegate as delegate



-(id)initWithProductIdentifier:(NSString *)productIdentifier;
//-(void)activateProductButton:(SKProduct *)myProductFromStore;
//-(void)registerTouchObserver:(id)observer;

@end
