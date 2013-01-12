//This source file was generated automatically by LevelHelper
//based on the class template defined by the user.
//For more info please visit: www.levelhelper.org


#import "QQLevelClass.h"

@implementation QQLevelClass


@synthesize gravity;


-(void) dealloc{
#if __has_feature(objc_arc) && __clang_major__ >= 3

#else


[super dealloc];

#endif // __has_feature(objc_arc)
}

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

	if([dictionary objectForKey:@"gravity"])
		[self setGravity:[[dictionary objectForKey:@"gravity"] floatValue]];

}

@end
