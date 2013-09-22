//
//  IAPProduct.h
//  TinyBunnyJump
//
//  Created by Que on 01.09.13.
//
//

@class SKProduct;

@interface IAPProduct : NSObject

- (id)initWithProductIdentifier:(NSString *)productIdentifier;
- (BOOL)allowedToPurchase;

@property (nonatomic, assign) BOOL availableForPurchase;
@property (nonatomic, strong) NSString * productIdentifier;
@property (nonatomic, strong) SKProduct * skProduct;

@end
