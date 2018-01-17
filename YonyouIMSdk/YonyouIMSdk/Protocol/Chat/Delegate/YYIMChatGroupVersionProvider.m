//
//  YYIMChatGroupVersionProvider.m
//  YonyouIMSdk
//
//  Created by litfb on 15/12/25.
//  Copyright © 2015年 yonyou. All rights reserved.
//

#import "YYIMChatGroupVersionProvider.h"
#import "JUMPFramework.h"
#import "YYIMDBHelper.h"
#import "YYIMJUMPHelper.h"
#import "YYIMLogger.h"
#import "YYIMConfig.h"
#import "YYIMChatGroupMemberDBHelper.h"

@implementation YYIMChatGroupVersionProvider

- (void)loadChatGroupAndMembers {
    NSString *packetID = [JUMPStream generateJUMPID];
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPMUCVersionItemsRequestPacketOpCode) packetID:packetID];
    
    NSNumber *versionNumber = [[YYIMConfig sharedInstance] getChatGroupVersionNumber];
    [iq setObject:versionNumber forKey:@"ts"];
    
    [[self tracker] addPacket:iq
                       target:self
                     selector:@selector(handleLoadChatGroupResponse:withInfo:)
                      timeout:30];
    
    [self.activeStream sendPacket:iq];
}

- (void)handleLoadChatGroupResponse:(JUMPPacket *)jumpPacket withInfo:(id <JUMPTrackingInfo>)info {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPMUCVersionItemsResultPacketOpCode)]) {
        YYIMError *error;
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        YYIMLogError(@"didNotLoadChatGroup:%ld-%@", (long)[error errorCode], [error errorMsg]);
        [[self activeDelegate] didNotLoadChatGroupWithError:error];
        return;
    }
    
    JUMPIQ *iq = (JUMPIQ *)jumpPacket;
    NSArray *items = [iq objectForKey:@"roomItems"];
    // 遍历群组
    NSMutableArray *chatGroupArray = [NSMutableArray array];
    for (NSDictionary *item in items) {
        YYChatGroup *group = [[YYChatGroup alloc] init];
        [group setGroupId:[YYIMJUMPHelper parseUser:[item objectForKey:@"jid"]]];
        [group setGroupName:[item objectForKey:@"name"]];
        [group setGroupTag:[item objectForKey:@"tag"]];
        [group setIsCollect:[[item objectForKey:@"collected"] integerValue] == 1];
        [group setIsSuper:[[item objectForKey:@"superLarge"] integerValue] == 1];
        [group setMemberCount:[[item objectForKey:@"numberOfMembers"] integerValue]];
        [group setTs:[[item objectForKey:@"ts"] longLongValue]];
        
        // members
        NSArray *members = [item objectForKey:@"members"];
        BOOL isOwner = NO;
        for (NSDictionary *mitem in members) {
            NSString *mid = [YYIMJUMPHelper parseUser:[mitem objectForKey:@"jid"]];
            NSString *memberRole = [mitem objectForKey:@"affiliation"];
            if ([mid isEqualToString:[[YYIMConfig sharedInstance] getUser]] && [memberRole isEqualToString:@"owner"]) {
                isOwner = YES;
                break;
            }
        }
        [group setIsOwner:isOwner];
        [chatGroupArray addObject:group];
    }
    
    // 收藏的群组集合
    NSArray *collectedRoomNames = [iq objectForKey:@"collectedRoomNames"];
    NSMutableArray *collectedGroupIds = [NSMutableArray arrayWithCapacity:[collectedRoomNames count]];
    for (NSString *roomName in collectedRoomNames) {
        [collectedGroupIds addObject:[YYIMJUMPHelper parseUser:roomName]];
    }
    
    // 所有群组ID集合
    NSArray *roomNames = [iq objectForKey:@"roomNames"];
    NSMutableArray *groupIds = [NSMutableArray arrayWithCapacity:[roomNames count]];
    for (NSString *roomName in roomNames) {
        [groupIds addObject:[YYIMJUMPHelper parseUser:roomName]];
    }
    
    // 更新数据库
    [[YYIMDBHelper sharedInstance] batchUpdateChatGroup:chatGroupArray allGroups:groupIds collectedGroups:collectedGroupIds];
    
    // 群组成员
    for (NSDictionary *item in items) {
        // groupId
        NSString *groupId = [YYIMJUMPHelper parseUser:[item objectForKey:@"jid"]];
        // members
        NSArray *members = [item objectForKey:@"members"];
        // memberArray
        NSMutableArray *memberArray = [NSMutableArray array];
        NSMutableArray *memberIdArray = [NSMutableArray array];
        for (NSDictionary *mitem in members) {
            NSString *mid = [YYIMJUMPHelper parseUser:[mitem objectForKey:@"jid"]];
            if ([memberIdArray containsObject:mid]) {
                continue;
            }
            [memberIdArray addObject:mid];
            YYChatGroupMember *member = [[YYChatGroupMember alloc] init];
            [member setMemberId:mid];
            [member setMemberName:[mitem objectForKey:@"name"]];
            [member setMemberPhoto:[mitem objectForKey:@"photo"]];
            [member setMemberRole:[mitem objectForKey:@"affiliation"]];
            [memberArray addObject:member];
        }
        // 更新数据库
        [[YYIMChatGroupMemberDBHelper sharedInstance] batchUpdateChatGroupMember:groupId members:memberArray];
        [[self activeDelegate] didChatGroupMemberUpdate:groupId];
    }
    
    // 群组版本号
    NSNumber *versionNumber = [iq objectForKey:@"ts"];
    [[YYIMConfig sharedInstance] setChatGroupVersionNumber:versionNumber];
    
    [self loadMUCOfflineMessage];
}

@end
