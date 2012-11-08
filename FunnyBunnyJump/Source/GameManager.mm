//
//  GameManager.m
//  Acrobat_g7003
//
//  Created by Que on 30.09.12.
//
//

#import "GameManager.h"

@implementation GameManager

static GameManager* _sharedGameManager = nil;

@synthesize levelToRun;
@synthesize currentScene;
@synthesize musicOn;
@synthesize soundEffectsOn;
@synthesize season;
@synthesize seasonName;
@synthesize seasonPage;
@synthesize effectSunShining;
@synthesize effectSnowing;
@synthesize effectRaining;
@synthesize effectFallingLeaves;

+(GameManager*)sharedGameManager {
    @synchronized([GameManager class]) {
        if(!_sharedGameManager) {
            [[self alloc] init];
        }
        return _sharedGameManager;
    }
    return nil;
}

+(id)alloc {
    @synchronized([GameManager class]) {
        NSAssert(_sharedGameManager == nil,
                 @"Attempted to allocate a second instance of the GameManger singleton");
        _sharedGameManager = [super alloc];
    }
    return nil;
}

-(id)init {
    self = [super init];
    if(self != nil) {
        //Game Manager initialized
        CCLOG(@"Game Manager Singleton, init");
        musicOn = YES;
        soundEffectsOn = YES;
        
        //Effects
        effectSunShining = NO;
        effectSnowing = NO;
        effectRaining = NO;
        effectFallingLeaves = NO;
        
        currentScene = kNoSceneUninitialized;
    }
    return self;
}

-(void)runSceneWithID:(SceneTypes)sceneID {
    SceneTypes oldScene = currentScene;
    currentScene = sceneID;
    id sceneToRun = nil;
    
    switch(sceneID) {
        case kHomeScreen:
            sceneToRun = [QQHomeScreen scene];
            break;
        case kSeasonsScreen:
            sceneToRun =[QQSeasonsScreen scene];
            break;
        case kLevelChooser:
            sceneToRun =[QQLevelChooser scene];
            break;
            
        case kLevel001: {
            NSString *fullLevelName = @"level";
            fullLevelName = [fullLevelName stringByAppendingString:seasonName];
            fullLevelName = [fullLevelName stringByAppendingString:@"2012001"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
            
        case kLevel002: {
            NSString *fullLevelName = @"level";
            fullLevelName = [fullLevelName stringByAppendingString:seasonName];
            fullLevelName = [fullLevelName stringByAppendingString:@"2012002"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
            
        case kLevel003: {
            NSString *fullLevelName = @"level";
            fullLevelName = [fullLevelName stringByAppendingString:seasonName];
            fullLevelName = [fullLevelName stringByAppendingString:@"2012003"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        
            /*
        case kLevelSpring2012002:
            [[GameManager sharedGameManager] setLevelToRun:@"l2012002"];
            sceneToRun =[QQLevel scene];
            break;
            */
            
        default:
            CCLOG(@"GameManger: Unknown ID, cannot switch scenes");
            return;
            break;
    }
    
    if(sceneToRun == nil) {
        //Revert back, since no new scene was found
        currentScene = oldScene;
        return;
    }
    
    if([[CCDirector sharedDirector] runningScene] == nil) {
        [[CCDirector sharedDirector] runWithScene:sceneToRun];
    } else {
        [[CCDirector sharedDirector] replaceScene:sceneToRun];
        //[[CCDirector sharedDirector] replaceScene:[CCTransitionTurnOffTiles transitionWithDuration:0.3f
        //                                                                                     scene:sceneToRun]];
    }
    
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionTurnOffTiles transitionWithDuration:0.3f
    //                                                                                     scene:[QQLevel scene:@"level001"]]];
}

-(void)toggleMusic {
    if(musicOn == YES) {
        musicOn = NO;
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    } else {
        musicOn = YES;
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.2f];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"zippy.mp3"];
    }
}

-(void)toggleSoundEffects {
    if(soundEffectsOn == YES) {
        soundEffectsOn = NO;
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0];
        [[SimpleAudioEngine sharedEngine] playEffect:@"heavyLaserBeam.mp3"];

    } else {
        soundEffectsOn = YES;
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:1];
        [[SimpleAudioEngine sharedEngine] playEffect:@"heavyLaserBeam.mp3"];

    }
}

@end
