//
//  GameManager.h
//  Acrobat_g7003
//
//  Created by Que on 30.09.12.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"
#import "QQHomeScreen.h"
#import "QQSeasonsScreen.h"
#import "QQLevelChooser.h"
#import "SimpleAudioEngine.h"
#import "QQLevel.h"

@interface GameManager : NSObject {
    BOOL musicOn;
    BOOL soundEffectsOn;
    
    SceneTypes currentScene;
    Seasons season;
    NSString *seasonName;
    NSInteger seasonPage;
    NSString *levelToRun;
    
    //Effects
    BOOL effectSunShining;
    BOOL effectSnowing;
    BOOL effectRaining;
    BOOL effectFallingLeaves;
}
@property SceneTypes currentScene;
@property (copy) NSString *seasonName;
@property (copy) NSString *levelToRun;
@property (getter=isMusicOn) BOOL musicOn;
@property (getter=isSoundEffectsOn) BOOL soundEffectsOn;
@property Seasons season;
@property NSInteger seasonPage;
@property BOOL effectSunShining;
@property BOOL effectSnowing;
@property BOOL effectRaining;
@property BOOL effectFallingLeaves;

+(GameManager*)sharedGameManager;
-(void)runSceneWithID:(SceneTypes)sceneID;
-(void)toggleMusic;
-(void)toggleSoundEffects;

@end
