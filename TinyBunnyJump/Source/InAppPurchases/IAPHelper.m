//
//  IAPHelper.m
//  TinyBunnyJump
//
//  Created by Que on 01.09.13.
//
//

#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "IAPProduct.h"

@interface IAPHelper () <SKProductsRequestDelegate>
@end

@implementation IAPHelper {
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
}
- (id)initWithProducts:(NSMutableDictionary *)products {
    if ((self = [super init])) {
        _products = products;
    }
    return self;
}

- (void)requestProductsWithCompletionHandler: (RequestProductsCompletionHandler)completionHandler {
    _completionHandler = [completionHandler copy];
    
    NSMutableSet * productIdentifiers = [NSMutableSet setWithCapacity:_products.count];
    for (IAPProduct * product in _products.allValues) {
        product.availableForPurchase = NO;
        [productIdentifiers addObject:product.productIdentifier];
    }
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        
        NSLog(@"Found product: %@ %@ %0.2f", skProduct.productIdentifier, skProduct.localizedTitle, skProduct.price.floatValue);
        
        IAPProduct * product = _products[skProduct.productIdentifier];
        product.skProduct = skProduct;
        product.availableForPurchase = YES;
        //NSLog(@"the product: %@", [_products[skProduct.productIdentifier]);
    }
    for (NSString * invalidProductIdentifier in response.invalidProductIdentifiers) {
        IAPProduct * product = _products[invalidProductIdentifier];
        product.availableForPurchase = NO;
        NSLog(@"Invalid product identifier, removing: %@", invalidProductIdentifier);

    }
    NSMutableArray * availableProducts = [NSMutableArray array]; for (IAPProduct * product in _products.allValues) {
        if (product.availableForPurchase) { [availableProducts addObject:product];
        } }
    _completionHandler(YES, availableProducts); _completionHandler = nil;
}
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    _completionHandler(FALSE, nil);
    _completionHandler = nil;
}

@end