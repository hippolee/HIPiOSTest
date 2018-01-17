//
//  YYIMChatGroupMemberDBHelper.h
//  YonyouIMSdk
//
//  Created by litfb on 15/5/25.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMBaseDBHelper.h"
#import "YYChatGroupMember.h"

@interface YYIMChatGroupMemberDBHelper : YYIMBaseDBHelper

+ (instancetype) sharedInstance;

#pragma mark member

- (NSArray *)getChatGroupMembersWithGroupId:(NSString *)groupId;

- (NSArray *)getChatGroupMembersWithGroupId:(NSString *)groupId limit:(NSInteger)limit;

- (void)batchUpdateChatGroupMember:(NSString *)groupId members:(NSArray *)memberArray;

- (void)deleteChatGroupMembers:(NSString *)groupId;

- (YYChatGroupMember *)getChatGroupMemberWithGroupId:(NSString *)groupId memberId:(NSString *)memberId;

- (void)updateChatGroupMember:(NSString *)groupId members:(NSArray *)memberArray;

@end
