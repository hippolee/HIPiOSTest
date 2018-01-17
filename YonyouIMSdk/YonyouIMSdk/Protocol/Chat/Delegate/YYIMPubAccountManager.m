//
//  YYIMPubAccountManager.m
//  YonyouIMSdk
//
//  Created by litfb on 15/4/13.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMPubAccountManager.h"
#import "JUMPFramework.h"
#import "YYIMConfig.h"
#import "YYIMJUMPHelper.h"
#import "YYIMDBHelper.h"
#import "YYIMStringUtility.h"
#import "YYIMLogger.h"
#import "YYIMConfig.h"
#import "YMAFNetworking.h"

@interface YYIMPubAccountManager ()<JUMPStreamDelegate>

@end

@implementation YYIMPubAccountManager

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark pub account protocol

- (void)loadPubAccount {
    // JUMPIQ
    NSString *packetId = [JUMPStream generateJUMPID];
    JUMPIQ *jumpIQ = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPPubAccountRequestItemsPacketOpCode) packetID:packetId];
    
    [[self tracker] addID:packetId
                   target:self
                 selector:@selector(handleLoadPubAccountResponse:withInfo:)
                  timeout:30];
    // 发包
    [[self activeStream] sendPacket:jumpIQ];
}

- (NSArray *)getAllPubAccount {
    return [[YYIMDBHelper sharedInstance] getAllPubAccount];
}

- (YYPubAccount *)getPubAccountWithAccountId:(NSString *)accountId {
    return [[YYIMDBHelper sharedInstance] getPubAccountWithId:accountId];
}

//(opcode:0x2150):
//{
//    "id":"14923983",
//    "start":0,
//    "size":20,
//    "search":"zhangxin",
//    "fields": ["Accountname","Name"]//如果fields==null, 默认有Accountname,Name
//}
- (void)searchPubAccountWithKeyword:(NSString *)keyword {
    if (!keyword) {
        [[self activeDelegate] didReceivePubAccountSearchResult:nil];
    }
    // JUMPIQ
    NSString *packetId = [JUMPStream generateJUMPID];
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPPubaccountSearchRequestPacketOpCode) packetID:packetId];
    [iq setObject:[NSNumber numberWithInt:0] forKey:@"start"];
    [iq setObject:[NSNumber numberWithInt:20] forKey:@"size"];
    [iq setObject:keyword forKey:@"search"];
    
    [[self tracker] addID:packetId
                   target:self
                 selector:@selector(handleSearchPubAccountResponse:withInfo:)
                  timeout:30];
    // 发包
    [[self activeStream] sendPacket:iq];
}


//请求订阅
//{
//    "type":"subscribe",
//    "to":"zhangxin0.udn.yonyou@im.yyuap.com",
//    "from":"zhangxin2.udn.yonyou@im.yyuap.com"
//}
- (void)followPubAccount:(NSString *)accountId {
    JUMPPresence *presence = [JUMPPresence presenceWithOpData:JUMP_OPDATA(JUMPPresencePacketOpCode) type:@"subscribe" to:[YYIMJUMPHelper genFullPubAccountJid:accountId]];
    [[self activeStream] sendPacket:presence];
}


//取消订阅公共账号
//{
//    "id":"000001",
//    "type":"unsubscribe",
//    "to":"usee.udn.yonyou@pubaccount.im.yyuap.com"
//}
- (void)unFollowPubAccount:(NSString *)accountId {
    JUMPPresence *presence = [JUMPPresence presenceWithOpData:JUMP_OPDATA(JUMPPresencePacketOpCode) type:@"unsubscribe" to:[YYIMJUMPHelper genFullPubAccountJid:accountId]];
    
    NSString *packetId = [JUMPStream generateJUMPID];
    [presence setPacketID:packetId];
    
    [[self tracker] addID:packetId
                   target:self
                 selector:@selector(handleUnfollowPubAccountResponse:withInfo:)
                  timeout:30];
    
    [[self activeStream] sendPacket:presence];
}

- (YYPubAccountMenu *)getPubAccountMenu:(NSString *)accountId {
    //从数据库获取
    YYPubAccountMenu *menu = [[YYIMDBHelper sharedInstance] getPubAccountMenu:accountId];
    if (menu) {
        //json to dic
        NSString *menuJson = menu.menuJson;
        NSError *error;
        id contentObj = [YYIMStringUtility decodeJsonString:menuJson error:&error];
        if (!error && contentObj && [contentObj isKindOfClass:[NSDictionary class]]) {
            [self fillPubAccountMenu:menu withDic:contentObj ];
        }
    }

    return menu;
}

- (void)LoadPubAccountMenu:(NSString *)accountId {
    // 用户ID
    NSString *user = [[YYIMConfig sharedInstance] getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        return;
    }
    
    YYPubAccountMenu *oldMenu = [[YYIMDBHelper sharedInstance] getPubAccountMenu:accountId];
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:[token tokenStr] forKey:@"token"];
            
            if (oldMenu) {
                [params setObject:[NSNumber numberWithDouble:oldMenu.ts]  forKey:@"ts"];
            }
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            NSString *urlString = [[YYIMConfig sharedInstance] getPubAccountMenuServlet:accountId];
            
            [manager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                if (![dic objectForKey:@"menu"]) {
                    //如果返回中没有数据，但是数据库总有数据，删除数据库数据，并通知更新。如果以前没有，什么都不做，没有变化
                    if (oldMenu) {
                        [[YYIMDBHelper sharedInstance] deletePubAccountMenu:accountId];
                        [self.activeDelegate didPubAccountMenuChange:accountId];
                    }
                } else {
                    NSError *error;
                    NSString *menuJson = [YYIMStringUtility encodeJsonObject:dic error:&error];
                    
                    if (error || !menuJson) {
                        return;
                    }
                    
                    //更新数据库
                    YYPubAccountMenu *menu = [[YYPubAccountMenu alloc] init];
                    [menu setAccountId:accountId];
                    [menu setMenuJson:menuJson];
                    [menu setLastUpdate:[[NSDate date] timeIntervalSince1970]];
                    [menu setTs:[[dic objectForKey:@"ts"] longLongValue]];
                    [[YYIMDBHelper sharedInstance] insertOrUpdatePubAccountMenu:menu accountId:accountId];
                    //通知前台
                    [self.activeDelegate didPubAccountMenuChange:accountId];
                }
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                if (response.statusCode == 304) {
                    //如果是304表示没有更新
                    return;
                }
                
                YYIMLogError(@"获取公共号菜单失败：%@", error.localizedDescription);
            }];
        } else {
            YYIMLogError(@"获取公共号菜单失败：%@", tokenError.errorMsg);
        }
    }];
}

- (void)sendPubAccountMenuCommand:(NSString *)accountId item:(YYPubAccountMenuItem *)item {
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:@"click" forKey:@"eventType"];
            [params setObject:item.itemKey forKey:@"eventKey"];
            [params setObject:item.itemName forKey:@"eventValue"];
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            [manager setRequestSerializer:[YMAFJSONRequestSerializer serializer]];
            NSString *urlString = [[YYIMConfig sharedInstance] getPubAccountMenuCommandServlet:accountId];
            urlString = [NSString stringWithFormat:@"%@?token=%@", urlString, [token tokenStr]];
            
            [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                YYIMLogDebug(@"发送公共号命令成功：%@", dic);
                [self.activeDelegate didSendPubAccountxCommandSuccess:accountId];
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                YYIMLogError(@"发送公共号命令失败：%@", error.localizedDescription);
                [self.activeDelegate didNotSendPubAccountCommandFailed:accountId error:[YYIMError errorWithNSError:error]];
            }];
        } else {
        }
    }];
}

/**
 *  通过tag获取公共号集合
 *
 *  @param tag tag
 *
 *  @return公共号集合
 */
- (NSArray *)getPubAccountsWithTag:(NSString *)tag {
    if ([YYIMStringUtility isEmpty:tag]) {
        return nil;
    }
    
    return [[YYIMDBHelper sharedInstance] getPubAccountsWithTag:tag];
}

#pragma mark jumpstream delegate

- (BOOL)jumpStream:(JUMPStream *)sender didReceiveIQ:(JUMPIQ *)iq {
    BOOL result = [[self tracker] invokeForID:[iq packetID] withObject:iq];
    if (!result) {
        if ([[[YYIMConfig sharedInstance] getPubAccountServerName] isEqualToString:[[iq from] domain]]) {
            return [self didReceivePubAccountPush:iq];
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
    if ([presence packetID]) {
        [[self tracker] invokeForID:[presence packetID] withObject:presence];
    }
}

#pragma mark private func

//(opcode:0x2251)
//{
//    "id":"yf3o6o5sfxp0e8axeja9",
//    "items":[{
//                 "jid":"uap_data.udn.yonyou@im.yyuap.com",
//                 "name":"uap"
//             }]
//}
- (void)handleLoadPubAccountResponse:(JUMPPacket *)jumpPacket withInfo:(id <JUMPTrackingInfo>)info {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPPubaccountItemsResultPacketOpCode)]) {
        YYIMError *error;
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        YYIMLogError(@"didNotLoadPubAccount:%ld-%@", (long)[error errorCode], [error errorMsg]);
        [[self activeDelegate] didNotLoadPubAccountWithError:error];
        return;
    }
    
    JUMPIQ *jumpIQ = (JUMPIQ *)jumpPacket;
    NSArray *items = [jumpIQ objectForKey:@"items"];
    NSMutableArray *accountArray = [NSMutableArray array];
    if (items && [items count] > 0) {
        for (NSDictionary *item in items) {
            YYPubAccount *account = [[YYPubAccount alloc] init];
            [account setAccountId:[YYIMJUMPHelper parseUser:[item objectForKey:@"jid"]]];
            NSString *name = [item objectForKey:@"name"];
            if ([YYIMStringUtility isEmpty:name]) {
                name = [account accountId];
            }
            [account setAccountName:name];
            [account setAccountPhoto:[item objectForKey:@"photo"]];
            [account setAccountType:[[item objectForKey:@"type"] integerValue]];
            [account setAccountDesc:[item objectForKey:@"description"]];
            [account setAccountTag:[item objectForKey:@"tag"]];
            
            [accountArray addObject:account];
        }
        
    }
    [[YYIMDBHelper sharedInstance] batchUpdatePubAccount:accountArray];
    [[self activeDelegate] didPubAccountChange];
}

//(opcode:0x2151):
//{
//    "id":"928989383",
//    "from":"pubaccount.im.yyuap.com",
//    "start":0,
//    "total":130,
//    "items":[
//             {
//                 "name":"uap_data",
//                 "jid":"uap_data.udn.yonyou@pubaccount.im.yyuap.com"
//             },{
//                 "name":"uap_data2",
//                 "jid":"uap_data2.udn.yonyou@pubaccount.im.yyuap.com"
//             }
//             ]
//}
- (void)handleSearchPubAccountResponse:(JUMPIQ *)jumpIQ withInfo:(id <JUMPTrackingInfo>)info {
    if (!jumpIQ) {
        YYIMLogError(@"didNotReceiveSearchResult");
        [[self activeDelegate] didNotReceivePubAccountSearchResult:nil];
        return;
    }
    if (![jumpIQ checkOpData:JUMP_OPDATA(JUMPPubaccountSearchResultPacketOpCode)]) {
        YYIMLogError(@"didNotReceiveSearchResult:%@-%@", [jumpIQ headerData], [jumpIQ jsonString]);
        [[self activeDelegate] didNotReceivePubAccountSearchResult:nil];
        return;
    }
    
    NSArray *items = [jumpIQ objectForKey:@"items"];
    if (!items || [items count] <= 0) {
        [[self activeDelegate] didReceivePubAccountSearchResult:nil];
    }
    
    NSMutableArray *accountArray = [NSMutableArray array];
    for (NSDictionary *item in items) {
        YYPubAccount *account = [[YYPubAccount alloc] init];
        [account setAccountId:[YYIMJUMPHelper parseUser:[item objectForKey:@"jid"]]];
        [account setAccountName:[item objectForKey:@"name"]];
        [account setAccountDesc:[item objectForKey:@"description"]];
        
        // add to array
        [accountArray addObject:account];
    }
    [[self activeDelegate] didReceivePubAccountSearchResult:accountArray];
}

- (void)handleUnfollowPubAccountResponse:(JUMPPresence *)jumpPacket withInfo:(id <JUMPTrackingInfo>)info {
    NSString *type = [jumpPacket type];
    if (![@"unsubscribed" isEqualToString:type]) {
        return;
    }
    
    NSString *accountId = [YYIMJUMPHelper parseUser:[[jumpPacket from] user]];
    [[YYIMDBHelper sharedInstance] deletePubAccount:accountId];
    [[self activeDelegate] didPubAccountChange];
    [[self activeDelegate] didMessageDelete:[NSDictionary dictionaryWithObject:accountId forKey:@"accountId"]];
}

- (BOOL)didReceivePubAccountPush:(JUMPIQ *)iq {
    if (![iq checkOpData:JUMP_OPDATA(JUMPPubaccountItemsResultPacketOpCode)]) {
        return NO;
    }
    
    NSArray *items = [iq objectForKey:@"items"];
    if (items && items.count > 0) {
        for (NSDictionary *item in items) {
            JUMPJID *jid = [JUMPJID jidWithString:[item objectForKey:@"jid"]];
            if (![[[YYIMConfig sharedInstance] getPubAccountServerName] isEqualToString:[jid domain]]) {
                continue;
            }
            
            YYPubAccount *account = [[YYPubAccount alloc] init];
            [account setAccountId:[YYIMJUMPHelper parseUser:[jid user]]];
            NSString *name = [item objectForKey:@"name"];
            if ([YYIMStringUtility isEmpty:name]) {
                name = [account accountId];
            }
            [account setAccountName:name];
            [account setAccountPhoto:[item objectForKey:@"photo"]];
            [account setAccountType:[[item objectForKey:@"type"] integerValue]];
            [account setAccountTag:[item objectForKey:@"tag"]];
            [[YYIMDBHelper sharedInstance] insertOrUpdatePubAccount:account];
            [[self activeDelegate] didPubAccountChange];
        }
        return YES;
    } else {
        return NO;
    }
}

- (void)fillPubAccountMenu:(YYPubAccountMenu *)menu withDic:(NSDictionary *)dic {
    if (![dic objectForKey:@"menu"]) {
        return;
    }
    
    NSArray *categorys = [dic objectForKey:@"menu"];
    NSMutableArray *categoryArray = [NSMutableArray array];
    
    for (NSDictionary *category in categorys) {
        YYPubAccountMenuItem *menuFirstLevel = [[YYPubAccountMenuItem alloc] init];
        if ([category objectForKey:@"menuItem"]) {
            NSArray *items = [category objectForKey:@"menuItem"];
            NSMutableArray *itemArray = [NSMutableArray array];
            
            for (NSDictionary *item in items) {
                YYPubAccountMenuItem *menuItem = [[YYPubAccountMenuItem alloc] init];
                [menuItem setItemName:[item objectForKey:@"name"]];
                
                if ([[item objectForKey:@"type"] isEqualToString:@"click"]) {
                    [menuItem setItemType:kYYPubAccountMenuItemTypeCommand];
                    [menuItem setItemKey:[item objectForKey:@"key"]];
                } else if ([[item objectForKey:@"type"] isEqualToString:@"view"]) {
                    [menuItem setItemType:kYYPubAccountMenuItemTypeURL];
                    [menuItem setItemUrl:[item objectForKey:@"url"]];
                } else {
                    [menuItem setItemType:kYYPubAccountMenuItemTypeURL];
                    [menuItem setItemUrl:[item objectForKey:@"url"]];
                }
                
                [itemArray addObject:menuItem];
                [menuFirstLevel setItemArray:itemArray];
                [menuFirstLevel setItemName:[category objectForKey:@"name"]];
            }
        } else {
            [menuFirstLevel setItemName:[category objectForKey:@"name"]];
            
            if ([[category objectForKey:@"type"] isEqualToString:@"click"]) {
                [menuFirstLevel setItemType:kYYPubAccountMenuItemTypeCommand];
                [menuFirstLevel setItemKey:[category objectForKey:@"key"]];
            } else if ([[category objectForKey:@"type"] isEqualToString:@"view"]) {
                [menuFirstLevel setItemType:kYYPubAccountMenuItemTypeURL];
                [menuFirstLevel setItemUrl:[category objectForKey:@"url"]];
            } else {
                [menuFirstLevel setItemType:kYYPubAccountMenuItemTypeURL];
                [menuFirstLevel setItemUrl:[category objectForKey:@"url"]];
            }
        }
        
        [categoryArray addObject:menuFirstLevel];
    }
    
    [menu setMenuItemArray:categoryArray];
}

@end
