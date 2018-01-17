//
//  YYIMChatGroupProvider.m
//  YonyouIM
//
//  Created by litfb on 15/1/21.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMChatGroupProvider.h"

#import "JUMPFramework.h"
#import "YYIMDBHelper.h"
#import "YYIMJUMPHelper.h"
#import "YYIMConfig.h"
#import "YYIMStringUtility.h"
#import "YYIMChat.h"
#import "YYIMChatGroupMemberDBHelper.h"
#import "YYIMLogger.h"
#import "YMAFNetworking.h"
#import "YYChatGroupInfo.h"

@interface YYIMChatGroupProvider ()<JUMPStreamDelegate>

@end

@implementation YYIMChatGroupProvider

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)loadChatGroupAndMembers {
    NSString *packetID = [JUMPStream generateJUMPID];
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPMUCItemsRequestPacketOpCode) packetID:packetID];
    
    [[self tracker] addPacket:iq
                       target:self
                     selector:@selector(handleLoadChatGroupResponse:withInfo:)
                      timeout:30];
    
    [self.activeStream sendPacket:iq];
}

- (NSString *)createChatGroupWithName:(NSString *)groupName user:(NSArray *)userIdArray {
    return [self createChatGroupWithName:groupName user:userIdArray maxUsers:200];
}

- (NSString *)createChatGroupWithName:(NSString *)groupName user:(NSArray *)userIdArray maxUsers:(NSUInteger)maxUsers {
    // groupName
    if ([YYIMStringUtility isEmpty:groupName]) {
        return nil;
    }
    
    // invitees
    NSMutableSet *userIdSet = [NSMutableSet set];
    for (NSString *userId in userIdArray) {
        if ([YYIMStringUtility isEmpty:userId]) {
            continue;
        }
        [userIdSet addObject:[userId lowercaseString]];
    }
    if (userIdSet.count <= 0) {
        return nil;
    }
    
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPMUCCreatePacketOpCode) packetID:packetID];
    [iq setObject:[userIdSet allObjects] forKey:@"invitees"];
    [iq setObject:groupName forKey:@"naturalLanguageName"];
    if (maxUsers > 0) {
        [iq setObject:[NSNumber numberWithInteger:maxUsers] forKey:@"maxUsers"];
    }
    
    [[self tracker] addPacket:iq
                       target:self
                     selector:@selector(handleGroupCreateResponse:withInfo:)
                      timeout:30];
    
    [[self activeStream] sendPacket:iq];
    return packetID;
}

- (void)inviteRosterIntoChatGroup:(NSString *)groupId user:(NSArray *)userIdArray {
    // groupId
    if ([YYIMStringUtility isEmpty:groupId]) {
        return;
    }
    
    // invitees
    NSMutableSet *userIdSet = [NSMutableSet set];
    for (NSString *userId in userIdArray) {
        if ([YYIMStringUtility isEmpty:userId]) {
            continue;
        }
        [userIdSet addObject:[userId lowercaseString]];
    }
    if (userIdSet.count <= 0) {
        return;
    }
    
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPMUCInvitePacketOpCode) packetID:packetID];
    [iq setTo:[YYIMJUMPHelper genFullGroupJid:groupId]];
    [iq setObject:[userIdSet allObjects] forKey:@"invitees"];
    
    [[self tracker] addPacket:iq
                       target:self
                     selector:@selector(handleInviteRosterIntoChatGroupResponse:withInfo:)
                      timeout:30];
    
    [[self activeStream] sendPacket:iq];
}

- (YYChatGroup *)getChatGroupWithGroupId:(NSString *)groupId {
    return [[YYIMDBHelper sharedInstance] getChatGroupWithId:groupId];
}

- (NSArray *)getAllChatGroups {
    return [[YYIMDBHelper sharedInstance] getAllGroup];
}

- (NSArray *)getGroupMembersWithGroupId:(NSString *)groupId {
    NSArray *array = [[YYIMChatGroupMemberDBHelper sharedInstance] getChatGroupMembersWithGroupId:groupId];
    for (YYChatGroupMember *member in array) {
        [member setUser:[[YYIMChat sharedInstance].chatManager getUserWithId:[member memberId]]];
    }
    return array;
}

- (NSArray *)getGroupMembersWithGroupId:(NSString *)groupId limit:(NSInteger)limit {
    NSArray *array = [[YYIMChatGroupMemberDBHelper sharedInstance] getChatGroupMembersWithGroupId:groupId limit:limit];
    for (YYChatGroupMember *member in array) {
        [member setUser:[[YYIMChat sharedInstance].chatManager getUserWithId:[member memberId]]];
    }
    return array;
}

- (void)getGroupMembersWithGroupId:(NSString *)groupId  complete:(void (^)(BOOL, NSArray *, YYIMError *))complete {
    [self getGroupMembersWithGroupId:groupId joinDate:0 complete:complete];
}

- (void)getGroupMembersWithGroupId:(NSString *)groupId joinDate:(NSTimeInterval)joinDate complete:(void (^)(BOOL, NSArray *, YYIMError *))complete {
    // 用户ID
    NSString *user = [[YYIMConfig sharedInstance] getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        complete(NO, nil, [YYIMError errorWithCode:YMERROR_CODE_UNEXPECT_STATE errorMessage:@"userId not found"]);
        return;
    }
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:[token tokenStr] forKey:@"token"];
            
            if (joinDate && joinDate != 0) {
                [params setObject:[NSNumber numberWithInteger:joinDate * 1000] forKey:@"ts"];
            }
            
            NSString *urlString = [[YYIMConfig sharedInstance] getChatGroupMembersServlet:groupId];
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            [manager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                NSArray *items = [dic objectForKey:@"list"];
                
                NSMutableArray *memberArray = [NSMutableArray array];
                for (NSDictionary *item in items) {
                    NSString *memberId = [YYIMJUMPHelper parseUser:[item objectForKey:@"jid"]];
                    NSString *memberRole = [item objectForKey:@"affiliation"];
                    
                    YYChatGroupMember *member = [[YYChatGroupMember alloc] init];
                    [member setMemberId:memberId];
                    [member setMemberName:[item objectForKey:@"name"]];
                    [member setMemberPhoto:[item objectForKey:@"photo"]];
                    [member setMemberRole:memberRole];
                    [member setUser:[[YYIMChat sharedInstance].chatManager getUserWithId:[member memberId]]];
                    
                    [memberArray addObject:member];
                }
                complete(YES, memberArray, nil);
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                YYIMLogError(@"获取群成员列表失败：%@", error.localizedDescription);
                complete(NO, nil, [YYIMError errorWithNSError:error]);
            }];
        } else {
            complete(NO, nil, tokenError);
        }
    }];
}

- (BOOL)isGroupOwner:(NSString *)groupId {
    YYChatGroup *group = [[YYIMDBHelper sharedInstance] getChatGroupWithId:groupId];
    return [group isOwner];
}

- (void)leaveChatGroup:(NSString *)groupId {
    // groupId
    if ([YYIMStringUtility isEmpty:groupId]) {
        return;
    }
    
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPMUCMemberExitPacketOpCode) packetID:[JUMPStream generateJUMPID]];
    [iq setTo:[YYIMJUMPHelper genFullGroupJid:groupId]];
    
    [[self tracker] addPacket:iq
                       target:self
                     selector:@selector(handleGroupLeaveResponse:withInfo:)
                      timeout:30];
    
    [[self activeStream] sendPacket:iq];
}

- (void)renameChatGroup:(NSString *)groupId name:(NSString *)groupName {
    // groupId
    if ([YYIMStringUtility isEmpty:groupId]) {
        return;
    }
    
    // groupName
    if ([YYIMStringUtility isEmpty:groupName]) {
        return;
    }
    
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPMUCInfoModifyPacketOpCode) packetID:packetID];
    [iq setTo:[YYIMJUMPHelper genFullGroupJid:groupId]];
    [iq setObject:groupName forKey:@"naturalLanguageName"];
    [[self activeStream] sendPacket:iq];
}

- (void)kickGroupMemberFromGroup:(NSString *)groupId member:(NSString *)memberId {
    // groupId
    if ([YYIMStringUtility isEmpty:groupId]) {
        return;
    }
    
    // memberId
    if ([YYIMStringUtility isEmpty:memberId]) {
        return;
    }
    
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPMUCKickOutMemberPacketOpCode) packetID:packetID];
    [iq setTo:[YYIMJUMPHelper genFullGroupJid:groupId]];
    [iq setObject:memberId forKey:@"member"];
    
    [[self tracker] addPacket:iq
                       target:self
                     selector:@selector(handleKickGroupMemberFromGroupResponse:withInfo:)
                      timeout:30];
    
    [[self activeStream] sendPacket:iq];
}

/**
 *  更换管理员
 *
 *  @param groupId  群组id
 *  @param memberId 新的管理员
 */
- (void)changeChatGroupAdminForGroup:(NSString *)groupId to:(NSString *)memberId {
    // groupId
    if ([YYIMStringUtility isEmpty:groupId]) {
        return;
    }
    
    // memberId
    if ([YYIMStringUtility isEmpty:memberId]) {
        return;
    }
    
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPMUCRoleConversionPacketOpCode) packetID:packetID];
    [iq setTo:[YYIMJUMPHelper genFullGroupJid:groupId]];
    [iq setObject:memberId forKey:@"newOwner"];
    
    [[self tracker] addPacket:iq
                       target:self
                     selector:@selector(handleGroupChangeAdmin:withInfo:)
                      timeout:30];
    
    [[self activeStream] sendPacket:iq];
}

- (void)searchChatGroupWithKeyword:(NSString *)keyword {
    if (!keyword) {
        [[self activeDelegate] didReceiveChatGroupSearchResult:nil];
    }
    // JUMPIQ
    NSString *packetId = [JUMPStream generateJUMPID];
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPMUCSearchRequestPacketOpCode) packetID:packetId];
    [iq setObject:[NSNumber numberWithInt:0] forKey:@"start"];
    [iq setObject:[NSNumber numberWithInt:20] forKey:@"size"];
    [iq setObject:keyword forKey:@"search"];
    
    [[self tracker] addID:packetId
                   target:self
                 selector:@selector(handleSearchChatGroupResponse:withInfo:)
                  timeout:30];
    // 发包
    [[self activeStream] sendPacket:iq];
}

- (void)joinChatGroup:(NSString *)groupId {
    // groupId
    if ([YYIMStringUtility isEmpty:groupId]) {
        return;
    }
    
    NSString *packetId = [JUMPStream generateJUMPID];
    JUMPJID *jid = [YYIMJUMPHelper genFullGroupJid:groupId];
    jid = [jid jidWithNewResource:[[YYIMConfig sharedInstance] getFullUser]];
    JUMPPresence *presence = [JUMPPresence presenceWithOpData:JUMP_OPDATA(JUMPPresenceMUCPacketOpCode) type:nil to:jid];
    [presence setPacketID:packetId];
    
    [[self tracker] addPacket:presence
                       target:self
                     selector:@selector(handleJoinChatGroupResponse:withInfo:)
                      timeout:30];
    
    [[self activeStream] sendPacket:presence];
}

- (NSArray *)getCollectChatGroups {
    return [[YYIMDBHelper sharedInstance] getAllCollectGroup];
}

//opcode: 0x2537
//{
//    "id": "h8wjlanfpwkuqberw0ds",
//    "type": "add",
//    "from": "liuhaoi.udn.yonyou@im.yyuap.com/pc-v2.0",
//    "to": "v2opy0ocmfgq89axnt4ckkxw.udn.yonyou@conference.im.yyuap.com"
//}
- (void)collectChatGroup:(NSString *)groupId {
    // groupId
    if ([YYIMStringUtility isEmpty:groupId]) {
        return;
    }
    
    // JUMPIQ
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPMUCCollectPacketOpCode) type:@"add" to:[YYIMJUMPHelper genFullGroupJid:groupId] packetID:[JUMPStream generateJUMPID]];
    
    [[self tracker] addPacket:iq
                       target:self
                     selector:@selector(handleCollectChatGroupResponse:withInfo:)
                      timeout:30];
    // 发包
    [[self activeStream] sendPacket:iq];
    
    [[YYIMDBHelper sharedInstance] updateChatGroupCollect:groupId collect:YES];
}

//opcode: 0x2537，MUCCollectPacket
//{
//    "id": "d1lsupksd0ht5yef4atm",
//    "type": "remove"
//    "from": "liuhaoi.udn.yonyou@im.yyuap.com/pc-v2.0",
//    "to": "v2opy0ocmfgq89axnt4ckkxw.udn.yonyou@conference.im.yyuap.com"
//}
- (void)unCollectChatGroup:(NSString *)groupId {
    // groupId
    if ([YYIMStringUtility isEmpty:groupId]) {
        return;
    }
    
    // JUMPIQ
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPMUCCollectPacketOpCode) type:@"remove" to:[YYIMJUMPHelper genFullGroupJid:groupId] packetID:[JUMPStream generateJUMPID]];
    
    [[self tracker] addPacket:iq
                       target:self
                     selector:@selector(handleUnCollectChatGroupResponse:withInfo:)
                      timeout:30];
    // 发包
    [[self activeStream] sendPacket:iq];
    
    [[YYIMDBHelper sharedInstance] updateChatGroupCollect:groupId collect:NO];
}

- (void)dismissChatGroup:(NSString *)groupId {
    // groupId
    if ([YYIMStringUtility isEmpty:groupId]) {
        return;
    }
    
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPMUCDismissPacketOpCode) type:nil to:[YYIMJUMPHelper genFullGroupJid:groupId] packetID:[JUMPStream generateJUMPID]];
    
    [[self tracker] addPacket:iq
                       target:self
                     selector:@selector(handleDismissChatGroupResponse:withInfo:)
                      timeout:30];
    [[self activeStream] sendPacket:iq];
}

- (void)genChatGroupQrCodeWithGroupId:(NSString *)groupId complete:(void (^)(BOOL, NSDictionary *, YYIMError *))complete {
    // 群组ID
    if ([YYIMStringUtility isEmpty:groupId]) {
        complete(NO, nil, [YYIMError errorWithCode:YMERROR_CODE_ILLEGAL_ARGUMENT errorMessage:@"groupId should not empty"]);
        return;
    }
    // 用户ID
    NSString *user = [[YYIMConfig sharedInstance] getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        complete(NO, nil, [YYIMError errorWithCode:YMERROR_CODE_UNEXPECT_STATE errorMessage:@"userId not found"]);
        return;
    }
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:user forKey:@"userid"];
            [params setObject:[token tokenStr] forKey:@"token"];
            [params setObject:groupId forKey:@"mucid"];
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            NSString *urlString = [[YYIMConfig sharedInstance] getMucQrCodeServlet];
            
            [manager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                
                NSMutableDictionary *result = [NSMutableDictionary dictionary];
                [result setObject:[NSString stringWithFormat:@"yyim://stellar.yyuap.com/info?qrid=%@", [dic objectForKey:@"mucqr_id"]] forKey:@"qrCodeText"];
                [result setObject:[dic objectForKey:@"expire_time"] forKey:@"qrCodeExpire"];
                
                complete(YES, result, nil);
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                complete(NO, nil, [YYIMError errorWithNSError:error]);
            }];
        } else {
            complete(NO, nil, tokenError);
        }
    }];
}

- (void)getChatGroupInfoWithQrCode:(NSString *)qrCodeText complete:(void (^)(BOOL, YYChatGroupInfo *, YYIMError *))complete {
    // parse qrid
    NSURL *url = [NSURL URLWithString:qrCodeText];
    NSString *query = [url query];
    NSArray *paramArray = [query componentsSeparatedByString:@"&"];
    
    NSString *qrcodeId;
    for (NSString *param in paramArray) {
        NSArray *array = [param componentsSeparatedByString:@"="];
        if ([array count] == 2) {
            if ([[array objectAtIndex:0] isEqualToString:@"qrid"]) {
                qrcodeId = [array objectAtIndex:1];
                break;
            }
        }
    }
    // 检查qrid
    if ([YYIMStringUtility isEmpty:qrcodeId]) {
        complete(NO, nil, [YYIMError errorWithCode:YMERROR_CODE_ILLEGAL_ARGUMENT errorMessage:@"qrCodeText invalid"]);
        return;
    }
    // 用户ID
    NSString *user = [[YYIMConfig sharedInstance] getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        complete(NO, nil, [YYIMError errorWithCode:YMERROR_CODE_UNEXPECT_STATE errorMessage:@"userId not found"]);
        return;
    }
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:user forKey:@"userid"];
            [params setObject:[token tokenStr] forKey:@"token"];
            [params setObject:qrcodeId forKey:@"mucqr_id"];
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            NSString *urlString = [[YYIMConfig sharedInstance] getMucQrCodeInfoServlet];
            
            [manager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                // 群组全名
                NSString *fullGroupId = [dic objectForKey:@"name"];
                // 拆分群组名
                NSArray *groupNameInfoArray = [fullGroupId componentsSeparatedByString:@"."];
                NSString *groupId = [groupNameInfoArray objectAtIndex:0];
                NSString *appId = [groupNameInfoArray objectAtIndex:1];
                NSString *etpId = [groupNameInfoArray objectAtIndex:2];
                
                YYChatGroupInfo *groupInfo = [[YYChatGroupInfo alloc] init];
                if (![appId isEqualToString:[[YYIMConfig sharedInstance] getAppKey]] || ![etpId isEqualToString:[[YYIMConfig sharedInstance] getEtpKey]]) {
                    [groupInfo setIsValidGroup:NO];
                    complete(YES, groupInfo, nil);
                    return;
                }
                [groupInfo setIsValidGroup:YES];
                
                YYChatGroup *group = [self getChatGroupWithGroupId:groupId];
                if (group) {
                    [groupInfo setIsJoindGroup:YES];
                    [groupInfo setGroup:group];
                    complete(YES, groupInfo, nil);
                    return;
                }
                
                group = [[YYChatGroup alloc] init];
                [group setGroupId:groupId];
                [group setGroupName:[dic objectForKey:@"naturalLanguageName"]];
                [group setMemberCount:[[dic objectForKey:@"memberCount"] integerValue]];
                
                [groupInfo setMaxMemberCount:[[dic objectForKey:@"maxUsers"] integerValue]];
                
                NSMutableArray *memberArray = [[NSMutableArray alloc] init];
                NSArray *items = [dic objectForKey:@"items"];
                for (NSDictionary *item in items) {
                    YYChatGroupMember *member = [[YYChatGroupMember alloc] init];
                    [member setMemberId:[YYIMJUMPHelper parseUser:[item objectForKey:@"jid"]]];
                    [member setMemberName:[item objectForKey:@"name"]];
                    [member setMemberPhoto:[item objectForKey:@"photo"]];
                    [memberArray addObject:member];
                }
                [groupInfo setGroup:group];
                [groupInfo setMemberArray:memberArray];
                
                complete(YES, groupInfo, nil);
                
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                complete(NO, nil, [YYIMError errorWithNSError:error]);
            }];
        } else {
            complete(NO, nil, tokenError);
        }
    }];
}

/**
 *  通过tag获取群组集合
 *
 *  @param tag tag
 *
 *  @return 群组集合
 */
- (NSArray *)getChatGroupsWithTag:(NSString *)tag {
    if ([YYIMStringUtility isEmpty:tag]) {
        return nil;
    }
    
    return [[YYIMDBHelper sharedInstance] getChatGroupsWithTag:tag];
}

- (void)participateFaceGroupWithCipher:(NSString *)cipher longitude:(float)longitude latitude:(float)latitude {
    [self participateFaceGroupWithCipher:cipher longitude:longitude latitude:latitude distance:-1 expireTime:-1];
}

- (void)participateFaceGroupWithCipher:(NSString *)cipher longitude:(float)longitude latitude:(float)latitude distance:(NSInteger)distance expireTime:(NSInteger)expireTime {
    if (cipher.length != 4 || ![YYIMStringUtility isNumberString:cipher]) {
        [self.activeDelegate didNotParticipateInFaceGropWithCipher:cipher error:[YYIMError errorWithCode:YMERROR_CODE_ILLEGAL_ARGUMENT errorMessage:@"cipher invalid"]];
        return;
    }
    
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPMUCFaceOperatePacketOpCode) packetID:[JUMPStream generateJUMPID]];
    [iq setObject:@"participation" forKey:@"operationType"];
    [iq setObject:cipher forKey:@"cipher"];
    [iq setObject:[NSNumber numberWithFloat:longitude] forKey:@"longitude"];
    [iq setObject:[NSNumber numberWithFloat:latitude] forKey:@"latitude"];
    if (distance > 0) {
        [iq setObject:[NSNumber numberWithInteger:distance] forKey:@"distance"];
    }
    if (expireTime > 0) {
        [iq setObject:[NSNumber numberWithInteger:expireTime] forKey:@"expireTime"];
    }
    
    [[self tracker] addPacket:iq target:self selector:@selector(handleParticipateFaceGroupResponse:withInfo:) timeout:30];
    
    [[self activeStream] sendPacket:iq];
}

- (void)joinFaceGroupWithCipher:(NSString *)cipher faceId:(NSString *)faceId {
    if ([YYIMStringUtility isEmpty:faceId]) {
        [[self activeDelegate] didNotJoinFaceGroupWithFaceId:faceId error:[YYIMError errorWithCode:YMERROR_CODE_ILLEGAL_ARGUMENT errorMessage:@"faceId is empty"]];
    }
    
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPMUCFaceOperatePacketOpCode) packetID:[JUMPStream generateJUMPID]];
    [iq setTo:[YYIMJUMPHelper genFullJid:faceId]];
    [iq setObject:cipher forKey:@"cipher"];
    [iq setObject:@"join" forKey:@"operationType"];
    
    [[self tracker] addPacket:iq target:self selector:@selector(handleJoinFaceGroupResponse:withInfo:) timeout:30];
    
    [[self activeStream] sendPacket:iq];
}

- (void)quitFaceGroupWithCipher:(NSString *)cipher faceId:(NSString *)faceId {
    if ([YYIMStringUtility isEmpty:faceId]) {
        [[self activeDelegate] didNotJoinFaceGroupWithFaceId:faceId error:[YYIMError errorWithCode:YMERROR_CODE_ILLEGAL_ARGUMENT errorMessage:@"faceId is empty"]];
    }
    
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPMUCFaceOperatePacketOpCode) packetID:[JUMPStream generateJUMPID]];
    [iq setTo:[YYIMJUMPHelper genFullJid:faceId]];
    [iq setObject:cipher forKey:@"cipher"];
    [iq setObject:@"exit" forKey:@"operationType"];
    
    [[self tracker] addPacket:iq target:self selector:@selector(handleQuitFaceGroupResponse:withInfo:) timeout:30];
    
    [[self activeStream] sendPacket:iq];
}

#pragma mark jumpstream delegate

- (BOOL)jumpStream:(JUMPStream *)sender didReceiveIQ:(JUMPIQ *)iq {
    BOOL result = [[self tracker] invokeForID:[iq packetID] withObject:iq];
    if (!result) {
        if ([iq checkOpData:JUMP_OPDATA(JUMPMUCOperateResultPacketOpCode)]) {
            return [self didReceiveGroupLeavePush:iq];
        } else if ([iq checkOpData:JUMP_OPDATA(JUMPMUCDetailInfoResultPacketOpCode)]) {
            return [self didReceiveGroupUpdatePush:iq];
        } else if ([iq checkOpData:JUMP_OPDATA(JUMPMUCFaceNotifyPacketOpCode)]) {
            return [self didReceiveFaceGroupUpdatePush:iq];
        }
    }
    return result;
}

- (void)jumpStream:(JUMPStream *)sender didFailToSendIQ:(JUMPIQ *)iq error:(NSError *)error {
    if ([iq packetID]) {
        [[self tracker] invokeForID:[iq packetID] withObject:nil];
    }
}

- (void)jumpStream:(JUMPStream *)sender didFailToSendPresence:(JUMPPresence *)presence error:(NSError *)error {
    if ([presence packetID]) {
        [[self tracker] invokeForID:[presence packetID] withObject:nil];
    }
}

- (void)jumpStream:(JUMPStream *)sender didReceiveError:(JUMPError *)error {
    if ([error packetID]) {
        [[self tracker] invokeForID:[error packetID] withObject:error];
    }
}

#pragma mark private func

- (BOOL)didReceiveGroupLeavePush:(JUMPIQ *)iq {
    NSString *groupId = [YYIMJUMPHelper parseUser:[[iq from] user]];
    [[YYIMDBHelper sharedInstance] deleteChatGroup:groupId];
    [[self activeDelegate] didLeaveChatGroup:groupId];
    [[self activeDelegate] didMessageDelete:[NSDictionary dictionaryWithObject:groupId forKey:@"groupId"]];
    return YES;
}

- (void)handleLoadChatGroupResponse:(JUMPPacket *)jumpPacket withInfo:(id <JUMPTrackingInfo>)info {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPMUCItemsResultPacketOpCode)]) {
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
    NSArray *items = [iq objectForKey:@"items"];
    
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
    // 更新数据库
    [[YYIMDBHelper sharedInstance] batchUpdateChatGroup:chatGroupArray];
    
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
    
    [self loadMUCOfflineMessage];
}

- (void)handleSearchChatGroupResponse:(JUMPIQ *)jumpIQ withInfo:(id <JUMPTrackingInfo>)info {
    if (!jumpIQ) {
        YYIMLogError(@"didNotReceiveChatGroupSearchResult");
        [[self activeDelegate] didNotReceiveChatGroupSearchResult:nil];
        return;
    }
    if (![jumpIQ checkOpData:JUMP_OPDATA(JUMPMUCSearchResultPacketOpCode)]) {
        YYIMLogError(@"didNotReceiveChatGroupSearchResult:%@-%@", [jumpIQ headerData], [jumpIQ jsonString]);
        [[self activeDelegate] didNotReceiveChatGroupSearchResult:nil];
        return;
    }
    
    NSArray *items = [jumpIQ objectForKey:@"items"];
    if (!items || [items count] <= 0) {
        [[self activeDelegate] didReceiveChatGroupSearchResult:nil];
    }
    
    NSMutableArray *groupArray = [NSMutableArray array];
    for (NSDictionary *item in items) {
        YYChatGroup *group = [[YYChatGroup alloc] init];
        [group setGroupId:[YYIMJUMPHelper parseUser:[item objectForKey:@"jid"]]];
        [group setGroupName:[item objectForKey:@"name"]];
        [group setGroupTag:[item objectForKey:@"tag"]];
        [group setIsCollect:[[item objectForKey:@"collect"] integerValue] == 1];
        // add to array
        [groupArray addObject:group];
    }
    [[self activeDelegate] didReceiveChatGroupSearchResult:groupArray];
}

- (BOOL)handleGroupCreateResponse:(JUMPPacket *)jumpPacket withInfo:(id <JUMPTrackingInfo>)info {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPMUCDetailInfoResultPacketOpCode)]) {
        YYIMError *error;
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        YYIMLogError(@"createGroupError:%ld:%@", (long)[error errorCode], [error errorMsg]);
        
        JUMPIQ *traceIQ = (JUMPIQ *)[info packet];
        if (traceIQ) {
            [[self activeDelegate] didNotChatGroupCreateWithSeriId:[traceIQ packetID]];
        }
        return YES;
    }
    return [self didReceiveGroupUpdatePush:(JUMPIQ *)jumpPacket];
}

- (BOOL)handleInviteRosterIntoChatGroupResponse:(JUMPPacket *)jumpPacket withInfo:(id <JUMPTrackingInfo>)info {
    YYIMError *error;
    
    if (!jumpPacket) {
        error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
    } else if ([jumpPacket checkOpData:JUMP_OPDATA(JUMPIQResultPacketOpCode)]){
        return NO;
    } else if (![jumpPacket checkOpData:JUMP_OPDATA(JUMPMUCDetailInfoResultPacketOpCode)]) {
        if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        
        YYIMLogError(@"inviteRosterIntoChatGroupError:%ld:%@:%@", (long)[error errorCode], [error errorMsg], [[info packet] jsonString]);
    }
    
    if (error) {
        JUMPIQ *traceIQ = (JUMPIQ *)[info packet];
        
        if (traceIQ) {
            NSString *groupId = [YYIMJUMPHelper parseUser:[[traceIQ to] user]];
            [[self activeDelegate] didNotInviteRosterIntoChatGroup:groupId error:error];
        }
        
        return YES;
    }
    
    return [self didReceiveGroupUpdatePush:(JUMPIQ *)jumpPacket];
}

- (BOOL)handleKickGroupMemberFromGroupResponse:(JUMPPacket *)jumpPacket withInfo:(id <JUMPTrackingInfo>)info {
    YYIMError *error;
    
    if (!jumpPacket) {
        error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
    } else if ([jumpPacket checkOpData:JUMP_OPDATA(JUMPIQResultPacketOpCode)]){
        return NO;
    } else if (![jumpPacket checkOpData:JUMP_OPDATA(JUMPMUCDetailInfoResultPacketOpCode)]) {
        if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        
        YYIMLogError(@"kickGroupMemberError:%ld:%@:%@", (long)[error errorCode], [error errorMsg], [[info packet] jsonString]);
    }
    
    if (error) {
        JUMPIQ *traceIQ = (JUMPIQ *)[info packet];
        
        if (traceIQ) {
            NSString *groupId = [YYIMJUMPHelper parseUser:[[traceIQ to] user]];
            [[self activeDelegate] didNotKickGroupMemberFromGroup:groupId error:error];
        }
        
        return YES;
    }
    
    return [self didReceiveGroupUpdatePush:(JUMPIQ *)jumpPacket];
}

- (BOOL)handleGroupLeaveResponse:(JUMPPacket *)jumpPacket withInfo:(id <JUMPTrackingInfo>)info {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPMUCOperateResultPacketOpCode)]) {
        YYIMError *error;
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        YYIMLogError(@"leaveGroupError:%ld:%@", (long)[error errorCode], [error errorMsg]);
        
        JUMPPacket *trackPacket = [info packet];
        NSString *groupId;
        if (trackPacket) {
            groupId = [YYIMJUMPHelper parseUser:[trackPacket toStr]];
        }
        [[self activeDelegate] didNotLeaveChatGroup:groupId error:error];
        return YES;
    }
    
    return [self didReceiveGroupLeavePush:(JUMPIQ *)jumpPacket];
}

- (void)handleCollectChatGroupResponse:(JUMPPacket *)jumpPacket withInfo:(id <JUMPTrackingInfo>)info {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPIQResultPacketOpCode)]) {
        YYIMError *error;
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        YYIMLogError(@"collectChatGroup:%ld:%@", (long)[error errorCode], [error errorMsg]);
        
        JUMPPacket *trackPacket = [info packet];
        NSString *groupId;
        if (trackPacket) {
            groupId = [YYIMJUMPHelper parseUser:[trackPacket toStr]];
        }
        
        [[self activeDelegate] didNotCollectChatGroup:groupId error:error];
        return;
    }
    
    NSString *groupId = [YYIMJUMPHelper parseUser:[jumpPacket fromStr]];
    [[YYIMDBHelper sharedInstance] updateChatGroupCollect:groupId collect:YES];
    [[self activeDelegate] didCollectChatGroup:groupId];
}

- (void)handleUnCollectChatGroupResponse:(JUMPPacket *)jumpPacket withInfo:(id <JUMPTrackingInfo>)info {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPIQResultPacketOpCode)]) {
        YYIMError *error;
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        YYIMLogError(@"unCollectChatGroup:%ld:%@", (long)[error errorCode], [error errorMsg]);
        
        JUMPPacket *trackPacket = [info packet];
        NSString *groupId;
        if (trackPacket) {
            groupId = [YYIMJUMPHelper parseUser:[trackPacket toStr]];
        }
        
        [[self activeDelegate] didNotUnCollectChatGroup:groupId error:error];
        return;
    }
    NSString *groupId = [YYIMJUMPHelper parseUser:[jumpPacket fromStr]];
    [[YYIMDBHelper sharedInstance] updateChatGroupCollect:groupId collect:NO];
    [[self activeDelegate] didUnCollectChatGroup:groupId];
}

- (void)handleJoinChatGroupResponse:(JUMPPacket *)jumpPacket withInfo:(id <JUMPTrackingInfo>)info {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPMUCDetailInfoResultPacketOpCode)]) {
        YYIMError *error;
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        YYIMLogError(@"joinGroupError:%ld:%@", (long)[error errorCode], [error errorMsg]);
        
        JUMPPacket *trackPacket = [info packet];
        NSString *groupId;
        if (trackPacket) {
            groupId = [YYIMJUMPHelper parseUser:[trackPacket toStr]];
        }
        if (trackPacket) {
            [[self activeDelegate] didNotJoinChatGroup:groupId error:error];
        }
        return;
    }
    [self didReceiveGroupUpdatePush:(JUMPIQ *)jumpPacket];
}

- (BOOL)didReceiveGroupUpdatePush:(JUMPIQ *)iq {
    if (![iq checkOpData:JUMP_OPDATA(JUMPMUCDetailInfoResultPacketOpCode)]) {
        return NO;
    }
    
    // group id
    NSString *groupId = [YYIMJUMPHelper parseUser:[[iq from] user]];
    
    // group entity
    YYChatGroup *group = [[YYChatGroup alloc] init];
    [group setGroupId:groupId];
    [group setGroupName:[iq objectForKey:@"naturalLanguageName"]];
    [group setGroupTag:[iq objectForKey:@"tag"]];
    [group setIsCollect:[[iq objectForKey:@"collected"] integerValue] == 1];
    [group setIsSuper:[[iq objectForKey:@"superLarge"] integerValue] == 1];
    [group setMemberCount:[[iq objectForKey:@"numberOfMembers"] integerValue]];
    
    [group setTs:[[iq objectForKey:@"ts"] longLongValue]];
    
    NSArray *members = [iq objectForKey:@"members"];
    BOOL isOwner = NO;
    // memberArray
    NSMutableArray *memberArray = [NSMutableArray array];
    NSMutableArray *memberIdArray = [NSMutableArray array];
    if (members && [members count] > 0) {
        for (NSDictionary *item in members) {
            NSString *memberId = [YYIMJUMPHelper parseUser:[item objectForKey:@"jid"]];
            NSString *memberRole = [item objectForKey:@"affiliation"];
            if ([memberId isEqualToString:[[YYIMConfig sharedInstance] getUser]] && [memberRole isEqualToString:@"owner"]) {
                isOwner = YES;
            }
            
            if ([memberIdArray containsObject:memberId]) {
                continue;
            }
            [memberIdArray addObject:memberId];
            
            YYChatGroupMember *member = [[YYChatGroupMember alloc] init];
            [member setMemberId:memberId];
            [member setMemberName:[item objectForKey:@"name"]];
            [member setMemberPhoto:[item objectForKey:@"photo"]];
            [member setMemberRole:memberRole];
            [memberArray addObject:member];
        }
        
        [group setIsOwner:isOwner];
        
        // insert group into db
        [[YYIMDBHelper sharedInstance] updateChatGroup:group];
        
        [[YYIMChatGroupMemberDBHelper sharedInstance] batchUpdateChatGroupMember:groupId members:memberArray];
        [[self activeDelegate] didChatGroupMemberUpdate:groupId];
    }
    
    NSString *type = [iq objectForKey:@"type"];
    NSString *operator = [YYIMJUMPHelper parseUser:[iq objectForKey:@"operator"]];
    NSNumber *dateline = [iq objectForKey:@"creationdate"];
    NSObject *operhand = [iq objectForKey:@"operhand"];
    
    // 创建群组
    if ([type isEqualToString:@"create"]) {
        // didChatGroupCreate
        [[self activeDelegate] didChatGroupCreateWithSeriId:[iq packetID] group:group];
        
        NSMutableArray *operhandArray = [NSMutableArray array];
        for (YYChatGroupMember *member in memberArray) {
            [operhandArray addObject:[member memberId]];
        }
        [operhandArray removeObject:operator];
        operhand = operhandArray;
        
        NSString *cipher = [iq objectForKey:@"cipher"];
        NSMutableDictionary *dic = nil;
        if (cipher) {
            dic = [NSMutableDictionary dictionaryWithObject:cipher forKey:@"cipher"];
        }
        // 生成消息
        [self injectGroupOperateMessage:groupId type:type operator:operator operhand:operhand dateline:dateline otherInfo:dic];
    } else if ([type isEqualToString:@"modify"]) {// 改名
        operhand = [group groupName];
        // 生成消息
        [self injectGroupOperateMessage:groupId type:type operator:operator operhand:operhand dateline:dateline otherInfo:nil];
    } else if ([type isEqualToString:@"join"]) {
        [[self activeDelegate] didJoinChatGroup:groupId];
        // 生成消息
        [self injectGroupOperateMessage:groupId type:type operator:operator operhand:operhand dateline:dateline otherInfo:nil];
    } else if ([type isEqualToString:@"invite"] || [type isEqualToString:@"kickmember"] || [type isEqualToString:@"exit"]) {
        if (operhand && [operhand isKindOfClass:[NSArray class]]) {
            NSMutableArray *operhandArray = [NSMutableArray array];
            for (NSString *oper in (NSArray *)operhand) {
                [operhandArray addObject:[YYIMJUMPHelper parseUser:oper]];
            }
            [operhandArray removeObject:operator];
            operhand = operhandArray;
        }
        // 生成消息
        [self injectGroupOperateMessage:groupId type:type operator:operator operhand:operhand dateline:dateline otherInfo:nil];
    }
    [[self activeDelegate] didChatGroupInfoUpdate:group];
    return YES;
}

- (void)injectGroupOperateMessage:(NSString *)groupId type:(NSString *)type operator:(NSString *)operator operhand:(NSObject *)operhand dateline:(NSNumber *)dateline otherInfo:(NSDictionary *)dic {
    // gen message
    JUMPMessage *message = [JUMPMessage messageWithOpData:JUMP_OPDATA(JUMPMUCMessagePacketOpCode) to:[YYIMJUMPHelper genFullJid:[[YYIMConfig sharedInstance] getUser]] packetID:[JUMPStream generateJUMPID]];
    JUMPJID *groupJid = [YYIMJUMPHelper genFullGroupJid:groupId];
    groupJid = [groupJid jidWithNewResource:operator];
    [message setFrom:groupJid];
    [message setObject:dateline forKey:@"dateline"];
    
    YYMessageContent *content = [[YYMessageContent alloc] init];
    [content setAttribute:operator forKey:@"operator"];
    [content setAttribute:operhand forKey:@"operhand"];
    [content setAttribute:type forKey:@"promptType"];
    if (dic) {
        [content setAttributesWithDictionary:dic];
    }
    [message setObject:[content jsonString:YM_MESSAGE_CONTENT_PROMPT] forKey:@"content"];
    [message setObject:[NSNumber numberWithInteger:YM_MESSAGE_CONTENT_PROMPT] forKey:@"contentType"];
    [[self activeStream] injectPacket:message];
}

- (void)handleGroupChangeAdmin:(JUMPPacket *)jumpPacket withInfo:(id <JUMPTrackingInfo>)info {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPMUCRoleConversionResultPacketOpCode)]) {
        YYIMError *error;
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        YYIMLogError(@"changeAdminError:%ld:%@", (long)[error errorCode], [error errorMsg]);
        
        JUMPPacket *trackPacket = [info packet];
        NSString *groupId;
        if (trackPacket) {
            groupId = [YYIMJUMPHelper parseUser:[trackPacket toStr]];
        }
        [[self activeDelegate] didNotChangeAdminFromGroup:groupId error:error];
        
        return;
    }
    
    [self didReceiveGroupChangeAdmin:(JUMPIQ *)jumpPacket];
}

/**
 *  只有老的管理员和新的管理员会收到这条信息
 *
 *  @param iq
 */
- (void)didReceiveGroupChangeAdmin:(JUMPIQ *)iq {
    // group id
    NSString *groupId = [YYIMJUMPHelper parseUser:[[iq from] user]];
    
    // group entity
    YYChatGroup *group = [[YYIMDBHelper sharedInstance] getChatGroupWithId:groupId];
    
    NSArray *memberItems = [iq objectForKey:@"memberItems"];
    NSMutableArray *updateMembers = [[NSMutableArray alloc] initWithCapacity:2];
    
    if (memberItems && memberItems.count > 0) {
        for (NSDictionary *item in memberItems) {
            NSString *user = [YYIMJUMPHelper parseUser:[item objectForKey:@"jid"]];
            
            if ([user isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
                if ([@"owner" isEqualToString:[item objectForKey:@"affiliation"]]) {
                    group.isOwner = YES;
                } else {
                    group.isOwner = NO;
                }
            }
            
            YYChatGroupMember *member = [[YYIMChatGroupMemberDBHelper sharedInstance] getChatGroupMemberWithGroupId:groupId memberId:user];
            [member setMemberRole:[item objectForKey:@"affiliation"]];
            
            [updateMembers addObject:member];
        }
    }
    
    [[YYIMDBHelper sharedInstance] updateChatGroup:group];
    [[YYIMChatGroupMemberDBHelper sharedInstance] updateChatGroupMember:groupId members:updateMembers];
    
    [[self activeDelegate] didChatGroupInfoUpdate:group];
}

- (void)handleDismissChatGroupResponse:(JUMPPacket *)jumpPacket withInfo:(id <JUMPTrackingInfo>)info {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPMUCOperateResultPacketOpCode)]) {
        YYIMError *error;
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        YYIMLogError(@"dismissChatGroup:%ld:%@", (long)[error errorCode], [error errorMsg]);
        
        JUMPPacket *trackPacket = [info packet];
        NSString *groupId;
        if (trackPacket) {
            groupId = [YYIMJUMPHelper parseUser:[trackPacket toStr]];
        }
        [[self activeDelegate] didNotDismissChatGroup:groupId error:error];
        return;
    }
    
    NSString *groupId = [YYIMJUMPHelper parseUser:[[jumpPacket from] user]];
    [[self activeDelegate] didDismissChatGroup:groupId];
    [self didReceiveGroupLeavePush:(JUMPIQ *)jumpPacket];
}

- (void)handleParticipateFaceGroupResponse:(JUMPPacket *)jumpPacket withInfo:(id<JUMPTrackingInfo>)info {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPMUCFaceNotifyPacketOpCode)]) {
        YYIMError *error;
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        
        
        JUMPPacket *trackPacket = [info packet];
        NSString *cipher = [trackPacket objectForKey:@"cipher"];
        YYIMLogError(@"participateFaceGroup:%@:%ld:%@", cipher, (long)[error errorCode], [error errorMsg]);
        [[self activeDelegate] didNotParticipateInFaceGropWithCipher:cipher error:error];
        return;
    }
    
    NSString *fromId = [YYIMJUMPHelper parseUser:[jumpPacket fromStr]];
    NSString *cipher = [jumpPacket objectForKey:@"cipher"];
    NSArray *members = [jumpPacket objectForKey:@"members"];
    NSMutableArray *memberIds = [NSMutableArray array];
    for (NSDictionary *item in members) {
        [memberIds addObject:[YYIMJUMPHelper parseUser:[item objectForKey:@"jid"]]];
    }
    [[self activeDelegate] didParticipateInFaceGrop:fromId cipher:cipher members:memberIds];
}

- (void)handleJoinFaceGroupResponse:(JUMPPacket *)jumpPacket withInfo:(id<JUMPTrackingInfo>)info {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPMUCDetailInfoResultPacketOpCode)]) {
        YYIMError *error;
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        
        
        JUMPPacket *trackPacket = [info packet];
        NSString *faceId = [YYIMJUMPHelper parseUser:[trackPacket toStr]];
        YYIMLogError(@"joinFaceGroup:%@:%ld:%@", faceId, (long)[error errorCode], [error errorMsg]);
        [[self activeDelegate] didNotJoinFaceGroupWithFaceId:faceId error:error];
        return;
    }
    
    JUMPPacket *trackPacket = [info packet];
    NSString *faceId = [YYIMJUMPHelper parseUser:[trackPacket toStr]];
    NSString *cipher = [trackPacket objectForKey:@"cipher"];
    [jumpPacket setObject:cipher forKey:@"cipher"];
    [self didReceiveGroupUpdatePush:(JUMPIQ *)jumpPacket];
    
    NSString *groupId = [YYIMJUMPHelper parseUser:[jumpPacket fromStr]];
    [[self activeDelegate] didJoinFaceGroupWithFaceId:faceId groupId:groupId];
}

- (void)handleQuitFaceGroupResponse:(JUMPPacket *)jumpPacket withInfo:(id<JUMPTrackingInfo>)info {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPMUCDetailInfoResultPacketOpCode)]) {
        YYIMError *error;
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        
        
        JUMPPacket *trackPacket = [info packet];
        NSString *faceId = [YYIMJUMPHelper parseUser:[trackPacket toStr]];
        YYIMLogError(@"quitFaceGroup:%@:%ld:%@", faceId, (long)[error errorCode], [error errorMsg]);
        [[self activeDelegate] didNotQuitFaceGroupWithFaceId:faceId error:error];
        return;
    }
    
    JUMPPacket *trackPacket = [info packet];
    NSString *faceId = [YYIMJUMPHelper parseUser:[trackPacket toStr]];
    [[self activeDelegate] didQuitFaceGroupWithFaceId:faceId];
}

- (BOOL)didReceiveFaceGroupUpdatePush:(JUMPIQ *)iq {
    // faceId
    NSString *faceId = [YYIMJUMPHelper parseUser:[iq fromStr]];
    // 操作类型
    NSString *operationType = [iq objectForKey:@"operationType"];
    // 操作人
    NSString *operator = [YYIMJUMPHelper parseUser:[iq objectForKey:@"operator"]];
    // cipher
    NSString *cipher = [iq objectForKey:@"cipher"];
    // members
    NSArray *members = [iq objectForKey:@"members"];
    NSMutableArray *memberIds = [NSMutableArray array];
    for (NSDictionary *item in members) {
        [memberIds addObject:[YYIMJUMPHelper parseUser:[item objectForKey:@"jid"]]];
    }
    
    if ([operationType isEqualToString:@"join"]) {
        [[self activeDelegate] didUserParticipateInFaceGroupWithFaceId:faceId cipher:cipher userId:operator members:memberIds];
    } else if ([operationType isEqualToString:@"exit"]) {
        [[self activeDelegate] didUserQuitFaceGroupWithFaceId:faceId cipher:cipher userId:operator members:memberIds];
    }
    return YES;
}

#pragma mark muc offline message

- (void)loadMUCOfflineMessage {
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result) {
            NSArray *superGroups = [[YYIMDBHelper sharedInstance] getAllSuperGroup];
            for (YYChatGroup *superGroup in superGroups) {
                NSInteger currentVersion = [[YYIMDBHelper sharedInstance] getGroupVersionWithId:[superGroup groupId]];
                [self doLoadMUCOfflineMessageWithVersion:currentVersion group:[superGroup groupId] token:[token tokenStr] start:0];
            }
        } else {
            YYIMLogError(@"getTokenFaildWithCode:%ld Msg:%@", (long)[tokenError errorCode], [tokenError errorMsg]);
        }
    }];
}

- (void)doLoadMUCOfflineMessageWithVersion:(NSInteger)version group:(NSString *)groupId token:(NSString *)token start:(NSInteger)start {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YYIMLogInfo(@"client do load muc offline message");
        
        NSString *urlString = [[YYIMConfig sharedInstance] getMUCVersionServlet];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:token forKey:@"token"];
        [params setObject:[[YYIMJUMPHelper genFullGroupJid:groupId] user] forKey:@"mucId"];
        [params setObject:[NSNumber numberWithInteger:version] forKey:@"version"];
        [params setObject:[NSString stringWithFormat:@"%@-%@", YM_CLIENT_IOS, YM_CLIENT_CURRENT_VERSION] forKey:@"resource"];
        [params setObject:[NSNumber numberWithInteger:start] forKey:@"start"];
        [params setObject:[NSNumber numberWithInteger:100] forKey:@"size"];
        
        YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
        [manager setCompletionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
        [manager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *dic = (NSDictionary *)responseObject;
            NSArray *items = (NSArray *)[dic objectForKey:@"packets"];
            for (NSDictionary *item in items) {
                JUMPMessage *messagePacket = [JUMPMessage messageWithOpData:JUMP_OPDATA(JUMPMUCMessagePacketOpCode) to:[YYIMJUMPHelper genFullJid:[[YYIMConfig sharedInstance] getUser]] packetID:[item objectForKey:@"packetId"]];
                // from
                JUMPJID *groupJID = [YYIMJUMPHelper genFullGroupJid:groupId];
                groupJID = [groupJID jidWithNewResource:[item objectForKey:@"sender"]];
                [messagePacket setFrom:groupJID];
                // 请求回执
                [messagePacket setObject:[NSNumber numberWithInt:1] forKey:@"receipts"];
                // content
                [messagePacket setObject:[item objectForKey:@"content"] forKey:@"content"];
                // contentType
                [messagePacket setObject:[item objectForKey:@"contentType"] forKey:@"contentType"];
                // dateline
                [messagePacket setObject:[item objectForKey:@"dateline"] forKey:@"dateline"];
                // mucMessageVersion
                [messagePacket setObject:[item objectForKey:@"version"] forKey:@"mucMessageVersion"];
                // 离线
                [messagePacket setObject:@"1" forKey:@"offline"];
                [[self activeStream] injectPacket:messagePacket];
            }
            if ([items count] > 0) {
                [[self activeDelegate] didReceiveMessage:nil];
                [self playSoundAndVibrate];
            }
            
            NSInteger count = [[dic objectForKey:@"count"] integerValue];
            NSInteger size = [[dic objectForKey:@"size"] integerValue];
            NSInteger start = [[dic objectForKey:@"start"] integerValue];
            YYIMLogInfo(@"client did load muc offline message:group:%@ start:%ld size:%ld count:%ld", groupId, (long)start, (long)size, (long)count);
            if (count > (size + start)) {
                [self doLoadMUCOfflineMessageWithVersion:version group:groupId token:token start:(size + start)];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, id responseObject, NSError * _Nonnull error) {
            NSHTTPURLResponse *response = [error.userInfo objectForKey:YMAFNetworkingOperationFailingURLResponseErrorKey];
            YYIMLogError(@"load muc offline message faild:%ld|%@", (long)[response statusCode], error.description);
        }];
    });
}

@end
