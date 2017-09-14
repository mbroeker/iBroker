//
//  KeychainWrapper.h
//  imported into iBroker
//
//  Created by Chris Lowe on 10/31/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainWrapper : NSObject

+ (NSData *)searchKeychainCopyMatchingIdentifier:(NSString *)identifier;
+ (NSString *)keychainStringFromMatchingIdentifier:(NSString *)identifier;
+ (BOOL)createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;
+ (BOOL)updateKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;
+ (void)deleteItemFromKeychainWithIdentifier:(NSString *)identifier;
+ (NSDictionary*)keychain2ApiKeyAndSecret:(NSString*)identifier;
@end
