//This header file was generated automatically by LevelHelper
//based on the class template defined by the user.
//For more info please visit: www.levelhelper.org


@interface QQLevelClass : NSObject
{


	float startImpulseX;
	float startImpulseY;
	float countdown;
	float gravity;


#if __has_feature(objc_arc) && __clang_major__ >= 3

#else


#endif // __has_feature(objc_arc)

}
@property float startImpulseX;
@property float startImpulseY;
@property float countdown;
@property float gravity;

+(QQLevelClass*) customClassInstance;

-(NSString*) className;

-(void) setPropertiesFromDictionary:(NSDictionary*)dictionary;

@end
