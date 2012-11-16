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
//#import "LHSpritePlayer.h"
#import "QQSpritePlayer.h"
#import "QQSpriteTrampoline.h"
#import "QQSpriteBalloon.h"
#import "QQSpriteBalloonShake.h"
#import "QQSpriteBalloonSizechanger.h"
#import "QQSpriteBalloonThreetimestoucher.h"
#import "QQSpriteBar.h"
#import "QQSpriteStar.h"
#import "CCScrollLayer.h"
//#import "SimpleAudioEngine.h"
#import "QQLabelTimer.h"
#import "QQLevelChooser.h"

#import "GameState.h"
#import "GCHelper.h"

#import "LHCustomClasses.h"




// HelloWorld Layer
@interface QQLevel : CCLayer
{
	b2World* _world;
	GLESDebugDraw *m_debugDraw;
    
    
    BOOL _explodeIt;
    NSInteger _starsCollected;
    NSInteger _score;

    float _countDown;
    
    
    //Layers
	LevelHelperLoader* loader;
    LevelHelperLoader* loaderJoystick;
    LevelHelperLoader* loaderPause;
    LevelHelperLoader* _loaderOverlayGameOver;
    
    LevelHelperLoader* loaderParallaxClouds;
    LHParallaxNode* parallaxClouds;

    //BOOL pause;
    BOOL _levelStarted;
    //BOOL _gameOver;
    BOOL _touchDown;
        
    //Sprites
    QQSpritePlayer* _player;
    QQSpriteTrampoline* _trampoline;
    QQSpriteBar* _bar;
    LHSprite *_star;
    LHSprite *_joystickLeft;
    LHSprite *_joystickRight;
    
    LHSprite *_earLeft, *_earRight;
    LHSprite *_handLeft, *_handRight;
    
    //NSArray *_balloons;
    //NSArray *_stars;
    //NSArray *_testinger;
    
    //NSArray *myColors;
    
    CCParticleSystem *_particleBeam1;
    CCParticleSystem *_particleBeam2;

    CCParticleSystemQuad *_particleLeaves;
    CCParticleSystemQuad *_particleSnow;
    CCParticleSystemQuad *_particleSun;
    CCParticleSystemQuad *_particleRain;
    
    
    QQLabelTimer* _labelTimer;
    CCLabelTTF* _labelLifes;
    CCLabelTTF* _labelScore;
    int _highScore;
    CCLabelTTF* _labelHighScore;
    NSMutableDictionary* _dictionaryHighScore;
    
    LHSprite *_spritePauseButton;
    LHSprite *_spritePlayButton;
    LHSprite *_spriteBackButton;
    LHSprite *_spriteReloadButton;

    BOOL alreadyFired;
    BOOL alreadyFiredBallon;
}

//@property BOOL pause;

// returns a Scene that contains the HelloWorld as the only child
+(id)scene;
+(id)scene:(NSString*)level;
-(void)setupLevelHelper;
-(void)setupDebugDraw;
-(void)setupWorld;
-(void)setupTrampoline;
-(void)setupPlayer;
-(void)setupBalloon;
-(void)setupBeam;
-(void)setupAudio;
-(void)setupBar;
-(void)setupStar;
-(void)setupJoystick;
-(void)pauseLevel:(BOOL)pause_;
-(void)pauseLevelAtStart:(BOOL)pause_;

@end