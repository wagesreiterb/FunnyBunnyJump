//This header file was generated automatically by LevelHelper
//based on the class template defined by the user.
//For more info please visit: www.levelhelper.org


@interface QQBalloonClass : NSObject
{


	float blinkInterval;
	float blinkDelay;
	float explodingEffect;
	float movingStartDelay;
	float blinkModulo;
	float scoreMultiplier;


#if __has_feature(objc_arc) && __clang_major__ >= 3

#else


#endif // __has_feature(objc_arc)

}
@property float blinkInterval;
@property float blinkDelay;
@property float explodingEffect;
@property float movingStartDelay;
@property float blinkModulo;
@property float scoreMultiplier;

+(QQBalloonClass*) customClassInstance;

-(NSString*) className;

-(void) setPropertiesFromDictionary:(NSDictionary*)dictionary;

@end
