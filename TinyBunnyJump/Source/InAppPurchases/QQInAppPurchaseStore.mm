//
//  QQInAppPurchaseLayer.m
//  TinyBunnyJump
//
//  Created by Que on 04.09.13.
//
//

#import "QQInAppPurchaseStore.h"
#import "GameManager.h"

#define PRODUCT_THIRTY_TRAMPOLINES @"com.querika.tinybunnyjump.thirtytrampolines"
#define PRODUCT_EIGHTY_TRAMPOLINES @"com.querika.tinybunnyjump.eightytrampolines"
#define PRODUCT_HUNDREDSEVENTY_TRAMPOLINES @"com.querika.tinybunnyjump.hundredseventytrampolines"
#define PRODUCT_FOURHUNDRED_TRAMPOLINES @"com.querika.tinybunnyjump.fourhundredtrampolines2"

#define PRODUCT_THIRTY_LIFES @"com.querika.tinybunnyjump.thirtylifes"
#define PRODUCT_EIGHTY_LIFES @"com.querika.tinybunnyjump.eightylifes"
#define PRODUCT_HUNDREDSEVENTY_LIFES @"com.querika.tinybunnyjump.hundredseventylifes"
#define PRODUCT_FOURHUNDRED_LIFES @"com.querika.tinybunnyjump.fourhundredlifes"

#define PRODUCT_THIRTY_SUPERJUMPS @"com.querika.tinybunnyjump.thirtysuperjumps"
#define PRODUCT_EIGHTY_SUPERJUMPS @"com.querika.tinybunnyjump.eightysuperjumps"
#define PRODUCT_HUNDREDSEVENTY_SUPERJUMPS @"com.querika.tinybunnyjump.hundredseventysuperjumps"
#define PRODUCT_FOURHUNDRED_SUPERJUMPS @"com.querika.tinybunnyjump.fourhundredsuperjumps"

#define PRODUCT_THIRTY_ALL @"com.querika.tinybunnyjump.thirtyall"
#define PRODUCT_EIGHTY_ALL @"com.querika.tinybunnyjump.eightyall"
#define PRODUCT_HUNDREDSEVENTY_ALL @"com.querika.tinybunnyjump.hundredseventyall"
#define PRODUCT_FOURHUNDRED_ALL @"com.querika.tinybunnyjump.fourhundredall"

@interface QQInAppPurchaseStore () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

@implementation QQInAppPurchaseStore {

    NSArray *_products;
}

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    
    NSLog(@"... sharedInstance inAppPurchase");
    return _sharedObject;
}

-(id)init
{
    NSLog(@"... init");
	if( (self=[super init])) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        _priceFormatter = [[NSNumberFormatter alloc] init];
        [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        _myQQProducts = [[NSMutableArray alloc] init];

	}
	return self;
}

-(void)openIAPStore {
    NSLog(@"... openInAppPurchase Store");
    
    [self setupProducts];
    
    if([SKPaymentQueue canMakePayments]) {
        // Display a store to the user
        [self inAppPurchaseActivated];
    }
//    else {
//        // Warn the user that purchases are disabled
//        [self inAppPurchaseDeactivated];
//    }
}

-(void)setupProducts {
    _arrayOfProductIdentifiers = [NSArray arrayWithObjects:
                                  PRODUCT_THIRTY_TRAMPOLINES,
                                  PRODUCT_EIGHTY_TRAMPOLINES,
                                  PRODUCT_HUNDREDSEVENTY_TRAMPOLINES,
                                  PRODUCT_FOURHUNDRED_TRAMPOLINES,
                                  PRODUCT_THIRTY_LIFES,
                                  PRODUCT_EIGHTY_LIFES,
                                  PRODUCT_HUNDREDSEVENTY_LIFES,
                                  PRODUCT_FOURHUNDRED_LIFES,
                                  PRODUCT_THIRTY_SUPERJUMPS,
                                  PRODUCT_EIGHTY_SUPERJUMPS,
                                  PRODUCT_HUNDREDSEVENTY_SUPERJUMPS,
                                  PRODUCT_FOURHUNDRED_SUPERJUMPS,
                                  PRODUCT_THIRTY_ALL,
                                  PRODUCT_EIGHTY_ALL,
                                  PRODUCT_HUNDREDSEVENTY_ALL,
                                  PRODUCT_FOURHUNDRED_ALL,
                                  nil];
    
    for(NSString *productIdentifier in _arrayOfProductIdentifiers) {
        QQProduct* product;
        product = [[QQProduct alloc] initWithProductIdentifier:productIdentifier];
        //product.delegate = self;
        
        [_myQQProducts addObject:product];
    }
}

-(void)inAppPurchaseActivated {
    NSLog(@"... display a store to the user");
    [self.delegate showPleaseWait];
    [self requestProductData];
}

//-(void)inAppPurchaseDeactivated {
//    //Settings -> General -> Restrictions
//    NSLog(@"... warn the user that purchases are disabled");
//    [self.delegate inAppPurchaseDeactivated];
//}

//add new products here
-(void)requestProductData {
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:
                                 [NSSet setWithObjects:
                                  PRODUCT_THIRTY_TRAMPOLINES,
                                  PRODUCT_EIGHTY_TRAMPOLINES,
                                  PRODUCT_HUNDREDSEVENTY_TRAMPOLINES,
                                  PRODUCT_FOURHUNDRED_TRAMPOLINES,
                                  PRODUCT_THIRTY_LIFES,
                                  PRODUCT_EIGHTY_LIFES,
                                  PRODUCT_HUNDREDSEVENTY_LIFES,
                                  PRODUCT_FOURHUNDRED_LIFES,
                                  PRODUCT_THIRTY_SUPERJUMPS,
                                  PRODUCT_EIGHTY_SUPERJUMPS,
                                  PRODUCT_HUNDREDSEVENTY_SUPERJUMPS,
                                  PRODUCT_FOURHUNDRED_SUPERJUMPS,
                                  PRODUCT_THIRTY_ALL,
                                  PRODUCT_EIGHTY_ALL,
                                  PRODUCT_HUNDREDSEVENTY_ALL,
                                  PRODUCT_FOURHUNDRED_ALL,
                                  nil]];
    
    request.delegate = self;
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"... QQInAppPurchase::productsRequest");
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    _myProducts = response.products;
    
    NSLog(@"... number of elements: %d", [_myProducts count]);
    for(SKProduct *myProductFromStore in _myProducts) {
        NSLog(@"... product: %@", [myProductFromStore productIdentifier]);
        
        for(QQProduct* myQQProduct in _myQQProducts) {
            NSLog(@"myQQProduct: %@", [myQQProduct productIdentifier]);
            NSLog(@"myProduct: %@", [myProductFromStore productIdentifier]);
            if([[myQQProduct productIdentifier] isEqualToString:[myProductFromStore productIdentifier]]) {
                [myQQProduct setAvailableForPurchase:YES];
                [myQQProduct setPrice: myProductFromStore.price];
                [myQQProduct setPriceLocale: myProductFromStore.priceLocale];
            }
        }
    }
    
    for(NSString *invalidProductIdentifier in response.invalidProductIdentifiers) {
        NSLog(@"... invalide Products: %@", invalidProductIdentifier);
    }
    
    //[self.delegate productsRequest:self]; //this will call the method implemented in your other class
    [self.delegate productsRequest]; //this will call the method implemented in your other class

    
    // Populate your UI from the products list.
    
    // Save a reference to the products list.
    
}

- (void)touchBeganProductButton:(QQProduct *)sender {
    if(_purchaseInProgress == NO) {
        _purchaseInProgress = YES;
        [self makePayment:[sender productIdentifier]];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Failed to load list of products.");
    [self.delegate removePleaseWait];
    [self.delegate showConfirmAlert:@"Error" withMessage:@"Failed to load list of products!"];
}

-(void)makePayment:(NSString*)productIdentifier {
    NSLog(@"... makePayment");
    for(SKProduct *myProduct in _myProducts) {
        if([productIdentifier isEqualToString:[myProduct productIdentifier]]) {
            SKPayment *payment = [SKPayment paymentWithProduct:myProduct];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    NSLog(@"... paymentQueue");
    for (SKPaymentTransaction *transaction in transactions)     
    {
        NSLog(@"... transaction.payment.productIdentifier: %@", transaction.payment.productIdentifier);
        switch (transaction.transactionState)
        {     
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                NSLog(@"... SKPaymentTransactionStatePurchased");
                break;       
            case SKPaymentTransactionStateFailed:    
                [self failedTransaction:transaction];
                NSLog(@"... SKPaymentTransactionStateFailed");
                break;   
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                NSLog(@"... SKPaymentTransactionStateRestored");
            default:    
                break;   
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    // Your application should implement these two methods.
    NSLog(@"... completeTransaction");
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    _purchaseInProgress = NO;
    [self.delegate removePleaseWait];
    [self.delegate showConfirmAlert:@"Success" withMessage:@"Payment finished!\nThank You!"];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"... restored Transaction");
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    _purchaseInProgress = NO;
    [self.delegate removePleaseWait];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"... failedTransaction");
    if (transaction.error.code != SKErrorPaymentCancelled) {
        // Optionally, display an error here.
    }   
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    _purchaseInProgress = NO;
    [self.delegate removePleaseWait];
    [self.delegate showConfirmAlert:@"Error" withMessage:@"Payment cancled!"];
}

-(void)recordTransaction:(SKPaymentTransaction*)transaction {
    
}

-(void)provideContent:(NSString*)productIdentifier {
    NSLog(@"... provideContent");
    [[GameState sharedInstance] setPayingUser:YES];
    
    if([PRODUCT_THIRTY_TRAMPOLINES isEqualToString:productIdentifier]) {
        [[GameState sharedInstance] setRedTrampolinesLeft:[[GameState sharedInstance] redTrampolinesLeft] + 30];
    } else if([PRODUCT_EIGHTY_TRAMPOLINES isEqualToString:productIdentifier]) {
        [[GameState sharedInstance] setRedTrampolinesLeft:[[GameState sharedInstance] redTrampolinesLeft] + 80];
    } else if([PRODUCT_HUNDREDSEVENTY_TRAMPOLINES isEqualToString:productIdentifier]) {
        [[GameState sharedInstance] setRedTrampolinesLeft:[[GameState sharedInstance] redTrampolinesLeft] + 170];
    } else if([PRODUCT_FOURHUNDRED_TRAMPOLINES isEqualToString:productIdentifier]) {
        [[GameState sharedInstance] setRedTrampolinesLeft:[[GameState sharedInstance] redTrampolinesLeft] + 400];
    }
    
    else if([PRODUCT_THIRTY_LIFES isEqualToString:productIdentifier]) {
        [[GameState sharedInstance] setLifesLeft:[[GameState sharedInstance] lifesLeft] + 30];
    } else if([PRODUCT_EIGHTY_LIFES isEqualToString:productIdentifier]) {
        [[GameState sharedInstance] setLifesLeft:[[GameState sharedInstance] lifesLeft] + 80];
    } else if([PRODUCT_HUNDREDSEVENTY_LIFES isEqualToString:productIdentifier]) {
        [[GameState sharedInstance] setLifesLeft:[[GameState sharedInstance] lifesLeft] + 170];
    } else if([PRODUCT_FOURHUNDRED_LIFES isEqualToString:productIdentifier]) {
        [[GameState sharedInstance] setLifesLeft:[[GameState sharedInstance] lifesLeft] + 400];
    }
    
    else if([PRODUCT_THIRTY_SUPERJUMPS isEqualToString:productIdentifier]) {
        [[GameState sharedInstance] setJumpButtonsLeft:[[GameState sharedInstance] jumpButtonsLeft] + 30];
    } else if([PRODUCT_EIGHTY_SUPERJUMPS isEqualToString:productIdentifier]) {
        [[GameState sharedInstance] setJumpButtonsLeft:[[GameState sharedInstance] jumpButtonsLeft] + 80];
    } else if([PRODUCT_HUNDREDSEVENTY_SUPERJUMPS isEqualToString:productIdentifier]) {
        [[GameState sharedInstance] setJumpButtonsLeft:[[GameState sharedInstance] jumpButtonsLeft] + 170];
    } else if([PRODUCT_FOURHUNDRED_SUPERJUMPS isEqualToString:productIdentifier]) {
        [[GameState sharedInstance] setJumpButtonsLeft:[[GameState sharedInstance] jumpButtonsLeft] + 400];
    }
    
    else if([PRODUCT_THIRTY_ALL isEqualToString:productIdentifier]) {
        [[GameState sharedInstance] setRedTrampolinesLeft:[[GameState sharedInstance] redTrampolinesLeft] + 30];
        [[GameState sharedInstance] setLifesLeft:[[GameState sharedInstance] lifesLeft] + 30];
        [[GameState sharedInstance] setJumpButtonsLeft:[[GameState sharedInstance] jumpButtonsLeft] + 30];
    } else if([PRODUCT_EIGHTY_ALL isEqualToString:productIdentifier]) {
        [[GameState sharedInstance] setRedTrampolinesLeft:[[GameState sharedInstance] redTrampolinesLeft] + 80];
        [[GameState sharedInstance] setLifesLeft:[[GameState sharedInstance] lifesLeft] + 80];
        [[GameState sharedInstance] setJumpButtonsLeft:[[GameState sharedInstance] jumpButtonsLeft] + 80];
    } else if([PRODUCT_HUNDREDSEVENTY_ALL isEqualToString:productIdentifier]) {
        [[GameState sharedInstance] setRedTrampolinesLeft:[[GameState sharedInstance] redTrampolinesLeft] + 170];
        [[GameState sharedInstance] setLifesLeft:[[GameState sharedInstance] lifesLeft] + 170];
        [[GameState sharedInstance] setJumpButtonsLeft:[[GameState sharedInstance] jumpButtonsLeft] + 170];
    } else if([PRODUCT_FOURHUNDRED_ALL isEqualToString:productIdentifier]) {
        [[GameState sharedInstance] setRedTrampolinesLeft:[[GameState sharedInstance] redTrampolinesLeft] + 400];
        [[GameState sharedInstance] setLifesLeft:[[GameState sharedInstance] lifesLeft] + 400];
        [[GameState sharedInstance] setJumpButtonsLeft:[[GameState sharedInstance] jumpButtonsLeft] + 400];
    }
    
    NSLog(@"[[GameState sharedInstance] save];");
    [[GameState sharedInstance] save];
}


@end









