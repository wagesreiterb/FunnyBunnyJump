//
//  IAPProduct.m
//  TinyBunnyJump
//
//  Created by Que on 01.09.13.
//
//

#import "IAPProduct.h"
@implementation IAPProduct

- (id)initWithProductIdentifier:(NSString *)productIdentifier {
    if ((self = [super init])) {
        self.availableForPurchase = NO;
        self.productIdentifier = productIdentifier;
        self.skProduct = nil;
    }
    return self;
}
- (BOOL)allowedToPurchase {
    if (!self.availableForPurchase) return NO;
    return YES;
}
@end
