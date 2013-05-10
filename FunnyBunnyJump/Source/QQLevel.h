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
#import "QQSpriteBalloonBlinker.h"
#import "QQSpriteBarShaker.h"
#import "QQSpriteTapScreenButton.h"
#import "QQSpriteBar.h"
#import "QQSpriteStar.h"
#import "CCScrollLayer.h"
//#import "SimpleAudioEngine.h"
#import "QQLabelTimer.h"
#import "QQLevelChooser.h"

#import "GameState.h"
#import "GCHelper.h"

#import "LHCustomClasses.h"
#import "LHSettings.h"
#import "QQPauseLayer.h"
#import "QQGameOver.h"
#import "QQAdmob.h"



// HelloWorld Layer
@interface QQLevel : LHLayer
{
	b2World* _world;
	GLESDebugDraw *m_debugDraw;
    BOOL _noMoreCollisionHandling;
    int _balloonsDestroyed;
    
    BOOL _backLevel;
    BOOL _reloadLevel;
    
    
    BOOL _explodeIt;
    NSInteger _starsCollected;
    NSInteger _score;
    b2Vec2 _gravity;
    double _startImpulseX, _startImpulseY;

    float _countDown;
    
    enum levelStates {
        levelNotStarted,
        levelRunning,
        levelPaused,
        levelPausedLifeLost,
        levelGameOver};
    
    enum levelStates _levelState;
    BOOL _gameOverLevelPassed;
    
    BOOL _highScoreEffectAlreadyPlayed;
    
    
    //Layers
	LevelHelperLoader* loader;
    LevelHelperLoader* loaderJoystick;
    LevelHelperLoader* loaderPause;
    LevelHelperLoader* _loaderOverlayGameOver;
    
    LevelHelperLoader* loaderParallaxClouds;
    LevelHelperLoader* _loaderHelpLabel;
    LHSprite* _helpLabel;
    //LHParallaxNode* _parallaxClouds;

    //BOOL pause;
    BOOL _levelStarted;
    //BOOL _gameOver;
    BOOL _touchDown;
        
    //Sprites
    QQSpritePlayer* _player;
    QQSpriteTrampoline* _trampoline;
    QQSpriteBar* _bar;
    LHSprite* _tapScreenButton;
    BOOL _tapScreenButtonMakeDynamicRequired;
    CGPoint _tapScreenButtonInitialPosition;
    LHSprite *_star;
    LHSprite *_joystickLeft, *_joystickLeftGlow;
    LHSprite *_joystickRight, *_joystickRightGlow;
    LHSprite *_redTrampolineButton;
    
    LHSprite *_earLeft, *_earRight;
    LHSprite *_handLeft, *_handRight;
    
    LHSprite *_spriteWatch;
    
    //NSArray *_balloons;
    //NSArray *_stars;
    //NSArray *_testinger;
    
    //NSArray *myColors;
    
    CCParticleSystem *_particleBeam1;
    CCParticleSystem *_particleBeam2;

    CCParticleSystemQuad *_particleSpring;
    CCParticleSystemQuad *_particleLeaves;
    CCParticleSystemQuad *_particleSnow;
    CCParticleSystemQuad *_particleSun;
    CCParticleSystemQuad *_particleRain;
    CCParticleSystemQuad *_particleFireBar;

    
    QQLabelTimer* _labelTimer;
    CCLabelTTF* _labelCountdown;
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
    
    QQPauseLayer *_pauseLayer;
    QQGameOver *_gameOverLayer;
    //QQGameOver *_gameOverLayer;
    
    BOOL _shallObejctsBeRemoved;
    BOOL _levelPaused;
    
    QQAdmob *_myAdmob;
    BOOL redTrampolineActive;
}



// returns a Scene that contains the HelloWorld as the only child
+(id)scene;
-(void)disableTouches;
//+(id)scene:(NSString*)level;
//-(void)setupLevelHelper;
//-(void)setupDebugDraw;
//-(void)setupWorld;
//-(void)setupTrampoline;
//-(void)setupPlayer;
//-(void)setupBalloon;
//-(void)setupBeam;
//-(void)setupAudio;
//-(void)setupBar;
//-(void)setupStar;
//-(void)setupJoystick;
//-(void)pauseLevel:(BOOL)pause_;
//-(void)pauseLevelAtStart:(BOOL)pause_;

@end
