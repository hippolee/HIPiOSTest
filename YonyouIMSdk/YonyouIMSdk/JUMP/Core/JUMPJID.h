//
//  JUMPJID.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

enum JUMPJIDCompareOptions {
    JUMPJIDCompareUser     = 1, // 001
    JUMPJIDCompareDomain   = 2, // 010
    JUMPJIDCompareResource = 4, // 100
    JUMPJIDCompareBare     = 3, // 011
    JUMPJIDCompareFull     = 7, // 111
};
typedef enum JUMPJIDCompareOptions JUMPJIDCompareOptions;

@interface JUMPJID : NSObject<NSCoding, NSCopying> {
    __strong NSString *user;
    __strong NSString *domain;
    __strong NSString *resource;
}

+ (JUMPJID *)jidWithString:(NSString *)jidStr;
+ (JUMPJID *)jidWithString:(NSString *)jidStr resource:(NSString *)resource;
+ (JUMPJID *)jidWithUser:(NSString *)user domain:(NSString *)domain resource:(NSString *)resource;

@property (strong, readonly) NSString *user;
@property (strong, readonly) NSString *domain;
@property (strong, readonly) NSString *resource;

/**
 * Terminology (from RFC 6120):
 *
 * The term "bare JID" refers to an JUMP address of the form <localpart@domainpart> (for an account at a server)
 * or of the form <domainpart> (for a server).
 *
 * The term "full JID" refers to an JUMP address of the form
 * <localpart@domainpart/resourcepart> (for a particular authorized client or device associated with an account)
 * or of the form <domainpart/resourcepart> (for a particular resource or script associated with a server).
 *
 * Thus a bareJID is one that does not have a resource.
 * And a fullJID is one that does have a resource.
 *
 * For convenience, there are also methods that that check for a user component as well.
 **/

- (JUMPJID *)bareJID;
- (JUMPJID *)domainJID;

- (NSString *)bare;
- (NSString *)full;

- (BOOL)isBare;
- (BOOL)isBareWithUser;

- (BOOL)isFull;
- (BOOL)isFullWithUser;

/**
 * A server JID does not have a user component.
 **/
- (BOOL)isServer;

/**
 * Returns a new jid with the given resource.
 **/
- (JUMPJID *)jidWithNewResource:(NSString *)resource;

/**
 * When you know both objects are JIDs, this method is a faster way to check equality than isEqual:.
 **/
- (BOOL)isEqualToJID:(JUMPJID *)aJID;
- (BOOL)isEqualToJID:(JUMPJID *)aJID options:(JUMPJIDCompareOptions)mask;

@end