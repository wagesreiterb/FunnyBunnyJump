//
//  LHLayer.m
//  ParallaxTimeBased
//
//  Created by Bogdan Vladu on 4/2/12.
//  Copyright (c) 2012 Bogdan Vladu. All rights reserved.
//

#import "LHLayer.h"
#import "LHBatch.h"
#import "LHSprite.h"
#import "LHBezier.h"
#import "LHDictionaryExt.h"
#import "LHSettings.h"
#import "LevelHelperLoader.h"
#import "lhConfig.h"
static int untitledLayersCount = 0;


@interface LHLayer (Private)
-(void)addChildFromDictionary:(NSDictionary*)childDict;
@end


@implementation LHLayer
@synthesize uniqueName;
@synthesize isMainLayer;
//------------------------------------------------------------------------------
-(void)dealloc{
    
//    CCLOG(@"LH Layer Dealloc %@", uniqueName);

#ifndef LH_ARC_ENABLED
    [uniqueName release];
    
    if(userCustomInfo){
        [userCustomInfo release];
        userCustomInfo = nil;
    }
#endif
    uniqueName = nil;
    parentLoader = nil;
    userCustomInfo = nil;
    
#ifndef LH_ARC_ENABLED
	[super dealloc];
#endif

}
//------------------------------------------------------------------------------
-(void) loadUserCustomInfoFromDictionary:(NSDictionary*)dictionary{
    userCustomInfo = nil;
    if(!dictionary)return;
    
    NSString* className = [dictionary stringForKey:@"ClassName"];
    Class customClass = NSClassFromString(className);
    
    if(!customClass) return;
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    userCustomInfo = [customClass performSelector:@selector(customClassInstance)];
#pragma clang diagnostic pop
    
#ifndef LH_ARC_ENABLED
    [userCustomInfo retain];
#endif
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [userCustomInfo performSelector:@selector(setPropertiesFromDictionary:) withObject:[dictionary objectForKey:@"ClassRepresentation"]];
#pragma clang diagnostic pop

    
    
}
-(NSString*)userInfoClassName{
    if(userCustomInfo)
        return NSStringFromClass([userCustomInfo class]);
    return @"No Class";
}
// used internally to alter the zOrder variable. DON'T call this method manually
-(void) _setZOrder:(NSInteger) z
{
#if COCOS2D_VERSION > 0x00020100 || COCOS2D_VERSION == 0x00020000 || COCOS2D_VERSION == 0x00010100 || COCOS2D_VERSION == 0x00010001 || COCOS2D_VERSION == 0x00010000
    zOrder_ = z;
#else
    zOrder_ = z;
#endif
}
//------------------------------------------------------------------------------
-(id)initWithDictionary:(NSDictionary*)dictionary{
  
    self = [super init];
    if (self != nil)
    {
        isMainLayer = false;
        NSString* uName = [dictionary stringForKey:@"UniqueName"];
        if(uName)
            uniqueName = [[NSString alloc] initWithString:uName];
        else {
            uniqueName = [[NSString alloc] initWithFormat:@"UntitledLayer_%d", untitledLayersCount];
            ++untitledLayersCount;
        }
                        
#if COCOS2D_VERSION >= 0x00020000
        self.zOrder = [dictionary intForKey:@"ZOrder"];
#else
        [self _setZOrder:[dictionary intForKey:@"ZOrder"]];
#endif
        
        [self setTag:[dictionary intForKey:@"Tag"]];
        
        NSArray* childrenInfo = [dictionary objectForKey:@"Children"];
        for(NSDictionary* childDict in childrenInfo){
            [self addChildFromDictionary:childDict];
        }
        
        [self loadUserCustomInfoFromDictionary:[dictionary objectForKey:@"CustomClassInfo"]];
    }
    return self;
}
//------------------------------------------------------------------------------
+(id)layerWithDictionary:(NSDictionary*)dictionary{
#ifndef LH_ARC_ENABLED
    return [[[self alloc] initWithDictionary:dictionary] autorelease];
#else
    return [[self alloc] initWithDictionary:dictionary];
#endif        
}
//------------------------------------------------------------------------------
-(void) removeSelf{
    [self removeFromParentAndCleanup:YES];
    parentLoader = nil;
}

-(LevelHelperLoader*)parentLoader{
    return parentLoader;
}

- (void)draw{
    
  //  NSLog(@"MAIN LAYER DRAW");
    [super draw];
    
    if(isMainLayer)
    {
        #ifdef LH_USE_BOX2D
        [[LHSettings sharedInstance] removeMarkedJoints];
        #endif
        
        [[LHSettings sharedInstance] removeMarkedSprites];
        [[LHSettings sharedInstance] removeMarkedBeziers];
    }
}
-(void)setParentLoader:(LevelHelperLoader*)p{
    parentLoader = p;
}
//------------------------------------------------------------------------------
-(void)addChildFromDictionary:(NSDictionary*)childDict
{
    if([[childDict stringForKey:@"NodeType"] isEqualToString:@"LHSprite"])
    {
        NSDictionary* texDict = [childDict objectForKey:@"TextureProperties"];
        int sprTag = [texDict intForKey:@"Tag"];
        
        Class spriteClass = [[LHCustomSpriteMgr sharedInstance] customSpriteClassForTag:(LevelHelper_TAG)sprTag];
        LHSprite* sprite = [spriteClass spriteWithDictionary:childDict];
        
        [self addChild:sprite];
        [sprite postInit];
    }
    else if([[childDict stringForKey:@"NodeType"] isEqualToString:@"LHBezier"])
    {
        LHBezier* bezier = [LHBezier bezierWithDictionary:childDict];
        [self addChild:bezier];
    }
    else if([[childDict stringForKey:@"NodeType"] isEqualToString:@"LHBatch"]){
        /*LHBatch* batch =*/ [LHBatch batchWithDictionary:childDict layer:self];
        //it adds self in the layer //this is needed for animations
        //we need to have the layer parent before creating the sprites
    }
    else if([[childDict stringForKey:@"NodeType"] isEqualToString:@"LHLayer"]){
        LHLayer* layer = [LHLayer layerWithDictionary:childDict];
        [self addChild:layer z:[layer zOrder]];
    }
}
-(id)userInfo{
    return userCustomInfo;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
-(LHLayer*)layerWithUniqueName:(NSString*)name{
    for(id layer in self.children){
        if([layer isKindOfClass:[LHLayer class]]){
            if([[(LHLayer*)layer uniqueName] isEqualToString:name])
                return layer;
        }
    }
    
    return nil;
}
//------------------------------------------------------------------------------
-(LHBatch*)batchWithUniqueName:(NSString*)name{
    for(id node in self.children){
        if([node isKindOfClass:[LHBatch class]]){
            if([[(LHBatch*)node uniqueName] isEqualToString:name])
                return node;
        }
        else if([node isKindOfClass:[LHLayer class]]){
            id child = [(LHLayer*)node batchWithUniqueName:name];
            if(child)
                return child;
        }
    }
    
    return nil;    
}
//------------------------------------------------------------------------------
-(LHSprite*)spriteWithUniqueName:(NSString*)name{

    for(id node in self.children){
        if([node isKindOfClass:[LHSprite class]])
        {
            if([[(LHSprite*)node uniqueName] isEqualToString:name])
                return node;
        }
        else if([node isKindOfClass:[LHBatch class]]){
            id child = [node spriteWithUniqueName:name];
            if(child)
                return child;
        }
        else if([node isKindOfClass:[LHLayer class]]){
            id child = [node spriteWithUniqueName:name];
            if(child)
                return child;
        }
    }
    
    return nil;    
}
//------------------------------------------------------------------------------
-(LHBezier*)bezierWithUniqueName:(NSString*)name{
    for(id node in self.children){
        if([node isKindOfClass:[LHBezier class]]){
            if([[node uniqueName] isEqualToString:name])
                return node;
        }
        else if([node isKindOfClass:[LHLayer class]]){
            id child = [node bezierWithUniqueName:name];
            if(child)
                return child;
        }
    }
    
    return nil;    
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
-(NSArray*)allLayers{
    NSMutableArray* array = [NSMutableArray array];
    
    for(id layer in self.children){
        if([layer isKindOfClass:[LHLayer class]]){
            [array addObject:layer];
        }
    }
    return array;
}
//------------------------------------------------------------------------------
-(NSArray*)allBatches{
    
    NSMutableArray* array = [NSMutableArray array];
    
    for(id node in self.children){
        if([node isKindOfClass:[LHBatch class]]){
            [array addObject:node];
        }
        else if([node isKindOfClass:[LHLayer class]]){
            [array addObjectsFromArray:[node allBatches]];
        }
    }
    
    return array;   
}
//------------------------------------------------------------------------------
-(NSArray*)allSprites{

    NSMutableArray* array = [NSMutableArray array];
    
    for(id node in self.children){
        
//NSLog(@"###### %@", [node description]);
        
        if([node isKindOfClass:[LHSprite class]]){
            [array addObject:node];
        }
        else if([node isKindOfClass:[LHBatch class]]){
            [array addObjectsFromArray:[(LHBatch*)node allSprites]];
        }
        else if([node isKindOfClass:[LHLayer class]]){
            [array addObjectsFromArray:[(LHLayer*)node allSprites]];
        }
    }
    return array;    
}
//------------------------------------------------------------------------------
-(NSArray*)allBeziers{

    NSMutableArray* array = [NSMutableArray array];
    
    for(id node in self.children){
        if([node isKindOfClass:[LHBezier class]]){
            [array addObject:node];
        }
        else if([node isKindOfClass:[LHLayer class]]){
            [array addObjectsFromArray:[(LHLayer*)node allBeziers]];
        }
    }
    
    return array;    
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
-(NSArray*)layersWithTag:(int)tag{
   
    NSMutableArray* array = [NSMutableArray array];
    
    for(id layer in self.children){
        if([layer isKindOfClass:[LHLayer class]]){
            if([(CCNode*)layer tag] == tag)
                [array addObject:layer];
        }
    }
    return array;
}
//------------------------------------------------------------------------------
-(NSArray*)batchesWithTag:(int)tag{
    NSMutableArray* array = [NSMutableArray array];
    
    for(id node in self.children){
        if([node isKindOfClass:[LHBatch class]]){
            if([(CCNode*)node tag] == tag)
                [array addObject:node];
        }
        else if([node isKindOfClass:[LHLayer class]]){
            [array addObjectsFromArray:[(LHLayer*)node batchesWithTag:tag]];
        }
    }
    
    return array;       
}
-(NSArray*)spritesWithTag:(int)tag{
    NSMutableArray* array = [NSMutableArray array];
    
    for(id node in self.children){
        if([node isKindOfClass:[LHSprite class]]){
            if([(CCNode*)node tag] == tag)
                [array addObject:node];
        }
        else if([node isKindOfClass:[LHBatch class]]){
            [array addObjectsFromArray:[(LHBatch*)node spritesWithTag:tag]];
        }
        else if([node isKindOfClass:[LHLayer class]]){
            [array addObjectsFromArray:[(LHLayer*)node spritesWithTag:tag]];
        }
    }
    return array;    
}
-(NSArray*)beziersWithTag:(int)tag{
    NSMutableArray* array = [NSMutableArray array];
    
    for(id node in self.children){
        if([node isKindOfClass:[LHBezier class]]){
            if([(CCNode*)node tag] == tag)
                [array addObject:node];
        }
        else if([node isKindOfClass:[LHLayer class]]){
            [array addObjectsFromArray:[(LHLayer*)node beziersWithTag:tag]];
        }
    }
    
    return array;     
}

@end
