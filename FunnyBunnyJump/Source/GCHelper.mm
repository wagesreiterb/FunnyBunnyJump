//
//  GCHelper.m
//  FunnyBunnyJump
//
//  Created by Que on 28.10.12.
//
//

#import "GCHelper.h"
#import "GCDatabase.h"

@implementation GCHelper

@synthesize scoresToReport;
@synthesize achievementsToReport;

#pragma mark Loading/Saving

static GCHelper *sharedHelper = nil;

+(GCHelper*)sharedInstance {
    @synchronized([GCHelper class]) {
        if(!sharedHelper) {
            sharedHelper = loadData(@"GameCenterData");
            if(!sharedHelper) {
                [[self alloc]
                 initWithScoresToReport:[NSMutableArray array]
                 achievementsToReport:[NSMutableArray array]];
            }
        }
        return sharedHelper;
    }
    return nil;
}

+(id)alloc {
    @synchronized([GCHelper class]) {
        NSAssert(sharedHelper == nil, @"Attempted to allocate a \
                  second instance of the GCHelper singleton");
        sharedHelper = [super alloc];
        return sharedHelper;
    }
    return nil;
}

-(BOOL)isGameCenterAvailable {
    //Check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    //Check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

-(void)save {
    saveData(self, @"GameCenterData");
}

-(id)initWithScoresToReport:(NSMutableArray *)theScoresToReport
       achievementsToReport:(NSMutableArray *)theAchievementsToReport {
    if((self = [super init])) {
        self.scoresToReport = theScoresToReport;
        self.achievementsToReport = theAchievementsToReport;
        gameCenterAvailable = [self isGameCenterAvailable];
        if(gameCenterAvailable) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

#pragma mark Internal functions

-(void)authenticationChanged {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
            NSLog(@"Authentication changed: player authenticated.");
            userAuthenticated = TRUE;
            [self resendData];
        } else if(![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
            NSLog(@"Authentication changed: player not authenticated");
            userAuthenticated = FALSE;
        }
    });
}

-(void)authenticateLocalUser {
    if(!gameCenterAvailable)
        return;
    NSLog(@"Authentication local user...");
    if([GKLocalPlayer localPlayer].authenticated == NO) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
    } else {
        NSLog(@"Already authenticated!");
    }
}

- (void)reportScore:(NSString *)identifier score:(int)rawScore {
    NSLog(@"GCHelper::reportScore");
    GKScore *score = [[GKScore alloc] initWithCategory:identifier];
    
    score.value = rawScore;
    [scoresToReport addObject:score];
    [self save];
    
    if (!gameCenterAvailable || !userAuthenticated) return;
    [self sendScore:score];
}

-(void)reportAchievements:(NSString *)identifier percentComplete:(double)percentComplete {
    GKAchievement* achievement = [[GKAchievement alloc]
                                   initWithIdentifier:identifier];
    achievement.percentComplete = percentComplete;
    [self save];
    
    if(!gameCenterAvailable || !userAuthenticated) return;
    [self sendAchievemnet:achievement];
}

//leaderBoard
/*
- (void)sendScore:(GKScore *)score {
    NSLog(@"GCHelper::sendScore");
    [score reportScoreWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (error == NULL) {
                NSLog(@"Successfully sent score!");
                [scoresToReport removeObject:score];
            } else {
                NSLog(@"Score failed to send... will try again later. \
                      Reason: %@", error.localizedDescription);
            }
        });
    }];
}
 */

//leaderBoard
// BugFix for iOS6
//http://www.cocos2d-iphone.org/forum/topic/41948
- (void)sendScore:(GKScore *)score {
    
    // Pull the score value and category from the passed in score
    int scoreValue = score.value;
    NSString*scoreCategory = score.category;
    
    // Create a new temporary score with these values
    GKScore *toReport = [[GKScore alloc]
                          initWithCategory:scoreCategory];
    toReport.value = scoreValue;
    
    // Report the temporary score, delete the original on success
    [toReport reportScoreWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            if (error == NULL) {
                NSLog(@"Successfully sent score!");
                [scoresToReport removeObject:score];
                [self save];
            }
            else {
                NSLog(@"Score failed to send... will try again later. Reason: %@", error.localizedDescription);
            }
        });
    }];
}



//achievements
-(void)sendAchievemnet:(GKAchievement*)achievement {
    [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if(error == NULL) {
                NSLog(@"Successfully sent achievement!");
                [achievementsToReport removeObject:achievement];
            } else {
                NSLog(@"Achievement failed to send... will try again \
                      later. Reason: %@", error.localizedDescription);
            }
        });
    }];
}

-(void)resendData {
    //achievements
    for(GKAchievement *achievement in achievementsToReport) {
        [self sendAchievemnet:achievement];
    }
    //leaderBoard
    for (GKScore *score in scoresToReport) {
        [self sendScore:score];
    }
}

- (void)resetAchievements {
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
    {
        if (error != nil)
            // handle errors
            NSLog(@"reset Achievements not possible");
        else
            NSLog(@"Achievements resettetet!");
    }];
}

#pragma mark NSCoding

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:scoresToReport forKey:@"ScoresToReport"];
    [encoder encodeObject:achievementsToReport forKey:@"AchievementsToReport"];
}

-(id)initWithCoder:(NSCoder*)decoder {
    NSMutableArray* theScoresToReport = [decoder decodeObjectForKey:@"ScoresToReport"];
    NSMutableArray* theAchievementsToReport = [decoder decodeObjectForKey:@"AchievementsToReport"];
    
    return [self initWithScoresToReport:theScoresToReport achievementsToReport:theAchievementsToReport];
}

@end
