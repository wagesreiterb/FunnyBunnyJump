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

@class QQProduct;

@protocol QQProductDelegate   //define delegate protocol
-(void)touchBeganProductButton:(QQProduct *)sender;  //define delegate method to be implemented within another class
@end //end protocol

@interface QQProduct : NSObject {
//    CCLabelTTF *_labelProductPrice;
//    LHSprite* _spriteProductButtonGrayscale;
//    LHSprite* _spriteProductButtonColor;
    LevelHelperLoader *_loader;
    LHLayer *_layer;
}

@property (nonatomic, strong) NSString * productIdentifier;
@property (nonatomic, strong) LHSprite * spriteProductButtonColor;
@property (nonatomic, strong) LHSprite * spriteProductButtonGrayscale;
@property (nonatomic, strong) CCLabelTTF * labelProductPrice;
@property (nonatomic, assign) BOOL availableForPurchase;
@property (nonatomic, weak) id <QQProductDelegate> delegate; //define MyClassDelegate as delegate



-(id)initWithProductIdentifier:(NSString *)productIdentifier
                     withLayer:(LHLayer *)layer
                    withLoader:(LevelHelperLoader *)loader;
-(void)activateProductButton:(SKProduct *)myProductFromStore;
-(void)registerTouchObserver:(id)observer;

@end
