//
//  YYIMRosterProvider.m
//  YonyouIM
//
//  Created by litfb on 15/1/21.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMRosterProvider.h"

#import "JUMPFramework.h"
#import "YYIMChat.h"
#import "YYIMJUMPHelper.h"
#import "YYIMDBHelper.h"
#import "YYIMStringUtility.h"
#import "YYIMConfig.h"
#import "YYIMLogger.h"
#import "YMAFNetworking.h"

@interface YYIMRosterProvider ()<JUMPStreamDelegate>

@end

@implementation YYIMRosterProvider

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark roster protocol

- (NSArray *)getAllRoster {
    NSArray *rosterArray = [[YYIMDBHelper sharedInstance] getAllRoster];
    for (YYRoster *roster in rosterArray) {
        [roster setUser:[[YYIMChat sharedInstance].chatManager getUserWithId:[roster rosterId]]];
    }
    
    // sort with first letter
    rosterArray = [self sortRosters:rosterArray];
    return rosterArray;
}

- (NSArray *)getAllRosterWithAsk {
    NSArray *rosterArray = [[YYIMDBHelper sharedInstance] getAllRosterWithAsk];
    for (YYRoster *roster in rosterArray) {
        [roster setUser:[[YYIMChat sharedInstance].chatManager getUserWithId:[roster rosterId]]];
    }
    
    // sort with first letter
    rosterArray = [self sortRosters:rosterArray];
    return rosterArray;
}

- (NSArray *)sortRosters:(NSArray *)rosterArray {
    // sort with first letter
    rosterArray = [rosterArray sortedArrayUsingComparator:^NSComparisonResult(YYRoster *obj1, YYRoster *obj2) {
        if ([@"#" isEqualToString:[obj1 getFirstLetter]] && [@"#" isEqualToString:[obj2 getFirstLetter]]) {
            return [[obj1 firstLetters] compare:[obj2 firstLetters]];
        } else if ([@"#" isEqualToString:[obj1 getFirstLetter]]) {
            return NSOrderedDescending;
        } else if ([@"#" isEqualToString:[obj2 getFirstLetter]]) {
            return NSOrderedAscending;
        } else {
            NSComparisonResult result = [[obj1 getFirstLetter] compare:[obj2 getFirstLetter]];
            switch (result) {
                case NSOrderedSame:
                    return [[obj1 firstLetters] compare:[obj2 firstLetters]];
                default:
                    return result;
            }
        }
    }];
    return rosterArray;
}

- (YYRoster *)getRosterWithId:(NSString *)rosterId {
    YYRoster *roster = [[YYIMDBHelper sharedInstance] getRosterWithId:rosterId];
    if (roster) {
        [roster setUser:[[YYIMChat sharedInstance].chatManager getUserWithId:[roster rosterId]]];
    }
    return roster;
}

- (void)loadRoster {
    NSString *packetID = [JUMPStream generateJUMPID];
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPRosterItemsRequestPacketOpCode) packetID:packetID];
    
    [[self tracker] addPacket:iq
                       target:self
                     selector:@selector(handleLoadRoster:withInfo:)
                      timeout:30];
    
    [self.activeStream sendPacket:iq];
}

//请求订阅
//{
//    "type":"subscribe",
//    "to":"zhangxin0.udn.yonyou@im.yyuap.com",
//    "from":"zhangxin2.udn.yonyou@im.yyuap.com"
//}
- (void)addRoster:(NSString *)userId {
    if ([YYIMStringUtility isEmpty:userId]) {
        return;
    }
    JUMPJID *userJid = [YYIMJUMPHelper genFullJid:userId];
    JUMPPresence *presence = [JUMPPresence presenceWithOpData:JUMP_OPDATA(JUMPPresencePacketOpCode) type:@"subscribe" to:userJid];
    [[self activeStream] sendPacket:presence];
}

- (void)updateRosterState:(NSInteger)state roster:(NSString *)rosterId clientType:(YYIMClientType)clientType {
    [[YYIMDBHelper sharedInstance] updateRosterState:state roster:rosterId clientType:clientType];
    [[self activeDelegate] didRosterStateChange:rosterId];
}

- (NSArray *)getAllRosterInvite {
    NSArray *rosterArray = [[YYIMDBHelper sharedInstance] getAllRosterInvite];
    // sort with first letter
    rosterArray = [rosterArray sortedArrayUsingComparator:^NSComparisonResult(YYRoster *obj1, YYRoster *obj2) {
        if ([@"#" isEqualToString:[obj1 getFirstLetter]] && [@"#" isEqualToString:[obj2 getFirstLetter]]) {
            return 0;
        } else if ([@"#" isEqualToString:[obj1 getFirstLetter]]) {
            return 1;
        } else if ([@"#" isEqualToString:[obj2 getFirstLetter]]) {
            return -1;
        }
        return [[obj1 getFirstLetter] compare:[obj2 getFirstLetter]];
    }];
    
    for (YYRoster *roster in rosterArray) {
        [roster setUser:[[YYIMChat sharedInstance].chatManager getUserWithId:[roster rosterId]]];
    }
    return rosterArray;
}

- (void)acceptRosterInvite:(NSString *)fromId {
    JUMPPresence *presence = [JUMPPresence presenceWithOpData:JUMP_OPDATA(JUMPPresencePacketOpCode) type:@"subscribed" to:[YYIMJUMPHelper genFullJid:fromId]];
    [[self activeStream] sendPacket:presence];
}

- (void)refuseRosterInvite:(NSString *)fromId {
    JUMPPresence *presence = [JUMPPresence presenceWithOpData:JUMP_OPDATA(JUMPPresencePacketOpCode) type:@"unsubscribed" to:[YYIMJUMPHelper genFullJid:fromId]];
    [[self activeStream] sendPacket:presence];
}

- (NSInteger)getNewRosterInviteCount {
    return [[YYIMDBHelper sharedInstance] newInviteCount];
}

- (void)deleteRoster:(NSString *)rosterId {
    NSString *packetID = [JUMPStream generateJUMPID];
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPRosterPacketOpCode) type:nil packetID:packetID];
    NSMutableDictionary *itemDic = [NSMutableDictionary dictionary];
    [itemDic setObject:[YYIMJUMPHelper genFullJidString:rosterId] forKey:@"jid"];
    [itemDic setObject:@"remove" forKey:@"subscription"];
    [iq setObject:itemDic forKey:@"item"];
    
    [[self tracker] addPacket:iq
                       target:self
                     selector:@selector(handleDeleteRoster:withInfo:)
                      timeout:30];
    
    [[self activeStream] sendPacket:iq];
}

- (void)renameRoster:(NSString *)rosterId name:(NSString *)name {
    YYRoster *roster = [self getRosterWithId:rosterId];
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPRosterPacketOpCode) type:nil packetID:[JUMPStream generateJUMPID]];
    NSMutableDictionary *itemDic = [NSMutableDictionary dictionary];
    [itemDic setObject:[YYIMJUMPHelper genFullJidString:rosterId] forKey:@"jid"];
    [itemDic setObject:name forKey:@"name"];
    if ([roster groups]) {
        [itemDic setObject:[roster groups] forKey:@"groups"];
    }
    [iq setObject:itemDic forKey:@"item"];
    
    [[self tracker] addPacket:iq
                       target:self
                     selector:@selector(handleModifyRoster:withInfo:)
                      timeout:30];
    
    [[self activeStream] sendPacket:iq];
}

- (void)addRosterTags:(NSArray *)rosterTags rosterId:(NSString *)rosterId complete:(void (^)(BOOL result, YYIMError *error))complete {
    if (!rosterTags || rosterTags.count == 0) {
        complete(NO, [YYIMError errorWithCode:YMERROR_CODE_ILLEGAL_ARGUMENT errorMessage:@"rosterTags must be a valid array with data"]);
        return;
    }
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:rosterTags forKey:@"tag"];
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            [manager setRequestSerializer:[YMAFJSONRequestSerializer serializer]];
            NSString *urlString = [[YYIMConfig sharedInstance] getRosterTagAddServlet:rosterId];
            urlString = [NSString stringWithFormat:@"%@?token=%@", urlString, [token tokenStr]];
            
            [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                YYIMLogDebug(@"设置好友tag成功：%@", dic);
                [[YYIMDBHelper sharedInstance] insertRosterTags:rosterTags rosterId:rosterId];
                complete(YES, nil);
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                YYIMLogError(@"设置好友tag失败：%@", error.localizedDescription);
                complete(NO, [YYIMError errorWithNSError:error]);
            }];
        } else {
            complete(NO, tokenError);
        }
    }];
}

- (void)deleteRosterTags:(NSArray *)rosterTags rosterId:(NSString *)rosterId complete:(void (^)(BOOL result, YYIMError *error))complete {
    if (!rosterTags || rosterTags.count == 0) {
        complete(NO, [YYIMError errorWithCode:YMERROR_CODE_ILLEGAL_ARGUMENT errorMessage:@"rosterTags must be a valid array with data"]);
        return;
    }
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:[token tokenStr] forKey:@"token"];
            
            NSMutableString *tagStr = [NSMutableString stringWithFormat:@"["];
            NSInteger count = 0;
            for (NSString *tag in rosterTags) {
                if (count != 0) {
                    [tagStr appendString:@","];
                }
                
                [tagStr appendFormat:@"'%@'",tag];
                count++;
            }
            [tagStr appendString:@"]"];
            [params setObject:tagStr forKey:@"tag"];
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            [manager setResponseSerializer:[YMAFHTTPResponseSerializer serializer]];
            NSString *urlString = [[YYIMConfig sharedInstance] getRosterTagDeleteServlet:rosterId];
            
            [manager DELETE:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                YYIMLogDebug(@"删除好友tag成功：%@", dic);
                [[YYIMDBHelper sharedInstance] deleteRosterTags:rosterTags rosterId:rosterId];
                complete(YES, nil);
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                YYIMLogError(@"删除好友tag失败：%@", error.localizedDescription);
                complete(NO, [YYIMError errorWithNSError:error]);
                
            }];
        } else {
            complete(NO, tokenError);
        }
    }];
}

/**
 *  通过tag获取好友集合
 *
 *  @param tag tag
 *
 *  @return 好友集合
 */
- (NSArray *)getRostersWithTag:(NSString *)tag {
    if ([YYIMStringUtility isEmpty:tag]) {
        return nil;
    }
    
    return [[YYIMDBHelper sharedInstance] getRostersWithTag:tag];
}

#pragma mark jumpstream delegate

- (BOOL)jumpStream:(JUMPStream *)sender didReceiveIQ:(JUMPIQ *)iq {
    BOOL result = [[self tracker] invokeForID:[iq packetID] withObject:iq];
    if (!result) {
        if ([iq checkOpData:JUMP_OPDATA(JUMPRosterItemsResultPacketOpCode)]) {
            return [self didReceiveRosterPush:iq];
        } else if ([iq checkOpData:JUMP_OPDATA(JUMPRosterPacketOpCode)]) {
            return [self didReceiveRosterModify:iq];
        }
    }
    return result;
}

- (void)jumpStream:(JUMPStream *)sender didFailToSendIQ:(JUMPIQ *)iq error:(NSError *)error {
    if ([iq packetID]) {
        [[self tracker] invokeForID:[iq packetID] withObject:nil];
    }
}

- (void)jumpStream:(JUMPStream *)sender didReceivePresence:(JUMPPresence *)presence {
    if (![presence checkOpData:JUMP_OPDATA(JUMPPresencePacketOpCode)]) {
        return;
    }
    
    JUMPJID *fromJid = [presence from];
    if (![[fromJid domain] isEqualToString:[[YYIMConfig sharedInstance] getIMServerName]]) {
        return;
    }
    
    NSString *type = [presence type];
    if ([type isEqualToString:@"subscribe"]) {
        NSString *fromId = [YYIMJUMPHelper parseUser:[fromJid user]];
        if ([[YYIMConfig sharedInstance] isAutoAcceptRosterInvite]) {
            [self acceptRosterInvite:fromId];
        }
    } else if ([type isEqualToString:@"subscribed"]) {
        NSString *fromId = [YYIMJUMPHelper parseUser:[fromJid user]];
        
        YYRoster *roster = [[YYIMDBHelper sharedInstance] getRosterWithId:fromId];
        
        if ([roster ask] == YYIM_ROSTER_ASK_SUB) {
            // gen message
            JUMPMessage *message = [JUMPMessage messageWithOpData:JUMP_OPDATA(JUMPMessagePacketOpCode) to:[YYIMJUMPHelper genFullJid:[[YYIMConfig sharedInstance] getUser]] packetID:[JUMPStream generateJUMPID]];
            [message setFrom:[YYIMJUMPHelper genFullJid:fromId]];
            [message setObject:[presence objectForKey:@"ts"] forKey:@"dateline"];
            YYMessageContent *content = [YYMessageContent contentWithText:@"我通过了你的好友请求，现在我们可以开始聊天了。" atUserArray:nil extendValue:nil];
            [message setObject:[content jsonString:YM_MESSAGE_CONTENT_TEXT] forKey:@"content"];
            [message setObject:[NSNumber numberWithInteger:YM_MESSAGE_CONTENT_TEXT] forKey:@"contentType"];
            [[self activeStream] injectPacket:message];
        } else if ([roster recv] == YYIM_ROSTER_RECV_SUB) {
            // gen message
            JUMPMessage *message = [JUMPMessage messageWithOpData:JUMP_OPDATA(JUMPMessagePacketOpCode) to:[YYIMJUMPHelper genFullJid:[[YYIMConfig sharedInstance] getUser]] packetID:[JUMPStream generateJUMPID]];
            [message setFrom:[YYIMJUMPHelper genFullJid:fromId]];
            [message setObject:[presence objectForKey:@"ts"] forKey:@"dateline"];
            YYMessageContent *content = [[YYMessageContent alloc] init];
            [content setAttribute:@"accept_roster" forKey:@"promptType"];
            [message setObject:[content jsonString:YM_MESSAGE_CONTENT_PROMPT] forKey:@"content"];
            [message setObject:[NSNumber numberWithInteger:YM_MESSAGE_CONTENT_PROMPT] forKey:@"contentType"];
            [[self activeStream] injectPacket:message];
        }
    }
}

#pragma mark private func

- (void)handleLoadRoster:(JUMPPacket *)jumpPacket withInfo:(JUMPBasicTrackingInfo *)trackerInfo {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPRosterItemsResultPacketOpCode)]) {
        YYIMError *error;
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        YYIMLogError(@"didNotLoadRosters:%ld-%@", (long)[error errorCode], [error errorMsg]);
        [[self activeDelegate] didNotLoadRostersWithError:error];
        return;
    }
    
    JUMPIQ *iq = (JUMPIQ *)jumpPacket;
    NSArray *items = [iq objectForKey:@"items"];
    NSMutableArray *rosterArray = [NSMutableArray array];
    if (items && [items count] > 0) {
        for (NSDictionary *item in items) {
            JUMPJID *jid = [JUMPJID jidWithString:[item objectForKey:@"jid"]];
            if (![[[YYIMConfig sharedInstance] getIMServerName] isEqualToString:[jid domain]]) {
                continue;
            }
            
            NSString *subscription = [item objectForKey:@"subscription"];
            NSInteger ask = [[item objectForKey:@"ask"] integerValue];
            NSInteger recv = [[item objectForKey:@"recv"] integerValue];
            if (![YYIM_ROSTER_SUBSCRIPTION_BOTH isEqualToString:subscription]) {
                subscription = YYIM_ROSTER_SUBSCRIPTION_NONE;
                if (ask != YYIM_ROSTER_ASK_SUB && recv != YYIM_ROSTER_RECV_SUB) {
                    continue;
                }
            }
            YYRoster *roster = [[YYRoster alloc] init];
            [roster setRosterId:[YYIMJUMPHelper parseUser:[jid user]]];
            [roster setRosterAlias:[item objectForKey:@"name"]];
            [roster setRosterTag:[item objectForKey:@"tag"]];
            [roster setRosterPhoto:[item objectForKey:@"photo"]];
            [roster setGroups:[item objectForKey:@"groups"]];
            [roster setSubscription:subscription];
            [roster setAsk:ask];
            [roster setRecv:recv];
            [rosterArray addObject:roster];
        }
    }
    [[YYIMDBHelper sharedInstance] batchUpdateRoster:rosterArray];
    [[self activeDelegate] didRosterChange];
}

- (void)handleDeleteRoster:(JUMPIQ *)iq withInfo:(JUMPBasicTrackingInfo *)trackerInfo {
    if (![iq checkOpData:JUMP_OPDATA(JUMPIQResultPacketOpCode)]) {
        return;
    }
}

- (void)handleModifyRoster:(JUMPIQ *)iq withInfo:(JUMPBasicTrackingInfo *)trackerInfo {
    if (![iq checkOpData:JUMP_OPDATA(JUMPIQResultPacketOpCode)]) {
        return;
    }
}

- (BOOL)didReceiveRosterPush:(JUMPIQ *)iq {
    NSArray *items = [iq objectForKey:@"items"];
    if (items && items.count > 0) {
        for (NSDictionary *item in items) {
            JUMPJID *jid = [JUMPJID jidWithString:[item objectForKey:@"jid"]];
            if (![[[YYIMConfig sharedInstance] getIMServerName] isEqualToString:[jid domain]]) {
                continue;
            }
            
            NSString *subscription = [item objectForKey:@"subscription"];
            NSInteger ask = [[item objectForKey:@"ask"] integerValue];
            NSInteger recv = [[item objectForKey:@"recv"] integerValue];
            if (![YYIM_ROSTER_SUBSCRIPTION_BOTH isEqualToString:subscription]) {
                subscription = YYIM_ROSTER_SUBSCRIPTION_NONE;
                if (ask != YYIM_ROSTER_ASK_SUB && recv != YYIM_ROSTER_RECV_SUB) {
                    NSString *rosterId = [YYIMJUMPHelper parseUser:[item objectForKey:@"jid"]];
                    [[YYIMDBHelper sharedInstance] deleteRoster:rosterId];
                    [[self activeDelegate] didRosterChange];
                    [[self activeDelegate] didRosterDelete:rosterId];
                    continue;
                }
            }
            YYRoster *roster = [[YYRoster alloc] init];
            [roster setRosterId:[YYIMJUMPHelper parseUser:[jid user]]];
            [roster setRosterAlias:[item objectForKey:@"name"]];
            [roster setRosterTag:[item objectForKey:@"tag"]];
            [roster setRosterPhoto:[item objectForKey:@"photo"]];
            [roster setGroups:[item objectForKey:@"groups"]];
            [roster setSubscription:subscription];
            [roster setAsk:ask];
            [roster setRecv:recv];
            [[YYIMDBHelper sharedInstance] insertOrUpdateRoster:roster];
            [[self activeDelegate] didRosterChange];
            [[self activeDelegate] didRosterUpdate:roster];
            
            if (ask == YYIM_ROSTER_RECV_SUB) {
                [self playSoundAndVibrate];
            }
        }
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)didReceiveRosterModify:(JUMPIQ *)iq {
    NSDictionary *item = [iq objectForKey:@"item"];
    if (!item) {
        return NO;
    }
    
    JUMPJID *jid = [JUMPJID jidWithString:[item objectForKey:@"jid"]];
    if (![[[YYIMConfig sharedInstance] getIMServerName] isEqualToString:[jid domain]]) {
        return NO;
    }
    
    NSString *subscription = [item objectForKey:@"subscription"];
    NSInteger ask = [[item objectForKey:@"ask"] integerValue];
    NSInteger recv = [[item objectForKey:@"recv"] integerValue];
    if (![YYIM_ROSTER_SUBSCRIPTION_BOTH isEqualToString:subscription]) {
        subscription = YYIM_ROSTER_SUBSCRIPTION_NONE;
        if (ask != YYIM_ROSTER_ASK_SUB && recv != YYIM_ROSTER_RECV_SUB) {
            NSString *rosterId = [YYIMJUMPHelper parseUser:[item objectForKey:@"jid"]];
            [[YYIMDBHelper sharedInstance] deleteRoster:rosterId];
            [[self activeDelegate] didRosterChange];
            [[self activeDelegate] didRosterDelete:rosterId];
            return YES;
        }
    }
    YYRoster *roster = [[YYRoster alloc] init];
    [roster setRosterId:[YYIMJUMPHelper parseUser:[item objectForKey:@"jid"]]];
    [roster setRosterAlias:[item objectForKey:@"name"]];
    [roster setRosterTag:[item objectForKey:@"tag"]];
    [roster setRosterPhoto:[item objectForKey:@"photo"]];
    [roster setGroups:[item objectForKey:@"groups"]];
    [roster setSubscription:subscription];
    [roster setAsk:ask];
    [roster setRecv:recv];
    [[YYIMDBHelper sharedInstance] insertOrUpdateRoster:roster];
    [[self activeDelegate] didRosterChange];
    [[self activeDelegate] didRosterUpdate:roster];
    return YES;
}

@end
