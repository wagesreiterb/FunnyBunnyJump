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

#define COUNTDOWN 100
#define LIFES 3
#define EFFECT_SUN "sun"
#define EFFECT_SNOW "snow"
#define EFFECT_RAIN "rain"
#define EFFECT_LEAVES "leaves"

@protocol Constants <NSObject>

typedef enum {
    kNoSceneUninitialized = 0,
    kHomeScreen = 1,
    kSeasonsScreen = 2,
    kLevelChooser = 3,
    
    kLevel001 = 2012001,
    kLevel002 = 2012002,
    kLevel003 = 2012003
    //kLevelSpring2012002 = 2012002
    
    
} SceneTypes;

typedef enum {
    spring, summer, fall, winter
} Seasons;



@end
