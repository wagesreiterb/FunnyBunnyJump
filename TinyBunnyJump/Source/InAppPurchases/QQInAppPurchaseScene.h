//
//  QQCreditsScene.h
//  FunnyBunnyJump
//
//  Created by Que on 09.01.13.
//
//

#import "LHLayer.h"

@interface QQInAppPurchaseScene : LHLayer
{
    //b2World* _world;
    //GLESDebugDraw *m_debugDraw;

    //Layers
    LevelHelperLoader* _loader;
    LHSprite* _buttonBackBalloon;
}

// returns a Scene that contains the HelloWorld as the only child
+(id)scene;
-(void)afterStep;

@end
