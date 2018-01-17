//
//  YYIMExtDelegate.h
//  YonyouIMSdk
//
//  Created by litfb on 16/7/14.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYUserExt.h"
#import "YYChatGroupExt.h"
#import "YYPubAccountExt.h"
#import "YYIMError.h"

@protocol YYIMExtDelegate <NSObject>

@optional

- (void)didUserProfileUpdate:(NSDictionary *)userProfiles;

- (void)didNotLoadUserProfileWithError:(YYIMError *)error;

- (void)didUserExtUpdate:(YYUserExt *)userExt;

- (void)didPubAccountExtUpdate:(YYPubAccountExt *)accountExt;

- (void)didChatGroupExtUpdate:(YYChatGroupExt *)groupExt;

- (void)didNotUpdateUserNoDisturb:(NSString *)userId error:(YYIMError *)error;

- (void)didNotUpdateUserStickTop:(NSString *)userId error:(YYIMError *)error;

- (void)didNotUpdateGroupNoDisturb:(NSString *)groupId error:(YYIMError *)error;

- (void)didNotUpdateGroupStickTop:(NSString *)groupId error:(YYIMError *)error;

- (void)didNotUpdatePubAccountNoDisturb:(NSString *)accountId error:(YYIMError *)error;

- (void)didNotUpdatePubAccountStickTop:(NSString *)accountId error:(YYIMError *)error;

- (void)didNotSetUserProfileWithError:(YYIMError *)error;

- (void)didNotRemoveUserProfileWithError:(YYIMError *)error;

- (void)didNotClearUserProfileWithError:(YYIMError *)error;

@end
