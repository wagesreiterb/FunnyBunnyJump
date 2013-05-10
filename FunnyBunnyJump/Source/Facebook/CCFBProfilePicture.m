//
//  CCFBProfilePicture.m
//  Cocos Facebook Profile Pictures
//
//  NOTE: This library is ARC enabled.
//
//  Created by Paul Moore on 2013-01-25.
/*
 Copyright (c) 2013 Paul Moore
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "CCFBProfilePicture.h"

@implementation CCFBProfilePicture

+ (CCFBProfilePicture *)profilePictureWithId:(NSString *)fbid accessToken:(NSString *)accessToken contentSize:(CGSize)content cached:(BOOL)useCache placeholder:(CCSpriteFrame *)temp
{
    return [[self alloc] initWithId:fbid accessToken:accessToken contentSize:content cached:useCache placeholder:temp];
}

- (id)initWithId:(NSString *)fbid accessToken:(NSString *)accessToken contentSize:(CGSize)content cached:(BOOL)useCache placeholder:(CCSpriteFrame *)temp
{
    if ((self = [super init])) {
        NSAssert(fbid, @"Facebook ID cannot be nil");
        _fbid = [fbid copy];
        _accessToken = [accessToken copy];
        self.contentSize = content;
        if (useCache && [[CCTextureCache sharedTextureCache] textureForKey:[self path]]) {
            [self updateDisplayFrameSync];
        } else {
            if (temp) {
                self.displayFrame = temp;
            }
            [self performSelectorInBackground:@selector(downloadFileAsync) withObject:nil];
        }
    }
    return self;
}

- (void)downloadFileAsync
{
    NSUInteger width = CC_CONTENT_SCALE_FACTOR() * self.contentSize.width;
    NSUInteger height = CC_CONTENT_SCALE_FACTOR() * self.contentSize.height;
    NSString *token = @"";
    if (_accessToken) {
        token = [NSString stringWithFormat:@"access_token=%@&", _accessToken];
    }
    NSString *https = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?%@width=%i&height=%i", _fbid, token, width, height];
    NSURL *url = [NSURL URLWithString:https];
    NSAssert(url, @"URL is malformed: %@", https);
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    if (data && !error) {
        [data writeToFile:[self path] options:NSDataWritingAtomic error:&error];
        if (!error) {
            [self performSelector:@selector(updateDisplayFrameSync) onThread:[[CCDirector sharedDirector] runningThread] withObject:nil waitUntilDone:NO];
        } else {
            CCLOG(@"[%@ %@] Could not save downloaded file: %@", [self class], NSStringFromSelector(_cmd), error);
        }
    } else {
        CCLOG(@"[%@ %@] Could not download file: %@", [self class], NSStringFromSelector(_cmd), error);
    }
}

- (void)updateDisplayFrameSync
{
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:[self path]];
    CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
    self.displayFrame = frame;
}

- (void)refresh
{
    [[NSFileManager defaultManager] removeItemAtPath:[self path] error:NULL];
    [self performSelectorInBackground:@selector(downloadFileAsync) withObject:nil];
}

- (NSString *)path
{
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[_fbid stringByAppendingString:@".jpg"]];
}

- (NSString *)fbid
{
    return _fbid;
}

- (NSString *)accessToken
{
    return _accessToken;
}

@end