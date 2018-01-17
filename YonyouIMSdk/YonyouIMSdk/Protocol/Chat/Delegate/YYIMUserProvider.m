//
//  YYIMUserProvider.m
//  YonyouIM
//
//  Created by litfb on 15/1/21.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#define YYIM_USER_OVERDUE_THRESHOLD 60 * 60

#import "YYIMUserProvider.h"

#import "JUMPFramework.h"
#import "YYIMChat.h"
#import "YYIMJUMPHelper.h"
#import "YYIMDBHelper.h"
#import "YYIMConfig.h"
#import "YYIMStringUtility.h"
#import "YYIMLogger.h"
#import "YYIMConfig.h"
#import "YMAFNetworking.h"

@implementation YYIMUserProvider

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark protocol

//(opcode:0x2110):
//{
//    "id":"14923983",
//    "start":0,
//    "size":20,
//    "search":"zhangxin",
//    "fields": ["Username","Name","Email"]//如果fields为null, 为Username, Name
//}
- (void)searchUserWithKeyword:(NSString *)keyword {
    if (!keyword) {
        [[self activeDelegate] didReceiveUserSearchResult:nil];
    }
    // JUMPIQ
    NSString *packetId = [JUMPStream generateJUMPID];
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPUserSearchRequestPacketOpCode) packetID:packetId];
    [iq setObject:[NSNumber numberWithInt:0] forKey:@"start"];
    [iq setObject:[NSNumber numberWithInt:20] forKey:@"size"];
    [iq setObject:keyword forKey:@"search"];
    
    [[self tracker] addID:packetId
                   target:self
                 selector:@selector(handleSearchUserResponse:withInfo:)
                  timeout:30];
    // 发包
    [[self activeStream] sendPacket:iq];
}

- (void)loadUser:(NSString *)userId {
    if (![[self activeStream] isAuthenticated]) {
        return;
    }
    if ([YYIMStringUtility isEmpty:userId]) {
        return;
    }
    
    JUMPIQ *jumpIQ = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPVCardPacketOpCode) type:@"get" to:[YYIMJUMPHelper genFullJid:userId] packetID:[JUMPStream generateJUMPID]];
    
    [[self tracker] addPacket:jumpIQ
                       target:self
                     selector:@selector(handleVCardResponse:withInfo:)
                      timeout:30];
    
    [[self activeStream] sendPacket:jumpIQ];
}

- (void)checkUserExist:(NSString *)userId {
    if (![[self activeStream] isAuthenticated]) {
        return;
    }
    if ([YYIMStringUtility isEmpty:userId]) {
        return;
    }
    
    JUMPIQ *jumpIQ = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPVCardPacketOpCode) type:@"get" to:[YYIMJUMPHelper genFullJid:userId] packetID:[JUMPStream generateJUMPID]];
    
    [[self tracker] addPacket:jumpIQ
                       target:self
                     selector:@selector(handleUserExistResponse:withInfo:)
                      timeout:30];
    
    [[self activeStream] sendPacket:jumpIQ];
}

- (void)loadRosterUsers {
    JUMPIQ *jumpIQ = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPVCardPacketOpCode) type:@"roster" to:nil packetID:[JUMPStream generateJUMPID]];
    
    [[self tracker] addPacket:jumpIQ
                       target:self
                     selector:@selector(handleVCardsResponse:withInfo:)
                      timeout:30];
    
    [[self activeStream] sendPacket:jumpIQ];
}

- (YYUser *)getUserWithId:(NSString *)userId {
    YYUser *user = [[YYIMDBHelper sharedInstance] getUserWithId:userId];
    if ([self isUserOverdue:user]) {
        [self loadUser:userId];
    }
    return user;
}

//更改自己的VCard
//opcode 0x2011
//{
//    "id": "003023",
//    "type": "set",
//    "vcard": {
//        "nickname":"",
//        "photo":"",
//        "email":"",
//        "mobile":"",
//        "telephone":""
//    }
//}
- (void)updateUser:(YYUser *)user {
    if (![[self activeStream] isAuthenticated]) {
        return;
    }
    if (!user || [YYIMStringUtility isEmpty:[user userId]]) {
        return;
    }
    JUMPIQ *jumpIQ = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPVCardPacketOpCode) type:@"set" packetID:[JUMPStream generateJUMPID]];
    
    NSMutableDictionary *vCardDic = [NSMutableDictionary dictionary];
    [vCardDic setObject:[user userName] forKey:@"nickname"];
    [vCardDic setObject:[user userEmail] forKey:@"email"];
    [vCardDic setObject:[user userPhoto] forKey:@"photo"];
    [vCardDic setObject:[user userMobile] forKey:@"mobile"];
    [vCardDic setObject:[user userTitle] forKey:@"position"];
    [vCardDic setObject:[user userGender] forKey:@"gender"];
    [vCardDic setObject:[user userNumber] forKey:@"number"];
    [vCardDic setObject:[user userTelephone] forKey:@"telephone"];
    [vCardDic setObject:[user userLocation] forKey:@"location"];
    [vCardDic setObject:[user userDesc] forKey:@"remarks"];
    
    [jumpIQ setObject:vCardDic forKey:@"vcard"];
    
    [[self tracker] addPacket:jumpIQ
                       target:self
                     selector:@selector(handleVCardUpdateResponse:withInfo:)
                      timeout:30];
    
    [[self activeStream] sendPacket:jumpIQ];
}

- (void)deleteAllUnExistUserMessages {
    NSArray *array = [[YYIMDBHelper sharedInstance] getRecentMessage2];
    for (YYRecentMessage *message in array) {
        if ([message isSystemMessage]) {
            continue;
        }
        
        [self checkUserExist:[message rosterId]];
    }
}

- (void)deleteUnExistUserMessage:(NSString *)userId {
    [self checkUserExist:userId];
}

- (void)AddUserTags:(NSArray *)userTags complete:(void (^)(BOOL, YYIMError *))complete {
    if (!userTags || userTags.count == 0) {
        complete(NO, [YYIMError errorWithCode:YMERROR_CODE_ILLEGAL_ARGUMENT errorMessage:@"usertags must be a valid array with data"]);
        return;
    }
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:userTags forKey:@"tag"];
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            [manager setRequestSerializer:[YMAFJSONRequestSerializer serializer]];
            NSString *urlString = [[YYIMConfig sharedInstance] getUserTagAddServlet];
            urlString = [NSString stringWithFormat:@"%@?token=%@", urlString, [token tokenStr]];
            
            [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                YYIMLogDebug(@"设置用户tag成功：%@", dic);
                
                //数据库增加tag
                [[YYIMDBHelper sharedInstance] insertUserTags:userTags userId:[[YYIMConfig sharedInstance] getUser]];
                complete(YES, nil);
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                YYIMLogError(@"设置用户tag失败：%@", error.localizedDescription);
                complete(NO, [YYIMError errorWithNSError:error]);
            }];
        } else {
            complete(NO, tokenError);
        }
    }];
}

- (void)deleteUserTags:(NSArray *)userTags complete:(void (^)(BOOL, YYIMError *))complete {
    if (!userTags || userTags.count == 0) {
        complete(NO, [YYIMError errorWithCode:YMERROR_CODE_ILLEGAL_ARGUMENT errorMessage:@"usertags must be a valid array with data"]);
        return;
    }
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:[token tokenStr] forKey:@"token"];
            
            NSMutableString *tagStr = [NSMutableString stringWithFormat:@"["];
            NSInteger count = 0;
            for (NSString *tag in userTags) {
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
            NSString *urlString = [[YYIMConfig sharedInstance] getUserTagDeleteServlet];
            
            [manager DELETE:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                YYIMLogDebug(@"删除用户tag成功：%@", dic);
                
                //从数据库删除tag
                [[YYIMDBHelper sharedInstance] deletetUserTags:userTags userId:[[YYIMConfig sharedInstance] getUser]];
                complete(YES, nil);
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                YYIMLogError(@"删除用户tag失败：%@", error.localizedDescription);
                complete(NO, [YYIMError errorWithNSError:error]);
                
            }];
        } else {
            complete(NO, tokenError);
        }
    }];
}

#pragma mark jump delegate

- (BOOL)jumpStream:(JUMPStream *)sender didReceiveIQ:(JUMPIQ *)iq {
    return [[self tracker] invokeForID:[iq packetID] withObject:iq];
}

- (void)jumpStream:(JUMPStream *)sender didFailToSendIQ:(JUMPIQ *)iq error:(NSError *)error {
    if ([iq packetID]) {
        [[self tracker] invokeForID:[iq packetID] withObject:nil];
    }
}

#pragma mark private func

//(opcode:0x2111):
//{
//    "id":"928989383",
//    "from":"search.im.yyuap.com",
//    "start":0,
//    "total":130,
//    "items":[
//             {
//                 "name":"张新",
//                 "email":"zhangxin0@yonyou.com",
//                 "photo":"/group/00/01/DE/...../.jpg",
//                 "jid":"zhangxin0.udn.yonyou@im.yyuap.com"
//             },{
//                 "name":"小xinxin",
//                 "email":"zhangxin1@yonyou.com",
//                 "jid":"zhangxin1.udn.yonyou@im.yyuap.com"
//             }
//             ]
//}
- (void)handleSearchUserResponse:(JUMPIQ *)jumpIQ withInfo:(id <JUMPTrackingInfo>)info {
    if (!jumpIQ) {
        YYIMLogError(@"didNotReceiveSearchUserResult");
        [[self activeDelegate] didNotReceiveUserSearchResult:nil];
        return;
    }
    if (![jumpIQ checkOpData:JUMP_OPDATA(JUMPUserSearchResultPacketOpCode)]) {
        YYIMLogError(@"didNotReceiveSearchUserResult:%@-%@", [jumpIQ headerData], [jumpIQ packetData]);
        [[self activeDelegate] didNotReceiveUserSearchResult:nil];
        return;
    }
    
    NSArray *items = [jumpIQ objectForKey:@"items"];
    if (!items || [items count] <= 0) {
        [[self activeDelegate] didReceiveUserSearchResult:nil];
    }
    
    NSMutableArray *userArray = [NSMutableArray array];
    for (NSDictionary *item in items) {
        NSString *userId = [YYIMJUMPHelper parseUser:[item objectForKey:@"jid"]];
        if ([[[YYIMConfig sharedInstance] getUser] isEqualToString:userId]) {
            continue;
        }
        YYUser *user = [[YYUser alloc] init];
        [user setUserId:userId];
        [user setUserName:[item objectForKey:@"name"]];
        [user setUserEmail:[item objectForKey:@"email"]];
        [user setUserPhoto:[item objectForKey:@"photo"]];
        // add to array
        [userArray addObject:user];
    }
    [[self activeDelegate] didReceiveUserSearchResult:userArray];
}

- (BOOL)isUserOverdue:(YYUser *)user {
    if (!user) {
        return NO;
    }
    NSInteger timeInterval = [[NSDate date] timeIntervalSince1970];
    if (timeInterval - [user lastUpdate] < YYIM_USER_OVERDUE_THRESHOLD) {
        return NO;
    }
    return YES;
}

- (void)handleVCardResponse:(JUMPIQ *)iq withInfo:(JUMPBasicTrackingInfo *)trackerInfo{
    if (!iq || ![iq checkOpData:JUMP_OPDATA(JUMPVCardPacketOpCode)]) {
        return;
    }
    
    NSDictionary *vCardDic = [iq objectForKey:@"vcard"];
    if (!vCardDic) {
        return;
    }
    
    NSNumber *codeNumber = [iq objectForKey:@"code"];
    if (!codeNumber || [codeNumber intValue] == 200) {
        YYUser *user = [[YYUser alloc] init];
        [user setUserId:[YYIMJUMPHelper parseUser:[vCardDic objectForKey:@"username"]]];
        [user setUserName:[vCardDic objectForKey:@"nickname"]];
        [user setUserEmail:[vCardDic objectForKey:@"email"]];
        [user setUserOrg:[vCardDic objectForKey:@"organization"]];
        [user setUserOrgId:[vCardDic objectForKey:@"orgId"]];
        [user setUserPhoto:[vCardDic objectForKey:@"photo"]];
        [user setUserMobile:[vCardDic objectForKey:@"mobile"]];
        [user setUserTitle:[vCardDic objectForKey:@"position"]];
        [user setUserGender:[vCardDic objectForKey:@"gender"]];
        [user setUserNumber:[vCardDic objectForKey:@"number"]];
        [user setUserTelephone:[vCardDic objectForKey:@"telephone"]];
        [user setUserLocation:[vCardDic objectForKey:@"location"]];
        [user setUserDesc:[vCardDic objectForKey:@"remarks"]];
        [user setUserTag:[vCardDic objectForKey:@"tag"]];
        [user setLastUpdate:[[NSDate date] timeIntervalSince1970]];
        [[YYIMDBHelper sharedInstance] insertOrUpdateUser:user];
        [[self activeDelegate] didUserInfoUpdate:user];
        if ([[user userId] isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
            NSArray *enableFields = [iq objectForKey:@"enableFields"];
            [[YYIMConfig sharedInstance] setUserSetting:enableFields];
        }
    } else if ([codeNumber intValue] == 404) {
        YYUser *user = [[YYUser alloc] init];
        [user setUserId:[YYIMJUMPHelper parseUser:[iq fromStr]]];
        [user setLastUpdate:[[NSDate date] timeIntervalSince1970]];
        [[YYIMDBHelper sharedInstance] insertOrUpdateUser:user];
        [[self activeDelegate] didUserInfoUpdate:user];
    }
}

- (void)handleUserExistResponse:(JUMPIQ *)iq withInfo:(JUMPBasicTrackingInfo *)trackerInfo{
    if (!iq || ![iq checkOpData:JUMP_OPDATA(JUMPVCardPacketOpCode)]) {
        return;
    }
    
    NSDictionary *vCardDic = [iq objectForKey:@"vcard"];
    if (!vCardDic) {
        return;
    }
    
    NSNumber *codeNumber = [iq objectForKey:@"code"];
    if (!codeNumber) {
        return;
    }
    
    if ([codeNumber intValue] == 404) {
        NSString *userId = [YYIMJUMPHelper parseUser:[iq fromStr]];
        [[YYIMDBHelper sharedInstance] deleteUnExistUser:userId];
        [[self activeDelegate] didMessageDelete:[NSDictionary dictionaryWithObject:userId forKey:@"userId"]];
    }
}

- (void)handleVCardsResponse:(JUMPPacket *)jumpPacket withInfo:(JUMPBasicTrackingInfo *)trackerInfo{
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPRosterVCardsPacketOpCode)]) {
        YYIMError *error;
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        YYIMLogError(@"didNotLoadRosterUsers:%ld-%@", (long)[error errorCode], [error errorMsg]);
        [[self activeDelegate] didNotLoadRosterUsersWithError:error];
        return;
    }
    
    JUMPIQ *iq = (JUMPIQ *)jumpPacket;
    NSArray *vCardArray = [iq objectForKey:@"vcards"];
    if (!vCardArray) {
        return;
    }
    
    for (NSDictionary *vCardDic in vCardArray) {
        YYUser *user = [[YYUser alloc] init];
        [user setUserId:[YYIMJUMPHelper parseUser:[vCardDic objectForKey:@"username"]]];
        [user setUserName:[vCardDic objectForKey:@"nickname"]];
        [user setUserEmail:[vCardDic objectForKey:@"email"]];
        [user setUserOrg:[vCardDic objectForKey:@"organization"]];
        [user setUserOrgId:[vCardDic objectForKey:@"orgId"]];
        [user setUserPhoto:[vCardDic objectForKey:@"photo"]];
        [user setUserMobile:[vCardDic objectForKey:@"mobile"]];
        [user setUserTitle:[vCardDic objectForKey:@"position"]];
        [user setUserGender:[vCardDic objectForKey:@"gender"]];
        [user setUserNumber:[vCardDic objectForKey:@"number"]];
        [user setUserTelephone:[vCardDic objectForKey:@"telephone"]];
        [user setUserLocation:[vCardDic objectForKey:@"location"]];
        [user setUserDesc:[vCardDic objectForKey:@"remarks"]];
        [user setUserTag:[vCardDic objectForKey:@"tag"]];
        [user setLastUpdate:[[NSDate date] timeIntervalSince1970]];
        [[YYIMDBHelper sharedInstance] insertOrUpdateUser:user];
        [[self activeDelegate] didUserInfoUpdate:user];
    }
}

- (void)handleVCardUpdateResponse:(JUMPIQ *)iq withInfo:(JUMPBasicTrackingInfo *)trackerInfo {
    [self loadUser:[[YYIMConfig sharedInstance] getUser]];
}

@end
