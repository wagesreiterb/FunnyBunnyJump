//
//  GCDatabase.m
//  FunnyBunnyJump
//
//  Created by Que on 28.10.12.
//
//


#import "GCDatabase.h"

/*
NSString *pathForFile(NSString *filename) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:filename];
}
 */


NSString *pathForFile(NSString *filename) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:filename];
}


id loadData(NSString * filename) {
    NSString *filePath = pathForFile(filename);
    NSLog(@"load: filePath: %@", filePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [[[NSData alloc]
                         initWithContentsOfFile:filePath] autorelease];
        NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc]
                                          initForReadingWithData:data] autorelease];
        id retval = [unarchiver decodeObjectForKey:@"Data"];
        [unarchiver finishDecoding];
        return retval;
    }
    else {
        NSLog(@"loadData::kein file - fotze");
    }
    
    return nil;
}

void saveData(id theData, NSString *filename) {
    NSLog(@"---saveData");
    NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
    NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archiver encodeObject:theData forKey:@"Data"];
    [archiver finishEncoding];
    
    //BOOL retVal = [data writeToFile:pathForFile(filename) atomically:YES];
    BOOL retVal = [data writeToFile:pathForFile(filename) atomically:YES];
    
    NSLog(@"save: filePath: %@", pathForFile(filename));
    NSLog(@"%i", retVal);
    BOOL yes = YES;
    BOOL no = NO;
    NSLog(@"YES: %i, NO: %i", yes = YES, no = NO);
}

//@implementation GCDatabase
//@end


/*
 
 id loadData(NSString *filename) {
 NSString *filePath = pathForFile(filename);
 if([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
 NSLog(@"loadData::file sollte existieren");
 NSData *data = [[[NSData alloc] initWithContentsOfFile:filePath] autorelease];
 NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc]
 initForReadingWithData:data] autorelease];
 id retval = [unarchiver decodeObjectForKey:@"Data"];
 [unarchiver finishDecoding];
 return retval;
 } else {
 NSLog(@"loadData::kein file - fotze");
 }
 
 return nil;
 }
 
 */

/*
 void saveData(id theData, NSString *filename) {
 // 9
 NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
 // 10
 NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc]
 initForWritingWithMutableData:data] autorelease];
 // 11
 [archiver encodeObject:theData forKey:@"Data"];
 [archiver finishEncoding];
 // 12
 [data writeToFile:pathForFile(filename) atomically:YES];
 }
 */
