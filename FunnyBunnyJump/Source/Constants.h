//
//  Constants.h
//  Acrobat_g7003
//
//  Created by Que on 30.09.12.
//
//
// iPad: 1024 x 768  4:3
// iPad 3: 2048 * 1536  4:3
// iPhone, iPod: 480 x 320  3:2
// iPhone 4: 960 x 640  3:2
// iPhone 5: 1136 x 640 16:9	

#import <Foundation/Foundation.h>

#define COUNTDOWN 120

#define LIFES 3
#define EFFECT_SUN "sun"
#define EFFECT_SNOW "snow"
#define EFFECT_RAIN "rain"
#define EFFECT_LEAVES "leaves"

NSInteger const LAST_LEVEL = 2012026;
float const volumeBackgroundMusic = 0.2f;

@protocol Constants <NSObject>

typedef enum {
    kNoSceneUninitialized = 0,
    kHomeScreen = 1,
    kSeasonsScreen = 2,
    kLevelChooser = 3,
    kCreditsScreen = 4,
    kHelpScreen = 5,
    
    kLevel2012001 = 2012001,
    kLevel2012002 = 2012002,
    kLevel2012003 = 2012003,
    kLevel2012004 = 2012004,
    kLevel2012005 = 2012005,
    kLevel2012006 = 2012006,
    kLevel2012007 = 2012007,
    kLevel2012008 = 2012008,
    kLevel2012009 = 2012009,
    kLevel2012010 = 2012010,
    kLevel2012011 = 2012011,
    kLevel2012012 = 2012012,
    kLevel2012013 = 2012013,
    kLevel2012014 = 2012014,
    kLevel2012015 = 2012015,
    kLevel2012016 = 2012016,
    kLevel2012017 = 2012017,
    kLevel2012018 = 2012018,
    kLevel2012019 = 2012019,
    kLevel2012020 = 2012020,
    kLevel2012021 = 2012021,
    kLevel2012022 = 2012022,
    kLevel2012023 = 2012023,
    kLevel2012024 = 2012024,
    kLevel2012025 = 2012025,
    kLevel2012026 = 2012026
    
} SceneTypes;

typedef enum {
    spring, summer, fall, winter
} Seasons;

typedef enum {
    kLinkTypeHomepage,
    kLinkTypeFacebook,
    kLinkTypeTwitter
} LinkTypes;


@end
