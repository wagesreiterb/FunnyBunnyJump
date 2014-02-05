//
//  QQProduct.m
//  TinyBunnyJump
//
//  Created by Que on 15.09.13.
//
//

#import "QQProduct.h"

@implementation QQProduct

-(id)initWithProductIdentifier:(NSString *)productIdentifier {
    NSLog(@"___ QQProduct::initWithProductIdentifier");
    if ((self = [super init])) {
        _productIdentifier = productIdentifier;

        //button color
        NSString* spriteNameColor = [NSString stringWithFormat:@"%@%@", productIdentifier, @"_color"];
        [self setSpriteProductButtonColor: [LHSprite spriteWithName:spriteNameColor
                                                              fromSheet:@"backgrounds2"
                                                                 SHFile:@"objects"]];
        
        //button gray
        NSString* spriteNameGray = [NSString stringWithFormat:@"%@%@", productIdentifier, @"_gray"];
        [self setSpriteProductButtonGray: [LHSprite spriteWithName:spriteNameGray
                                                          fromSheet:@"backgrounds2"
                                                             SHFile:@"objects"]];
    }
    return self;
}



//
//-(id)initWithProductIdentifier:(NSString *)productIdentifier {
//    NSLog(@"___ QQProduct::initWithProductIdentifier");
//    if ((self = [super init])) {
//        _productIdentifier = productIdentifier;
//        LevelHelperLoader* loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"inAppPurchase"];
//        
//        //NSString* stringSpritePlaceholder = [NSString stringWithFormat:@"%@%@", productIdentifier, @"_spritePlaceholder"];
//        //LHSprite *buttonSpritePlaceholder = [loader spriteWithUniqueName:stringSpritePlaceholder];
//        
//        //button grayscale
//        //        NSString* spriteNameGrayscale = [NSString stringWithFormat:@"%@%@", productIdentifier, @"_grayscale"];
//        //        [self setSpriteProductButtonGrayscale: [LHSprite spriteWithName:spriteNameGrayscale
//        //                                                                 fromSheet:@"assets"
//        //                                                                    SHFile:@"objects"]];
//        //[self.spriteProductButtonGrayscale setPosition:[buttonSpritePlaceholder position]];
//        //[self.spriteProductButtonGrayscale setZOrder:5];
//        
//        //button color
//        NSString* spriteNameColor = [NSString stringWithFormat:@"%@%@", productIdentifier, @"_color"];
//        [self setSpriteProductButtonColor: [LHSprite spriteWithName:spriteNameColor
//                                                          fromSheet:@"assets"
//                                                             SHFile:@"objects"]];
//        //[self.spriteProductButtonColor setPosition:[buttonSpritePlaceholder position]];
//        //[self.spriteProductButtonColor setZOrder:6];
//    }
//    return self;
//}

@end
