//
//  QQInAppPurchaseLayer.m
//  TinyBunnyJump
//
//  Created by Que on 04.09.13.
//
//

#import "QQInAppPurchaseLayer.h"
#import "QQInAppPurchaseStore.h"
#import "GameManager.h"


@interface QQInAppPurchaseLayer () <QQInAppPurchaseStoreDelegate>
@end

@implementation QQInAppPurchaseLayer {
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
        
        _priceFormatter = [[NSNumberFormatter alloc] init];
        [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	}
	return self;
}

-(void)showIAPStoreFromLevel:(QQLevel*)mainLayer {
    
    //dispatch only in main thread is required
    //for the confirm dialog
    //otherwise the app crashes
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"... openInAppPurchase Store");
        _entryFromLevel = YES;
        _mainLayer = mainLayer;
        
        [(QQLevel*)_mainLayer disableTouchesForPause:YES];
        [(QQLevel*)_mainLayer setInAppPurchaseStoreOpen:YES];
        
        [self showIapStore];
    });
}

-(void)showIAPStoreFromHomescreen:(LHLayer*)mainLayer {
    //dispatch only in main thread is required
    //for the confirm dialog
    //otherwise the app crashes
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"... openInAppPurchase Store");
        _entryFromLevel = NO;
        _mainLayer = mainLayer;
        
        [self showIapStore];
    });
}

-(void)showIapStore {
    
    if(![SKPaymentQueue canMakePayments]) {
        [self inAppPurchaseDeactivated];
    }
    
    [_loaderIAP addSpritesToLayer:_mainLayer];
    
    _spriteBackButton = [_loaderIAP spriteWithUniqueName:@"buttonBack"];
    [_spriteBackButton registerTouchBeganObserver:self selector:@selector(touchBeganBackButton:)];
    [_spriteBackButton registerTouchEndedObserver:self selector:@selector(touchEndedBackButton:)];
    
    [[QQInAppPurchaseStore sharedInstance] setDelegate:self];
    [[QQInAppPurchaseStore sharedInstance] openIAPStore];
    
    [self populateGrayIcons];
}

-(void)populateGrayIcons {
    NSLog(@"xxx: xxx");
    
    for(QQProduct* qqProduct in [[QQInAppPurchaseStore sharedInstance] myQQProducts]) {
        NSString* stringSpritePlaceholder = [NSString stringWithFormat:@"%@%@", qqProduct.productIdentifier, @"_spritePlaceholder"];
        LHSprite *buttonSpritePlaceholder = [_loaderIAP spriteWithUniqueName:stringSpritePlaceholder];
        
        [qqProduct.spriteProductButtonGray setPosition:[buttonSpritePlaceholder position]];
        [qqProduct.spriteProductButtonGray setZOrder:5];
        [_mainLayer addChild:qqProduct.spriteProductButtonGray];
        
    }
}

//-(void)removeGrayIcons {
//    NSLog(@"xxx: removeGrayIcons");
//    NSArray* myProducts = [[QQInAppPurchaseStore sharedInstance] arrayOfProductIdentifiers];
//    for(NSString* productIdentifier in myProducts) {
//
//    }
//}

- (void)touchBeganProductButton:(QQProduct*)sender {
    NSLog(@"Delegates are great!");
    if(_purchaseInProgress == NO) {
        _purchaseInProgress = YES;
        [self setPleaseWaitActive:YES];
        //[self showPleaseWait];
    }
}

-(void)touchBeganBackButton:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"+++++++++++++++++++++++++++++++++ touchBeganBackButton: %@", info.sprite.uniqueName);
    }
}

-(void)touchEndedBackButton:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"+++++++++++++++++++++++++++++++++ touchEndedBackButton");
        [self.scheduler unscheduleAllForTarget:self];
        
        NSArray *sprites = [_loaderIAP allSprites];
        for(LHSprite *sprite in sprites) {
            [sprite removeSelf];
        }
        
        for(QQProduct* qqProduct in [[QQInAppPurchaseStore sharedInstance] myQQProducts]) {
        //for(QQProduct* myQQProduct in _myQQProducts) {
            [[qqProduct spriteProductButtonGray] removeSelf];
            [[qqProduct spriteProductButtonColor] removeSelf];
            [[qqProduct labelPrice] removeFromParent];
        }

        if(_entryFromLevel) {
            if([(QQLevel*)_mainLayer getLevelState] == running) {
                [(QQLevel*)_mainLayer makePlayerDynamic];
            }
            [(QQLevel*)_mainLayer disableTouchesForPause:NO];
            [(QQLevel*)_mainLayer setInAppPurchaseStoreOpen:NO];
        }
        
        [self removeFromParentAndCleanup:YES];
        
        [self setPleaseWaitActive:NO];
        _mainLayer = nil;
    }
}

-(void)onEnter
{
    NSLog(@"... onEnter");
	[super onEnter];
    [self.scheduler unscheduleAllForTarget:self];
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
//- (void)showConfirmAlert
//{
//    UIAlertView *alert = [[UIAlertView alloc] init];
//    [alert setTitle:@"Confirm"];
//    [alert setMessage:@"Do you pick Yes or No?"];
//    [alert setDelegate:self];
//    [alert addButtonWithTitle:@"OK"];
////    [alert addButtonWithTitle:@"Yes"];
////    [alert addButtonWithTitle:@"No"];
//    [alert show];
//}

- (void)showConfirmAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:title];
    [alert setMessage:message];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"OK"];
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

-(void)removePleaseWait {
    [self setPleaseWaitActive:NO];
}

#pragma mark delegates

-(void)productsRequest {
//-(void)productsRequest:(QQInAppPurchaseStore*)response {
    NSLog(@"xxx: the response is comming!");
    [self removePleaseWait];
    for(QQProduct* qqProduct in [[QQInAppPurchaseStore sharedInstance] myQQProducts]) {
        NSLog(@"xxx: productIdentifier: %@", qqProduct.productIdentifier);
        
        //LHSprite* buttonColor = qqProduct.spriteProductButtonColor;
        
        if(qqProduct.availableForPurchase) {
            NSString* stringSpritePlaceholder = [NSString stringWithFormat:@"%@%@", qqProduct.productIdentifier, @"_spritePlaceholder"];
            LHSprite *buttonSpritePlaceholder = [_loaderIAP spriteWithUniqueName:stringSpritePlaceholder];
            
            [qqProduct.spriteProductButtonColor setPosition:[buttonSpritePlaceholder position]];
            [qqProduct.spriteProductButtonColor setZOrder:6];
            [qqProduct.spriteProductButtonColor setUniqueName:qqProduct.productIdentifier];
            [_mainLayer addChild:qqProduct.spriteProductButtonColor];
            
            [qqProduct.spriteProductButtonColor registerTouchBeganObserver:self selector:@selector(touchBegan:)];
            [qqProduct.spriteProductButtonColor registerTouchEndedObserver:self selector:@selector(touchEnded:)];
            
            ////////////////////////
            [_priceFormatter setLocale:qqProduct.priceLocale];
            NSString* stringPricePlaceholder = [NSString stringWithFormat:@"%@%@", qqProduct.productIdentifier, @"_pricePlaceholder"];
            NSLog(@"... the price is: %@", [_priceFormatter stringFromNumber:qqProduct.price]);

            LHSprite* spritePricePlaceholder = [_loaderIAP spriteWithUniqueName:stringPricePlaceholder];
            qqProduct.labelPrice = [CCLabelTTF labelWithString:[_priceFormatter stringFromNumber:qqProduct.price]
                                                     fontName:@"Marker Felt"
                                                     fontSize:12
                                                   dimensions:CGSizeMake(50, 50)
                                                   hAlignment:kCCTextAlignmentCenter
                                                   vAlignment:kCCVerticalTextAlignmentCenter];

            [qqProduct.labelPrice setColor:ccc3(0,0,0)];
            [qqProduct.labelPrice setPosition:[spritePricePlaceholder position]];
            [qqProduct.labelPrice setZOrder:6];
            [_mainLayer addChild:qqProduct.labelPrice];
            
            
        } else {
            NSLog(@"xxx: product not available for purchase: %@", qqProduct.productIdentifier);
        }
    }
}

-(void)showPleaseWait {
    if(!_pleaseWaitActive) {
        NSLog(@"------------------------- please Wait");
        [self setupPleaseWait];
        [self.scheduler scheduleSelector:@selector(tickRotatePleaseWaitSprite:) forTarget:self interval:0.1f repeat:-1 delay:1 paused:NO];
    }
}

-(void)inAppPurchaseDeactivated {
    //Settings -> General -> Restrictions
    NSLog(@"... warn the user that purchases are disabled");
    [self setPleaseWaitActive:NO];
    [self showConfirmAlert:@"Alert" withMessage:@"In-App Purchases deactivated!\nTo enable go to Settings -> General -> Restrictions"];
}

#pragma mark touch receivers
-(void)touchBegan:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"xxx: Touch BEGIN on sprite %@", [info.sprite uniqueName]);
        for(QQProduct* qqProduct in [[QQInAppPurchaseStore sharedInstance] myQQProducts]) {
            if([qqProduct.productIdentifier isEqualToString:[info.sprite uniqueName]]) {
                [[QQInAppPurchaseStore sharedInstance] touchBeganProductButton:qqProduct];
                NSLog(@"xxx: Touch xxx %@", [info.sprite uniqueName]);
                [self showPleaseWait];
            }
        }
    }
}

-(void)touchEnded:(LHTouchInfo*)info{
//    if(info.sprite) {
//        NSLog(@"xxx: Touch END on sprite %@", [info.sprite uniqueName]);
//        for(QQProduct* qqProduct in [[QQInAppPurchaseStore sharedInstance] myQQProducts]) {
//            if([qqProduct.productIdentifier isEqualToString:[info.sprite uniqueName]]) {
//                [[QQInAppPurchaseStore sharedInstance] touchBeganProductButton:qqProduct];
//                NSLog(@"xxx: Touch END xxx %@", [info.sprite uniqueName]);
//                [self showPleaseWait];
//            }
//        }
//    }
}


@end





