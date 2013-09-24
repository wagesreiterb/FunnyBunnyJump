//This source file was generated automatically by LevelHelper
//based on the class template defined by the user.
//For more info please visit: www.levelhelper.org


#import "QQLevelClass.h"

@implementation QQLevelClass


@synthesize startImpulseX;
@synthesize startImpulseY;
@synthesize countdown;
@synthesize gravity;



+(QQLevelClass*) customClassInstance{
#if __has_feature(objc_arc) && __clang_major__ >= 3
return [[QQLevelClass alloc] init];
#else
return [[[QQLevelClass alloc] init] autorelease];
#endif
}

-(NSString*) className{
return NSStringFromClass([self class]);
}
-(void) setPropertiesFromDictionary:(NSDictionary*)dictionary
{

	if([dictionary objectForKey:@"startImpulseX"])
		[self setStartImpulseX:[[dictionary objectForKey:@"startImpulseX"] floatValue]];

	if([dictionary objectForKey:@"startImpulseY"])
		[self setStartImpulseY:[[dictionary objectForKey:@"startImpulseY"] floatValue]];

	if([dictionary objectForKey:@"countdown"])
		[self setCountdown:[[dictionary objectForKey:@"countdown"] floatValue]];

	if([dictionary objectForKey:@"gravity"])
		[self setGravity:[[dictionary objectForKey:@"gravity"] floatValue]];

}

@end
