//
//  QQLevelChooser.h
//  Acrobat_g7003
//
//  Created by Que on 24.09.12.
//
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "LevelHelperLoader.h"
#import "SimpleAudioEngine.h"
#import "GameManager.h"
#import "GameState.h"


//#import "QQLevel.h"
//#import "QQHomeScreen.h"
//#import "QQLevelMainScreen.h"

@interface QQLevelChooser : CCLayer
{
	b2World* _world;
	GLESDebugDraw *m_debugDraw;

    
    //Layers
	LevelHelperLoader* loader;
    
    //LHSprite *_sprite;
    NSArray* _levelChooserIcons;
}

// returns a Scene that contains the HelloWorld as the only child
+(id)scene;
-(void)setupLevelHelper;
-(void)setupDebugDraw;
-(void)setupWorld;
@end
