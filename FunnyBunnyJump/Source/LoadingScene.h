//
//  LoadingScene.h
//  FunnyBunnyJump
//
//  Created by Que on 28.12.12.
//
//

#import "LHLayer.h"
#import "cocos2d.h"

@interface LoadingScene : CCScene {
    int numberOfLoadedTextures;
    
}

@property CCTexture2D* textures;

@end
