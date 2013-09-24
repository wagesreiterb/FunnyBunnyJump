//
//  CCFBProfilePicture.h
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

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/**
 * A simple class to handle Facebook profile pictures in cocos2d.
 * Works like any other CCSprite.
 */
@interface CCFBProfilePicture : CCSprite
{
@private
    NSString *_fbid, *_accessToken;
}

/** The User's Facebook ID. */
@property (weak, readonly) NSString *fbid;
/**
 * (Optional) The Facebook access token you recieved if are logged in.
 * This will help prevent rate limiting if your App becomes popular
 * and makes many requests for pictures.
 */
@property (weak, readonly) NSString *accessToken;

/**
 * Creates a new CCFBProfilePicture.
 * The profile picture will begin downloading (or loading from the cache) immediatly.
 *
 * @param fbid The Facebook ID of the user.
 * @param accessToken (Optional) The Facebook accessToken you received with your login.  Helps prevent rate limiting.
 * @param content The size (in points) of the image to grab.  This will set the contentSize property of the sprite.
 * @param useCache If YES, this class will first try to find the profile image (keyed by id) in the local cache before downloading.
 * @param temp (Optional) The sprite frame to display while loading.  For best results it should be the same size as content.
 * @return The CCFBProfilePicture instance, which is downloading the profile image.
 */
+ (CCFBProfilePicture *)profilePictureWithId:(NSString *)fbid accessToken:(NSString *)accessToken contentSize:(CGSize)content cached:(BOOL)useCache placeholder:(CCSpriteFrame *)temp;

- (id)initWithId:(NSString *)fbid accessToken:(NSString *)accessToken contentSize:(CGSize)content cached:(BOOL)useCache placeholder:(CCSpriteFrame *)temp;

/**
 * Removes the image from the cache, and attempts to download a fresh copy of the profile picture.
 * If this fails, the old picture remains visible.
 */
- (void)refresh;

@end