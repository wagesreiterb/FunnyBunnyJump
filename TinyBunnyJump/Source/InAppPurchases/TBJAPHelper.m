//
//  HMIAPHelper.m
//  TinyBunnyJump
//
//  Created by Que on 01.09.13.
//
//

#import "TBJIAPHelper.h"
#import "IAPProduct.h"

@implementation TBJIAPHelper

+ (TBJIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static TBJIAPHelper * sharedInstance; dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    //IAPProduct * hundredHints = [[IAPProduct alloc] initWithProductIdentifier:@"com.razeware.hangman.hundredhints"];
    //NSMutableDictionary * products = [@{tenHints.productIdentifier: tenHints, hundredHints.productIdentifier: hundredHints} mutableCopy];
    
    NSLog(@"TBJIAPHelper::init");
    
    IAPProduct * thirtyTrampolines = [[IAPProduct alloc] initWithProductIdentifier:@"com.querika.tinybunnyjump.thirtytrampolines"];
    NSMutableDictionary * products = [@{thirtyTrampolines.productIdentifier: thirtyTrampolines} mutableCopy];
        
    if ((self = [super initWithProducts:products])) { }
    
    return self;
}
@end
