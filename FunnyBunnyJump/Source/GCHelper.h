//
//  GCHelper.h
//  FunnyBunnyJump
//
//  Created by Que on 28.10.12.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#define kAchievementSeasonSpring2012 @"com.querika.funnybunnyjump.achievement.seasonspring2012"
#define kAchievementSeasonSummer2012 @"com.querika.funnybunnyjump.achievement.seasonsummer2012"
#define kAchievementSeasonFall2012 @"com.querika.funnybunnyjump.achievement.seasonfall2012"
#define kAchievementSeasonWinter2012 @"com.querika.funnybunnyjump.achievement.seasonwinter2012"

#define kLeaderBoard @"com.querika.funnybunnyjump.leaderboard"


@interface GCHelper : NSObject <NSCoding> {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    NSMutableArray *scoresToReport;
    NSMutableArray *achievementsToReport;
}

@property (retain) NSMutableArray *scoresToReport;
@property (retain) NSMutableArray *achievementsToReport;

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
