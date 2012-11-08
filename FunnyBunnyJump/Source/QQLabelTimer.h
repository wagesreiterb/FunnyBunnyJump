//
//  QQTime.h
//  Acrobat_g7003
//
//  Created by Que on 11.09.12.
//
//

#import <Foundation/Foundation.h>
#import "CCLabelTTF.h"
#import "CCLayer.h"

@interface QQLabelTimer : CCLabelTTF {
    CCLabelTTF *label;
    ccTime _timer;
    ccTime _interval;
}


-(void) dealloc;
-(id) init;
-(void)startTimer;

@end
