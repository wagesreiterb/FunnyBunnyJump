//
//  QQProduct.m
//  TinyBunnyJump
//
//  Created by Que on 15.09.13.
//
//

#import "QQProduct.h"

@implementation QQProduct

-(id)initWithProductIdentifier:(NSString *)productIdentifier withLayer:(LHLayer *)layer withLoader:(LevelHelperLoader *)loader {
    NSLog(@"___ QQProduct::initWithProductIdentifier");
    if ((self = [super init])) {
        _productIdentifier = productIdentifier;
        _loader = loader;
        _layer = layer;
        
        //LevelHelperLoader *loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"inAppPurchase"];
        
        NSString* stringSpritePlaceholder = [NSString stringWithFormat:@"%@%@", productIdentifier, @"_spritePlaceholder"];
        LHSprite *buttonSpritePlaceholder = [loader spriteWithUniqueName:stringSpritePlaceholder];
        
        NSString* spriteNameGrayscale = [NSString stringWithFormat:@"%@%@", productIdentifier, @"_grayscale"];
        
        [self setSpriteProductButtonGrayscale: [LHSprite spriteWithName:spriteNameGrayscale
                                                                 fromSheet:@"assets"
                                                                    SHFile:@"objects"]];
        
        [self.spriteProductButtonGrayscale setPosition:[buttonSpritePlaceholder position]];
        [self.spriteProductButtonGrayscale setZOrder:5];
        [layer addChild:self.spriteProductButtonGrayscale];
    }
    return self;
}

-(void)activateProductButton:(SKProduct *)myProductFromStore {
    //show button in color
    NSString* stringSpritePlaceholder = [NSString stringWithFormat:@"%@%@", _productIdentifier, @"_spritePlaceholder"];
    LHSprite *buttonSpritePlaceholder = [_loader spriteWithUniqueName:stringSpritePlaceholder];
    
    NSString* spriteNameColor = [NSString stringWithFormat:@"%@%@", _productIdentifier, @"_color"];
    
    [_spriteProductButtonGrayscale removeSelf];
    
    _spriteProductButtonColor = [LHSprite spriteWithName:spriteNameColor
                                              fromSheet:@"assets"
                                                 SHFile:@"objects"];
    
    [_spriteProductButtonColor setPosition:[buttonSpritePlaceholder position]];
    [_spriteProductButtonColor setZOrder:5];
    
    [_layer addChild:_spriteProductButtonColor];
    //--- show button in color
    
    //show price as Label
    NSNumberFormatter* priceFormatter = [[NSNumberFormatter alloc] init];
    [priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [priceFormatter setLocale:myProductFromStore.priceLocale];
    NSLog(@"... the price is: %@", [priceFormatter stringFromNumber:myProductFromStore.price]);
    
    NSString* stringPricePlaceholder = [NSString stringWithFormat:@"%@%@", _productIdentifier, @"_pricePlaceholder"];
    NSLog(@"---stringPricePlaceholder: %@", stringPricePlaceholder);
    LHSprite *spritePricePlaceholder = [_loader spriteWithUniqueName:stringPricePlaceholder];
    
    _labelProductPrice = [CCLabelTTF labelWithString:[priceFormatter stringFromNumber:myProductFromStore.price]
                                             fontName:@"Marker Felt"
                                             fontSize:12
                                           dimensions:CGSizeMake(50, 50)
                                           hAlignment:kCCTextAlignmentCenter
                                           vAlignment:kCCVerticalTextAlignmentCenter];
    
    
    [_labelProductPrice setColor:ccc3(0,0,0)];
    [_labelProductPrice setPosition:[spritePricePlaceholder position]];
    [_labelProductPrice setZOrder:10];
    [_layer addChild:_labelProductPrice];
    //--- show price as Label
}

//-(void)registerTouchObserver:(QQInAppPurchaseLayer *)observer {
//    //[observer setChosenProductIdentifier:_productIdentifier];
//    //NSLog(@"--- productIdentifier_1: %@", _productIdentifier);
//    [_spriteProductButtonColor registerTouchBeganObserver:observer selector:@selector(touchBeganProductButton:)];
//    [_spriteProductButtonColor registerTouchEndedObserver:observer selector:@selector(touchEndedProductButton:)];
//}

-(void)registerTouchObserver:(QQInAppPurchaseLayer *)observer {
    //[observer setChosenProductIdentifier:_productIdentifier];
    //NSLog(@"--- productIdentifier_1: %@", _productIdentifier);
    [_spriteProductButtonColor registerTouchBeganObserver:self selector:@selector(touchBeganProductButton:)];
    [_spriteProductButtonColor registerTouchEndedObserver:self selector:@selector(touchEndedProductButton:)];
}

-(void)touchBeganProductButton:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"+++++++++++++++++++++++++++++++++ QQProduct::touchBeganProductButton");
        NSLog(@"+++++++++++++++++++++++++++++++++ QQProduct::productIdentifier: %@", _productIdentifier);
        [self.delegate touchBeganProductButton:self]; //this will call the method implemented in your other class
    }
}

-(void)touchEndedProductButton:(LHTouchInfo*)info{
    if(info.sprite) {
        NSLog(@"+++++++++++++++++++++++++++++++++ QQProduct::touchEndedProductButton");
    }
}

@end
