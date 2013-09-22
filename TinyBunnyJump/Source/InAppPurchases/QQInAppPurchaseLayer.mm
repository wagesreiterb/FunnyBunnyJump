//
//  QQInAppPurchaseLayer.m
//  TinyBunnyJump
//
//  Created by Que on 04.09.13.
//
//

#import "QQInAppPurchaseLayer.h"
#import "GameManager.h"

#define PRODUCT_THIRTY_TRAMPOLINES @"com.querika.tinybunnyjump.thirtytrampolines"
#define PRODUCT_EIGHTY_TRAMPOLINES @"com.querika.tinybunnyjump.eightytrampolines"

@interface QQInAppPurchaseLayer () <SKProductsRequestDelegate, SKPaymentTransactionObserver, QQProductDelegate>
@end

@implementation QQInAppPurchaseLayer {

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
        _loaderIAP = [[LevelHelperLoader alloc] initWithContentOfFile:@"inAppPurchase"];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        _priceFormatter = [[NSNumberFormatter alloc] init];
        [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        _myQQProducts = [[NSMutableArray alloc] init];

	}
	return self;
}

-(void)openIAPStore:(QQLevel*)mainLayer {
    NSLog(@"... openInAppPurchase Store");
    
    //[self showConfirmAlert];
    
    
    _mainLayer = mainLayer;
    [_mainLayer disableTouchesForPause:YES];
    [_mainLayer setInAppPurchaseStoreOpen:YES];
    
    [_loaderIAP addSpritesToLayer:mainLayer];
    
    _spriteBackButton = [_loaderIAP spriteWithUniqueName:@"buttonBack"];
    [_spriteBackButton registerTouchBeganObserver:self selector:@selector(touchBeganBackButton:)];
    [_spriteBackButton registerTouchEndedObserver:self selector:@selector(touchEndedBackButton:)];

    //[self setupThirtyTrampolinesButton];
    //[self setupEightyTrampolinesButton];
    
    [self setupProducts];
    
    if([SKPaymentQueue canMakePayments]) {
        // Display a store to the user
        [self inAppPurchaseActivated];
    } else {
        // Warn the user that purchases are disabled
        [self inAppPurchaseDeactivated];
    }
}

-(void)setupProducts {
    NSArray *arrayOfProductIdentifiers = [NSArray arrayWithObjects:PRODUCT_THIRTY_TRAMPOLINES, PRODUCT_EIGHTY_TRAMPOLINES,nil];
    
    for(NSString *productIdentifier in arrayOfProductIdentifiers) {
        QQProduct* product;
        product = [[QQProduct alloc] initWithProductIdentifier:productIdentifier
                                                                withLayer:_mainLayer
                                                               withLoader:_loaderIAP];
        product.delegate = self;
        
        [_myQQProducts addObject:product];
        //[self setupProductWithProduct:product];
    }
    
//    NSString *productIdentifier = @"com.querika.tinybunnyjump.thirtytrampolines";
//    QQProduct* productThirtyTrampolines = [[QQProduct alloc] initWithProductIdentifier:productIdentifier];
//    
//    [self setupProductWithProduct:productThirtyTrampolines];
}
-(void)inAppPurchaseActivated {
    NSLog(@"... display a store to the user");
    [self setupPleaseWait];
    [self.scheduler scheduleSelector:@selector(tickRotatePleaseWaitSprite:) forTarget:self interval:0.1f repeat:-1 delay:1 paused:NO];
    [self requestProductData];
}

-(void)inAppPurchaseDeactivated {
    //Settings -> General -> Restrictions
    NSLog(@"... warn the user that purchases are disabled");
    [self setPleaseWaitActive:NO];
    [self showConfirmAlert:@"Alert" withMessage:@"In-App Purchases deactivated!\nTo enable go to Settings -> General -> Restrictions"];
}

//add new products here
-(void)requestProductData {
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:
                                 [NSSet setWithObjects: PRODUCT_THIRTY_TRAMPOLINES, PRODUCT_EIGHTY_TRAMPOLINES, nil]];
    
    request.delegate = self;
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"... QQInAppPurchase::productsRequest");
    [self setPleaseWaitActive:NO];
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    myProducts = response.products;
    
    NSLog(@"... number of elements: %d", [myProducts count]);
    for(SKProduct *myProductFromStore in myProducts) {
        NSLog(@"... product: %@", [myProductFromStore productIdentifier]);
        
        for(QQProduct* myQQProduct in _myQQProducts) {
            NSLog(@"myQQProduct: %@", [myQQProduct productIdentifier]);
            NSLog(@"myProduct: %@", [myProductFromStore productIdentifier]);
            if([[myQQProduct productIdentifier] isEqualToString:[myProductFromStore productIdentifier]]) {
                [myQQProduct setAvailableForPurchase:YES];
                [myQQProduct activateProductButton: myProductFromStore];
                [myQQProduct registerTouchObserver:self];
                NSLog(@"jajajajaja");
            }
        }
//        
//        if([PRODUCT_THIRTY_TRAMPOLINES isEqualToString:[myProduct productIdentifier]]) {
//            NSLog(@"... PRODUCT_THIRTY_TRAMPOLINES found in Array");
//            [self activateThirtyTrampolinesButtonToColor];
//            [_priceFormatter setLocale:myProduct.priceLocale];
//            NSLog(@"... the price is: %@", [_priceFormatter stringFromNumber:myProduct.price]);
//            
//            //-----
//            LHSprite* spriteBuyTrampoline = [_loaderIAP spriteWithUniqueName:@"thirtyTrampolinesPlaceholderText"];
//            _labelBuyTrampoline = [CCLabelTTF labelWithString:[_priceFormatter stringFromNumber:myProduct.price]
//                                                     fontName:@"Marker Felt"
//                                                     fontSize:12
//                                                   dimensions:CGSizeMake(50, 50)
//                                                   hAlignment:kCCTextAlignmentCenter
//                                                   vAlignment:kCCVerticalTextAlignmentCenter];
//            
//            
//            [_labelBuyTrampoline setColor:ccc3(0,0,0)];
//            [_labelBuyTrampoline setPosition:[spriteBuyTrampoline position]];
//            [_mainLayer addChild:_labelBuyTrampoline];
//            //----
//            
//            
//        } else if([PRODUCT_EIGHTY_TRAMPOLINES isEqualToString:[myProduct productIdentifier]]) {
//            NSLog(@"... PRODUCT_EIGHTY_TRAMPOLINES found in Array");
//            [self activateEightyTrampolinesButtonToColor];
//            [_priceFormatter setLocale:myProduct.priceLocale];
//            NSLog(@"... the price is: %@", [_priceFormatter stringFromNumber:myProduct.price]);
//            
//            //-----
//            LHSprite* spriteBuyTrampoline = [_loaderIAP spriteWithUniqueName:@"eightyTrampolinesPlaceholderText"];
//            _labelBuy80Trampoline = [CCLabelTTF labelWithString:[_priceFormatter stringFromNumber:myProduct.price]
//                                                       fontName:@"Marker Felt"
//                                                       fontSize:12
//                                                     dimensions:CGSizeMake(50, 50)
//                                                     hAlignment:kCCTextAlignmentCenter
//                                                     vAlignment:kCCVerticalTextAlignmentCenter];
//            
//            
//            [_labelBuy80Trampoline setColor:ccc3(0,0,0)];
//            [_labelBuy80Trampoline setPosition:[spriteBuyTrampoline position]];
//            [_mainLayer addChild:_labelBuy80Trampoline];
//            //----
//        }
    }
    
    for(NSString *invalidProductIdentifier in response.invalidProductIdentifiers) {
        NSLog(@"... invalide Products: %@", invalidProductIdentifier);
    }
    
    // Populate your UI from the products list.
    
    // Save a reference to the products list.
    
}

- (void)touchBeganProductButton:(QQProduct *)sender {
    NSLog(@"Delegates are great!");
    if(_purchaseInProgress == NO) {
        _purchaseInProgress = YES;
        [self setPleaseWaitActive:YES];
//        NSLog(@"+++ _chosenProductIdentifier: %@", _chosenProductIdentifier);
//        [self makePayment:_chosenProductIdentifier];
          NSLog(@"+++ _chosenProductIdentifier: %@", [sender productIdentifier]);
          [self makePayment:[sender productIdentifier]];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Failed to load list of products.");
}

-(void)makePayment:(NSString*)productIdentifier {
    for(SKProduct *myProduct in myProducts) {
        //NSLog(@"... product: %@", [myProduct productIdentifier]);
        
        if([productIdentifier isEqualToString:[myProduct productIdentifier]]) {
            NSLog(@"... product payment");
            SKPayment *payment = [SKPayment paymentWithProduct:myProduct];
            NSLog(@"... xxx: %@", [myProduct productIdentifier]);
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
    [self setPleaseWaitActive:NO];
    _purchaseInProgress = NO;
    [self showConfirmAlert:@"Success" withMessage:@"Payment finished!\nThank You!"];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"... restored Transaction");
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [self setPleaseWaitActive:NO];
    _purchaseInProgress = NO;
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"... failedTransaction");
    if (transaction.error.code != SKErrorPaymentCancelled) {
        // Optionally, display an error here.
    }   
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [self setPleaseWaitActive:NO];
    _purchaseInProgress = NO;
    [self showConfirmAlert:@"Error" withMessage:@"Payment cancled!"];
}

-(void)recordTransaction:(SKPaymentTransaction*)transaction {
    
}

-(void)provideContent:(NSString*)productIdentifier {
    NSLog(@"... provideContent");
    if([PRODUCT_THIRTY_TRAMPOLINES isEqualToString:productIdentifier]) {
        NSLog(@"... PRODUCT_THIRTY_TRAMPOLINES provide Content");
        [[GameState sharedInstance] setRedTrampolinesLeft:[[GameState sharedInstance] redTrampolinesLeft] + 3];   //TODO change to 30
    } else if([PRODUCT_EIGHTY_TRAMPOLINES isEqualToString:productIdentifier]) {
        NSLog(@"... PRODUCT_EIGHTY_TRAMPOLINES provide Content");
        [[GameState sharedInstance] setRedTrampolinesLeft:[[GameState sharedInstance] redTrampolinesLeft] + 8];   //TODO change to 80
    }
}

-(void)touchBeganBackButton:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"+++++++++++++++++++++++++++++++++ touchBeganBackButton");
    }
}

-(void)touchEndedBackButton:(LHTouchInfo*)info{
    if(info.sprite) {
        if([_mainLayer getLevelState] == running) {
            [_mainLayer makePlayerDynamic];
        }
        NSLog(@"+++++++++++++++++++++++++++++++++ touchEndedBackButton");
        [self.scheduler unscheduleAllForTarget:self];
        //[self removeFromParentAndCleanup:YES];

        //[_mainLayer setLevelState:levelRunning];
        
        NSArray *sprites = [_loaderIAP allSprites];
        for(LHSprite *sprite in sprites) {
            [sprite removeSelf];
        }
        
        for(QQProduct* myQQProduct in _myQQProducts) {
            [[myQQProduct spriteProductButtonGrayscale] removeSelf];
            [[myQQProduct spriteProductButtonColor] removeSelf];
            [[myQQProduct labelProductPrice] removeFromParent];
        }
        
        //[_thirtyTrampolinesButton removeSelf];
        //[_eightyTrampolinesButton removeSelf];
        [self setPleaseWaitActive:NO];
        //[_labelBuyTrampoline removeFromParent];     //TODO: sometimes it is not removed?!?
        //[_labelBuy80Trampoline removeFromParent];

        [_mainLayer disableTouchesForPause:NO];
        [_mainLayer setInAppPurchaseStoreOpen:NO];
        
        [self removeFromParentAndCleanup:YES];
        
        _mainLayer = nil;
    }
}

-(void)onEnter
{
    NSLog(@"... onEnter");
	[super onEnter];
    [self.scheduler unscheduleAllForTarget:self];
    //[self.scheduler unscheduleAllSelectorsForTarget:self];
}

#pragma mark progress HUD
-(void)tickRotatePleaseWaitSprite:(ccTime)dt {
    if(_pleaseWaitActive) {
        [_spritePleaseWait setRotation:_rotation += 30];
        if(_rotation == 360) _rotation = 0;
    }
}

-(void)setPleaseWaitActive:(BOOL)visible {
    NSLog(@"... setPleaseWaitActive: %d", visible);
    [_spritePleaseWait setVisible:visible];
    [_pleaseWaitBackground setVisible:visible];
    _pleaseWaitActive = visible;
}

-(void)setupPleaseWait {
    NSLog(@"... setupPleaseWait");
    
    LHSprite *pleaseWait_background_Placeholder = [_loaderIAP spriteWithUniqueName:@"pleaseWait_background_Placeholder"];
    _pleaseWaitBackground = [LHSprite spriteWithName:@"pleaseWait_background"
                                           fromSheet:@"assets"
                                              SHFile:@"objects"];
    
    [_pleaseWaitBackground setPosition:[pleaseWait_background_Placeholder position]];
    [_pleaseWaitBackground setZOrder:10];
    [_pleaseWaitBackground setVisible:NO];
    [_mainLayer addChild:_pleaseWaitBackground];
    
    LHSprite *pleaseWaitPlaceholder = [_loaderIAP spriteWithUniqueName:@"pleaseWaitPlaceholder"];
    _spritePleaseWait = [LHSprite spriteWithName:@"pleaseWait"
                                       fromSheet:@"assets"
                                          SHFile:@"objects"];
    
    [_spritePleaseWait setPosition:[pleaseWaitPlaceholder position]];
    [_spritePleaseWait setZOrder:20];
    [_spritePleaseWait setVisible:NO];
    [_mainLayer addChild:_spritePleaseWait];
    
    [self setPleaseWaitActive:YES];
}

#pragma mark alert dialog
- (void)showConfirmAlert
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Confirm"];
    [alert setMessage:@"Do you pick Yes or No?"];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"OK"];
//    [alert addButtonWithTitle:@"Yes"];
//    [alert addButtonWithTitle:@"No"];
    [alert show];
}

- (void)showConfirmAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:title];
    [alert setMessage:message];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"OK"];
    //    [alert addButtonWithTitle:@"Yes"];
    //    [alert addButtonWithTitle:@"No"];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // Yes, do something
        NSLog(@"Alert Dialog: YES");
    }
    else if (buttonIndex == 1)
    {
        // No
        NSLog(@"Alert Dialog: NO");
    }
}



@end


//-(void)touchBeganThirtyTrampolinesButton:(LHTouchInfo*)info{
//    if(info.sprite) {
//        if(_purchaseInProgress == NO) {
//            NSLog(@"+++++++++++++++++++++++++++++++++ touchBeganThirtyTrampolinesButton");
//            _purchaseInProgress = YES;
//            [self setPleaseWaitActive:YES];
//            [self makePayment:PRODUCT_THIRTY_TRAMPOLINES];
//        }
//    }
//}
//
//-(void)touchEndedThirtyTrampolinesButton:(LHTouchInfo*)info{
//    if(info.sprite) {
//        NSLog(@"+++++++++++++++++++++++++++++++++ touchEndedThirtyTrampolinesButton");
//    }
//}
//
//-(void)touchBeganEightyTrampolinesButton:(LHTouchInfo*)info{
//    if(info.sprite) {
//        if(_purchaseInProgress == NO) {
//            NSLog(@"+++++++++++++++++++++++++++++++++ touchBeganEightyTrampolinesButton");
//            _purchaseInProgress = YES;
//            [self setPleaseWaitActive:YES];
//            [self makePayment:PRODUCT_EIGHTY_TRAMPOLINES];
//        }
//    }
//}
//
//-(void)touchEndedEightyTrampolinesButton:(LHTouchInfo*)info{
//    if(info.sprite) {
//        NSLog(@"+++++++++++++++++++++++++++++++++ touchEndedEightyTrampolinesButton");
//    }
//}



//-(void)touchBeganProductButton:(LHTouchInfo*)info{
//    if(info.sprite) {
//        NSLog(@"+++++++++++++++++++++++++++++++++ touchBeganProductButton");
//
//        //if(_purchaseInProgress == NO) {
//            _purchaseInProgress = YES;
//            [self setPleaseWaitActive:YES];
//            NSLog(@"+++ _chosenProductIdentifier: %@", _chosenProductIdentifier);
//            //[self makePayment:_chosenProductIdentifier];
//        //}
//    }
//}
//
//-(void)touchEndedProductButton:(LHTouchInfo*)info{
//    if(info.sprite) {
//        NSLog(@"+++++++++++++++++++++++++++++++++ touchEndedProductButton");
//    }
//}

//- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
//    NSLog(@"... QQInAppPurchase::productsRequest");
//    [self setPleaseWaitActive:NO];
//
//    _priceFormatter = [[NSNumberFormatter alloc] init];
//    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
//    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
//
//    myProducts = response.products;
//
//    NSLog(@"... number of elements: %d", [myProducts count]);
//    for(SKProduct *myProduct in myProducts) {
//        NSLog(@"... product: %@", [myProduct productIdentifier]);
//
//
//        if([PRODUCT_THIRTY_TRAMPOLINES isEqualToString:[myProduct productIdentifier]]) {
//            NSLog(@"... PRODUCT_THIRTY_TRAMPOLINES found in Array");
//            [self activateThirtyTrampolinesButtonToColor];
//            [_priceFormatter setLocale:myProduct.priceLocale];
//            NSLog(@"... the price is: %@", [_priceFormatter stringFromNumber:myProduct.price]);
//
//            //-----
//            LHSprite* spriteBuyTrampoline = [_loaderIAP spriteWithUniqueName:@"thirtyTrampolinesPlaceholderText"];
//            _labelBuyTrampoline = [CCLabelTTF labelWithString:[_priceFormatter stringFromNumber:myProduct.price]
//                                                     fontName:@"Marker Felt"
//                                                     fontSize:12
//                                                   dimensions:CGSizeMake(50, 50)
//                                                   hAlignment:kCCTextAlignmentCenter
//                                                   vAlignment:kCCVerticalTextAlignmentCenter];
//
//
//            [_labelBuyTrampoline setColor:ccc3(0,0,0)];
//            [_labelBuyTrampoline setPosition:[spriteBuyTrampoline position]];
//            [_mainLayer addChild:_labelBuyTrampoline];
//            //----
//
//
//        } else if([PRODUCT_EIGHTY_TRAMPOLINES isEqualToString:[myProduct productIdentifier]]) {
//            NSLog(@"... PRODUCT_EIGHTY_TRAMPOLINES found in Array");
//            [self activateEightyTrampolinesButtonToColor];
//            [_priceFormatter setLocale:myProduct.priceLocale];
//            NSLog(@"... the price is: %@", [_priceFormatter stringFromNumber:myProduct.price]);
//
//            //-----
//            LHSprite* spriteBuyTrampoline = [_loaderIAP spriteWithUniqueName:@"eightyTrampolinesPlaceholderText"];
//            _labelBuy80Trampoline = [CCLabelTTF labelWithString:[_priceFormatter stringFromNumber:myProduct.price]
//                                                     fontName:@"Marker Felt"
//                                                     fontSize:12
//                                                   dimensions:CGSizeMake(50, 50)
//                                                   hAlignment:kCCTextAlignmentCenter
//                                                   vAlignment:kCCVerticalTextAlignmentCenter];
//
//
//            [_labelBuy80Trampoline setColor:ccc3(0,0,0)];
//            [_labelBuy80Trampoline setPosition:[spriteBuyTrampoline position]];
//            [_mainLayer addChild:_labelBuy80Trampoline];
//            //----
//        }
//    }
//
//    for(NSString *invalidProductIdentifier in response.invalidProductIdentifiers) {
//        NSLog(@"... invalide Products: %@", invalidProductIdentifier);
//    }
//
//    // Populate your UI from the products list.
//
//    // Save a reference to the products list.
//
//}


//-(void)setupProductWithProduct:(QQProduct *)product {
//    NSLog(@"... setupProductWithProductIdentifier");
//
//    NSString* stringSpritePlaceholder = [NSString stringWithFormat:@"%@%@", [product productIdentifier], @"_spritePlaceholder"];
//    LHSprite *buttonSpritePlaceholder = [_loaderIAP spriteWithUniqueName:stringSpritePlaceholder];
//
//    NSString* spriteNameGrayscale = [NSString stringWithFormat:@"%@%@", [product productIdentifier], @"_grayscale"];
//
//    [product setSpriteProductButtonGrayscale: [LHSprite spriteWithName:spriteNameGrayscale
//                                              fromSheet:@"assets"
//                                                 SHFile:@"objects"]];
//
//    [product.spriteProductButtonGrayscale setPosition:[buttonSpritePlaceholder position]];
//    [product.spriteProductButtonGrayscale setZOrder:5];
//    [_mainLayer addChild:product.spriteProductButtonGrayscale];
//}

//-(void)setupProductWithProduct:(QQProduct *)product {
//    NSLog(@"... setupProductWithProductIdentifier");
//
//    NSString* stringSpritePlaceholder = [NSString stringWithFormat:@"%@%@", [product productIdentifier], @"_spritePlaceholder"];
//    LHSprite *buttonSpritePlaceholder = [_loaderIAP spriteWithUniqueName:stringSpritePlaceholder];
//
//    NSString* spriteName = [NSString stringWithFormat:@"%@%@", [product productIdentifier], @"_grayscale"];
//
//    _thirtyTrampolinesButton = [LHSprite spriteWithName:spriteName
//                                              fromSheet:@"assets"
//                                                 SHFile:@"objects"];
//
//    [_thirtyTrampolinesButton setPosition:[buttonSpritePlaceholder position]];
//    [_thirtyTrampolinesButton setZOrder:5];
//    [_mainLayer addChild:_thirtyTrampolinesButton];
//}


//-(void)setupThirtyTrampolinesButton {
//    NSLog(@"... setupThirtyTrampolinesButton");
//
//    NSString *productIdentifier = @"com.querika.tinybunnyjump.thirtytrampolines";
//
//    NSString* stringSpritePlaceholder = [NSString stringWithFormat:@"%@%@", productIdentifier, @"_spritePlaceholder"];
//    LHSprite *buttonSpritePlaceholder = [_loaderIAP spriteWithUniqueName:stringSpritePlaceholder];
//
//    NSString* spriteName = [NSString stringWithFormat:@"%@%@", productIdentifier, @"_grayscale"];
//
//    _thirtyTrampolinesButton = [LHSprite spriteWithName:spriteName
//                                              fromSheet:@"assets"
//                                                 SHFile:@"objects"];
//
//    [_thirtyTrampolinesButton setPosition:[buttonSpritePlaceholder position]];
//    [_thirtyTrampolinesButton setZOrder:5];
//    [_mainLayer addChild:_thirtyTrampolinesButton];
//}

//-(void)activateThirtyTrampolinesButtonToColor {
//    NSLog(@"... activateThirtyTrampolinesButtonToColor");
//
//    NSString *productIdentifier = @"com.querika.tinybunnyjump.thirtytrampolines";
//
//    NSString* stringSpritePlaceholder = [NSString stringWithFormat:@"%@%@", productIdentifier, @"_spritePlaceholder"];
//    LHSprite *buttonSpritePlaceholder = [_loaderIAP spriteWithUniqueName:stringSpritePlaceholder];
//
//    NSString* spriteName = [NSString stringWithFormat:@"%@%@", productIdentifier, @"_color"];
//
//    [_thirtyTrampolinesButton removeSelf];
//
//    _thirtyTrampolinesButton = [LHSprite spriteWithName:spriteName
//                                              fromSheet:@"assets"
//                                                 SHFile:@"objects"];
//
//    [_thirtyTrampolinesButton setPosition:[buttonSpritePlaceholder position]];
//    [_thirtyTrampolinesButton registerTouchBeganObserver:self selector:@selector(touchBeganThirtyTrampolinesButton:)];
//    [_thirtyTrampolinesButton registerTouchEndedObserver:self selector:@selector(touchEndedThirtyTrampolinesButton:)];
//    [_mainLayer addChild:_thirtyTrampolinesButton];
//}

//-(void)activateEightyTrampolinesButtonToColor {
//    NSLog(@"... activateEightyTrampolinesButtonToColor");
//
//    NSString *productIdentifier = PRODUCT_EIGHTY_TRAMPOLINES;
//
//    NSString* stringSpritePlaceholder = [NSString stringWithFormat:@"%@%@", productIdentifier, @"_spritePlaceholder"];
//    LHSprite *buttonSpritePlaceholder = [_loaderIAP spriteWithUniqueName:stringSpritePlaceholder];
//
//    NSString* spriteName = [NSString stringWithFormat:@"%@%@", productIdentifier, @"_color"];
//
//    [_eightyTrampolinesButton removeSelf];
//
//    _eightyTrampolinesButton = [LHSprite spriteWithName:spriteName
//                                              fromSheet:@"assets"
//                                                 SHFile:@"objects"];
//
//    [_eightyTrampolinesButton setPosition:[buttonSpritePlaceholder position]];
//    [_eightyTrampolinesButton registerTouchBeganObserver:self selector:@selector(touchBeganEightyTrampolinesButton:)];
//    [_eightyTrampolinesButton registerTouchEndedObserver:self selector:@selector(touchEndedEightyTrampolinesButton:)];
//    [_mainLayer addChild:_eightyTrampolinesButton];
//}

//-(void)setupEightyTrampolinesButton {
//    NSLog(@"... setupEightyTrampolinesButton");
//    LHSprite *eightyTrampolinesButtonPlaceholder = [_loaderIAP spriteWithUniqueName:@"com.querika.tinybunnyjump.eightytrampolines"];
//    _eightyTrampolinesButton = [LHSprite spriteWithName:@"inAppPurchaseEightyTramplines_grayscale"
//                                              fromSheet:@"assets"
//                                                 SHFile:@"objects"];
//
//    [_eightyTrampolinesButton setPosition:[eightyTrampolinesButtonPlaceholder position]];
//    [_eightyTrampolinesButton setZOrder:5];
//    [_mainLayer addChild:_eightyTrampolinesButton];
//}

//-(void)activateEightyTrampolinesButtonToColor {
//    NSLog(@"... activateEightyTrampolinesButtonToColor");
//    [_eightyTrampolinesButton removeSelf];
//
//    LHSprite *eightyTrampolinesButtonPlaceholder = [_loaderIAP spriteWithUniqueName:@"com.querika.tinybunnyjump.eightytrampolines"];
//    _eightyTrampolinesButton = [LHSprite spriteWithName:@"inAppPurchaseEightyTramplines_color"
//                                              fromSheet:@"assets"
//                                                 SHFile:@"objects"];
//
//    [_eightyTrampolinesButton setPosition:[eightyTrampolinesButtonPlaceholder position]];
//    [_eightyTrampolinesButton registerTouchBeganObserver:self selector:@selector(touchBeganEightyTrampolinesButton:)];
//    [_eightyTrampolinesButton registerTouchEndedObserver:self selector:@selector(touchEndedEightyTrampolinesButton:)];
//    [_mainLayer addChild:_eightyTrampolinesButton];
//}


