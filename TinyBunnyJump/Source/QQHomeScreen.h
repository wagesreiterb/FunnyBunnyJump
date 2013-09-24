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
#import "QQSpritePlayer.h"
#import "QQSpriteTrampoline.h"
#import "QQSpriteMusicButton.h"
//#import "SimpleAudioEngine.h"
#import "GameManager.h"
#import "AppDelegate.h"
#import <GameKit/GameKit.h>
#import "GameState.h"
#import "CCFBProfilePicture.h"
#import "QQInAppPurchaseLayer.h"


// HelloWorld Layer
@interface QQHomeScreen : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
	b2World* _world;
	GLESDebugDraw *m_debugDraw;

    //Layers
	LevelHelperLoader* loader;
    
    //Sprites
    QQSpritePlayer* _player;
    QQSpriteTrampoline* _trampoline;

    //LHSprite *_spriteSoundEffectsOn, *_spriteSoundEffectsOff;
    //LHSprite *_spriteMusicOn, *_spriteMusicOff;
    LHSprite *_spriteMusic;
    LHSprite *_spriteSound;
    LHSprite *_spritePlay;
    LHSprite *_spriteLeaderBoard;
    LHSprite *_spriteAchievements;
    LHSprite *_spriteFacebookButton, *_spriteTwitterButton;
    LHSprite *_creditsButton;
    LHSprite *_inAppStoreButton;
    //LHSprite *_helpButton;
    
    LHSprite *_spriteToScaleMusicButton;
    BOOL _balloonMusicButtonCompletelyInflated;
    
    LHSprite *_spriteToScaleSoundButton;
    BOOL _balloonSoundButtonCompletelyInflated;

    //LHSprite *_spriteToScale;
    
    int _repeat;
    float _scaleFactor;
}

// returns a Scene that contains the HelloWorld as the only child
+(id)scene;
-(void)afterStep;
-(void)setupLevelHelper;
-(void)setupDebugDraw;
-(void)setupWorld;
-(void)setupTrampoline;
-(void)setupPlayer;


@end
