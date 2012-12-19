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
//@synthesize musicOn;
//@synthesize soundEffectsOn;
@synthesize season;
@synthesize seasonName;
@synthesize seasonPage;

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
        //musicOn = YES;
        //soundEffectsOn = YES;
        
        currentScene = kNoSceneUninitialized;
    }
    return self;
}

-(void)runSceneWithID:(SceneTypes)sceneID {
    SceneTypes oldScene = currentScene;
    currentScene = sceneID;
    id sceneToRun = nil;
    
    NSString *fullLevelName = @"level";
    if(seasonName == nil) seasonName = @"";
    fullLevelName = [fullLevelName stringByAppendingString:seasonName];
    
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
            
        case kLevel2012001: {
            //NSString *fullLevelName = @"level";
            //fullLevelName = [fullLevelName stringByAppendingString:seasonName];
            fullLevelName = [fullLevelName stringByAppendingString:@"2012001"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
            
        case kLevel2012002: {
            //NSString *fullLevelName = @"level";
            //fullLevelName = [fullLevelName stringByAppendingString:seasonName];
            fullLevelName = [fullLevelName stringByAppendingString:@"2012002"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
            
        case kLevel2012003: {
            //NSString *fullLevelName = @"level";
            //fullLevelName = [fullLevelName stringByAppendingString:seasonName];
            fullLevelName = [fullLevelName stringByAppendingString:@"2012003"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012004: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012003"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }

            
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
    if([[GameState sharedInstance] isMusicEnabled]) {
        [[GameState sharedInstance] setMusicEnabled:NO];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    } else {
        [[GameState sharedInstance] setMusicEnabled:YES];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.2f];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"zippy.mp3"];
    }
    [[GameState sharedInstance] save];
}

-(void)playOrNotMusic {
    if([[GameState sharedInstance] isMusicEnabled]) {
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.2f];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"zippy.mp3"];
    } else {
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    }
}

-(void)playOrNotSound {
    if([[GameState sharedInstance] isSoundEnabled]) {
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:1];
        [[SimpleAudioEngine sharedEngine] playEffect:@"heavyLaserBeam.mp3"];
    } else {
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0];
        [[SimpleAudioEngine sharedEngine] playEffect:@"heavyLaserBeam.mp3"];
    }
}

-(void)toggleSound {
    if([[GameState sharedInstance] isSoundEnabled]) {
        [[GameState sharedInstance] setSoundEnabled:NO];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0];
        [[SimpleAudioEngine sharedEngine] playEffect:@"heavyLaserBeam.mp3"];
        
    } else {
        [[GameState sharedInstance] setSoundEnabled:YES];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:1];
        [[SimpleAudioEngine sharedEngine] playEffect:@"heavyLaserBeam.mp3"];
    }
    [[GameState sharedInstance] save];
}

/*
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
 */

/*
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
 */

@end
