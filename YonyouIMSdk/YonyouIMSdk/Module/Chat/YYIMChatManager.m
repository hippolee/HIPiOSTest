//
//  YYIMChatManager.m
//  YonyouIM
//
//  Created by litfb on 14/12/30.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JUMPFramework.h"
#import "YYIMBaseDataManager.h"
#import "YYIMChatManager.h"
#import "YYIMConfig.h"
#import "YYIMDBHelper.h"
#import "YYIMDefs.h"
#import "YYIMLoginManager.h"
#import "YYIMMessageManager.h"
#import "YYIMRosterProvider.h"
#import "YYIMRosterCollectProvider.h"
#import "YYIMChatGroupProvider.h"
#import "YYIMChatGroupVersionProvider.h"
#import "YYIMUserProvider.h"
#import "YYIMExtManager.h"
#import "YYIMConnectManager.h"
#import "YYIMPubAccountManager.h"
#import "YYIMNotificationManager.h"
#import "YYIMTeleconferenceManager.h"
#import "YYIMNetMeetingManager.h"
#import "YYIMAttachManager.h"
#import "YYFMDB.h"
#import "YYIMHttpUtility.h"
#import "YYIMStringUtility.h"
#import "YYRoster.h"
#import "YYIMJUMPHelper.h"
#import "YYIMChatGroupMemberDBHelper.h"
#import "YYIMPanDBHelper.h"
#import "YYIMNetMeetingDBHelper.h"
#import "YYIMLogger.h"

@interface YYIMChatManager ()<JUMPStreamDelegate>

@property (retain, nonatomic) id<YYIMTokenDelegate> tokenDelegate;

@property (retain, nonatomic) YYIMLoginManager *loginManager;
@property (retain, nonatomic) YYIMMessageManager *messageManager;
@property (retain, nonatomic) YYIMConnectManager *connectManager;
@property (retain, nonatomic) YYIMExtManager *extManager;
@property (retain, nonatomic) YYIMPubAccountManager *pubAccountManager;
@property (retain, nonatomic) YYIMNotificationManager *notificationManager;
@property (retain, nonatomic) YYIMTeleconferenceManager *teleconferenceManager;
@property (retain, nonatomic) YYIMNetMeetingManager *netMeetingManager;
@property (retain, nonatomic) YYIMAttachManager *attachManager;

@end

@implementation YYIMChatManager

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark init

- (instancetype)init {
    if (self = [super init]) {
        // JUMPStream
        JUMPStream *jumpStream = [[JUMPStream alloc] init];
        // delegate
        YMGCDMulticastDelegate<YYIMChatDelegate> *multicastDelegate = (YMGCDMulticastDelegate<YYIMChatDelegate> *)[[YMGCDMulticastDelegate alloc] init];
        [self activateWithJUMPStream:jumpStream delegate:multicastDelegate];
        
        // db
        [[YYIMDBHelper sharedInstance] setupDatabase];
        [[YYIMChatGroupMemberDBHelper sharedInstance] setupDatabase];
        [[YYIMPanDBHelper sharedInstance] setupDatabase];
        [[YYIMNetMeetingDBHelper sharedInstance] setupDatabase];
        
        // loginManager
        self.loginManager = [YYIMLoginManager sharedInstance];
        [self.loginManager activateWithJUMPStream:jumpStream delegate:multicastDelegate];
        // messageManager
        self.messageManager = [YYIMMessageManager sharedInstance];
        [self.messageManager activateWithJUMPStream:jumpStream delegate:multicastDelegate];
        // connectManager
        self.connectManager = [YYIMConnectManager sharedInstance];
        [self.connectManager activateWithJUMPStream:jumpStream delegate:multicastDelegate];
        // extManager
        self.extManager = [YYIMExtManager sharedInstance];
        [self.extManager activateWithJUMPStream:jumpStream delegate:multicastDelegate];
        // pubAccountManager
        self.pubAccountManager = [YYIMPubAccountManager sharedInstance];
        [self.pubAccountManager activateWithJUMPStream:jumpStream delegate:multicastDelegate];
        // notification
        self.notificationManager = [YYIMNotificationManager sharedInstance];
        [self.notificationManager activateWithJUMPStream:jumpStream delegate:multicastDelegate];
        [self addDelegate:self.notificationManager];
        // teleconference
        self.teleconferenceManager = [YYIMTeleconferenceManager sharedInstance];
        [self.teleconferenceManager activateWithJUMPStream:jumpStream delegate:multicastDelegate];
        // netmeeting
        self.netMeetingManager = [YYIMNetMeetingManager sharedInstance];
        [self.netMeetingManager activateWithJUMPStream:jumpStream delegate:multicastDelegate];
        // attach
        self.attachManager = [YYIMAttachManager sharedInstance];
        [self.attachManager activateWithJUMPStream:jumpStream delegate:multicastDelegate];
    }
    return self;
}

- (void)addDelegate:(id<YYIMChatDelegate>)delegate {
    [super addDelegate:delegate];
}

- (void)removeDelegate:(id<YYIMChatDelegate>)delegate {
    [super removeDelegate:delegate];
}

#pragma mark -
#pragma mark register providers

- (void)regisgerRosterProvider:(id<YYIMRosterProtocol>)rosterProvider {
    self.rosterProvider = rosterProvider;
    if ([self.rosterProvider respondsToSelector:@selector(activeYYIMDelegate:)]) {
        [self.rosterProvider activeYYIMDelegate:self.activeDelegate];
    }
}

- (void)registerChatGroupProvider:(id<YYIMChatGroupProtocol>) chatGroupProvider {
    self.chatGroupProvider = chatGroupProvider;
    if ([self.chatGroupProvider respondsToSelector:@selector(activeYYIMDelegate:)]) {
        [self.chatGroupProvider activeYYIMDelegate:self.activeDelegate];
    }
}

- (void)registerUserProvider:(id<YYIMUserProtocol>)userProvider {
    self.userProvider = userProvider;
    if ([self.userProvider respondsToSelector:@selector(activeYYIMDelegate:)]) {
        [self.userProvider activeYYIMDelegate:self.activeDelegate];
    }
}

- (id<YYIMRosterProtocol>)getRosterProvider {
    if (!self.rosterProvider) {
        if ([[YYIMConfig sharedInstance] isRosterCollect]) {
            YYIMRosterCollectProvider *rosterProvider = [YYIMRosterCollectProvider sharedInstance];
            [rosterProvider activateWithJUMPStream:[self activeStream] delegate:[self activeDelegate]];
            self.rosterProvider = rosterProvider;
        } else {
            YYIMRosterProvider *rosterProvider = [YYIMRosterProvider sharedInstance];
            [rosterProvider activateWithJUMPStream:[self activeStream] delegate:[self activeDelegate]];
            self.rosterProvider = rosterProvider;
        }
    }
    return self.rosterProvider;
}

- (id<YYIMChatGroupProtocol>)getChatGroupProvider {
    if (!self.chatGroupProvider) {
        if ([[YYIMConfig sharedInstance] isChatGroupVersion]) {
            YYIMChatGroupVersionProvider *chatGroupProvider = [YYIMChatGroupVersionProvider sharedInstance];
            [chatGroupProvider activateWithJUMPStream:[self activeStream] delegate:[self activeDelegate]];
            self.chatGroupProvider = chatGroupProvider;
        } else {
            YYIMChatGroupProvider *chatGroupProvider = [YYIMChatGroupProvider sharedInstance];
            [chatGroupProvider activateWithJUMPStream:[self activeStream] delegate:[self activeDelegate]];
            self.chatGroupProvider = chatGroupProvider;
        }
    }
    return self.chatGroupProvider;
}

- (id<YYIMUserProtocol>)getUserProvider {
    if (!self.userProvider) {
        YYIMUserProvider *userProvider = [YYIMUserProvider sharedInstance];
        [userProvider activateWithJUMPStream:[self activeStream] delegate:[self activeDelegate]];
        self.userProvider = userProvider;
    }
    return self.userProvider;
}

#pragma mark -
#pragma mark login protocol

- (BOOL) isAutoLogin {
    return [self.loginManager isAutoLogin];
}

- (YYIMError *)login:(NSString *)account {
    account = [account lowercaseString];
    return [self.loginManager login:account];
}

- (void)login:(NSString *)account completion:(YYIMLoginCompleteBlock)completeBlock {
    account = [account lowercaseString];
    [self.loginManager login:account completion:completeBlock];
}

- (YYIMError *)loginAnonymous {
    return [self.loginManager loginAnonymous];
}

- (void)loginAnonymousWithCompletion:(YYIMLoginCompleteBlock)completeBlock {
    return [self.loginManager loginAnonymousWithCompletion:completeBlock];
}

- (YYIMError *)logoff {
    [(YYIMConnectManager *) self.connectManager stopReconnect];
    [self.notificationManager stopLazyNotify];
    YYIMError *error = [self.loginManager logoff];
    [YYIMHttpUtility removeDeviceToken];
    [[YYIMConfig sharedInstance] setAutoLogin:NO];
    return error;
}

- (BOOL)isConnected {
    return [self.loginManager isConnected];
}

- (YYIMConnectState)connectState {
    return [self.loginManager connectState];
}

- (void)registerTokenDelegate:(id<YYIMTokenDelegate>)delegate {
    self.tokenDelegate = delegate;
}

- (void)goOnline {
    [self.notificationManager startLazyNotify];
    [self.loginManager goOnline];
}

- (void)goOffline {
    [self.notificationManager stopLazyNotify];
    [self.loginManager goOffline];
}

- (void)modifiPassword:(NSString *)newPassword {
    [self.loginManager modifiPassword:newPassword];
}

- (void)doAutoLogin {
    [self.loginManager doAutoLogin];
}

#pragma mark -
#pragma mark token delegate

- (void)getAppTokenWithComplete:(void (^)(BOOL, id))complete {
    if ([self tokenDelegate] && [[self tokenDelegate] respondsToSelector:@selector(getAppTokenWithComplete:)]) {
        [[self tokenDelegate] getAppTokenWithComplete:complete];
    } else {
        YYToken *token = [self getAppToken];
        if (token) {
            complete(YES, token);
        } else {
            complete(NO, nil);
        }
    }
}

- (YYToken *)getAppToken {
    return [[self tokenDelegate] getAppToken];
}

#pragma mark -
#pragma mark message protocol

- (NSArray *)getRecentMessage {
    return [self.messageManager getRecentMessage];
}

- (void)getRecentMessageWithBlock:(void (^)(NSArray *))block {
    [self.messageManager getRecentMessageWithBlock:block];
}

- (NSArray *)getRecentRoster {
    return [self.messageManager getRecentRoster];
}

- (NSInteger)getUnreadMsgCount {
    return [self.messageManager getUnreadMsgCount];
}

- (NSInteger)getUnreadMsgCount:(NSString *)chatId {
    chatId = [chatId lowercaseString];
    return [self.messageManager getUnreadMsgCount:chatId];
}

- (NSInteger)getUnreadMsgCountMyOtherClient {
    return [self.messageManager getUnreadMsgCountMyOtherClient];
}

- (NSArray *)getMessageWithId:(NSString *) chatId {
    chatId = [chatId lowercaseString];
    return [self.messageManager getMessageWithId:chatId];
}

- (YYMessage *)getMessageWithPid:(NSString *)pid {
    return [self.messageManager getMessageWithPid:pid];
}

- (NSArray *)getMessageWithId:(NSString *)chatId beforePid:(NSString *)pid pageSize:(NSInteger)pageSize {
    chatId = [chatId lowercaseString];
    return [self.messageManager getMessageWithId:chatId beforePid:pid pageSize:pageSize];
}

- (NSArray *)getCustomMessageWithId:(NSString *)chatId customType:(NSInteger)customType beforePid:(NSString *)pid pageSize:(NSInteger)pageSize {
    chatId = [chatId lowercaseString];
    return [self.messageManager getCustomMessageWithId:chatId customType:customType beforePid:pid pageSize:pageSize];
}

- (NSArray *)getMessageWithId:(NSString *)chatId afterPid:(NSString *)pid {
    chatId = [chatId lowercaseString];
    return [self.messageManager getMessageWithId:chatId afterPid:pid];
}

- (NSArray *)getMessageWithId:(NSString *)chatId contentType:(NSInteger)contentType {
    chatId = [chatId lowercaseString];
    return [self.messageManager getMessageWithId:chatId contentType:contentType];
}

- (NSArray *)getChatUserWithChatId:(NSString *)chatId {
    chatId = [chatId lowercaseString];
    return [self.messageManager getChatUserWithChatId:chatId];
}

- (NSArray *)getMessageWithKey:(NSString *)key{
    return [self.messageManager getMessageWithKey:key];
}

- (NSArray *)getMessageWithKey:(NSString *)key limit:(NSInteger)limit{
    return [self.messageManager getMessageWithKey:key limit:limit];
}

- (NSArray *)getMessageWithKey:(NSString *)key chatId:(NSString *)chatId {
    return [self.messageManager getMessageWithKey:key chatId:chatId];
}

- (void)deleteMessageWithId:(NSString *)chatId {
    chatId = [chatId lowercaseString];
    [self.messageManager deleteMessageWithId:chatId];
}

- (void)deleteMessageWithPid:(NSString *)packetId {
    [self.messageManager deleteMessageWithPid:packetId];
}

- (void)deleteAllMessage {
    [self.messageManager deleteAllMessage];
}

- (NSArray *)getReceivedFileMessage {
    return [self.messageManager getReceivedFileMessage];
}

- (void)updateAudioReaded:(NSString *)packetId {
    return [self.messageManager updateAudioReaded:packetId];
}

- (void)updateMessageReadedWithPid:(NSString *)packetId {
    [self.messageManager updateMessageReadedWithPid:packetId];
}

- (void)updateMessageReadedWithId:(NSString *)chatId {
    chatId = [chatId lowercaseString];
    [self.messageManager updateMessageReadedWithId:chatId];
}

- (void)sendTextMessage:(NSString *)chatId text:(NSString *)text chatType:(NSString *)chatType {
    chatId = [chatId lowercaseString];
    [self.messageManager sendTextMessage:chatId text:text chatType:chatType];
}

- (void)sendTextMessage:(NSString *)chatId text:(NSString *)text chatType:(NSString *)chatType atUserArray:(NSArray *)atUserArray {
    chatId = [chatId lowercaseString];
    [self.messageManager sendTextMessage:chatId text:text chatType:chatType atUserArray:atUserArray];
}

- (void)sendTextMessage:(NSString *)chatId text:(NSString *)text chatType:(NSString *)chatType atUserArray:(NSArray *)atUserArray extendValue:(NSString *)extendValue {
    chatId = [chatId lowercaseString];
    [self.messageManager sendTextMessage:chatId text:text chatType:chatType atUserArray:atUserArray extendValue:extendValue];
}

- (void)sendNetMeetingMessage:(NSString *)chatId chatType:(NSString *)chatType netMeeting:(YYNetMeeting *)netMeeting {
    chatId = [chatId lowercaseString];
    [self.messageManager sendNetMeetingMessage:chatId chatType:chatType netMeeting:netMeeting];
}

- (void)sendImageMessage:(NSString *)chatId assets:(NSArray *)assetArray chatType:(NSString *)chatType {
    chatId = [chatId lowercaseString];
    [self.messageManager sendImageMessage:chatId assets:assetArray chatType:chatType];
}

- (void)sendImageMessage:(NSString *)chatId assets:(NSArray *)assetArray chatType:(NSString *)chatType isOriginal:(BOOL)isOriginal {
    chatId = [chatId lowercaseString];
    [self.messageManager sendImageMessage:chatId assets:assetArray chatType:chatType isOriginal:isOriginal];
}

- (void)sendImageMessage:(NSString *)chatId assets:(NSArray *)assetArray chatType:(NSString *)chatType isOriginal:(BOOL)isOriginal extendValue:(NSString *)extendValue {
    chatId = [chatId lowercaseString];
    [self.messageManager sendImageMessage:chatId assets:assetArray chatType:chatType isOriginal:isOriginal extendValue:extendValue];
}

- (void)sendImageMessage:(NSString *)chatId paths:(NSArray *)imagePathArray chatType:(NSString *)chatType {
    chatId = [chatId lowercaseString];
    [self.messageManager sendImageMessage:chatId paths:imagePathArray chatType:chatType];
}

/**
 *  发送短视频消息
 *
 *  @param chatId    用户/群组ID
 *  @param filePath  短视频的路径
 *  @param thumbNail 缩略图的路径
 *  @param chatType  单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 */
- (void)sendMicroVideoMessage:(NSString *)chatId filePath:(NSString *)filePath thumbPath:(NSString *)thumbPath chatType:(NSString *)chatType {
    chatId = [chatId lowercaseString];
    [self.messageManager sendMicroVideoMessage:chatId filePath:filePath thumbPath:thumbPath chatType:chatType];
}

- (void)sendAudioMessage:(NSString *)chatId wavPath:(NSString *)audioPath chatType:(NSString *)chatType {
    chatId = [chatId lowercaseString];
    [self.messageManager sendAudioMessage:chatId wavPath:audioPath chatType:chatType];
}

- (void)sendAudioMessage:(NSString *)chatId wavPath:(NSString *)audioPath chatType:(NSString *)chatType extendValue:(NSString *)extendValue {
    chatId = [chatId lowercaseString];
    [self.messageManager sendAudioMessage:chatId wavPath:audioPath chatType:chatType extendValue:extendValue];
}

- (void)sendFileMessage:(NSString *)chatId filePath:(NSString *)filePath chatType:(NSString *)chatType {
    chatId = [chatId lowercaseString];
    [self.messageManager sendFileMessage:chatId filePath:filePath chatType:chatType];
}

- (void)sendFileMessage:(NSString *)chatId filePath:(NSString *)filePath chatType:(NSString *)chatType extendValue:(NSString *)extendValue {
    chatId = [chatId lowercaseString];
    [self.messageManager sendFileMessage:chatId filePath:filePath chatType:chatType extendValue:extendValue];
}

- (void)sendShareMessage:(NSString *)chatId url:(NSString *)urlString title:(NSString *)title description:(NSString *)description imageUrl:(NSString *)imageUrlString extendValue:(NSString *)extendValue chatType:(NSString *)chatType {
    chatId = [chatId lowercaseString];
    [self.messageManager sendShareMessage:chatId url:urlString title:title description:description imageUrl:imageUrlString extendValue:extendValue chatType:chatType];
}

- (void)sendCustomMessage:(NSString *)chatId customType:(NSInteger)customType customDictionary:(NSDictionary *)customDictionary extendValue:(NSString *)extendValue chatType:(NSString *)chatType {
    chatId = [chatId lowercaseString];
    [self.messageManager sendCustomMessage:chatId customType:customType customDictionary:customDictionary extendValue:extendValue chatType:chatType];
}

- (void)forwardFileMessage:(NSString *)chatId pid:(NSString *)packetId chatType:(NSString *)chatType {
    chatId = [chatId lowercaseString];
    [self.messageManager forwardFileMessage:chatId pid:packetId chatType:chatType];
}

- (void)forwardMessage:(NSString *)chatId pid:(NSString *)packetId chatType:(NSString *)chatType {
    chatId = [chatId lowercaseString];
    [self.messageManager forwardMessage:chatId pid:packetId chatType:chatType];
}

- (void)sendLocationManager:(NSString *)chatId imagePath:(NSString *)imagePath address:(NSString *)address longitude:(float)longitude latitude:(float)latitude chatType:(NSString *)chatType {
    chatId = [chatId lowercaseString];
    [self.messageManager sendLocationManager:chatId imagePath:imagePath address:address longitude:longitude latitude:latitude chatType:chatType];
}

- (void)resendMessage:(NSString *) pid {
    [self.messageManager resendMessage:pid];
}

- (void)downloadMessageRes:(NSString *)pid {
    [self.messageManager downloadMessageRes:pid];
}

/**
 *  下载短视频的视频文件
 *
 *  @param pid              消息pid
 *  @param downloadProgress 进度回调block
 *  @param downloadComplete 完成回调block
 */
- (void)downloadMicroVideoMessageRes:(NSString *)pid progress:(YYIMAttachDownloadProgressBlock)downloadProgress complete:(YYIMAttachDownloadCompleteBlock)downloadComplete {
    [self.messageManager downloadMicroVideoMessageRes:pid progress:downloadProgress complete:downloadComplete];
}

- (void)downloadImageMessageRes:(NSString *)pid imageType:(YYIMImageType)imageType progress:(YYIMAttachDownloadProgressBlock)downloadProgress complete:(YYIMAttachDownloadCompleteBlock)downloadComplete {
    [self.messageManager downloadImageMessageRes:pid imageType:imageType progress:downloadProgress complete:downloadComplete];
}

/**
 *  获取消息中文件列表
 *
 *  @param chatId   用户/群组ID
 *  @param chatType 单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 *  @param fileType 文件类型
 *  @param offset   偏移量
 *  @param limit    数量
 *  @param complete 完成回调block
 */
- (void)getChatMessageFileList:(NSString *)chatId chatType:(NSString *)chatType fileType:(YYIMMessageFileType)fileType offset:(NSUInteger)offset limit:(NSUInteger)limit complete:(void (^)(BOOL, NSArray *, YYIMError *))complete {
    [self.messageManager getChatMessageFileList:chatId chatType:chatType fileType:fileType offset:offset limit:limit complete:complete];
}

/**
 *  消息中文件搜索
 *
 *  @param chatId   用户/群组ID
 *  @param chatType 单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 *  @param fileType 文件类型
 *  @param keyword  关键字
 *  @param offset   偏移量
 *  @param limit    数量
 *  @param complete 完成回调block
 */
- (void)getChatMessageFileList:(NSString *)chatId chatType:(NSString *)chatType fileType:(YYIMMessageFileType)fileType keyword:(NSString *)keyword offset:(NSUInteger)offset limit:(NSUInteger)limit complete:(void (^)(BOOL, NSArray *, YYIMError *))complete {
    [self.messageManager getChatMessageFileList:chatId chatType:chatType fileType:fileType keyword:keyword offset:offset limit:limit complete:complete];
}

- (void)revokeChatMessageWithId:(NSString *)pid {
    [self.messageManager revokeChatMessageWithId:pid];
}

- (void)revokeGroupChatMessageWithId:(NSString *)pid {
    [self.messageManager revokeGroupChatMessageWithId:pid];
}

#pragma mark -
#pragma mark roster protocol

- (NSArray *)getAllRoster {
    return [[self getRosterProvider] getAllRoster];
}

- (NSArray *)getAllRosterWithAsk {
    return [[self getRosterProvider] getAllRosterWithAsk];
}

- (YYRoster *)getRosterWithId:(NSString *)rosterId {
    rosterId = [rosterId lowercaseString];
    return [[self getRosterProvider] getRosterWithId:rosterId];
}

- (void)loadRoster {
    [[self getRosterProvider] loadRoster];
}

- (void)addRoster:(NSString *)userId {
    userId = [userId lowercaseString];
    [[self getRosterProvider] addRoster:userId];
}

- (NSArray *)getAllRosterInvite {
    return [[self getRosterProvider] getAllRosterInvite];
}

- (void)acceptRosterInvite:(NSString *)fromId {
    fromId = [fromId lowercaseString];
    [[self getRosterProvider] acceptRosterInvite:fromId];
}

- (void)refuseRosterInvite:(NSString *)fromId {
    fromId = [fromId lowercaseString];
    [[self getRosterProvider] refuseRosterInvite:fromId];
}

- (NSInteger)getNewRosterInviteCount {
    return [[self getRosterProvider] getNewRosterInviteCount];
}

- (void)deleteRoster:(NSString *)rosterId {
    rosterId = [rosterId lowercaseString];
    return [[self getRosterProvider] deleteRoster:rosterId];
}

- (void)renameRoster:(NSString *)rosterId name:(NSString *)name {
    rosterId = [rosterId lowercaseString];
    return [[self getRosterProvider] renameRoster:rosterId name:name];
}

/**
 *  设置好友的tag
 *
 *  @param rosterTags tag集合
 *  @param rosterId   好友Id
 *  @param complete   执行的回调
 */
- (void)addRosterTags:(NSArray *)rosterTags rosterId:(NSString *)rosterId complete:(void (^)(BOOL result, YYIMError *error))complete {
    [[self getRosterProvider] addRosterTags:rosterTags rosterId:rosterId complete:complete];
}

/**
 *  删除好友的tag
 *
 *  @param rosterTags tag集合
 *  @param rosterId   好友Id
 *  @param complete   执行的回调
 */
- (void)deleteRosterTags:(NSArray *)rosterTags rosterId:(NSString *)rosterId complete:(void (^)(BOOL result, YYIMError *error))complete {
    [[self getRosterProvider] deleteRosterTags:rosterTags rosterId:rosterId complete:complete];
}

/**
 *  通过tag获取好友集合
 *
 *  @param tag tag
 *
 *  @return 好友集合
 */
- (NSArray *)getRostersWithTag:(NSString *)tag {
    return [[self getRosterProvider] getRostersWithTag:tag];
}

#pragma mark -
#pragma mark chatgroup protocol

- (void)loadChatGroupAndMembers {
    [[self getChatGroupProvider] loadChatGroupAndMembers];
}

- (NSString *)createChatGroupWithName:(NSString *)groupName user:(NSArray *)userIdArray {
    return [[self getChatGroupProvider] createChatGroupWithName:groupName user:userIdArray];
}

- (NSString *)createChatGroupWithName:(NSString *)groupName user:(NSArray *)userIdArray maxUsers:(NSUInteger)maxUsers {
    return [[self getChatGroupProvider] createChatGroupWithName:groupName user:userIdArray maxUsers:maxUsers];
}

- (void)inviteRosterIntoChatGroup:(NSString *)groupId user:(NSArray *)userIdArray {
    [[self getChatGroupProvider] inviteRosterIntoChatGroup:groupId user:userIdArray];
}

- (YYChatGroup *)getChatGroupWithGroupId:(NSString *)groupId {
    groupId = [groupId lowercaseString];
    return [[self getChatGroupProvider] getChatGroupWithGroupId:groupId];
}

- (NSArray *)getAllChatGroups {
    return [[self getChatGroupProvider] getAllChatGroups];
}

- (NSArray *)getGroupMembersWithGroupId:(NSString *)groupId {
    groupId = [groupId lowercaseString];
    return [[self getChatGroupProvider] getGroupMembersWithGroupId:groupId];
}

- (NSArray *)getGroupMembersWithGroupId:(NSString *)groupId limit:(NSInteger)limit {
    groupId = [groupId lowercaseString];
    return [[self getChatGroupProvider] getGroupMembersWithGroupId:groupId limit:limit];
}

/**
 *  获取群成员列表
 *
 *  @param groupId  群组ID
 *  @param complete  成功的回调
 */
- (void)getGroupMembersWithGroupId:(NSString *)groupId complete:(void (^)(BOOL, NSArray *, YYIMError *))complete {
    [self.chatGroupProvider getGroupMembersWithGroupId:groupId complete:complete];
}

/**
 *  获取群成员列表
 *
 *  @param groupId  群组ID
 *  @param joinDate 加入时间（只查此时间之前加入的人员）
 
 *  @param complete  成功的回调
 */
- (void)getGroupMembersWithGroupId:(NSString *)groupId joinDate:(NSTimeInterval)joinDate complete:(void (^)(BOOL, NSArray *, YYIMError *))complete {
    [self.chatGroupProvider getGroupMembersWithGroupId:groupId joinDate:joinDate complete:complete];
}

- (BOOL)isGroupOwner:(NSString *)groupId {
    return [[self getChatGroupProvider] isGroupOwner:groupId];
}

- (void)leaveChatGroup:(NSString *)groupId {
    groupId = [groupId lowercaseString];
    [[self getChatGroupProvider] leaveChatGroup:groupId];
}

- (void)renameChatGroup:(NSString *)groupId name:(NSString *)groupName {
    groupId = [groupId lowercaseString];
    [[self getChatGroupProvider] renameChatGroup:groupId name:groupName];
}

- (void)kickGroupMemberFromGroup:(NSString *)groupId member:(NSString *)memberId {
    groupId = [groupId lowercaseString];
    memberId = [memberId lowercaseString];
    [[self getChatGroupProvider] kickGroupMemberFromGroup:groupId member:memberId];
}

- (void)changeChatGroupAdminForGroup:(NSString *)groupId to:(NSString *)memberId {
    groupId = [groupId lowercaseString];
    memberId = [memberId lowercaseString];
    [[self getChatGroupProvider] changeChatGroupAdminForGroup:groupId to:memberId];
}

- (void)searchChatGroupWithKeyword:(NSString *)keyword {
    [[self getChatGroupProvider] searchChatGroupWithKeyword:keyword];
}

- (void)joinChatGroup:(NSString *)groupId {
    groupId = [groupId lowercaseString];
    [[self getChatGroupProvider] joinChatGroup:groupId];
}

- (NSArray *)getCollectChatGroups {
    return [[self getChatGroupProvider] getCollectChatGroups];
}

- (void)collectChatGroup:(NSString *)groupId {
    groupId = [groupId lowercaseString];
    [[self getChatGroupProvider] collectChatGroup:groupId];
}

- (void)unCollectChatGroup:(NSString *)groupId {
    groupId = [groupId lowercaseString];
    [[self getChatGroupProvider] unCollectChatGroup:groupId];
}

- (void)dismissChatGroup:(NSString *)groupId {
    groupId = [groupId lowercaseString];
    [[self getChatGroupProvider] dismissChatGroup:groupId];
}

- (void)genChatGroupQrCodeWithGroupId:(NSString *)groupId complete:(void (^)(BOOL, NSDictionary *, YYIMError *))complete {
    groupId = [groupId lowercaseString];
    [[self getChatGroupProvider] genChatGroupQrCodeWithGroupId:groupId complete:complete];
}

- (void)getChatGroupInfoWithQrCode:(NSString *)qrCodeText complete:(void (^)(BOOL, YYChatGroupInfo *, YYIMError *))complete {
    [[self getChatGroupProvider] getChatGroupInfoWithQrCode:qrCodeText complete:complete];
}

/**
 *  通过tag获取群组集合
 *
 *  @param tag tag
 *
 *  @return 群组集合
 */
- (NSArray *)getChatGroupsWithTag:(NSString *)tag {
    return [[self getChatGroupProvider] getChatGroupsWithTag:tag];
}

/**
 *  参加面对面建群
 *  默认有效距离1000米
 *  默认有效时间1800秒
 *
 *  @param cipher    四位数字密码
 *  @param longitude 经度
 *  @param latitude  纬度
 */
- (void)participateFaceGroupWithCipher:(NSString *)cipher longitude:(float)longitude latitude:(float)latitude {
    return [[self getChatGroupProvider] participateFaceGroupWithCipher:cipher longitude:longitude latitude:latitude];
}

/**
 *  参加面对面建群
 *
 *  @param cipher     四位数字密码
 *  @param longitude  经度
 *  @param latitude   纬度
 *  @param distance   有效距离（米）
 *  @param expireTime 有效时间（秒）
 */
- (void)participateFaceGroupWithCipher:(NSString *)cipher longitude:(float)longitude latitude:(float)latitude distance:(NSInteger)distance expireTime:(NSInteger)expireTime {
    return [[self getChatGroupProvider] participateFaceGroupWithCipher:cipher longitude:longitude latitude:latitude distance:distance expireTime:expireTime];
}

/**
 *  加入面对面建群
 *
 *  @param faceId 面对面建群标识
 */
- (void)joinFaceGroupWithCipher:(NSString *)cipher faceId:(NSString *)faceId {
    [[self getChatGroupProvider] joinFaceGroupWithCipher:cipher faceId:faceId];
}

/**
 *  离开面对面建群
 *
 *  @param faceId 面对面建群标识
 */
- (void)quitFaceGroupWithCipher:(NSString *)cipher faceId:(NSString *)faceId {
    [[self getChatGroupProvider] quitFaceGroupWithCipher:cipher faceId:faceId];
}

#pragma mark -
#pragma mark user

- (void)searchUserWithKeyword:(NSString *)keyword {
    [[self getUserProvider] searchUserWithKeyword:keyword];
}

- (void)loadUser:(NSString *)userId {
    userId = [userId lowercaseString];
    [[self getUserProvider] loadUser:userId];
}

- (void)loadRosterUsers {
    if ([[self getUserProvider] respondsToSelector:@selector(loadRosterUsers)]) {
        [[self getUserProvider] loadRosterUsers];
    }
}

- (YYUser *)getUserWithId:(NSString *)userId {
    userId = [userId lowercaseString];
    YYUser *user = [[self getUserProvider] getUserWithId:userId];
    if (!user) {
        [[self getUserProvider] loadUser:userId];
    }
    return user;
}

- (void)updateUser:(YYUser *)user {
    [user setUserId:[[user userId] lowercaseString]];
    [[self getUserProvider] updateUser:user];
}

- (void)deleteAllUnExistUserMessages {
    if ([[self getUserProvider] respondsToSelector:@selector(deleteAllUnExistUserMessages)]) {
        [[self getUserProvider] deleteAllUnExistUserMessages];
    }
}

- (void)deleteUnExistUserMessage:(NSString *)userId {
    if ([[self getUserProvider] respondsToSelector:@selector(deleteUnExistUserMessage:)]) {
        userId = [userId lowercaseString];
        [[self getUserProvider] deleteUnExistUserMessage:userId];
    }
}

/**
 *  给用户增加tag
 *
 *  @param userTags tag数组
 *  @param complete 执行的回调
 */
- (void)AddUserTags:(NSArray *)userTags complete:(void (^)(BOOL, YYIMError *))complete {
    [self.userProvider AddUserTags:userTags complete:complete];
}

/**
 *  删除用户的tag
 *
 *  @param userTags tag数组
 *  @param complete 执行的回调
 */
- (void)deleteUserTags:(NSArray *)userTags complete:(void (^)(BOOL, YYIMError *))complete {
    return [self.userProvider deleteUserTags:userTags complete:complete];
}

#pragma mark -
#pragma mark ext protocol

/**
 *  加载用户Profile信息
 */
- (void)loadUserProfiles {
    [self.extManager loadUserProfiles];
}

/**
 *  设置用户消息免打扰
 *
 *  @param noDisturb 免打扰
 *  @param userId    用户ID
 */
- (void)updateUserNoDisturb:(BOOL)noDisturb userId:(NSString *)userId {
    userId = [userId lowercaseString];
    [self.extManager updateUserNoDisturb:noDisturb userId:userId];
}

/**
 *  设置用户置顶
 *
 *  @param stickTop 置顶
 *  @param userId   用户ID
 */
- (void)updateUserStickTop:(BOOL)stickTop userId:(NSString *)userId {
    userId = [userId lowercaseString];
    [self.extManager updateUserStickTop:stickTop userId:userId];
}

/**
 *  设置群组消息免打扰
 *
 *  @param noDisturb 免打扰
 *  @param groupId   群组ID
 */
- (void)updateGroupNoDisturb:(BOOL)noDisturb groupId:(NSString *)groupId {
    groupId = [groupId lowercaseString];
    [self.extManager updateGroupNoDisturb:noDisturb groupId:groupId];
}

/**
 *  设置群组置顶
 *
 *  @param stickTop 置顶
 *  @param groupId  群组ID
 */
- (void)updateGroupStickTop:(BOOL)stickTop groupId:(NSString *)groupId {
    groupId = [groupId lowercaseString];
    [self.extManager updateGroupStickTop:stickTop groupId:groupId];
}

/**
 *  设置公共号消息免打扰
 *
 *  @param noDisturb 免打扰
 *  @param accountId 公共号ID
 */
- (void)updatePubAccountNoDisturb:(BOOL)noDisturb accountId:(NSString *)accountId {
    accountId = [accountId lowercaseString];
    [self.extManager updatePubAccountNoDisturb:noDisturb accountId:accountId];
}

/**
 *  设置公共号消息置顶
 *
 *  @param stickTop  置顶
 *  @param accountId 公共号ID
 */
- (void)updatePubAccountStickTop:(BOOL)stickTop accountId:(NSString *)accountId {
    accountId = [accountId lowercaseString];
    [self.extManager updatePubAccountStickTop:stickTop accountId:accountId];
}

/**
 *  获取用户Profile
 *
 *  @return 用户Profile
 */
- (NSDictionary<NSString *,NSString *> *)getUserProfiles {
    return [self.extManager getUserProfiles];
}

/**
 *  添加用户Profile
 *
 *  @param profileDic 用户profile
 */
- (void)setUserProfileWithDic:(NSDictionary<NSString *,NSString *> *)profileDic {
    [self.extManager setUserProfileWithDic:profileDic];
}

/**
 *  移除用户Profile
 *
 *  @param profileKeys 要移除的key
 */
- (void)removeUserProfileWithKeys:(NSArray<NSString *> *)profileKeys {
    [self.extManager removeUserProfileWithKeys:profileKeys];
}

- (void)clearUserProfiles {
    [self.extManager clearUserProfiles];
}

- (YYUserExt *)getUserExtWithId:(NSString *)userId {
    userId = [userId lowercaseString];
    return [self.extManager getUserExtWithId:userId];
}

- (YYChatGroupExt *)getChatGroupExtWithId:(NSString *)groupId {
    groupId = [groupId lowercaseString];
    return [self.extManager getChatGroupExtWithId:groupId];
}

- (YYPubAccountExt *)getPubAccountExtWithId:(NSString *)accountId {
    accountId = [accountId lowercaseString];
    return [self.extManager getPubAccountExtWithId:accountId];
}

- (void)setChatGroupShowName:(BOOL)showName groupId:(NSString *)groupId {
    groupId = [groupId lowercaseString];
    [self.extManager setChatGroupShowName:showName groupId:groupId];
}

#pragma mark -
#pragma mark pub account protocol

- (void)loadPubAccount {
    [self.pubAccountManager loadPubAccount];
}

- (NSArray *)getAllPubAccount {
    return [self.pubAccountManager getAllPubAccount];
}

- (YYPubAccount *)getPubAccountWithAccountId:(NSString *)accountId {
    return [self.pubAccountManager getPubAccountWithAccountId:accountId];
}

- (void)searchPubAccountWithKeyword:(NSString *)keyword {
    [self.pubAccountManager searchPubAccountWithKeyword:keyword];
}

- (void)followPubAccount:(NSString *)accountId {
    accountId = [accountId lowercaseString];
    [self.pubAccountManager followPubAccount:accountId];
}

- (void)unFollowPubAccount:(NSString *)accountId {
    accountId = [accountId lowercaseString];
    [self.pubAccountManager unFollowPubAccount:accountId];
}

/**
 *  获取公共号的菜单
 *
 *  @param accountId公共号id
 *  @param complete 执行的回调
 */
- (YYPubAccountMenu *)getPubAccountMenu:(NSString *)accountId {
    return [self.pubAccountManager getPubAccountMenu:accountId];
}

/**
 *  向Server请求公共号菜单
 *
 *  @param accountId公共号id
 */
- (void)LoadPubAccountMenu:(NSString *)accountId {
    [self.pubAccountManager LoadPubAccountMenu:accountId];
}

/**
 *  发送公共号的菜单命令
 *
 *  @param accountId公共号id
 *  @param item     公共号菜单选项
 *  @param complete  执行的回调
 */
- (void)sendPubAccountMenuCommand:(NSString *)accountId item:(YYPubAccountMenuItem *)item {
    [self.pubAccountManager sendPubAccountMenuCommand:accountId item:item];
}

/**
 *  通过tag获取公共号集合
 *
 *  @param tag tag
 *
 *  @return公共号集合
 */
- (NSArray *)getPubAccountsWithTag:(NSString *)tag {
    return [self.pubAccountManager getPubAccountsWithTag:tag];
}

#pragma mark -
#pragma mark notification protocol

- (void)setEnableLocalNotification:(BOOL)enable {
    [self.notificationManager setEnableLocalNotification:YES];
}

- (YYSettings *)getSettings {
    return [self.notificationManager getSettings];
}

- (void)updateSettings:(YYSettings *)settings {
    [self.notificationManager updateSettings:settings];
}

- (void)registerNotificationDelegate:(id<YYIMNotificationDelegate>) delegate {
    [self.notificationManager registerNotificationDelegate:delegate];
}

#pragma mark -
#pragma mark teleconference protocol

- (void)registerDuduWithAccountIdentify:(NSString *)accountIdentify appkeyTemp:(NSString *)appkeyTemp {
    [self.teleconferenceManager registerDuduWithAccountIdentify:accountIdentify appkeyTemp:appkeyTemp];
}

- (void)createDuduConferenceWithCaller:(NSString *)userId participants:(NSArray *)participants {
    [self.teleconferenceManager createDuduConferenceWithCaller:userId participants:participants];
}

- (void)createDuduConferenceWithCallerPhone:(NSString *)phoneNumber participantPhones:(NSArray *)phoneNumbers {
    [self.teleconferenceManager createDuduConferenceWithCallerPhone:phoneNumber participantPhones:phoneNumbers];
}

- (void)createTeleConferenceWithCaller:(NSString *)userId participants:(NSArray *)participants {
    [self.teleconferenceManager createTeleConferenceWithCaller:userId participants:participants];
}

- (void)createTeleConferenceWithCallerPhone:(NSString *)phoneNumber participantPhones:(NSArray *)phoneNumbers {
    [self.teleconferenceManager createTeleConferenceWithCallerPhone:phoneNumber participantPhones:phoneNumbers];
}

#pragma mark -
#pragma mark netmeeting protocol

- (void)resetNetMeetingKit {
    return [self.netMeetingManager resetNetMeetingKit];
}

/**
 *  获取当前是否有会议在进行
 *
 *  @return
 */
- (BOOL)isNetMeetingProcessing {
    return [self.netMeetingManager isNetMeetingProcessing];
}

/**
 *  获取还没有处理的网络会议邀请
 *
 *  @return 邀请的id（没有返回nil）
 */
- (NSString *)getUntreatedNetMeetingInviting {
    return [self.netMeetingManager getUntreatedNetMeetingInviting];
}

- (void)treatNetMeetingInvite {
    [self.netMeetingManager treatNetMeetingInvite];
}

/**
 *  设置视频采集质量
 *
 *  @param profile 采集质量配置
 *
 *  return 返回0表示成功，负数表示失败。
 */
- (int)setNetMeetingVideoProfile:(YYIMNetMeetingVideoProfile)profile {
    return [self.netMeetingManager setNetMeetingVideoProfile:profile];
}

/**
 *  设置网络会议的优化配置
 *
 *  @param profile 优化配置
 */
- (void)setNetMeetingProfile:(YYIMNetMeetingProfile)profile {
    [self.netMeetingManager setNetMeetingProfile:profile];
}

- (void)enterNetMeeting:(NSString *)channelId {
    [self.netMeetingManager enterNetMeeting:channelId];
}

- (int)enableNetMeetingVideo {
    return [self.netMeetingManager enableNetMeetingVideo];
}

- (int)disableNetMeetingVideo {
    return [self.netMeetingManager disableNetMeetingVideo];
}

- (int)setNetMeetingEnableSpeakerphone:(BOOL)enableSpeaker {
    return [self.netMeetingManager setNetMeetingEnableSpeakerphone:enableSpeaker];
}

- (BOOL)isNetMeetingSpeakerphoneEnabled {
    return [self.netMeetingManager isNetMeetingSpeakerphoneEnabled];
}

- (int)startNetMeetingPreview {
    return [self.netMeetingManager startNetMeetingPreview];
}

- (int)stopNetMeetingPreview {
    return [self.netMeetingManager stopNetMeetingPreview];
}

- (int)muteNetMeetingLocalAudioStream:(BOOL)mute {
    return [self.netMeetingManager muteNetMeetingLocalAudioStream:mute];
}

- (int)muteNetMeetingLocalVideoStream:(BOOL)mute {
    return [self.netMeetingManager muteNetMeetingLocalVideoStream:mute];
}

/**
 *  设置暂停播放所有远程音频流
 *
 *  @param mute 是否禁止
 *
 *  @return 返回0表示成功，负数表示失败。
 */
- (int)muteAllNetMeetingRemoteAudioStreams:(BOOL)mute {
    return [self.netMeetingManager muteAllNetMeetingRemoteAudioStreams:mute];
}

/**
 *  设置暂停播放所有远程视频流
 *
 *  @param mute 是否禁止
 *
 *  @return 返回0表示成功，负数表示失败
 */
- (int)muteAllNetMeetingRemoteVideoStreams:(BOOL)mute {
    return [self.netMeetingManager muteAllNetMeetingRemoteVideoStreams:mute];
}

- (int)setupNetMeetingLocalVideo:(UIView *)view userId:(NSString *)userId {
    return [self.netMeetingManager setupNetMeetingLocalVideo:view userId:userId];
}

- (int)setupNetMeetingRemoteVideo:(UIView *)view userId:(NSString *)userId {
    return [self.netMeetingManager setupNetMeetingRemoteVideo:view userId:userId];
}

- (int)switchNetMeetingCamera {
    return [self.netMeetingManager switchNetMeetingCamera];
}

- (int)enableNetMeetingNetworkTest {
    return [self.netMeetingManager enableNetMeetingNetworkTest];
}

- (int)disableNetMeetingNetworkTest {
    return [self.netMeetingManager disableNetMeetingNetworkTest];
}

/**
 *  设置视频会议日志的打印级别
 *
 *  @param logFilte打印级别
 */
- (void)setNetMeetingLogFilter:(YYIMNetMeetingLogFilter)logFilter {
    [self.netMeetingManager setNetMeetingLogFilter:logFilter];
}

/**
 *  获得指定的频道
 *
 *  @param channelId 频道id
 *
 *  @return 频道对象
 */
- (YYNetMeeting *)getNetMeetingWithChannelId:(NSString *)channelId {
    return [self.netMeetingManager getNetMeetingWithChannelId:channelId];
}

/**
 *  获得频道下的所有成员
 *
 *  @param channelId 频道id
 *
 *  @return 成员集合
 */
- (NSArray *)getNetMeetingMembersWithChannelId:(NSString *)channelId {
    return [self.netMeetingManager getNetMeetingMembersWithChannelId:channelId];
}

/**
 *  获得频道下的指定数量的成员
 *
 *  @param channelId 频道id
 *  @param limit     数量限制
 *
 *  @return 成员集合
 */
- (NSArray *)getNetMeetingMembersWithChannelId:(NSString *)channelId limit:(NSInteger)limit {
    return [self.netMeetingManager getNetMeetingMembersWithChannelId:channelId limit:limit];
}

- (NSArray *)getNetMeetingNoticeWithOffset:(NSInteger)offset limit:(NSInteger)limit {
    return [self.netMeetingManager getNetMeetingNoticeWithOffset:offset limit:limit];
}

/**
 *  获得会议主持人
 *
 *  @param channelId
 *
 *  @return
 */
- (YYNetMeetingMember *)getNetMeetingModerator:(NSString *)channelId {
    return [self.netMeetingManager getNetMeetingModerator:channelId];
}

/**
 *  设置预约会议的日历事件
 *
 *  @param calendarEvent  日历事件的对象
 *
 *  @return
 */
- (void)addNetMeetingCalendarEvent:(YYNetMeetingCalendarEvent *) calendarEvent {
    [self.netMeetingManager addNetMeetingCalendarEvent:calendarEvent];
}

/**
 *  开始预约会议
 *
 *  @param channelId 会议id
 *
 *  @return 创建的唯一标示
 */
- (NSString *)startReservationNetMeeting:(NSString *)channelId {
    return [self.netMeetingManager startReservationNetMeeting:channelId];
}

/**
 *  创建一个会议
 *
 *  @param netMeetingType 会议类型（会议或者直播）
 *  @param netMeetingMode 会议模式（视频或者语音）
 *  @param invitees       被邀请人
 *  @param topic          会议主题
 *
 *  @return 创建的唯一标示
 */
- (NSString *)createNetMeetingWithNetMeetingType:(YYIMNetMeetingType)netMeetingType netMeetingMode:(YYIMNetMeetingMode)netMeetingMode invitees:(NSArray *)invitees topic:(NSString *)topic {
    return [self.netMeetingManager createNetMeetingWithNetMeetingType:netMeetingType netMeetingMode:netMeetingMode invitees:invitees topic:topic];
}

/**
 *  获取频道下的指定成员
 *
 *  @param channelId 频道id
 *  @param memberId  成员id
 *
 *  @return 成员
 */
- (YYNetMeetingMember *)getNetMeetingMemberWithChannelId:(NSString *)channelId memberId:(NSString *)memberId {
    return [self.netMeetingManager getNetMeetingMemberWithChannelId:channelId memberId:memberId];
}

/**
 *  发送会议的邀请
 *
 *  @param channelId 频道id
 *  @param invitees  被邀请人集合
 */
- (void)inviteNetMeetingMember:(NSString *)channelId invitees:(NSArray *)invitees {
    [self.netMeetingManager inviteNetMeetingMember:channelId invitees:invitees];
}

/**
 *  主动加入会议
 *
 *  @param channelId 频道id
 */
- (void)joinNetMeeting:(NSString *)channelId {
    [self.netMeetingManager joinNetMeeting:channelId];
}

/**
 *  同意加入会议
 *
 *  @param channelId 频道id
 */
- (void)agreeEnterNetMeeting:(NSString *)channelId {
    [self.netMeetingManager agreeEnterNetMeeting:channelId];
}

/**
 *  拒绝加入会议
 *
 *  @param channelId 频道id
 */
- (void)refuseEnterNetMeeting:(NSString *)channelId {
    [self.netMeetingManager refuseEnterNetMeeting:channelId];
}

/**
 *  打开视频通知
 *
 *  @param channelId 频道id
 */
- (void)openNetMeetingVideo:(NSString *)channelId {
    [self.netMeetingManager openNetMeetingVideo:channelId];
}

/**
 *  关闭视频通知
 *
 *  @param channelId 频道id
 */
- (void)closeNetMeetingVideo:(NSString *)channelId {
    [self.netMeetingManager closeNetMeetingVideo:channelId];
}

/**
 *  打开音频通知
 *
 *  @param channelId 频道id
 */
- (void)openNetMeetingAudio:(NSString *)channelId {
    [self.netMeetingManager openNetMeetingAudio:channelId];
}

/**
 *  打开音频通知
 *
 *  @param channelId 频道id
 */
- (void)closeNetMeetingAudio:(NSString *)channelId {
    [self.netMeetingManager closeNetMeetingAudio:channelId];
}

/**
 *  会议上锁
 *
 *  @param channelId 频道id
 */
- (void)lockNetMeeting:(NSString *)channelId {
    [self.netMeetingManager lockNetMeeting:channelId];
}

/**
 *  会议解锁
 *
 *  @param channelId 频道id
 */
- (void)unlockNetMeeting:(NSString *)channelId {
    [self.netMeetingManager unlockNetMeeting:channelId];
}

- (void)editNetMeetingTopic:(NSString *)channelId topic:(NSString *)topic {
    [self.netMeetingManager editNetMeetingTopic:channelId topic:topic];
}

/**
 *  更换主持人
 *
 *  @param channelId 频道id
 *  @param userId    新的主持人
 */
- (void)roleConversionOfNetMeeting:(NSString *)channelId withUserId:(NSString *)userId {
    [self.netMeetingManager roleConversionOfNetMeeting:channelId withUserId:userId];
}

/**
 *  发送离开会议的报文
 *
 *  @param channelId 频道id
 */
- (void)exitNetMeeting:(NSString *)channelId {
    [self.netMeetingManager exitNetMeeting:channelId];
}

/**
 *  主持人结束了会议
 *
 *  @param channelId 频道id
 */
- (void)endNetMeeting:(NSString *)channelId {
    [self.netMeetingManager endNetMeeting:channelId];
}

/**
 *  从房间踢出成员
 *
 *  @param channelId   频道id
 *  @param memberArray 成员集合
 */
- (void)kickMemberFromNetMeeting:(NSString *)channelId memberArray:(NSArray *)memberArray {
    [self.netMeetingManager kickMemberFromNetMeeting:channelId memberArray:memberArray];
}

/**
 *  从频道中踢出成员
 *
 *  @param channelId   频道id
 *  @param memberArray 成员集合
 */
- (void)disableMemberSpeakFromNetMeeting:(NSString *)channelId  userId:(NSString *)userId {
    [self.netMeetingManager disableMemberSpeakFromNetMeeting:channelId userId:userId];
}

/**
 *  静音所有人
 *
 *  @param channelId 频道id
 */
- (void)disableAllSpeakFromNetMeeting:(NSString *)channelId {
    [self.netMeetingManager disableAllSpeakFromNetMeeting:channelId];
}

/**
 *  频道中指定成员取消禁言
 *
 *  @param channelId   频道id
 *  @param memberArray 成员集合
 */
- (void)enableMemberSpeakFromNetMeeting:(NSString *)channelId  userId:(NSString *)userId {
    [self.netMeetingManager enableMemberSpeakFromNetMeeting:channelId userId:userId];
}

/**
 *  静音所有人
 *
 *  @param channelId 频道id
 */
- (void)enableAllSpeakFromNetMeeting:(NSString *)channelId {
    [self.netMeetingManager enableAllSpeakFromNetMeeting:channelId];
}

/**
 *  获得会议详情
 *
 *  @param channelId 会议id
 *  @param complete
 */
- (void)getNetmeetingDetail:(NSString *)channelId complete:(void (^)(BOOL, YYNetMeetingDetail *, NSArray *, YYIMError *))complete {
    [self .netMeetingManager getNetmeetingDetail:channelId complete:complete];
}

/**
 *  获取我的会议
 *
 *  @param complete
 */
- (void)getMyNetMeetingWithOffset:(NSUInteger)offset limit:(NSUInteger)limit complete:(void (^)(BOOL, NSArray *, YYIMError *))complete {
    [self.netMeetingManager getMyNetMeetingWithOffset:offset limit:limit complete:complete];
}

/**
 *  预约会议
 *
 *  @param netMeetingDetail 预约会议信息
 *  @param members          邀请人
 *  @param complete
 */
- (void)reservationNetMeetingWithNetMeetingDetail:(YYNetMeetingDetail *)netMeetingDetail members:(NSArray *)members complete:(void (^)(BOOL, YYIMError *, NSString *, NSArray *))complete {
    [self.netMeetingManager reservationNetMeetingWithNetMeetingDetail:netMeetingDetail members:members complete:complete];
}

/**
 *  删除会议
 *
 *  @param channelId 会议ID
 *  @param complete
 */
- (void)removeNetMeetingWithChannelId:(NSString *)channelId complete:(void (^)(BOOL, YYIMError *))complete {
    [self.netMeetingManager removeNetMeetingWithChannelId:channelId complete:complete];
}

/**
 *  取消预约会议
 *
 *  @param channelId 会议id
 *  @param complete
 */
- (void)cancelReservationNetMeeting:(NSString *)channelId complete:(void (^)(BOOL, YYIMError *))complete {
    [self.netMeetingManager cancelReservationNetMeeting:channelId complete:complete];
}

/**
 *  编辑预约会议
 *
 *  @param netMeetingDetail 会议详情
 *  @param complete
 */
- (void)EditReservationNetMeeting:(YYNetMeetingDetail *)netMeetingDetail complete:(void (^)(BOOL, YYIMError *))complete {
    [self.netMeetingManager EditReservationNetMeeting:netMeetingDetail complete:complete];
}

/**
 *  预约会议邀请
 *
 *  @param channelId 会议id
 *  @param members 成员集合
 *  @param complete
 */
- (void)inviteReservationNetMeeting:(NSString *)channelId member:(NSArray *)members complete:(void (^)(BOOL, YYIMError *, NSArray *))complete {
    [self.netMeetingManager inviteReservationNetMeeting:channelId member:members complete:complete];
}

/**
 *  预约会议踢人
 *
 *  @param channelId 会议id
 *  @param members   成员集合
 *  @param complete
 */
- (void)kickReservationNetMeeting:(NSString *)channelId member:(NSArray *)members complete:(void (^)(BOOL, YYIMError *))complete {
    [self.netMeetingManager kickReservationNetMeeting:channelId member:members complete:complete];
}

#pragma mark -
#pragma mark attach

- (void)addAttachProgressDelegate:(id<YYIMAttachProgressDelegate>)delegate {
    [self.attachManager addAttachProgressDelegate:delegate];
}

- (void)downloadAttach:(NSString *)attachId targetPath:(NSString *)targetPath imageType:(YYIMImageType)imageType thumbnail:(BOOL)thumbnail fileSize:(long long)fileSize progress:(YYIMAttachDownloadProgressBlock)downloadProgress complete:(YYIMAttachDownloadCompleteBlock)downloadComplete {
    [self.attachManager downloadAttach:attachId targetPath:targetPath imageType:imageType thumbnail:thumbnail fileSize:fileSize progress:downloadProgress complete:downloadComplete];
}

- (void)uploadAttach:(NSString *)relaAttachPath fileName:(NSString *)fileName receiver:(NSString *)receiver mediaType:(YYIMUploadMediaType)mediaType isOriginal:(BOOL)isOriginal complete:(YYIMAttachUploadCompleteBlock)complete {
    [self.attachManager uploadAttach:relaAttachPath fileName:fileName receiver:receiver mediaType:mediaType isOriginal:isOriginal complete:complete];
}

- (YYAttach *)getAttachState:(NSString *)attachId {
    return [self.attachManager getAttachState:attachId];
}

- (YYAttach *)getAttachState:(NSString *)attachId imageType:(YYIMImageType)imageType {
    return [self.attachManager getAttachState:attachId imageType:imageType];
}

#pragma mark -
#pragma mark jumpstream

- (void)jumpStreamDidAuthenticate:(JUMPStream *)sender {
    [[YYIMConfig sharedInstance] setJid:[[sender myJID] bare]];
    [YYIMHttpUtility updateDeviceToken];
    [self loadUser:[[YYIMConfig sharedInstance] getUser]];
    [self loadRoster];
    [self loadRosterUsers];
    [self loadPubAccount];
    [self loadChatGroupAndMembers];
    [self resetNetMeetingKit];
    [self goOnline];
    [self.messageManager loadOfflineMessage];
    [[self activeDelegate] didAuthenticate];
}

- (BOOL)jumpStream:(JUMPStream *)sender didReceiveIQ:(JUMPIQ *)iq {
    
    return NO;
}

- (void)jumpStream:(JUMPStream *)sender didReceivePresence:(JUMPPresence *)presence {
    if (![presence checkOpData:JUMP_OPDATA(JUMPPresencePacketOpCode)]) {
        return;
    }
    
    JUMPJID *fromJID = [presence from];
    if (![[[YYIMConfig sharedInstance] getIMServerName] isEqualToString:[fromJID domain]]) {
        return;
    }
    
    NSString *rosterId = [YYIMJUMPHelper parseUser:[fromJID user]];
    if ([YYIMStringUtility isEmpty:rosterId]) {
        return;
    }
    
    if ([rosterId isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        [[self activeDelegate] didPresenceOnline];
        return;
    }
    
    NSString *type = [presence type];
    
    YYIMClientType clientType = [YYIMJUMPHelper parseResourceClient:[fromJID resource]];
    if ([type isEqualToString:@"available"]) {
        NSString *state = [presence status];
        YYIMRosterState clientState = kYYIMRosterStateOffline;
        if([state isEqualToString:@"chat"]) {
            clientState = kYYIMRosterStateChat;
        } else if ([state isEqualToString:@"unavailable"]) {
            clientState = kYYIMRosterStateUnavaliable;
        } else if ([state isEqualToString:@"away"]) {
            clientState = kYYIMRosterStateAway;
        } else if ([state isEqualToString:@"dnd"]) {
            clientState = kYYIMRosterStateDnd;
        } else {
            clientState = kYYIMRosterStateChat;
        }
        if (clientState > 0) {
            [[self getRosterProvider] updateRosterState:clientState roster:rosterId clientType:clientType];
        }
    } else if ([type isEqualToString:@"unavailable"]) {
        [[self getRosterProvider] updateRosterState:kYYIMRosterStateOffline roster:rosterId clientType:clientType];
    }
}

- (void)jumpStream:(JUMPStream *)sender didReceiveError:(JUMPError *)error {
    if ([error isStreamError]) {
        YYIMLogError(@"didReceiveStreamError%@", [error jsonString]);
    } else if ([error isPacketError]) {
        YYIMLogError(@"didReceivePacketError%@", [error jsonString]);
    }
}

@end
