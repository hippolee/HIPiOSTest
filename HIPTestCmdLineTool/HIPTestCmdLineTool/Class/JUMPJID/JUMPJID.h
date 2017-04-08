//
//  JUMPJID.h
//  YonyouIMFramework
//
//  Created by litfb on 2017/3/28.
//  Copyright © 2017年 Yonyou Network. All rights reserved.
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

@interface JUMPJID : NSObject<NSCoding, NSCopying>


/**
 Generate a JUMPJID from string expression
 JidString format:user@domain/resource
 
 @param jidStr String expression of a JUMPJID
 @return JUMPJID
 */
+ (JUMPJID *)jidWithString:(NSString *)jidStr;

/**
 Generate JUMPJID from string expression and resource
 JidString format:user@domain/resource
 
 @param jidStr String expression of a JUMPJID
 @param resource Resource of a JUMPJID
 @return JUMPJID
 */
+ (JUMPJID *)jidWithString:(NSString *)jidStr resource:(NSString *)resource;


/**
 Generate JUMPJID from user,domain,resource

 @param user User of a JUMPJID
 @param domain Domain of a JUMPJID
 @param resource Resource of a JUMPJID
 @return JUMPJID
 */
+ (JUMPJID *)jidWithUser:(NSString *)user domain:(NSString *)domain resource:(NSString *)resource;


/**
 User part of JUMPJID
 */
@property (strong, readonly) NSString *user;

/**
 Domain part of JUMPJID
 */
@property (strong, readonly) NSString *domain;

/**
 Resource part of JUMPJID
 */
@property (strong, readonly) NSString *resource;

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
