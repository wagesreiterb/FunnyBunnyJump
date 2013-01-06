//
//  IntroLayer.m
//  FunnyBunnyJump
//
//  Created by Que on 09.10.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"


#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//

/*
-(void) onEnter
{
	[super onEnter];
    
    [self scheduleOnce:@selector(makeTransition:) delay:0];
}
*/


-(void) onEnter
{
	[super onEnter];

	// ask director for the window size
	CGSize size = [[CCDirector sharedDirector] winSize];
	CCSprite *background;
    
    
//	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
//		background = [CCSprite spriteWithFile:@"Default.png"];
//		background.rotation = 90;
//	} else {
//		//background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
//        background = [CCSprite spriteWithFile:@"splashScreen-ipad.png"];
//	}
 
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        CGFloat scale = [[UIScreen mainScreen] scale];
        
        if (scale > 1.0)
        {
            //iPad retina screen
            background = [CCSprite spriteWithFile:@"Default-Landscape@2x~ipad.png"];
            //NSLog(@"iPad retina screen");
            //[background setScale:2.0f];
        }
        else
        {
            //iPad screen
            background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
            NSLog(@"iPad normal screen");
        }
    }
    else
    {
        if ([UIScreen instancesRespondToSelector:@selector(scale)])
        {
            CGFloat scale = [[UIScreen mainScreen] scale];
            
            if (scale > 1.0)
            {
                //iphone retina screen
                NSLog(@"iPhone retina screen");
                //[background setScale:2.0f];
                background = [CCSprite spriteWithFile:@"Default.png"];
                [background setRotation:90];
            }
            else
            {
                //iphone screen
                NSLog(@"iPhone normal screen");
                background = [CCSprite spriteWithFile:@"Default.png"];
                [background setRotation:90];
                [background setScale:0.5f];
            }
        }
    }
    
	background.position = ccp(size.width/2, size.height/2);
	[self addChild: background];
    
    
    /*
    for(NSString *file in bundleContents) {
		if([[file pathExtension] compare:@"png"] == NSOrderedSame) {
			[CCTextureCache addImage: file];
		}
	}
    */
    

    [self preloadTextures];
    [self preloadSoundEffects];
    
    [self scheduleOnce:@selector(makeTransition:) delay:0];
    //[[CCDirector sharedDirector] runWithScene:[QQHomeScreen scene]];
}

-(void)preloadSoundEffects {
    //TODO: are all sounds preloaded, what about music?
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"ouch_que.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"hui_que.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"yippy_que.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"balloon.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"boink.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"jubilant-fanfare-3.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"explosive-orchestra.mp3"];
}

-(void)preloadTextures {
    //CCTexture2D *texture =
    //TODO: what about other devices?!?!
    [[CCTextureCache sharedTextureCache] addImage:@"objects_foregrounds-hd.png"];
    [[CCTextureCache sharedTextureCache] addImage:@"objects_assets-hd.png"];
    [[CCTextureCache sharedTextureCache] addImage:@"objects_backgrounds-hd.png"];
    [[CCTextureCache sharedTextureCache] addImage:@"objects_backgrounds2-hd.png"];
    [[CCTextureCache sharedTextureCache] addImage:@"objects_backgrounds3-hd.png"];
}


/*
-(void) onEnter
{
	[super onEnter];
    
	// ask director for the window size
	CGSize size = [[CCDirector sharedDirector] winSize];
    
	CCSprite *background;
	
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
		background = [CCSprite spriteWithFile:@"Default.png"];
		background.rotation = 90;
	} else {
		background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
	}
	background.position = ccp(size.width/2, size.height/2);
    
	// add the label as a child to this Layer
	[self addChild: background];
	
	// In one second transition to the new scene
	[self scheduleOnce:@selector(makeTransition:) delay:1];
}
 */

-(void) makeTransition:(ccTime)dt
{
	//[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[QQHomeScreen scene] withColor:ccWHITE]];
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionTurnOffTiles transitionWithDuration:0.3f
    //                                                                                     scene:[QQHomeScreen scene]]];

    if([[GameState sharedInstance] tempHighScore] == nil) {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
        [[GameState sharedInstance] setTempHighScore:tmpDict];
        [tmpDict release];
    }
    
    if([[GameState sharedInstance] tempLevelPassed] == nil) {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
        [[GameState sharedInstance] setTempLevelPassed:tmpDict];
        [tmpDict release];
    }
    
    if([[GameState sharedInstance] tempLevelPassedInTime] == nil) {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
        [[GameState sharedInstance] setTempLevelPassedInTime:tmpDict];
        [tmpDict release];
    }
    
    if([[GameState sharedInstance] tempLevelPassedNoLivesLost] == nil) {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
        [[GameState sharedInstance] setTempLevelPassedNoLivesLost:tmpDict];
        [tmpDict release];
    }
    
    
    [[CCDirector sharedDirector] replaceScene:[QQHomeScreen scene]];
}


/*
-(void) makeTransition:(ccTime)dt
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[QQHomeScreen scene] withColor:ccWHITE]];
}
*/

@end
