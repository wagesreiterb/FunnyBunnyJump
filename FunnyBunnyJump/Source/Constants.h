//
//  Constants.h
//  Acrobat_g7003
//
//  Created by Que on 30.09.12.
//
//

#import <Foundation/Foundation.h>

#define COUNTDOWN 100;

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
