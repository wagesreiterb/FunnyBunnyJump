//
//  QQTime.m
//  Acrobat_g7003
//
//  Created by Que on 11.09.12.
//
//

#import "QQLabelTimer.h"

@implementation QQLabelTimer

-(void) dealloc{
	[super dealloc];
}

-(id) init {
    //wird das überhaupt benötigt?
    self = [super init];
    if (self != nil){

    }
    return self;
}

-(void)updateTime:(ccTime)dt {
    NSString *timeString = [NSString stringWithFormat:@"%2f", dt];
    [self setString:timeString];
}

-(void)startTimer {
    _interval = 0.1f;
    [self schedule: @selector(tick:) interval:_interval];
    _timer = 0;
    [self setColor:ccc3(0,0,255)];
    [self setPosition:CGPointMake(100, 300)];
}

-(void) tick: (ccTime) dt
{
    _timer += _interval;
    //NSLog(@"tick tick tick");
    NSString *timeString = [NSString stringWithFormat:@"%.1f", _timer];
    [self setString:timeString];
}

@end



//NSLog(@"here I am!");
//self = [CCLabelTTF labelWithString:@"Tap screen" fontName:@"Marker Felt" fontSize:32];
//[self setColor:ccc3(0,0,255)];
