//
//  GameState.m
//  FunnyBunnyJump
//
//  Created by Que on 28.10.12.
//
//

#import "GameState.h"
#import "GCDatabase.h"

@implementation GameState


@synthesize completedSeasonSpring2012;
@synthesize completedSeasonSummer2012;
@synthesize completedSeasonFall2012;
@synthesize completedSeasonWinter2012;

@synthesize highScore;
@synthesize tempHighScore;

static GameState *sharedInstance = nil;

+(GameState*)sharedInstance {
    @synchronized([GameState class]) {
        if(!sharedInstance) {
            sharedInstance = [loadData(@"GameState") retain];
            if(!sharedInstance) {
                [[self alloc] init];
            }
        }
        return sharedInstance;
    }    
    return nil;
}

+(id)alloc {
    @synchronized([GameState class]) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a \
                 second instance of the GameState singleton");
        sharedInstance = [super alloc];
        return sharedInstance;
    }
}

-(void)save {
    saveData(self, @"GameState");
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    //WRITE
    [encoder encodeBool:completedSeasonSpring2012 forKey:@"CompletedSeasonSpring2012"];
    [encoder encodeBool:completedSeasonSummer2012 forKey:@"CompletedSeasonSummer2012"];
    [encoder encodeBool:completedSeasonFall2012 forKey:@"CompletedSeasonFall2012"];
    [encoder encodeBool:completedSeasonWinter2012 forKey:@"CompletedSeasonWinter2012"];
    
    NSLog(@"--- WRITE BEGIN");   
    
    highScore = [NSDictionary dictionaryWithDictionary:tempHighScore];
    [encoder encodeObject:highScore forKey:@"highScore"];
    NSLog(@"---READ tempHighScore retainCount %d", [tempHighScore retainCount]);
}

-(id)initWithCoder:(NSCoder *)decoder {
    //READ
    NSLog(@"---READ BEGIN");
    if((self = [super init])) {
        completedSeasonSpring2012 = [decoder decodeBoolForKey:@"CompletedSeasonSpring2012"];
        completedSeasonSummer2012 = [decoder decodeBoolForKey:@"CompletedSeasonSummer2012"];
        completedSeasonFall2012 = [decoder decodeBoolForKey:@"CompletedSeasonFall2012"];
        completedSeasonWinter2012 = [decoder decodeBoolForKey:@"CompletedSeasonWinter2012"];
        
        highScore = [decoder decodeObjectForKey:@"highScore"];
        //[highScore retain];
        if(tempHighScore == nil) {
            tempHighScore = [NSMutableDictionary dictionaryWithDictionary:highScore];
            [tempHighScore retain];
            NSLog(@"---READ tempHighScore %@", tempHighScore);
            NSLog(@"---READ tempHighScore retainCount %d", [tempHighScore retainCount]);
        }
    }
    return self;
}

-(void)dealloc {
    [tempHighScore release];
    [super dealloc];
}

@end
