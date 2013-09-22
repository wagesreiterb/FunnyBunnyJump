//
//  IAPHelper.h
//  TinyBunnyJump
//
//  Created by Que on 01.09.13.
//
//

#import <Foundation/Foundation.h>

typedef void (^RequestProductsCompletionHandler) (BOOL success, NSArray * products);

@interface IAPHelper : NSObject

@property (nonatomic, strong) NSMutableDictionary * products;

- (id)initWithProducts:(NSMutableDictionary *)products;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

@end
