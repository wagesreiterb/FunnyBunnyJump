//
//  GCHelper.h
//  FunnyBunnyJump
//
//  Created by Que on 28.10.12.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#define kAchievementSeasonSpring2012 @"com.querika.tinybunnyjump.achievement.seasonspring2012"
#define kAchievementSeasonSummer2012 @"com.querika.tinybunnyjump.achievement.seasonsummer2012"
#define kAchievementSeasonFall2012 @"com.querika.tinybunnyjump.achievement.seasonfall2012"
#define kAchievementSeasonWinter2012 @"com.querika.tinybunnyjump.achievement.seasonwinter2012"

//#define kLeaderBoard @"com.querika.tinybunnyjump.leaderboard"
#define kLeaderBoardSpring2012 @"com.querika.tinybunnyjump.leaderboardspring2012"
#define kLeaderBoardSummer2012 @"com.querika.tinybunnyjump.leaderboardsummer2012"
#define kLeaderBoardFall2012 @"com.querika.tinybunnyjump.leaderboardfall2012"
#define kLeaderBoardWinter2012 @"com.querika.tinybunnyjump.leaderboardwinter2012"

@interface GCHelper : NSObject <NSCoding> {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    NSMutableArray *scoresToReport;
    NSMutableArray *achievementsToReport;
}

@property (strong) NSMutableArray *scoresToReport;
@property (strong) NSMutableArray *achievementsToReport;

+(GCHelper*)sharedInstance;
-(void)authenticationChanged;
-(void)authenticateLocalUser;

-(void)save;
-(id)initWithScoresToReport:(NSMutableArray*)scoresToReport
       achievementsToReport:(NSMutableArray*)achievementsToReport;
-(void)reportAchievements:(NSString*)identifier
          percentComplete:(double)percentComplete;
-(void)reportScore:(NSString*)identifier score:(int)score;

//TODO: for test purpose only!
- (void)resetAchievements;

@end
