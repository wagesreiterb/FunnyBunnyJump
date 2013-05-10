//
//  NSData+LHAES256.mm
//  LevelHelper API
//
//  Created by Rabih on 7/5/11.
//  Modified by Vladu Bogdan for LevelHelper usage
//

#import "NSData+LHAES256.h"
#import <CommonCrypto/CommonCryptor.h>

#if __has_feature(objc_arc) && __clang_major__ >= 3
#define LH_ARC_ENABLED 1
#endif // __has_feature(objc_arc)


// Key size is 32 bytes for AES256
#define kKeySize kCCKeySizeAES256

@implementation NSData (AES256)

- (NSData*)makeCryptedVersionWithKeyData:(const void*)keyData ofLength:(int)keyLength decrypt:(bool)decrypt {
	// Copy the key data, padding with zeroes if needed
	char key[kKeySize];
	bzero(key, sizeof(key));
	memcpy(key, keyData, keyLength > kKeySize ? kKeySize : keyLength);
    
	size_t bufferSize = [self length] + kCCBlockSizeAES128;
	void* buffer = malloc(bufferSize);
    
	size_t dataUsed;
    
	CCCryptorStatus status = CCCrypt(decrypt ? kCCDecrypt : kCCEncrypt,
									 kCCAlgorithmAES128,
									 kCCOptionPKCS7Padding,
									 key, kKeySize,
									 NULL,
									 [self bytes], [self length],
									 buffer, bufferSize,
									 &dataUsed);
    
	switch(status) {
		case kCCSuccess:
			return [NSData dataWithBytesNoCopy:buffer length:dataUsed];
		case kCCParamError:
			NSLog(@"Error: NSData+AES256: Could not %s data: Param error", decrypt ? "decrypt" : "encrypt");
			break;
		case kCCBufferTooSmall:
			NSLog(@"Error: NSData+AES256: Could not %s data: Buffer too small", decrypt ? "decrypt" : "encrypt");
			break;
		case kCCMemoryFailure:
			NSLog(@"Error: NSData+AES256: Could not %s data: Memory failure", decrypt ? "decrypt" : "encrypt");
			break;
		case kCCAlignmentError:
			NSLog(@"Error: NSData+AES256: Could not %s data: Alignment error", decrypt ? "decrypt" : "encrypt");
			break;
		case kCCDecodeError:
			NSLog(@"Error: NSData+AES256: Could not %s data: Decode error", decrypt ? "decrypt" : "encrypt");
			break;
		case kCCUnimplemented:
			NSLog(@"Error: NSData+AES256: Could not %s data: Unimplemented", decrypt ? "decrypt" : "encrypt");
			break;
		default:
			NSLog(@"Error: NSData+AES256: Could not %s data: Unknown error", decrypt ? "decrypt" : "encrypt");
	}
    
	free(buffer);
	return nil;
}

- (NSData*)encryptedWithKey:(NSData*)key {
	return [self makeCryptedVersionWithKeyData:[key bytes] ofLength:[key length] decrypt:NO];
}

- (NSData*)decryptedWithKey:(NSData*)key {
	return [self makeCryptedVersionWithKeyData:[key bytes] ofLength:[key length] decrypt:YES];
}


+ (id)dataWithContentsOfEncryptedFile:(NSString *)path withKey:(NSData *)key {
#ifndef LH_ARC_ENABLED
    return [[[self alloc] initWithContentsOfEncryptedFile:path withKey:key] autorelease];
#else
    return [[self alloc] initWithContentsOfEncryptedFile:path withKey:key];
#endif
}

- (id)initWithContentsOfEncryptedFile:(NSString *)path withKey:(NSData *)key {
    NSData *encryptedData = [[NSData alloc] initWithContentsOfFile:path];
    if (!encryptedData) return nil;
#ifndef LH_ARC_ENABLED
    self = [[encryptedData decryptedWithKey:key] retain];
    [encryptedData release];
#else
    self = [encryptedData decryptedWithKey:key];
    encryptedData = nil;
#endif
    return self;
}

@end
