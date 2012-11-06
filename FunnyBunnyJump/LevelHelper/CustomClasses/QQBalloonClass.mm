//This source file was generated automatically by LevelHelper
//based on the class template defined by the user.
//For more info please visit: www.levelhelper.org


#import "QQBalloonClass.h"

@implementation QQBalloonClass


@synthesize score;
@synthesize movingStartDelay;


-(void) dealloc{
#if __has_feature(objc_arc) && __clang_major__ >= 3

#else


[super dealloc];

#endif // __has_feature(objc_arc)
}

+(QQBalloonClass*) customClassInstance{
#if __has_feature(objc_arc) && __clang_major__ >= 3
return [[QQBalloonClass alloc] init];
#else
return [[[QQBalloonClass alloc] init] autorelease];
#endif
}

-(NSString*) className{
return NSStringFromClass([self class]);
}
-(void) setPropertiesFromDictionary:(NSDictionary*)dictionary
{

	if([dictionary objectForKey:@"score"])
		[self setScore:[[dictionary objectForKey:@"score"] floatValue]];

	if([dictionary objectForKey:@"movingStartDelay"])
		[self setMovingStartDelay:[[dictionary objectForKey:@"movingStartDelay"] floatValue]];

}

@end
