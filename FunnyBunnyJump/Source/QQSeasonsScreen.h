//
//  QQLevel.h
//  presentation
//
//  Created by Bogdan Vladu on 15.03.2011.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "LevelHelperLoader.h"
#import "CCScrollLayer.h"
#import "QQLevelChooser.h"
#import "GameManager.h"

// HelloWorld Layer
@interface QQSeasonsScreen : CCLayer
{
	b2World* _world;
	GLESDebugDraw *m_debugDraw;
    
    LevelHelperLoader* loader;
    LevelHelperLoader* _loader1;
    //NSString* name;
    
    /*
    LHSprite *_spriteSeasonSpring;
    LHSprite *_spriteSeasonSummer;
    LHSprite *_spriteSeasonFall;
    LHSprite *_spriteSeasonWinter;
     */
    
    
    LHSprite *_emptySeason;
    LHSprite *_backButton;
    
    //CCScrollLayer *myScroller;
    

}

//@property NSString* name;

// returns a Scene that contains the HelloWorld as the only child
+(id)scene;
-(void)setupLevelHelper:(NSString*)withLevel;
-(void)setupDebugDraw;
-(void)setupWorld;

@end
