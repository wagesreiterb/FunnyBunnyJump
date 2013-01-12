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
            
        case kCreditsScreen:
            sceneToRun =[QQCreditsScene scene];
            break;
            
        case kHelpScreen:
            sceneToRun =[QQHelp scene];
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
            fullLevelName = [fullLevelName stringByAppendingString:@"2012002"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
            
        case kLevel2012003: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012003"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012004: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012004"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012005: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012005"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012006: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012006"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        } 
        case kLevel2012007: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012007"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012008: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012008"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012009: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012009"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012010: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012010"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012011: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012011"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012012: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012012"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012013: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012013"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012014: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012014"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012015: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012015"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012016: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012016"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012017: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012017"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012018: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012018"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012019: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012019"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012020: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012020"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012021: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012021"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012022: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012022"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012023: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012023"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012024: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012024"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012025: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012025"];
            [[GameManager sharedGameManager] setLevelToRun:fullLevelName];
            sceneToRun =[QQLevel scene];
            break;
        }
        case kLevel2012026: {
            fullLevelName = [fullLevelName stringByAppendingString:@"2012026"];
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

-(void)openSiteWithLinkType:(LinkTypes)linkTypeToOpen {
    NSURL *urlToOpen = nil;
    if (linkTypeToOpen == kLinkTypeHomepage) {
        CCLOG(@"Opening Homepage");
        urlToOpen = [NSURL URLWithString:@"http://www.querika.com"];
    } else if (linkTypeToOpen == kLinkTypeFacebook) {
        CCLOG(@"Opening Facebook");
        urlToOpen = [NSURL URLWithString:@"http://www.facebook.com/querika.com"];
    } else if (linkTypeToOpen == kLinkTypeTwitter) {
        CCLOG(@"Opening Twitter");
        urlToOpen = [NSURL URLWithString:@"http://www.twitter.com/querika_com"];
    } else {
        CCLOG(@"Defaulting to www.querika.com");
        urlToOpen = [NSURL URLWithString:@"http://www.querika.com"];
    }
    if (![[UIApplication sharedApplication] openURL:urlToOpen]) {
        CCLOG(@"%@%@",@"Failed to open url:",[urlToOpen description]);
        [self runSceneWithID:kHomeScreen];
    }
}

-(void)toggleMusic {
    if([[GameState sharedInstance] isMusicEnabled]) {
        [[GameState sharedInstance] setMusicEnabled:NO];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    } else {
        [[GameState sharedInstance] setMusicEnabled:YES];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:volumeBackgroundMusic];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"zippy.mp3"];
    }
    [[GameState sharedInstance] save];
}

-(void)playOrNotMusic {
    if([[GameState sharedInstance] isMusicEnabled]) {
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:volumeBackgroundMusic];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"zippy.mp3"];
    } else {
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    }
}

-(void)playOrNotSound {
    if([[GameState sharedInstance] isSoundEnabled]) {
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:1];
        //[[SimpleAudioEngine sharedEngine] playEffect:@"heavyLaserBeam.mp3"];
    } else {
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0];
        //[[SimpleAudioEngine sharedEngine] playEffect:@"heavyLaserBeam.mp3"];
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
