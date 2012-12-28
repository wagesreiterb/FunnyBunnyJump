//
//  LoadingScene.m
//  Astralis
//
//  Created by Brian Dittmer on 1/8/10.
//  Copyright 2010 Sad Robot Software. All rights reserved.
//

#import "LoadingScene.h"
//#import "StarGunnerConstants.h"

@implementation LoadingScene

@synthesize textures;

/*
- (id) init {
	if((self = [super init]) == nil) return nil;
    
	CCSprite *bg = [CCSprite spriteWithFile:@"Default.png"];
	bg.position = ccp(160, 240);
	[self addChild:bg z:0];
    
	CCSprite *loadingStatusBackground = [CCSprite spriteWithFile:@"loading_progress_background.png"];
	loadingStatusBackground.anchorPoint = ccp(0,0);
	loadingStatusBackground.position = ccp(22, 150);
	[self addChild:loadingStatusBackground z:1];
    
	CCSprite *loadingStatusForeground = [CCSprite spriteWithFile:@"loading_progress_foreground.png"];
	loadingStatusForeground.anchorPoint = loadingStatusBackground.anchorPoint;
	loadingStatusForeground.position = loadingStatusBackground.position;
	loadingStatusForeground.scaleX = 0;
	[self addChild:loadingStatusForeground z:2 tag:1];
    
	CCBitmapFontAtlas *loadingText = [CCBitmapFontAtlas bitmapFontAtlasWithString:@" " fntFile:@"visitor_12pt_green.fnt"];
	loadingText.anchorPoint = loadingStatusBackground.anchorPoint;
	loadingText.position = ccp(loadingStatusBackground.position.x, loadingStatusBackground.position.y - 15);
	[self addChild:loadingText z:2 tag:2];
    
	return self;
}

- (void) onEnter {
	[super onEnter];
    
	NSError *error;
	NSArray *bundleContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] bundlePath] error:&error];
    
	self.textures = [NSMutableArray arrayWithCapacity:[bundleContents count]];
    
	for(NSString *file in bundleContents) {
		if([[file pathExtension] compare:@"png"] == NSOrderedSame) {
			[textures addObject:[file lastPathComponent]];
		}
	}
    
	numberOfLoadedTextures = 0;
	[(CCBitmapFontAtlas*)[self getChildByTag:2] setString:[NSString stringWithFormat:@"Loading %@...", [textures objectAtIndex:numberOfLoadedTextures]]];
	[[CCTextureCache sharedTextureCache] addImageAsync:[textures objectAtIndex:numberOfLoadedTextures] target:self selector:@selector(imageDidLoad:)];
}

- (void) imageDidLoad:(CCTexture2D*)tex {
	NSString *plistFile =
    [[(NSString*)[textures objectAtIndex:numberOfLoadedTextures] stringByDeletingPathExtension] stringByAppendingString:@".plist"];
    
	if([[NSFileManager defaultManager] fileExistsAtPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:plistFile]]) {
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:plistFile];
		NSLog(@"loading %@", plistFile);
	}
    
	numberOfLoadedTextures++;
	CCSprite *loadingStatusForeground = (CCSprite*)[self getChildByTag:1];
	loadingStatusForeground.scaleX = (float)numberOfLoadedTextures / (float)[textures count];
    
	if(numberOfLoadedTextures == [textures count]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kPreloadingDone object:nil];
	} else {
		[(CCBitmapFontAtlas*)[self getChildByTag:2] setString:[NSString stringWithFormat:@"Loading %@...", [textures objectAtIndex:numberOfLoadedTextures]]];
		[[CCTextureCache sharedTextureCache] addImageAsync:[textures objectAtIndex:numberOfLoadedTextures] target:self selector:@selector(imageDidLoad:)];
	}
}

- (void) dealloc {
	[textures release];
}
 */

@end