//
//  YYIMMessageManager.m
//  YonyouIM
//
//  Created by litfb on 15/1/21.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "YYIMMessageManager.h"

#import "JUMPFramework.h"
#import "YYIMChat.h"
#import "YYIMDBHelper.h"
#import "YYIMJUMPHelper.h"
#import "YYIMStringUtility.h"
#import "YYIMHttpUtility.h"
#import "YYIMDefs.h"
#import "YYIMConfig.h"
#import "YYIMResourceUtility.h"
#import "YYIMError.h"
#import "YYIMLogger.h"
#import "YMAFNetworking.h"
#import "YYIMConfig.h"
#import "YYIMStringUtility.h"
#import "YYIMNotificationManager.h"
#import "YYIMMessageVersionHelper.h"
#import "YYNetMeetingInfo.h"
#import "YYIMNetMeetingDBHelper.h"
#import "YYNetMeetingDefine.h"
#import "YYMessageFile.h"

#define YM_RECEIPT_STATE_ARRIVAL            @"1"
#define YM_RECEIPT_STATE_READED             @"2"

@interface YYIMMessageManager ()<JUMPStreamDelegate> {
    dispatch_queue_t messageSerialQueue;
}

@end

@implementation YYIMMessageManager

- (instancetype)init {
    if (self = [super init]) {
        messageSerialQueue = dispatch_queue_create("com.yonyou.sns.im.yyimmessagemanager", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark message protocol

- (NSArray *)getRecentMessage {
    NSArray *array = [[YYIMDBHelper sharedInstance] getRecentMessage];
    for (YYRecentMessage *message in array) {
        if ([YM_MESSAGE_TYPE_CHAT isEqualToString:[message chatType]]) {
            [message setRoster:[[YYIMChat sharedInstance].chatManager getRosterWithId:[message rosterId]]];
            [message setUser:[[YYIMChat sharedInstance].chatManager getUserWithId:[message rosterId]]];
            [message setChatExt:[[YYIMDBHelper sharedInstance] getUserExtWithId:[message rosterId]]];
        } else if ([YM_MESSAGE_TYPE_GROUPCHAT isEqualToString:[message chatType]]) {
            NSString *groupId = [message direction] == YM_MESSAGE_DIRECTION_RECEIVE ? [message fromId] : [message toId];
            [message setGroup:[[YYIMChat sharedInstance].chatManager getChatGroupWithGroupId:groupId]];
            [message setRoster:[[YYIMChat sharedInstance].chatManager getRosterWithId:[message rosterId]]];
            [message setUser:[[YYIMChat sharedInstance].chatManager getUserWithId:[message rosterId]]];
            [message setChatExt:[[YYIMDBHelper sharedInstance] getChatGroupExtWithId:groupId]];
        } else if ([YM_MESSAGE_TYPE_PUBACCOUNT isEqualToString:[message chatType]]) {
            [message setAccount:[[YYIMDBHelper sharedInstance] getPubAccountWithId:[message rosterId]]];
            [message setChatExt:[[YYIMDBHelper sharedInstance] getPubAccountExtWithId:[message rosterId]]];
        }
    }
    return array;
}

- (void)getRecentMessageWithBlock:(void (^)(NSArray *))resultBlock {
    dispatch_async([self moduleQueue], ^{
        NSArray *array = [self getRecentMessage];
        dispatch_async(dispatch_get_main_queue(), ^{
            resultBlock(array);
        });
    });
}

- (NSArray *)getRecentRoster {
    NSArray *array = [[YYIMDBHelper sharedInstance] getRecentMessage2];
    NSMutableArray *rosterArray = [NSMutableArray array];
    for (YYRecentMessage *message in array) {
        if ([YM_MESSAGE_TYPE_CHAT isEqualToString:[message chatType]]) {
            if ([message isSystemMessage]) {
                continue;
            }
            YYRoster *roster = [[YYIMChat sharedInstance].chatManager getRosterWithId:[message rosterId]];
            YYUser *user = [[YYIMChat sharedInstance].chatManager getUserWithId:[message rosterId]];
            if (roster) {
                [roster setUser:user];
                [rosterArray addObject:roster];
            } else if (user) {
                [rosterArray addObject:user];
            }
        } else {
            continue;
        }
    }
    return rosterArray;
}

- (NSInteger)getUnreadMsgCount {
    return [[YYIMDBHelper sharedInstance] getUnreadMsgCount];
}

- (NSInteger)getUnreadMsgCount:(NSString *)chatId {
    return [[YYIMDBHelper sharedInstance] getUnreadMsgCount:chatId];
}

- (NSInteger)getUnreadMsgCountMyOtherClient {
    return [[YYIMDBHelper sharedInstance] getUnreadMsgCountMyOtherClient];
}

- (NSArray *)getMessageWithId:(NSString *)chatId {
    NSArray *messageArray = [[YYIMDBHelper sharedInstance] getMessageWithId:chatId];
    // 处理消息已读状态、资源状态
    [self processMessageState:messageArray];
    return messageArray;
}

- (NSArray *)getMessageWithId:(NSString *)chatId beforePid:(NSString *)pid pageSize:(NSInteger)pageSize {
    NSArray *messageArray = [[YYIMDBHelper sharedInstance] getMessageWithId:chatId beforePid:pid pageSize:pageSize];
    // 处理消息已读状态、资源状态
    [self processMessageState:messageArray];
    return messageArray;
}

- (NSArray *)getCustomMessageWithId:(NSString *)chatId customType:(NSInteger)customType beforePid:(NSString *)pid pageSize:(NSInteger)pageSize {
    return [[YYIMDBHelper sharedInstance] getCustomMessageWithId:chatId customType:customType beforePid:pid pageSize:pageSize];
}

- (void)processMessageState:(NSArray *)messageArray {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL sendReaded = YES;
        for (long i = messageArray.count - 1; i >= 0; i--) {
            YYMessage *message = [messageArray objectAtIndex:i];
            if (sendReaded && [message direction] == YM_MESSAGE_DIRECTION_RECEIVE) {
                if ([[message chatType] isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT] || [[message chatType] isEqualToString:YM_MESSAGE_TYPE_PUBACCOUNT] || [message isSystemMessage]) {
                    sendReaded = NO;
                }
                if ([message status] == YM_MESSAGE_STATE_NEW) {
                    [self sendReadedMessageWithType:[message chatType] to:[YYIMJUMPHelper genFullJid:[message fromId]] packetID:[message pid]];
                }
                sendReaded = NO;
            }
            // 处理资源下载
            switch ([message type]) {
                case YM_MESSAGE_CONTENT_IMAGE:
                case YM_MESSAGE_CONTENT_MICROVIDEO:
                case YM_MESSAGE_CONTENT_AUDIO:
                case YM_MESSAGE_CONTENT_LOCATION:
                    if ([message direction] == YM_MESSAGE_DIRECTION_SEND && ([message status] < YM_MESSAGE_STATE_SENT_OR_READ || ![YYIMStringUtility isEmpty:[message resThumbLocal]] || ![YYIMStringUtility isEmpty:[message resLocal]])) {
                        break;
                    }
                    
                    if ([message downloadStatus] == YM_MESSAGE_DOWNLOADSTATE_INI) {
                        // 资源下载
                        [self messageResDownload:message];
                    }
                    break;
                default:
                    break;
            }
        }
    });
}

- (NSArray *)getMessageWithId:(NSString *)chatId afterPid:(NSString *)pid {
    NSArray *messageArray = [[YYIMDBHelper sharedInstance] getMessageWithId:chatId afterPid:pid];
    return messageArray;
}

- (YYMessage *)getMessageWithPid:(NSString *)pid {
    return [[YYIMDBHelper sharedInstance] getMessageWithPid:pid];
}

- (NSArray *)getChatUserWithChatId:(NSString *)chatId {
    NSArray *rosterIdArray = [[YYIMDBHelper sharedInstance] getRosterIdArrayWithChatId:chatId];
    NSMutableArray *userArray = [NSMutableArray array];
    for (NSString *rosterId in rosterIdArray) {
        YYUser *user = [[YYIMChat sharedInstance].chatManager getUserWithId:rosterId];
        if (user) {
            [userArray addObject:user];
        }
    }
    return userArray;
}

- (NSArray *)getMessageWithId:(NSString *)chatId contentType:(NSInteger)contentType {
    return [[YYIMDBHelper sharedInstance] getMessageWithId:chatId contentType:contentType];
}

/**
 *  根据关键字返回消息信息集合
 *
 *  @param key 关键字
 *
 *  @return 根据关键字返回消息信息集合
 */
- (NSArray *)getMessageWithKey:(NSString *)key{
    return [self getMessageWithKey:key limit:0];
}

/**
 *  根据关键字返回消息信息集合
 *
 *  @param key   关键字
 *  @param limit 返回的条目上限
 *
 *  @return 根据关键字返回消息信息集合
 */
- (NSArray *)getMessageWithKey:(NSString *)key limit:(NSInteger)limit {
    NSArray *array = [[YYIMDBHelper sharedInstance] getMessageWithKey:key limit:limit];
    
    for (YYMessage *message in array) {
        if ([YM_MESSAGE_TYPE_CHAT isEqualToString:[message chatType]]) {
            [message setRoster:[[YYIMChat sharedInstance].chatManager getRosterWithId:[message rosterId]]];
            [message setUser:[[YYIMChat sharedInstance].chatManager getUserWithId:[message rosterId]]];
        }
        if ([YM_MESSAGE_TYPE_GROUPCHAT isEqualToString:[message chatType]]) {
            NSString *groupId = [message direction] == YM_MESSAGE_DIRECTION_RECEIVE ? [message fromId] : [message toId];
            [message setGroup:[[YYIMChat sharedInstance].chatManager getChatGroupWithGroupId:groupId]];
        } else if ([YM_MESSAGE_TYPE_PUBACCOUNT isEqualToString:[message chatType]]) {
            [message setAccount:[[YYIMDBHelper sharedInstance] getPubAccountWithId:[message rosterId]]];
        }
    }
    
    return array;
}

/**
 *  根据关键字和对方id返回消息信息集合
 *
 *  @param key    关键字
 *  @param fromId 对方id
 *
 *  @return 根据关键字和对方id返回消息信息集合
 */
- (NSArray *)getMessageWithKey:(NSString *)key chatId:(NSString *)chatId {
    NSArray *array = [[YYIMDBHelper sharedInstance] getMessageWithKey:key chatId:chatId];
    
    for (YYMessage *message in array) {
        if ([YM_MESSAGE_TYPE_CHAT isEqualToString:[message chatType]]) {
            [message setRoster:[[YYIMChat sharedInstance].chatManager getRosterWithId:[message rosterId]]];
            [message setUser:[[YYIMChat sharedInstance].chatManager getUserWithId:[message rosterId]]];
        }
        if ([YM_MESSAGE_TYPE_GROUPCHAT isEqualToString:[message chatType]]) {
            NSString *groupId = [message direction] == YM_MESSAGE_DIRECTION_RECEIVE ? [message fromId] : [message toId];
            [message setGroup:[[YYIMChat sharedInstance].chatManager getChatGroupWithGroupId:groupId]];
        } else if ([YM_MESSAGE_TYPE_PUBACCOUNT isEqualToString:[message chatType]]) {
            [message setAccount:[[YYIMDBHelper sharedInstance] getPubAccountWithId:[message rosterId]]];
        }
    }
    
    return array;
}

- (void)deleteMessageWithId:(NSString *)chatId {
    [[YYIMDBHelper sharedInstance] deleteMessageWithId:chatId];
    
    if ([chatId isEqualToString:YM_NETCONFERENCE_PUBACCOUNT]) {
        [[YYIMNetMeetingDBHelper sharedInstance] cleanNetMeetingNotice];
    }
    
    [[self activeDelegate] didMessageDelete:[NSDictionary dictionaryWithObject:chatId forKey:@"chatId"]];
}

- (void)deleteMessageWithPid:(NSString *)packetId {
    [[YYIMDBHelper sharedInstance] deleteMessageWithPid:packetId];
    [[self activeDelegate] didMessageDelete:[NSDictionary dictionaryWithObject:packetId forKey:@"packetId"]];
}


- (void)deleteAllMessage {
    [[YYIMDBHelper sharedInstance] deleteAllMessage];
    [[self activeDelegate] didMessageDelete:[NSDictionary dictionaryWithObject:@"all" forKey:@"chatId"]];
}

- (NSArray *)getReceivedFileMessage {
    NSArray *array = [[YYIMDBHelper sharedInstance] getReceivedFileMessage];
    for (YYRecentMessage *message in array) {
        [message setUser:[[YYIMChat sharedInstance].chatManager getUserWithId:[message rosterId]]];
    }
    return array;
}

- (void)updateAudioReaded:(NSString *)packetId {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[YYIMDBHelper sharedInstance] updateMessageSpecState:YM_MESSAGE_SPECIFIC_AUDIO_READ pid:packetId];
    });
}

- (void)updateMessageReadedWithPid:(NSString *)packetId {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YYMessage *message = [[YYIMDBHelper sharedInstance] getMessageWithPid:packetId];
        if ([message status] >= YM_MESSAGE_STATE_SENT_OR_READ) {
            return;
        }
        
        [[YYIMDBHelper sharedInstance] updateMessageReadedWithPid:packetId];
        [self sendReadedMessageWithType:[message chatType] to:[YYIMJUMPHelper genFullJid:[message fromId]] packetID:[message pid]];
        [[self activeDelegate] didMessageStateChange:message];
    });
}

- (void)updateMessageReadedWithId:(NSString *)chatId {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[YYIMDBHelper sharedInstance] updateMessageReadedWithId:chatId];
        [[self activeDelegate] didMessageStateChangeWithChatId:chatId];
    });
}

- (void)sendTextMessage:(NSString *)chatId text:(NSString *)text chatType:(NSString *)chatType {
    [self sendTextMessage:chatId text:text chatType:chatType atUserArray:nil extendValue:nil];
}

- (void)sendTextMessage:(NSString *)chatId text:(NSString *)text chatType:(NSString *)chatType atUserArray:(NSArray *)atUserArray {
    [self sendTextMessage:chatId text:text chatType:chatType atUserArray:atUserArray extendValue:nil];
}

- (void)sendTextMessage:(NSString *)chatId text:(NSString *)text chatType:(NSString *)chatType atUserArray:(NSArray *)atUserArray extendValue:(NSString *)extendValue {
    NSParameterAssert(chatId != nil);
    NSParameterAssert(text != nil && ![@"" isEqualToString:text]);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YYMessageContent *content = [YYMessageContent contentWithText:text atUserArray:atUserArray extendValue:extendValue];
        [self sendMessage:chatId contentType:YM_MESSAGE_CONTENT_TEXT content:content chatType:chatType];
    });
}

/**
 *  发送视频会议或者直播的分享消息
 *
 *  @param chatId     会话id
 *  @param chatType   会话类型
 *  @param netMeeting 会议对象
 */
- (void)sendNetMeetingMessage:(NSString *)chatId chatType:(NSString *)chatType netMeeting:(YYNetMeeting *)netMeeting {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YYMessageContent *content = [YYMessageContent contentWithNetMeeting:netMeeting];
        [self sendMessage:chatId contentType:YM_MESSAGE_CONTENT_NETMEETING content:content chatType:chatType];
    });
}

- (void)sendImageMessage:(NSString *)chatId paths:(NSArray *)imagePathArray chatType:(NSString *)chatType {
    NSParameterAssert(chatId != nil);
    NSParameterAssert(imagePathArray != nil && [imagePathArray count] > 0);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSString *imagePath in imagePathArray) {
            // content
            YYMessageContent *content = [YYMessageContent contentWithImagePath:imagePath isOriginal:NO];
            [self sendMessage:chatId contentType:YM_MESSAGE_CONTENT_IMAGE content:content chatType:chatType];
        }
    });
}

- (void)sendImageMessage:(NSString *)chatId assets:(NSArray *)assetArray chatType:(NSString *)chatType {
    [self sendImageMessage:chatId assets:assetArray chatType:chatType isOriginal:NO];
}

- (void)sendImageMessage:(NSString *)chatId assets:(NSArray *)assetArray chatType:(NSString *)chatType isOriginal:(BOOL)isOriginal {
    [self sendImageMessage:chatId assets:assetArray chatType:chatType isOriginal:isOriginal extendValue:nil];
}

- (void)sendImageMessage:(NSString *)chatId assets:(NSArray *)assetArray chatType:(NSString *)chatType isOriginal:(BOOL)isOriginal extendValue:(NSString *)extendValue {
    NSParameterAssert(chatId != nil);
    NSParameterAssert(assetArray != nil && [assetArray count] > 0);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (id obj in assetArray) {
            if (![obj isMemberOfClass:[ALAsset class]]) {
                return;
            }
            // asset
            ALAsset *asset = (ALAsset *)obj;
            
            NSString *imagePath;
            NSString *fileName;
            if (isOriginal) {
                imagePath = [YYIMResourceUtility saveAssets:asset];
                fileName = [[asset defaultRepresentation] filename];
            } else {
                CGImageRef imageRef = [[asset defaultRepresentation] fullScreenImage];
                // 缩图
                UIImage *thumbImage = [YYIMResourceUtility thumbImage:[UIImage imageWithCGImage:imageRef] maxSide:1280.0f];
                // 保存image到Document
                imagePath = [YYIMResourceUtility saveImage:thumbImage];
                fileName = [imagePath lastPathComponent];
            }
            
            // content
            YYMessageContent *content = [YYMessageContent contentWithImagePath:imagePath isOriginal:isOriginal];
            [content setFileName:fileName];
            if (![YYIMStringUtility isEmpty:extendValue]) {
                [content setExtendValue:extendValue];
            }
            [self sendMessage:chatId contentType:YM_MESSAGE_CONTENT_IMAGE content:content chatType:chatType];
        }
    });
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
    NSParameterAssert(chatId != nil);
    NSParameterAssert(filePath != nil);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // content
        YYMessageContent *content = [YYMessageContent contentWithMicroVideoPath:filePath thumbPath:thumbPath];
        [self sendMessage:chatId contentType:YM_MESSAGE_CONTENT_MICROVIDEO content:content chatType:chatType];
    });
}

- (void)sendAudioMessage:(NSString *)chatId wavPath:(NSString *)audioPath chatType:(NSString *)chatType {
    [self sendAudioMessage:chatId wavPath:audioPath chatType:chatType extendValue:nil];
}

- (void)sendAudioMessage:(NSString *)chatId wavPath:(NSString *)audioPath chatType:(NSString *)chatType extendValue:(NSString *)extendValue {
    NSParameterAssert(chatId != nil);
    NSParameterAssert(audioPath != nil);
    NSParameterAssert([@"wav" isEqualToString:[audioPath pathExtension]]);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // relaPath
        NSString *relaPath = [YYIMResourceUtility resourceRelaPathWithResType:YYIM_RESOURCE_TYPE_AUDIO filePath:audioPath];
        // content
        YYMessageContent *content = [YYMessageContent contentWithAudioPath:relaPath];
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:audioPath] error:nil];
        [content setDuration:audioPlayer.duration];
        if (![YYIMStringUtility isEmpty:extendValue]) {
            [content setExtendValue:extendValue];
        }
        [self sendMessage:chatId contentType:YM_MESSAGE_CONTENT_AUDIO content:content chatType:chatType];
    });
}

- (void)sendFileMessage:(NSString *)chatId filePath:(NSString *)filePath chatType:(NSString *)chatType {
    [self sendFileMessage:chatId filePath:filePath chatType:chatType extendValue:nil];
}

- (void)sendFileMessage:(NSString *)chatId filePath:(NSString *)filePath chatType:(NSString *)chatType extendValue:(NSString *)extendValue {
    NSParameterAssert(chatId != nil);
    NSParameterAssert(filePath != nil);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YYMessageContent *content = [YYMessageContent contentWithFilePath:filePath];
        [content setExtendValue:extendValue];
        [self sendMessage:chatId contentType:YM_MESSAGE_CONTENT_FILE content:content chatType:chatType];
    });
}

- (void)sendShareMessage:(NSString *)chatId url:(NSString *)urlString title:(NSString *)title description:(NSString *)description imageUrl:(NSString *)imageUrlString extendValue:(NSString *)extendValue chatType:(NSString *)chatType {
    NSParameterAssert(chatId != nil);
    NSParameterAssert(title != nil);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YYMessageContent *content = [YYMessageContent contentWithShareUrl:urlString title:title description:description imageUrlString:imageUrlString extendValue:extendValue];
        [self sendMessage:chatId contentType:YM_MESSAGE_CONTENT_SHARE content:content chatType:chatType];
    });
}

- (void)sendCustomMessage:(NSString *)chatId customType:(NSInteger)customType customDictionary:(NSDictionary *)customDictionary extendValue:(NSString *)extendValue chatType:(NSString *)chatType {
    NSParameterAssert(chatId != nil);
    NSParameterAssert(extendValue != nil);
    NSParameterAssert(customDictionary != nil);
    NSParameterAssert([NSJSONSerialization isValidJSONObject:customDictionary]);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YYMessageContent *content = [YYMessageContent contentWithCustomType:customType customDictionary:customDictionary extendValue:extendValue];
        [self sendMessage:chatId contentType:YM_MESSAGE_CONTENT_CUSTOM content:content chatType:chatType];
    });
}

- (void)forwardFileMessage:(NSString *)chatId pid:(NSString *)packetId chatType:(NSString *)chatType {
    if ([YYIMStringUtility isEmpty:chatId]) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YYMessage *message = [[YYIMDBHelper sharedInstance] getMessageWithPid:packetId];
        if (!message || [message type] != YM_MESSAGE_CONTENT_FILE || [message direction] != YM_MESSAGE_DIRECTION_RECEIVE) {
            return;
        }
        
        [self forwardMessage:chatId oldMessage:message chatType:chatType];
    });
}

- (void)forwardMessage:(NSString *)chatId pid:(NSString *)packetId chatType:(NSString *)chatType {
    if ([YYIMStringUtility isEmpty:chatId]) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YYMessage *message = [[YYIMDBHelper sharedInstance] getMessageWithPid:packetId];
        if (!message) {
            return;
        }
        
        [self forwardMessage:chatId oldMessage:message chatType:chatType];
    });
}

- (void)sendLocationManager:(NSString *)chatId imagePath:(NSString *)imagePath address:(NSString *)address longitude:(float)longitude latitude:(float)latitude chatType:(NSString *)chatType {
    NSParameterAssert(chatId != nil);
    NSParameterAssert(imagePath != nil);
    NSParameterAssert(address != nil);
    NSParameterAssert(longitude > 0);
    NSParameterAssert(latitude > 0);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YYMessageContent *content = [YYMessageContent contentWithLocation:imagePath address:address longitude:longitude latitude:latitude];
        [self sendMessage:chatId contentType:YM_MESSAGE_CONTENT_LOCATION content:content chatType:chatType];
    });
}

- (void)resendMessage:(NSString *) pid {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 更新成New
        [[YYIMDBHelper sharedInstance] updateMessageState:YM_MESSAGE_STATE_NEW pid:pid force:YES];
        // willSend
        YYMessage *message = [[YYIMDBHelper sharedInstance] getMessageWithPid:pid];
        [[self activeDelegate] willSendMessage:message];
        switch ([message type]) {
            case YM_MESSAGE_CONTENT_TEXT:
                [self sendMessage:message];
                break;
            case YM_MESSAGE_CONTENT_IMAGE:
            case YM_MESSAGE_CONTENT_MICROVIDEO:
            case YM_MESSAGE_CONTENT_AUDIO:
            case YM_MESSAGE_CONTENT_FILE:
            case YM_MESSAGE_CONTENT_LOCATION: {
                if ([message uploadStatus] == YM_MESSAGE_UPLOADSTATE_SUCCESS) {
                    [self sendMessage:message];
                } else {
                    [self uploadMessageRes:message];
                }
                break;
            }
            default:
                break;
        }
    });
}

- (void)downloadMessageRes:(NSString *)pid {
    YYMessage *message = [[YYIMDBHelper sharedInstance] getMessageWithPid:pid];
    [self messageResDownload:message];
}

- (void)downloadMicroVideoMessageRes:(NSString *)pid progress:(YYIMAttachDownloadProgressBlock)downloadProgress complete:(YYIMAttachDownloadCompleteBlock)downloadComplete {
    YYMessage *message = [[YYIMDBHelper sharedInstance] getMessageWithPid:pid];
    if ([message type] != YM_MESSAGE_CONTENT_MICROVIDEO) {
        return;
    }
    
    YYMessageContent *content = [message getMessageContent];
    NSString *attachId = [content fileAttachId];
    // 资源相对路径
    long long fileSize = [content fileSize];
    NSString *relaPath = [YYIMResourceUtility resourceAttachRelaPathWithId:attachId ext:[content fileExtension]];
    
    [message setDownloadStatus:YM_MESSAGE_DOWNLOADSTATE_ING];
    [[YYIMDBHelper sharedInstance] updateMessage:message];
    [[self activeDelegate] didMessageResStatusChanged:message error:nil];
    
    [[YYIMChat sharedInstance].chatManager downloadAttach:attachId targetPath:relaPath imageType:kYYIMImageTypeNormal thumbnail:NO fileSize:fileSize progress:downloadProgress complete:^(BOOL result, NSString *filePath, YYIMError *error) {
        if (result) {
            // 资源下载成功
            [message setResLocal:relaPath];
            [message setDownloadStatus:YM_MESSAGE_DOWNLOADSTATE_SUCCESS];
        } else {
            // 资源下载失败
            [message setDownloadStatus:YM_MESSAGE_DOWNLOADSTATE_FAILD];
        }
        // 更新消息
        [[YYIMDBHelper sharedInstance] updateMessage:message];
        // 通知
        [[self activeDelegate] didMessageResStatusChanged:message error:error];
        
        if (downloadComplete) {
            downloadComplete(result, filePath, error);
        }
    }];
}

- (void)downloadImageMessageRes:(NSString *)pid imageType:(YYIMImageType)imageType progress:(YYIMAttachDownloadProgressBlock)downloadProgress complete:(YYIMAttachDownloadCompleteBlock)downloadComplete {
    YYMessage *message = [[YYIMDBHelper sharedInstance] getMessageWithPid:pid];
    if ([message type] != YM_MESSAGE_CONTENT_IMAGE) {
        return;
    }
    if (imageType == kYYIMImageTypeThumb) {
        [message setDownloadStatus:YM_MESSAGE_DOWNLOADSTATE_ING];
        [[YYIMDBHelper sharedInstance] updateMessage:message];
        [[self activeDelegate] didMessageResStatusChanged:message error:nil];
    }
    
    YYMessageContent *content = [message getMessageContent];
    NSString *attachId = [content fileAttachId];
    // 资源相对路径
    NSString *relaPath;
    long long fileSize = -1;
    switch (imageType) {
        case kYYIMImageTypeOriginal:
            relaPath = [YYIMResourceUtility resourceAttachRelaPathWithId:[NSString stringWithFormat:@"%@_%@", attachId, @"original"] ext:[content fileExtension]];
            if ([content isOriginal]) {
                fileSize = [content fileSize];
            }
            break;
        case kYYIMImageTypeThumb:
            relaPath = [YYIMResourceUtility resourceAttachRelaPathWithId:[NSString stringWithFormat:@"%@_%@", attachId, @"thumb"] ext:[content fileExtension]];
            fileSize = [content fileSize];
            break;
        default:
            relaPath = [YYIMResourceUtility resourceAttachRelaPathWithId:attachId ext:[content fileExtension]];
            if (![content isOriginal]) {
                fileSize = [content fileSize];
            }
            break;
    }
    
    [[YYIMChat sharedInstance].chatManager downloadAttach:attachId targetPath:relaPath imageType:imageType thumbnail:NO fileSize:fileSize progress:downloadProgress complete:^(BOOL result, NSString *filePath, YYIMError *error) {
        if (downloadComplete) {
            downloadComplete(result, filePath, error);
        }
        if (result) {
            // 资源下载成功
            switch (imageType) {
                case kYYIMImageTypeOriginal:
                    [message setResOriginalLocal:relaPath];
                    break;
                case kYYIMImageTypeThumb:
                    [message setResThumbLocal:relaPath];
                    [message setDownloadStatus:YM_MESSAGE_DOWNLOADSTATE_SUCCESS];
                    break;
                default:
                    [message setResLocal:relaPath];
                    break;
            }
            // 更新消息
            [[YYIMDBHelper sharedInstance] updateMessage:message];
            // 通知
            [[self activeDelegate] didMessageResStatusChanged:message error:error];
        } else {// 资源下载失败
            if (imageType == kYYIMImageTypeThumb) {
                [message setDownloadStatus:YM_MESSAGE_DOWNLOADSTATE_FAILD];
                // 更新消息
                [[YYIMDBHelper sharedInstance] updateMessage:message];
                // 通知
                [[self activeDelegate] didMessageResStatusChanged:message error:error];
            }
        }
    }];
}

- (void)getChatMessageFileList:(NSString *)chatId chatType:(NSString *)chatType fileType:(YYIMMessageFileType)fileType offset:(NSUInteger)offset limit:(NSUInteger)limit complete:(void (^)(BOOL, NSArray *, YYIMError *))complete {
    [self getChatMessageFileList:chatId chatType:chatType fileType:fileType keyword:nil offset:offset limit:limit complete:complete];
}

- (void)getChatMessageFileList:(NSString *)chatId chatType:(NSString *)chatType fileType:(YYIMMessageFileType)fileType keyword:(NSString *)keyword offset:(NSUInteger)offset limit:(NSUInteger)limit complete:(void (^)(BOOL, NSArray *, YYIMError *))complete {
    NSString *fileTypeString;
    switch (fileType) {
        case kYYIMMessageFileTypeDefault:
            fileTypeString = @"file";
            break;
        case kYYIMMessageFileTypeImage:
            fileTypeString = @"image";
            break;
        case kYYIMMessageFileTypeMicroVideo:
            fileTypeString = @"microvideo";
            break;
        default:
            fileTypeString = @"file";
            break;
    }
    
    NSString *urlString;
    if ([chatType isEqualToString:YM_MESSAGE_TYPE_CHAT]) {
        if ([YYIMStringUtility isEmpty:keyword]) {
            urlString = [[YYIMConfig sharedInstance] getMessageFileChatListServlet:chatId];
        } else {
            urlString = [[YYIMConfig sharedInstance] getMessageFileChatSearchServlet:chatId];
        }
    } else if ([chatType isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
        if ([YYIMStringUtility isEmpty:keyword]) {
            urlString = [[YYIMConfig sharedInstance] getMessageFileChatGroupListServlet:chatId];
        } else {
            urlString = [[YYIMConfig sharedInstance] getMessageFileChatGroupSearchServlet:chatId];
        }
    } else {
        complete(NO, nil, [YYIMError errorWithCode:YMERROR_CODE_UNEXPECT_STATE errorMessage:@"chatType not supported"]);
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
            [params setObject:[token tokenStr] forKey:@"token"];
            [params setObject:[NSNumber numberWithInteger:offset] forKey:@"start"];
            [params setObject:[NSNumber numberWithInteger:limit] forKey:@"size"];
            [params setObject:fileTypeString forKey:@"fileType"];
            
            if (fileType == kYYIMMessageFileTypeDefault && ![YYIMStringUtility isEmpty:keyword]) {
                [params setObject:keyword forKey:@"fileName"];
            }
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            [manager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                NSArray *items = [dic objectForKey:@"list"];
                
                NSMutableArray *files = [NSMutableArray array];
                for (NSDictionary *item in items) {
                    YYMessageFile *msgFile = [[YYMessageFile alloc] init];
                    [msgFile setAttachId:[item objectForKey:@"attachId"]];
                    [msgFile setCreator:[YYIMJUMPHelper parseUser:[item objectForKey:@"creator"]]];
                    [msgFile setFileName:[item objectForKey:@"fileName"]];
                    [msgFile setFileSize:[[item objectForKey:@"fileSize"] doubleValue]];
                    [msgFile setFileType:[item objectForKey:@"fileType"]];
                    [msgFile setOwnerId:[item objectForKey:@"ownerId"]];
                    
                    if ([[item objectForKey:@"ownerType"] isEqualToString:@"personal"]) {
                        [msgFile setOwnerType:YYIMFileOwnerTypePersonal];
                    } else {
                        [msgFile setOwnerType:YYIMFileOwnerTypeChatGroup];
                    }
                    
                    [msgFile setDate:[[item objectForKey:@"ts"] doubleValue]];
                    [msgFile setFileType:[item objectForKey:@"fileType"]];
                    [msgFile setDetailFileType:[item objectForKey:@"detailFileType"]];
                    [msgFile setSuffix:[item objectForKey:@"suffix"]];
                    
                    if (fileType == kYYIMMessageFileTypeDefault) {
                        //生成文件url
                        NSMutableString *fullUrlString = [NSMutableString stringWithString:[[YYIMConfig sharedInstance] getResourceDownloadServlet]];
                        [fullUrlString appendString:[NSString stringWithFormat:@"?token=%@&attachId=%@&downloader=%@", [token tokenStr], msgFile.attachId, [[YYIMConfig sharedInstance] getFullUser]]];
                        [msgFile setFilePreviewURL:[NSURL URLWithString:fullUrlString]];
                    } else if (fileType == kYYIMMessageFileTypeImage) {
                        //生成图片缩略图和图片
                        NSMutableString *fullUrlString = [NSMutableString stringWithString:[[YYIMConfig sharedInstance] getResourceDownloadServlet]];
                        [fullUrlString appendString:[NSString stringWithFormat:@"?token=%@&attachId=%@&downloader=%@", [token tokenStr], msgFile.attachId, [[YYIMConfig sharedInstance] getFullUser]]];
                        
                        NSString *thumb = [NSString stringWithFormat:@"%@&mediaType=%ld", fullUrlString, (long)kYYIMImageTypeThumb];
                        
                        [msgFile setImageURL:[NSURL URLWithString:fullUrlString]];
                        [msgFile setThumbImageURL:[NSURL URLWithString:thumb]];
                    }
                    
                    [files addObject:msgFile];
                }
                complete(YES, files, nil);
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                YYIMLogError(@"获取%@文件列表失败：%@", fileTypeString, error.localizedDescription);
                complete(NO, nil, [YYIMError errorWithNSError:error]);
            }];
        } else {
            complete(NO, nil, tokenError);
        }
    }];
}

- (void)revokeChatMessageWithId:(NSString *)pid {
    YYMessage *message = [[YYIMDBHelper sharedInstance] getMessageWithPid:pid];
    if (!message || [message direction] != YM_MESSAGE_DIRECTION_SEND) {
        YYIMError *error = [YYIMError errorWithCode:YMERROR_CODE_ILLEGAL_ARGUMENT errorMessage:@"no message revokable"];
        [[self activeDelegate] didNotRevokeMessageWithPid:pid error:error];
    }
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:[token tokenStr] forKey:@"token"];
            [params setObject:[message fromId] forKey:@"fromuserid"];
            [params setObject:[message toId] forKey:@"touserid"];
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            [manager PUT:[[YYIMConfig sharedInstance] getPersonalMessageRevokeServlet:pid] parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                // do revoke
                YYMessage *message = [[YYIMDBHelper sharedInstance] revokeMessageWithPid:pid];
                [[self activeDelegate] didRevokeMessageWithPid:pid];
                [[self activeDelegate] didMessageRevoked:message];
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {YYIMLogError(@"chatMessageRevokeFaild:%@", responseObject);
                NSDictionary *dic = (NSDictionary *)responseObject;
                [[self activeDelegate] didNotRevokeMessageWithPid:pid error:[YYIMError errorWithCode:[[dic objectForKey:@"detailCode"] integerValue] errorMessage:[dic objectForKey:@"message"]]];
            }];
        } else {
            [[self activeDelegate] didNotRevokeMessageWithPid:pid error:tokenError];
        }
    }];
}

- (void)revokeGroupChatMessageWithId:(NSString *)pid {
    YYMessage *message = [[YYIMDBHelper sharedInstance] getMessageWithPid:pid];
    if (!message || [message direction] != YM_MESSAGE_DIRECTION_SEND) {
        YYIMError *error = [YYIMError errorWithCode:YMERROR_CODE_ILLEGAL_ARGUMENT errorMessage:@"no message revokable"];
        [[self activeDelegate] didNotRevokeMessageWithPid:pid error:error];
    }
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:[token tokenStr] forKey:@"token"];
            [params setObject:[message fromId] forKey:@"userid"];
            [params setObject:[message toId] forKey:@"mucid"];
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            [manager PUT:[[YYIMConfig sharedInstance] getGroupMessageRevokeServlet:pid] parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                // do revoke
                YYMessage *message = [[YYIMDBHelper sharedInstance] revokeMessageWithPid:pid];
                [[self activeDelegate] didRevokeMessageWithPid:pid];
                [[self activeDelegate] didMessageRevoked:message];
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                YYIMLogError(@"groupMessageRevokeFaild:%@", responseObject);
                NSDictionary *dic = (NSDictionary *)responseObject;
                [[self activeDelegate] didNotRevokeMessageWithPid:pid error:[YYIMError errorWithCode:[[dic objectForKey:@"detailCode"] integerValue] errorMessage:[dic objectForKey:@"message"]]];
            }];
        } else {
            [[self activeDelegate] didNotRevokeMessageWithPid:pid error:tokenError];
        }
    }];
}

#pragma mark jumpstream protocol

- (BOOL)jumpStream:(JUMPStream *)sender didReceiveIQ:(JUMPIQ *)iq {
    return [[self tracker] invokeForID:[iq packetID] withObject:iq];
}

- (void)jumpStream:(JUMPStream *)sender didFailToSendIQ:(JUMPIQ *)iq error:(NSError *)error {
    if ([iq packetID]) {
        [[self tracker] invokeForID:[iq packetID] withObject:nil];
    }
}

#pragma mark message send new logic
- (void)jumpStream:(JUMPStream *)sender didFailToSendMessage:(JUMPMessage *)message error:(NSError *)error {
    if ([message checkOpData:JUMP_OPDATA(JUMPMessagePacketOpCode)] || [message checkOpData:JUMP_OPDATA(JUMPMUCMessagePacketOpCode)] || [message checkOpData:JUMP_OPDATA(JUMPPubAccountMessagePacketOpCode)]) {
        [[self tracker] invokeForID:[message packetID] withObject:nil];
    }
}

//#warning 1
//- (void)jumpStream:(JUMPStream *)sender didSendMessage:(JUMPMessage *)message {
//    if ([message isMessageWithContent]) {
//        [[YYIMDBHelper sharedInstance] updateMessageState:YM_MESSAGE_STATE_SENT_OR_READ pid:[message packetID]];
//        [[self activeDelegate] didSendMessage:[[YYIMDBHelper sharedInstance] getMessageWithPid:[message packetID]]];
//    }
//}
//
//#warning 2
//- (void)jumpStream:(JUMPStream *)sender didFailToSendMessage:(JUMPMessage *)message error:(NSError *)error {
//    if ([message checkOpData:JUMP_OPDATA(JUMPMessagePacketOpCode)] && [message checkOpData:JUMP_OPDATA(JUMPMUCMessagePacketOpCode)] && [message checkOpData:JUMP_OPDATA(JUMPPubAccountMessagePacketOpCode)]) {
//        [[YYIMDBHelper sharedInstance] updateMessageState:YM_MESSAGE_STATE_FAILD pid:[message packetID]];
//        [[self activeDelegate] didSendMessageFaild:[[YYIMDBHelper sharedInstance] getMessageWithPid:[message packetID]] error:[YYIMError errorWithNSError:error]];
//    }
//}

- (void)jumpStream:(JUMPStream *)sender didReceiveMessage:(JUMPMessage *)message {
    // 检查OpCode
    if ([message checkOpData:JUMP_OPDATA(JUMPMessageNotifyPacketOpCode)]) {// 离线消息通知处理
        YYIMLogInfo(@"client was told to load offline message!");
        [self loadOfflineMessage];
    } else if ([message checkOpData:JUMP_OPDATA(JUMPMessageReceiptsPacketOpCode)]) {// 处理回执
        [[self tracker] invokeForID:[message packetID] withObject:message];
        [self handleReceiptResponse:message];
    } else if ([message checkOpData:JUMP_OPDATA(JUMPMessagePacketOpCode)]) {// 单聊消息
        [self handleChatMessage:message];
    } else if ([message checkOpData:JUMP_OPDATA(JUMPMUCMessagePacketOpCode)]) {// 群聊消息
        [self handleGroupChatMessage:message];
    } else if ([message checkOpData:JUMP_OPDATA(JUMPPubAccountMessagePacketOpCode)]) {// 公共号消息
        [self handlePubAccountMessage:message];
    } else if ([message checkOpData:JUMP_OPDATA(JUMPMessageCarbonPacketOpCode)]) {// 其他端发送消息
        [self handleCarbonMessage:message];
    } else if ([message checkOpData:JUMP_OPDATA(JUMPMucOnlineDeliverPacketOpCode)]) {// 群组透传消息
        [self handleMucOnlineDeliverPacket:message];
    } else if ([message checkOpData:JUMP_OPDATA(JUMPPubAccountMessagePacketOpCode)]) {//公共号透传消息
        [self handlePubAccountOnlineDeliverPacket:message];
    } else if ([message checkOpData:JUMP_OPDATA(JUMPUserOnlineDeliverPacketOpCode)]) {// 用户透传消息
        [self handleUserOnlineDeliverPacket:message];
    }
}

/**
 *  处理单聊消息
 *
 *  @param messagePacket 消息Packet
 */
- (void)handleChatMessage:(JUMPMessage *)messagePacket {
    // 是否离线消息
    BOOL isOffline = [[messagePacket objectForKey:@"offline"] boolValue];
    // 消息版本号
    NSInteger packetVersion = [[messagePacket objectForKey:@"packetVersion"] longValue];
    if (!isOffline) {
        // 发回执
        if ([[[messagePacket objectForKey:@"receipts"] stringValue] isEqualToString:@"1"]) {
            JUMPMessage *response = [messagePacket generateReceiptResponse];
            [[self activeStream] sendPacket:response];
        }
        if (packetVersion > 0) {
            // 本地消息版本号处理
            [[YYIMMessageVersionHelper sharedInstance] handleMessageVersion:packetVersion];
        }
    }
    
    // 消息体
    NSString *body = [messagePacket objectForKey:@"content"];
    // body判空
    if ([YYIMStringUtility isEmpty:body]) {
        return;
    }
    
    // fromJID
    JUMPJID *fromJid = [messagePacket from];
    // 发送方ID
    NSString *fromId = nil;
    // 是匿名者
    if ([YM_ANONYMOUS_RESOURCE isEqualToString:[fromJid resource]]) {
        fromId = [NSString stringWithFormat:@"%@/ANONYMOUS", [fromJid user]];
    } else {
        fromId = [YYIMJUMPHelper parseUser:[fromJid user]];
    }
    
    // 判重
    if ([[YYIMDBHelper sharedInstance] isMessageReceived:[messagePacket packetID] fromId:fromId]) {
        return;
    }
    
    // 组装message对象
    YYMessage *message = [[YYMessage alloc] init];
    [message setPid:[messagePacket packetID]];
    [message setFromId:fromId];
    [message setToId:[[YYIMConfig sharedInstance] getUser]];
    // 联系人Id
    [message setRosterId:fromId];
    // 单聊
    [message setChatType:YM_MESSAGE_TYPE_CHAT];
    // 消息方向
    [message setDirection:YM_MESSAGE_DIRECTION_RECEIVE];
    // 消息体
    [message setMessage:body];
    // 发送方客户端类型
    [message setClientType:[YYIMJUMPHelper parseResourceClient:[fromJid resource]]];
    // 消息内容类型
    [message setType:[[messagePacket objectForKey:@"contentType"] integerValue]];
    // 消息时间戳
    [message setDate:[[messagePacket objectForKey:@"dateline"] longLongValue]];
    // 消息版本号
    [message setVersion:packetVersion];
    // 自定义消息类型
    [message setCustomType:[[message getMessageContent] customType]];
    
    // 是提示消息，直接是已读
    if ([message type] == YM_MESSAGE_CONTENT_PROMPT) {
        [message setStatus:YM_MESSAGE_STATE_SENT_OR_READ];
    } else {
        [message setStatus:YM_MESSAGE_STATE_NEW];
    }
    
    // 设置上传下载状态
    [message setUploadStatus:YM_MESSAGE_UPLOADSTATE_INI];
    [message setDownloadStatus:YM_MESSAGE_DOWNLOADSTATE_INI];
    
    // 设置keyinfo
    [message setKeyInfo:[self getKeyInfoWithType:[message type] message:message]];
    
    // 保存入数据库
    message = [[YYIMDBHelper sharedInstance] insertMessage:message];
    
    if (!isOffline) {
        // 通知didReceive
        [[self activeDelegate] didReceiveMessage:message];
        
        // 处理资源下载
        switch ([message type]) {
            case YM_MESSAGE_CONTENT_IMAGE:
            case YM_MESSAGE_CONTENT_AUDIO:
            case YM_MESSAGE_CONTENT_MICROVIDEO:
            case YM_MESSAGE_CONTENT_LOCATION:
                // 资源下载
                [self messageResDownload:message];
                break;
            default:
                break;
        }
    } else {
        [[YYIMNotificationManager sharedInstance] didReceiveOfflineMessage];
    }
}

/**
 *  处理群聊消息
 *
 *  @param messagePacket 消息Packet
 */
- (void)handleGroupChatMessage:(JUMPMessage *)messagePacket {
    // 是否离线消息
    BOOL isOffline = [[messagePacket objectForKey:@"offline"] boolValue];
    // 消息版本号
    NSInteger packetVersion = [[messagePacket objectForKey:@"packetVersion"] longValue];
    if (!isOffline) {
        // 发回执
        if ([[[messagePacket objectForKey:@"receipts"] stringValue] isEqualToString:@"1"]) {
            JUMPMessage *response = [messagePacket generateReceiptResponse];
            [[self activeStream] sendPacket:response];
        }
        if (packetVersion > 0) {
            // 本地消息版本号处理
            [[YYIMMessageVersionHelper sharedInstance] handleMessageVersion:packetVersion];
        }
    }
    
    // 消息体
    NSString *body = [messagePacket objectForKey:@"content"];
    // body判空
    if ([YYIMStringUtility isEmpty:body]) {
        return;
    }
    
    // fromJID
    JUMPJID *fromJid = [messagePacket from];
    // 群ID
    NSString *fromId = [YYIMJUMPHelper parseUser:[fromJid user]];
    
    // 判重
    if ([[YYIMDBHelper sharedInstance] isMessageReceived:[messagePacket packetID] fromId:fromId]) {
        return;
    }
    
    // 组装message对象
    YYMessage *message = [[YYMessage alloc] init];
    [message setPid:[messagePacket packetID]];
    
    // 自己发的
    NSString *rosterId = [YYIMJUMPHelper parseUser:[fromJid resource]];
    if ([YYIMJUMPHelper isSelf:rosterId]) {
        [message setFromId:[[YYIMConfig sharedInstance] getUser]];
        [message setToId:fromId];
        // 消息方向
        [message setDirection:YM_MESSAGE_DIRECTION_SEND];
    } else {
        [message setFromId:fromId];
        [message setToId:[[YYIMConfig sharedInstance] getUser]];
        // 联系人Id
        if ([message type] != YM_MESSAGE_CONTENT_PROMPT) {
            [message setRosterId:rosterId];
        }
        // 消息方向
        [message setDirection:YM_MESSAGE_DIRECTION_RECEIVE];
    }
    // 群聊
    [message setChatType:YM_MESSAGE_TYPE_GROUPCHAT];
    // 消息体
    [message setMessage:body];
    // 发送方客户端类型
    [message setClientType:[YYIMJUMPHelper parseResourceClient:[fromJid resource]]];
    // 消息内容类型
    [message setType:[[messagePacket objectForKey:@"contentType"] integerValue]];
    // 消息时间戳
    [message setDate:[[messagePacket objectForKey:@"dateline"] longLongValue]];
    // 消息版本号
    [message setVersion:packetVersion];
    // 群消息版本号
    [message setMucVersion:[[messagePacket objectForKey:@"mucMessageVersion"] longValue]];
    // 自定义消息类型
    [message setCustomType:[[message getMessageContent] customType]];
    
    // 是提示消息，直接是已读
    if ([message type] == YM_MESSAGE_CONTENT_PROMPT) {
        [message setStatus:YM_MESSAGE_STATE_SENT_OR_READ];
    } else {
        if ([YYIMJUMPHelper isSelf:rosterId]) {
            [message setStatus:YM_MESSAGE_STATE_SENT_OR_READ];
        } else {
            [message setStatus:YM_MESSAGE_STATE_NEW];
        }
    }
    
    // 设置上传下载状态
    [message setUploadStatus:YM_MESSAGE_UPLOADSTATE_INI];
    [message setDownloadStatus:YM_MESSAGE_DOWNLOADSTATE_INI];
    
    // 设置keyinfo
    [message setKeyInfo:[self getKeyInfoWithType:[message type] message:message]];
    
    // 保存入数据库
    message = [[YYIMDBHelper sharedInstance] insertMessage:message];
    
    if (!isOffline) {
        
        if ([YYIMJUMPHelper isSelf:rosterId]) {
            // 通知didSend
            [[self activeDelegate] didSendMessage:message];
        } else {
            // 通知didReceive
            [[self activeDelegate] didReceiveMessage:message];
        }
        
        // 处理资源下载
        switch ([message type]) {
            case YM_MESSAGE_CONTENT_IMAGE:
            case YM_MESSAGE_CONTENT_MICROVIDEO:
            case YM_MESSAGE_CONTENT_AUDIO:
            case YM_MESSAGE_CONTENT_LOCATION:
                // 资源下载
                [self messageResDownload:message];
                break;
            default:
                break;
        }
    } else {
        [[YYIMNotificationManager sharedInstance] didReceiveOfflineMessage];
    }
}

- (void)handlePubAccountMessage:(JUMPMessage *)messagePacket {
    // 是否离线消息
    BOOL isOffline = [[messagePacket objectForKey:@"offline"] boolValue];
    // 消息版本号
    NSInteger packetVersion = [[messagePacket objectForKey:@"packetVersion"] longValue];
    if (!isOffline) {
        // 发回执
        if ([[[messagePacket objectForKey:@"receipts"] stringValue] isEqualToString:@"1"]) {
            JUMPMessage *response = [messagePacket generateReceiptResponse];
            [[self activeStream] sendPacket:response];
        }
        if (packetVersion > 0) {
            // 本地消息版本号处理
            [[YYIMMessageVersionHelper sharedInstance] handleMessageVersion:packetVersion];
        }
    }
    
    // 消息体
    NSString *body = [messagePacket objectForKey:@"content"];
    // body判空
    if ([YYIMStringUtility isEmpty:body]) {
        return;
    }
    
    // fromJID
    JUMPJID *fromJid = [messagePacket from];
    // 发送方ID
    NSString *fromId = [YYIMJUMPHelper parseUser:[fromJid user]];
    
    // 判重
    if ([[YYIMDBHelper sharedInstance] isMessageReceived:[messagePacket packetID] fromId:fromId]) {
        return;
    }
    
    // 组装message对象
    YYMessage *message = [[YYMessage alloc] init];
    [message setPid:[messagePacket packetID]];
    [message setFromId:fromId];
    [message setToId:[[YYIMConfig sharedInstance] getUser]];
    // 联系人Id
    [message setRosterId:fromId];
    // 公共号
    [message setChatType:YM_MESSAGE_TYPE_PUBACCOUNT];
    // 消息方向
    [message setDirection:YM_MESSAGE_DIRECTION_RECEIVE];
    // 消息体
    [message setMessage:body];
    // 发送方客户端类型
    [message setClientType:[YYIMJUMPHelper parseResourceClient:[fromJid resource]]];
    // 消息内容类型
    [message setType:[[messagePacket objectForKey:@"contentType"] integerValue]];
    // 消息时间戳
    [message setDate:[[messagePacket objectForKey:@"dateline"] longLongValue]];
    // 消息版本号
    [message setVersion:packetVersion];
    // 自定义消息类型
    [message setCustomType:[[message getMessageContent] customType]];
    
    // 是提示消息，直接是已读
    if ([message type] == YM_MESSAGE_CONTENT_PROMPT) {
        [message setStatus:YM_MESSAGE_STATE_SENT_OR_READ];
    } else {
        [message setStatus:YM_MESSAGE_STATE_NEW];
    }
    
    // 设置上传下载状态
    [message setUploadStatus:YM_MESSAGE_UPLOADSTATE_INI];
    [message setDownloadStatus:YM_MESSAGE_DOWNLOADSTATE_INI];
    
    // 设置一下keyinfo
    [message setKeyInfo:[self getKeyInfoWithType:[message type] message:message]];
    
    if ([message.fromId isEqualToString:YM_NETCONFERENCE_PUBACCOUNT]) {
        [self dealIfNetMeetingNotice:message];
        return;
    }
    
    // 保存入数据库
    message = [[YYIMDBHelper sharedInstance] insertMessage:message];
    
    if (!isOffline) {
        // 通知didReceive
        [[self activeDelegate] didReceiveMessage:message];
        
        // 处理资源下载
        switch ([message type]) {
            case YM_MESSAGE_CONTENT_IMAGE:
            case YM_MESSAGE_CONTENT_MICROVIDEO:
            case YM_MESSAGE_CONTENT_AUDIO:
            case YM_MESSAGE_CONTENT_LOCATION:
                // 资源下载
                [self messageResDownload:message];
                break;
            default:
                break;
        }
    } else {
        [[YYIMNotificationManager sharedInstance] didReceiveOfflineMessage];
    }
}

/**
 *  多端同步消息处理
 *
 *  @param messagePacket 消息Packet
 * MessageCarbonPacket(opcode:0x2710)
 * {
 * "id":"666666",
 * "reveiver":"liuhaoi.udn.yonyou@im.yyuap.com",  //消息接收者
 * "from":"majun5.udn.yonyou@im.yyuap.com/pc-v2.1",  //消息发送端
 * "to":"majun5.udn.yonyou@im.yyuap.com/android-v2.1", //消息同步端
 * "content":"{"content":"this is a message"}",
 * "type":"chat", // 消息包类型：chat, groupchat, pubaccount
 * "contentType":2, //可参考AbstractMessagePacket中ContentType的声明
 * "receipts":true, //是否需要回执
 * "dateline":1427167889026//发往服务器的报文不需要该字段，在收到的报文中为服务器接收到消息的时间
 * }
 */
- (void)handleCarbonMessage:(JUMPMessage *)messagePacket {
    // 是否离线消息
    BOOL isOffline = [[messagePacket objectForKey:@"offline"] boolValue];
    // 消息版本号
    NSInteger packetVersion = [[messagePacket objectForKey:@"packetVersion"] longValue];
    if (!isOffline) {
        // 发回执
        if ([[[messagePacket objectForKey:@"receipts"] stringValue] isEqualToString:@"1"]) {
            JUMPMessage *response = [messagePacket generateReceiptResponse];
            [[self activeStream] sendPacket:response];
        }
        if (packetVersion > 0) {
            // 本地消息版本号处理
            [[YYIMMessageVersionHelper sharedInstance] handleMessageVersion:packetVersion];
        }
    }
    
    // 消息体
    NSString *body = [messagePacket objectForKey:@"content"];
    // body判空
    if ([YYIMStringUtility isEmpty:body]) {
        return;
    }
    
    // fromJID
    JUMPJID *fromJid = [messagePacket from];
    // 发送方ID
    NSString *fromId = [YYIMJUMPHelper parseUser:[fromJid user]];
    // 接收方
    NSString *receiverId = [YYIMJUMPHelper parseUser:[messagePacket objectForKey:@"receiver"]];
    
    // 判重
    if ([[YYIMDBHelper sharedInstance] isMessageReceived:[messagePacket packetID] fromId:receiverId]) {
        return;
    }
    
    // 组装message对象
    YYMessage *message = [[YYMessage alloc] init];
    [message setPid:[messagePacket packetID]];
    [message setFromId:fromId];
    [message setToId:receiverId];
    // 联系人Id
    [message setRosterId:receiverId];
    // 单聊
    [message setChatType:YM_MESSAGE_TYPE_CHAT];
    // 消息方向
    [message setDirection:YM_MESSAGE_DIRECTION_SEND];
    // 消息体
    [message setMessage:body];
    // 发送方客户端类型
    [message setClientType:[YYIMJUMPHelper parseResourceClient:[fromJid resource]]];
    // 消息内容类型
    [message setType:[[messagePacket objectForKey:@"contentType"] integerValue]];
    // 消息时间戳
    [message setDate:[[messagePacket objectForKey:@"dateline"] longLongValue]];
    // 消息版本号
    [message setVersion:packetVersion];
    // 自定义消息类型
    [message setCustomType:[[message getMessageContent] customType]];
    // 已发送
    [message setStatus:YM_MESSAGE_STATE_SENT_OR_READ];
    
    // 设置上传下载状态
    [message setUploadStatus:YM_MESSAGE_UPLOADSTATE_INI];
    [message setDownloadStatus:YM_MESSAGE_DOWNLOADSTATE_INI];
    
    //设置一下keyinfo
    [message setKeyInfo:[self getKeyInfoWithType:[message type]message:message]];
    
    // 保存入数据库
    message = [[YYIMDBHelper sharedInstance] insertMessage:message];
    
    if (!isOffline) {
        // 通知didSend
        [[self activeDelegate] didSendMessage:message];
        
        // 处理资源下载
        switch ([message type]) {
            case YM_MESSAGE_CONTENT_IMAGE:
            case YM_MESSAGE_CONTENT_MICROVIDEO:
            case YM_MESSAGE_CONTENT_AUDIO:
            case YM_MESSAGE_CONTENT_LOCATION:
                // 资源下载
                [self messageResDownload:message];
                break;
            default:
                break;
        }
    } else {
        [[YYIMNotificationManager sharedInstance] didReceiveOfflineMessage];
    }
}

- (void)handleReceiptResponse:(JUMPMessage *)message {
    NSString *receiptState = [[message objectForKey:@"state"] stringValue];
    if ([YM_RECEIPT_STATE_ARRIVAL isEqualToString:receiptState]) {
        NSTimeInterval dateline = [[message objectForKey:@"dateline"] longLongValue];
        [[YYIMDBHelper sharedInstance] updateMessageDateline:dateline pid:[message packetID]];
        [[self activeDelegate] didMessageStateChange:[[YYIMDBHelper sharedInstance] getMessageWithPid:[message packetID]]];
    } else if ([YM_RECEIPT_STATE_READED isEqualToString:receiptState]) {
        YYMessage *msg = [[YYIMDBHelper sharedInstance] getMessageWithPid:[message packetID]];
        if ([msg direction] == YM_MESSAGE_DIRECTION_SEND) {
            [[YYIMDBHelper sharedInstance] updateMessageDeliveredWithId:[msg toId]];
            
            [[self activeDelegate] didMessageStateChange:[[YYIMDBHelper sharedInstance] getMessageWithPid:[message packetID]]];
        }
    } else {
        [[YYIMDBHelper sharedInstance] updateMessageState:YM_MESSAGE_STATE_ACKED pid:[message packetID]];
    }
}

- (void)messageResDownload:(YYMessage *)msg {
    YYMessageContent *content = [msg getMessageContent];
    NSString *attachId = [content fileAttachId];
    
    if ([YYIMStringUtility isEmpty:attachId]) {
        return;
    }
    
    [msg setDownloadStatus:YM_MESSAGE_DOWNLOADSTATE_ING];
    [[YYIMDBHelper sharedInstance] updateMessage:msg];
    [[self activeDelegate] didMessageResStatusChanged:msg error:nil];
    
    // 资源相对路径
    NSString *relaPath;
    long long fileSize = -1;
    YYIMImageType imageType = kYYIMImageTypeNormal;
    BOOL thumbnail = NO;
    
    if ([msg type] == YM_MESSAGE_CONTENT_IMAGE) {
        relaPath = [YYIMResourceUtility resourceAttachRelaPathWithId:[NSString stringWithFormat:@"%@_%@", attachId, @"thumb"] ext:[content fileExtension]];
        imageType = kYYIMImageTypeThumb;
        fileSize = [content fileSize];
    } else if ([msg type] == YM_MESSAGE_CONTENT_MICROVIDEO) {
        thumbnail = YES;
        relaPath = [YYIMResourceUtility resourceAttachRelaPathWithId:attachId ext:@"jpg"];
        fileSize = [content fileSize];
    }else {
        relaPath = [YYIMResourceUtility resourceAttachRelaPathWithId:attachId ext:[content fileExtension]];
        fileSize = [content fileSize];
    }
    
    [[YYIMChat sharedInstance].chatManager downloadAttach:attachId targetPath:relaPath imageType:imageType thumbnail:thumbnail fileSize:fileSize progress:nil complete:^(BOOL result, NSString *filePath, YYIMError *error) {
        if (result) {
            // 资源下载成功
            [msg setDownloadStatus:YM_MESSAGE_DOWNLOADSTATE_SUCCESS];
            if ([msg type] == YM_MESSAGE_CONTENT_IMAGE) {
                [msg setResThumbLocal:filePath]; //消息附带资源，图片默认是缩略图
            } else if ([msg type] == YM_MESSAGE_CONTENT_AUDIO) {
                [msg setResThumbLocal:filePath];
                NSString *wavPath = [YYIMResourceUtility amrToWav:filePath];
                [msg setResLocal:wavPath];
            } else if ([msg type] == YM_MESSAGE_CONTENT_MICROVIDEO) {
                [msg setResThumbLocal:filePath]; //消息附带资源，小视频是第一帧图片
            }else {
                [msg setResLocal:filePath];
            }
        } else {
            // 资源下载失败
            [msg setDownloadStatus:YM_MESSAGE_DOWNLOADSTATE_FAILD];
        }
        // 更新消息
        [[YYIMDBHelper sharedInstance] updateMessage:msg];
        // 通知
        [[self activeDelegate] didMessageResStatusChanged:msg error:error];
    }];
}

- (void)handleMucOnlineDeliverPacket:(JUMPMessage *)messagePacket {
    // category
    NSString *category = [messagePacket objectForKey:@"category"];
    // attributes
    NSDictionary *attributes = [messagePacket objectForKey:@"attributes"];
    // 消息撤销
    if ([@"revoke" isEqualToString:category]) {
        // pid
        NSString *packetId = [attributes objectForKey:@"packetId"];
        // groupJid
        JUMPJID *groupJid = [messagePacket from];
        // groupId
        NSString *groupId = [YYIMJUMPHelper parseUser:[groupJid bare]];
        // message
        YYMessage *message = [[YYIMDBHelper sharedInstance] getMessageWithPid:packetId];
        if (message && [message type] != YM_MESSAGE_CONTENT_REVOKE && [[message fromId] isEqualToString:groupId]) {
            YYMessage *revokedMessage = [[YYIMDBHelper sharedInstance] revokeMessageWithPid:packetId];
            [[self activeDelegate] didMessageRevoked:revokedMessage];
        }
    }
}

- (void)handlePubAccountOnlineDeliverPacket:(JUMPMessage *)messagePacket {
    
}

- (void)handleUserOnlineDeliverPacket:(JUMPMessage *)messagePacket {
    // category
    NSString *category = [messagePacket objectForKey:@"category"];
    // attributes
    NSDictionary *attributes = [messagePacket objectForKey:@"attributes"];
    // 消息撤销
    if ([@"revoke" isEqualToString:category]) {
        // pid
        NSString *packetId = [attributes objectForKey:@"packetId"];
        // fromId
        NSString *fromId = [YYIMJUMPHelper parseUser:[messagePacket fromStr]];
        // message
        YYMessage *message = [[YYIMDBHelper sharedInstance] getMessageWithPid:packetId];
        if (message && [message type] != YM_MESSAGE_CONTENT_REVOKE && [[message fromId] isEqualToString:fromId]) {
            YYMessage *revokedMessage = [[YYIMDBHelper sharedInstance] revokeMessageWithPid:packetId];
            [[self activeDelegate] didMessageRevoked:revokedMessage];
        }
    }
}

#pragma mark rest version

- (void)loadOfflineMessage {
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result) {
            NSInteger currentVersion = [[YYIMConfig sharedInstance] getMessageVersionNumber];
            [self doLoadOfflineMessageWithVersion:currentVersion token:[token tokenStr] start:0];
        } else {
            YYIMLogError(@"getTokenFaildWithCode:%ld Msg:%@", (long)[tokenError errorCode], [tokenError errorMsg]);
        }
    }];
}

- (void)doLoadOfflineMessageWithVersion:(NSInteger)version token:(NSString *)token start:(NSInteger)start {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YYIMLogInfo(@"client do load offline message");
        
        NSString *urlString = [[YYIMConfig sharedInstance] getVersionServlet:nil];
        if ([YYIMStringUtility isEmpty:urlString]) {
            return;
        }
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:token forKey:@"token"];
        [params setObject:[NSNumber numberWithInteger:version] forKey:@"version"];
        [params setObject:[NSString stringWithFormat:@"%@-%@", YM_CLIENT_IOS, YM_CLIENT_CURRENT_VERSION] forKey:@"resource"];
        [params setObject:[NSNumber numberWithInteger:start] forKey:@"start"];
        [params setObject:[NSNumber numberWithInteger:100] forKey:@"size"];
        
        // 强制获取版本消息，忽略标记
        if ([[YYIMConfig sharedInstance] isForceMessageSync]) {
            [params setObject:@"true" forKey:@"ignoreConsumed"];
        }
        
        YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
        [manager setCompletionQueue:self.moduleQueue];
        
        [manager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            // response dic
            NSDictionary *dic = (NSDictionary *)responseObject;
            // 报文数组
            NSArray *packetArray = (NSArray *)[dic objectForKey:@"packets"];
            for (NSDictionary *packetDic in packetArray) {
                // 报文opcode
                NSString *opcode = [packetDic objectForKey:@"opcode"];
                // base64解码
                NSData *opData = [YYIMStringUtility base64Decode:opcode];
                // 报文内容
                NSString *body = [packetDic objectForKey:@"body"];
                // 转换报文体数据
                NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error;
                NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:bodyData options:NSJSONReadingMutableLeaves error:&error];
                if (error) {
                    // 报文转换失败
                    YYIMLogError(@"offline message with opcode:%@ body:%@ error:%@", opcode, bodyData, error);
                } else {
                    // 组装报文Packet
                    JUMPPacket *packet = [[JUMPPacket alloc] initWithOpData:opData];
                    [packet setDictionary:contentDic];
                    if ([packet isMessagePacket]) {
                        [packet setObject:@"1" forKey:@"offline"];
                    }
                    [[self activeStream] injectPacket:packet];
                }
            }
            // 离线消息总量
            NSInteger count = [[dic objectForKey:@"count"] integerValue];
            // 本批次数量
            NSInteger size = [[dic objectForKey:@"size"] integerValue];
            // 起始下标
            NSInteger start = [[dic objectForKey:@"start"] integerValue];
            // 最新版本号
            NSInteger newVersion = [[dic objectForKey:@"version"] longValue];
            
            YYIMLogInfo(@"client did load offline message:version:%ld start:%ld size:%ld count:%ld", (long)newVersion, (long)start, (long)size, (long)count);
            if (count > (size + start)) {
                [self doLoadOfflineMessageWithVersion:version token:token start:(size + start)];
            } else {
                if (newVersion > version) {
                    [[YYIMConfig sharedInstance] setMessageVersionNumber:newVersion];
                    [[YYIMMessageVersionHelper sharedInstance] attemptIncreaseMessageVersion];
                    [self sendMessageACKWithVersion:newVersion oldVersion:version token:token];
                }
            }
        } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
            NSHTTPURLResponse *response = [error.userInfo objectForKey:YMAFNetworkingOperationFailingURLResponseErrorKey];
            YYIMLogError(@"offline message faild:%ld|%@", (long)response.statusCode, error.description);
        }];
    });
}

- (void)sendMessageACKWithVersion:(NSInteger)version oldVersion:(NSInteger)oldVersion token:(NSString *)token {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlString = [[YYIMConfig sharedInstance] getVersionServlet:@"ack"];
        if ([YYIMStringUtility isEmpty:urlString]) {
            return;
        }
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:token forKey:@"token"];
        [params setObject:[NSNumber numberWithInteger:oldVersion] forKey:@"oldversion"];
        [params setObject:[NSNumber numberWithInteger:version] forKey:@"version"];
        [params setObject:[NSString stringWithFormat:@"%@-%@", YM_CLIENT_IOS, YM_CLIENT_CURRENT_VERSION] forKey:@"resource"];
        
        YYIMLogInfo(@"client ack message with old version:%ld new version:%ld", (long)oldVersion, (long)version);
        YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
        [manager setCompletionQueue:self.moduleQueue];
        
        [manager PUT:urlString parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            YYIMLogDebug(@"send message ack success");
        } failure:^(NSURLSessionDataTask * _Nullable task, id responseObject, NSError * _Nonnull error) {
            YYIMLogError(@"send message ack faild:%@", error.localizedDescription);
        }];
    });
}

#pragma mark private func

- (void)sendMessage:(NSString *)chatId contentType:(NSInteger)contentType content:(YYMessageContent *)content chatType:(NSString *)chatType {
    if ([YYIMStringUtility isEmpty:chatType]) {
        chatType = YM_MESSAGE_TYPE_CHAT;
    }
    
    YYMessage *message = [[YYMessage alloc] init];
    [message setPid:[JUMPStream generateJUMPID]];
    [message setFromId:[[YYIMConfig sharedInstance] getUser]];
    [message setToId:chatId];
    if ([YM_MESSAGE_TYPE_CHAT isEqualToString:chatType] || [YM_MESSAGE_TYPE_PUBACCOUNT isEqualToString:chatType]) {
        [message setRosterId:chatId];
    }
    [message setDirection:YM_MESSAGE_DIRECTION_SEND];
    [message setStatus:YM_MESSAGE_STATE_NEW];
    [message setType:contentType];
    [message setChatType:chatType];
    [message setDate:[YYIMJUMPHelper getCurrentTimeinmillis]];
    [message setClientType:kYYIMClientTypeIOS];
    
    //设置一下keyinfo
    [message setKeyInfo:[self getKeyInfoWithType:contentType content:content]];
    
    switch ([message type]) {
        case YM_MESSAGE_CONTENT_TEXT:
        case YM_MESSAGE_CONTENT_SHARE:
        case YM_MESSAGE_CONTENT_NETMEETING:
        case YM_MESSAGE_CONTENT_CUSTOM:
            if ([message type] == YM_MESSAGE_CONTENT_CUSTOM) {
                [message setCustomType:[content customType]];
            }
            [message setMessage:[content jsonString:[message type]]];
            message = [[YYIMDBHelper sharedInstance] insertMessage:message];
            [[self activeDelegate] willSendMessage:message];
            [self sendMessage:message];
            break;
        case YM_MESSAGE_CONTENT_IMAGE:
        case YM_MESSAGE_CONTENT_MICROVIDEO:
        case YM_MESSAGE_CONTENT_AUDIO:
        case YM_MESSAGE_CONTENT_FILE:
        case YM_MESSAGE_CONTENT_LOCATION: {
            [message setResLocal:[content localResPath]];
            
            if ([message type] == YM_MESSAGE_CONTENT_MICROVIDEO) {
                //短视频的缩略图由客户端自己生成，接收端用服务器生成的
                [message setResThumbLocal:[content localResThumbPath]];
            }
            
            if ([message type] == YM_MESSAGE_CONTENT_AUDIO) {
                // 格式转换
                NSString *amrPath = [YYIMResourceUtility wavToAmr:[content localResPath]];
                [message setResThumbLocal:amrPath];
                [content setLocalResPath:amrPath];
            }
            
            if ([message type] == YM_MESSAGE_CONTENT_FILE && [content fileAttachId]) {
                [message setMessage:[content jsonString:[message type]]];
                [message setUploadStatus:YM_MESSAGE_UPLOADSTATE_SUCCESS];
                
                YYAttach *attach = [[YYIMChat sharedInstance].chatManager getAttachState:[content fileAttachId]];
                if ([attach downloadState] == kYYIMAttachDownloadSuccess) {
                    [message setResLocal:[attach attachPath]];
                    [message setDownloadStatus:YM_MESSAGE_DOWNLOADSTATE_SUCCESS];
                }
                message = [[YYIMDBHelper sharedInstance] insertMessage:message];
                [[self activeDelegate] willSendMessage:message];
                [self sendMessage:message];
            } else {
                // 文件管理器
                NSString *fullPath = [YYIMResourceUtility fullPathWithResourceRelaPath:[content localResPath]];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ([fileManager fileExistsAtPath:fullPath]) {
                    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:fullPath error:nil];
                    if (![content fileName]) {
                        [content setFileName:[[content localResPath] lastPathComponent]];
                    }
                    [content setFileSize:[fileAttributes fileSize]];
                    [content setFileExtension:[[content localResPath] pathExtension]];
                } else {
                    YYIMLogError(@"file:%@ not exists!", [content localResPath]);
                }
                [message setMessage:[content jsonString:[message type]]];
                [message setUploadStatus:YM_MESSAGE_UPLOADSTATE_ING];
                message = [[YYIMDBHelper sharedInstance] insertMessage:message];
                [[self activeDelegate] willSendMessage:message];
                // 上传附件
                [self uploadMessageRes:message];
            }
            break;
        }
        default:
            break;
    }
}

- (void)forwardMessage:(NSString *)chatId oldMessage:(YYMessage *)message chatType:(NSString *)chatType {
    if ([YYIMStringUtility isEmpty:chatType]) {
        chatType = YM_MESSAGE_TYPE_CHAT;
    }
    
    YYMessage *newMessage = [[YYMessage alloc] init];
    [newMessage setPid:[JUMPStream generateJUMPID]];
    [newMessage setFromId:[[YYIMConfig sharedInstance] getUser]];
    [newMessage setToId:chatId];
    if ([YM_MESSAGE_TYPE_CHAT isEqualToString:chatType]) {
        [newMessage setRosterId:chatId];
    }
    [newMessage setDirection:YM_MESSAGE_DIRECTION_SEND];
    [newMessage setStatus:YM_MESSAGE_STATE_NEW];
    [newMessage setUploadStatus:YM_MESSAGE_UPLOADSTATE_SUCCESS];
    [newMessage setDownloadStatus:[message downloadStatus]];
    [newMessage setType:[message type]];
    [newMessage setChatType:chatType];
    [newMessage setDate:[YYIMJUMPHelper getCurrentTimeinmillis]];
    [newMessage setClientType:kYYIMClientTypeIOS];
    
    [newMessage setResLocal:[message resLocal]];
    [newMessage setResThumbLocal:[message resThumbLocal]];
    [newMessage setResOriginalLocal:[message resOriginalLocal]];
    
    //设置一下keyinfo
    [newMessage setKeyInfo:[self getKeyInfoWithType:[message type] message:message]];
    
    [newMessage setMessage:[message message]];
    newMessage = [[YYIMDBHelper sharedInstance] insertMessage:newMessage];
    [[self activeDelegate] willSendMessage:newMessage];
    [self sendMessage:newMessage];
}

- (void)uploadMessageRes:(YYMessage *) message {
    NSString *receiver;
    if ([[message chatType] isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
        receiver = [YYIMJUMPHelper genFullGroupJidString:[message toId]];
    } else {
        receiver = [YYIMJUMPHelper genFullJidString:[message toId]];
    }
    
    YYMessageContent *content = [message getMessageContent];
    NSString *relaPath;
    if ([message type] == YM_MESSAGE_CONTENT_AUDIO) {
        relaPath = [message resThumbLocal];
    } else {
        relaPath = [message resLocal];
    }
    
    YYIMUploadMediaType mediaType = kYYIMUploadMediaTypeFile;
    
    if ([message type] == YM_MESSAGE_CONTENT_IMAGE) {
        mediaType = kYYIMUploadMediaTypeImage;
    }
    
    switch (message.type) {
        case YM_MESSAGE_CONTENT_IMAGE:
            mediaType = kYYIMUploadMediaTypeImage;
            break;
        case YM_MESSAGE_CONTENT_FILE:
            mediaType = kYYIMUploadMediaTypeFile;
            break;
        case YM_MESSAGE_CONTENT_MICROVIDEO:
            mediaType = kYYIMUploadMediaTypeMicroVideo;
        default:
            break;
    }
    
    BOOL isOriginal = [[message getMessageContent] isOriginal];
    
    [[YYIMChat sharedInstance].chatManager uploadAttach:relaPath fileName:[[message getMessageContent] fileName] receiver:receiver mediaType:mediaType isOriginal:isOriginal complete:^(BOOL result, YYAttach *attach, YYIMError *error) {
        if (result) {
            NSString *attachId = [attach attachId];
            [content setFileAttachId:attachId];
            [message setMessage:[content jsonString:[message type]]];
            [message setUploadStatus:YM_MESSAGE_UPLOADSTATE_SUCCESS];
            [[YYIMDBHelper sharedInstance] updateMessage:message];
            [self.activeDelegate didMessageResStatusChanged:message error:nil];
            [self sendMessage:message];
        } else {
            [message setUploadStatus:YM_MESSAGE_UPLOADSTATE_FAILD];
            [message setStatus:YM_MESSAGE_STATE_FAILD];
            [[YYIMDBHelper sharedInstance] updateMessage:message];
            [self.activeDelegate didMessageResStatusChanged:message error:error];
        }
    }];
}

- (void)sendMessage:(YYMessage *)message {
    JUMPJID *toJID;
    NSData *opData;
    if ([[message chatType] isEqualToString:YM_MESSAGE_TYPE_CHAT]) {
        toJID = [YYIMJUMPHelper genFullJid:[message toId]];
        opData = JUMP_OPDATA(JUMPMessagePacketOpCode);
    } else if ([[message chatType] isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
        toJID = [YYIMJUMPHelper genFullGroupJid:[message toId]];
        opData = JUMP_OPDATA(JUMPMUCMessagePacketOpCode);
    } else if ([[message chatType] isEqualToString:YM_MESSAGE_TYPE_PUBACCOUNT]) {
        toJID = [YYIMJUMPHelper genFullPubAccountJid:[message toId]];
        opData = JUMP_OPDATA(JUMPPubAccountMessagePacketOpCode);
    }
    
    JUMPMessage *msg = [JUMPMessage messageWithOpData:opData to:toJID packetID:[message pid]];
    [msg setObject:[message message] forKey:@"content"];
    [msg setObject:[NSNumber numberWithInteger:[message type]] forKey:@"contentType"];
    [msg setObject:@"1" forKey:@"receipts"];
    
    [[self tracker] addPacket:msg target:self selector:@selector(handleSendMessage:withInfo:) timeout:30];
    
    [[self activeStream] sendPacket:msg];
}

- (void)handleSendMessage:(JUMPPacket *)packet withInfo:(JUMPBasicTrackingInfo *)trackerInfo {
    if (!packet) {
        JUMPPacket *message = [trackerInfo packet];
        [[YYIMDBHelper sharedInstance] updateMessageState:YM_MESSAGE_STATE_FAILD pid:[message packetID]];
        [[self activeDelegate] didSendMessageFaild:[[YYIMDBHelper sharedInstance] getMessageWithPid:[message packetID]] error:[YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"]];
    }
    
    if (![packet checkOpData:JUMP_OPDATA(JUMPMessageReceiptsPacketOpCode)]) {
        return;
    }
    
    [[YYIMDBHelper sharedInstance] updateMessageState:YM_MESSAGE_STATE_SENT_OR_READ pid:[packet packetID]];
    [[self activeDelegate] didSendMessage:[[YYIMDBHelper sharedInstance] getMessageWithPid:[packet packetID]]];
}

- (void)sendReadedMessageWithType:(NSString *)type to:(JUMPJID *)to packetID:(NSString *)packetID {
    JUMPMessage *receipt = [JUMPMessage messageWithOpData:JUMP_OPDATA(JUMPMessageReceiptsPacketOpCode) to:[to bareJID] packetID:packetID];
    [receipt setObject:YM_RECEIPT_STATE_READED forKey:@"state"];
    [[self activeStream] sendPacket:receipt];
}


/**
 *  获得关键文字用于搜索
 *
 *  @param type    获得关键文字用于搜索
 *  @param message 消息json文本
 *
 *  @return 关键文字
 */
- (NSString *)getKeyInfoWithType:(NSInteger)type message:(YYMessage *)message {
    YYMessageContent *content = [message getMessageContent];
    
    return [self getKeyInfoWithType:type content:content];
}

/**
 *  获得关键文字用于搜索
 *
 *  @param type    获得关键文字用于搜索
 *  @param content 消息体对象
 *
 *  @return 关键文字
 */
- (NSString *)getKeyInfoWithType:(NSInteger)type content:(YYMessageContent *)content {
    switch (type) {
        case YM_MESSAGE_CONTENT_TEXT: {
            return content.message;
        }
            
        case YM_MESSAGE_CONTENT_SHARE: {
            return [NSString stringWithFormat:@"%@|%@", content.shareTitle, content.shareDesc];
        }
        case YM_MESSAGE_CONTENT_FILE: {
            return content.fileName;
        }
            
        case YM_MESSAGE_CONTENT_LOCATION: {
            return content.address;
        }
            
        case YM_MESSAGE_CONTENT_SINGLE_MIXED: {
            return content.paContent.title;
        }
            
        case YM_MESSAGE_CONTENT_BATCH_MIXED: {
            NSArray *paArray = content.paArray;
            YYPubAccountContent *paContent = [paArray objectAtIndex:0];
            
            return paContent.title;
        }
        case YM_MESSAGE_CONTENT_NETMEETING: {
            YYNetMeetingContent *netMeetingContent = content.netMeetingContent;
            
            return netMeetingContent.topic;
        }
            
        default:
            return @"";
    }
}

- (void)dealIfNetMeetingNotice:(YYMessage *)message {
    dispatch_async(messageSerialQueue, ^{
        [self dealSyncNetMeetingNotice:message];
    });
}

- (void)dealSyncNetMeetingNotice:(YYMessage *)message {
    // message body
    NSString *body = [message message];
    // 解析JSONString到JSONObject
    NSError *error;
    id contentObj = [YYIMStringUtility decodeJsonString:body error:&error];
    
    if (error) {
        YYIMLogError(@"decode message error:%@|%@", body, error.localizedDescription);
        return;
    }
    
    if (![contentObj isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    // content dictionary
    NSDictionary *contentDic = (NSDictionary *)contentObj;
    
    id subContent = [contentDic objectForKey:@"content"];
    if (![subContent isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSDictionary *subDic = (NSDictionary *)subContent;
    
    NSString *channelId = [subDic objectForKey:@"channelId"];
    if (!channelId) {
        return;
    }
    
    YYNetMeetingInfo *netMeetingInfo = [[YYNetMeetingInfo alloc] init];
    [netMeetingInfo setChannelId:channelId];
    [netMeetingInfo setTopic:[subDic objectForKey:@"topic"]];
    [netMeetingInfo setModerator:[YYIMJUMPHelper parseUser:[subDic objectForKey:@"operator"]]];
    [netMeetingInfo setCreator:[YYIMJUMPHelper parseUser:[subDic objectForKey:@"creator"]]];
    [netMeetingInfo setNotifyDate:message.date];
    
    NSString *netMeetingTypeStr = [subDic objectForKey:@"conferenceType"];
    YYIMNetMeetingType netMeetingType = kYYIMNetMeetingTypeMeeting;
    if ([netMeetingTypeStr isEqualToString:@"conference"]) {
        netMeetingType = kYYIMNetMeetingTypeMeeting;
    } else if ([netMeetingTypeStr isEqualToString:@"live"]) {
        netMeetingType = kYYIMNetMeetingTypeLive;
    } else if ([netMeetingTypeStr isEqualToString:@"singleChat"]) {
        netMeetingType = kYYIMNetMeetingTypeSingleChat;
    } else if ([netMeetingTypeStr isEqualToString:@"groupChat"]) {
        netMeetingType = kYYIMNetMeetingTypeGroupChat;
    } else {
        netMeetingType = kYYIMNetMeetingTypeMeeting;
    }
    [netMeetingInfo setType:netMeetingType];
    
    NSString *netMeetingStateStr = [subDic objectForKey:@"type"];
    YYIMNetMeetingState netMeetingState = kYYIMNetMeetingStateEnd;
    if ([netMeetingStateStr isEqualToString:@"create"]) {
        netMeetingState = kYYIMNetMeetingStateIng;
    } else if ([netMeetingStateStr isEqualToString:@"invite"]) {
        netMeetingState = kYYIMNetMeetingStateIng;
    } else if ([netMeetingStateStr isEqualToString:@"end"]) {
        netMeetingState = kYYIMNetMeetingStateEnd;
    } else if ([netMeetingStateStr isEqualToString:@"reservation"]) {
        netMeetingState = kYYIMNetMeetingStateNew;
    } else if ([netMeetingStateStr isEqualToString:@"cancelReservation"]) {
        netMeetingState = kYYIMNetMeetingStateCancelReservation;
    } else if ([netMeetingStateStr isEqualToString:@"reservationInvite"]) {
        netMeetingState = kYYIMNetMeetingStateReservationInvite;
    } else if ([netMeetingStateStr isEqualToString:@"reservationKick"]) {
        netMeetingState = kYYIMNetMeetingStateReservationKick;
    } else if ([netMeetingStateStr isEqualToString:@"reservationEdit"]) {
        netMeetingState = kYYIMNetMeetingStateReservationEdit;
    } else if ([netMeetingStateStr isEqualToString:@"reservationReady"]) {
        netMeetingState = kYYIMNetMeetingStateReservationReady;
    } else {
        netMeetingState = kYYIMNetMeetingStateEnd;
    }
    [netMeetingInfo setState:netMeetingState];
    
    NSString *talkTime = [subDic objectForKey:@"talktime"];
    [netMeetingInfo setDuration:[talkTime integerValue]];
    
    NSArray *oldInfoArray = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingNoticeWithMeetingId:netMeetingInfo.channelId];
    
    if (!netMeetingInfo.isReservationNotice) {
        if (netMeetingInfo.state == kYYIMNetMeetingStateIng) {
            if (oldInfoArray.count > 0) {
                for (YYNetMeetingInfo *info in oldInfoArray) {
                    if (info.state == kYYIMNetMeetingStateEnd) {
                        //如果会议已经结束的时候，又收到了正在进行的通知不需要任何操作，直接返回。
                        return;
                    }
                }
            }
        }
        
        //如果收到了普通会议的开始和结束，插入或者更新普通会议信息
        NSNumber *createTime = [subDic objectForKey:@"createTime"];
        [netMeetingInfo setDate:[createTime doubleValue]];
        netMeetingInfo.waitBegin = NO;
        [netMeetingInfo setReservationInvalidReason:YYIMNetMeetingReservationInvalidReasonBegin];
        [[YYIMNetMeetingDBHelper sharedInstance] updateOrInsertNetMeetingCommonNotice:netMeetingInfo];
        
        //如果是会议开始了，需要将预约的会议都设取消等待开始的状态
        if (netMeetingInfo.state == kYYIMNetMeetingStateIng || netMeetingInfo.state == kYYIMNetMeetingStateEnd) {
            [[YYIMNetMeetingDBHelper sharedInstance] updateNetMeetingReservationNotice:netMeetingInfo.channelId wait:NO reason:YYIMNetMeetingReservationInvalidReasonBegin];
        }
    } else {
        //如果是预约会议，直接插入不合并
        NSNumber *planBeginTime = [subDic objectForKey:@"planBeginTime"];
        [netMeetingInfo setDate:[planBeginTime doubleValue]];
        
        if (netMeetingInfo.state == kYYIMNetMeetingStateCancelReservation) {
            netMeetingInfo.waitBegin = NO;
            netMeetingInfo.reservationInvalidReason = YYIMNetMeetingReservationInvalidReasonCancel;
        } else if (netMeetingInfo.state == kYYIMNetMeetingStateReservationKick) {
            netMeetingInfo.waitBegin = NO;
            netMeetingInfo.reservationInvalidReason = YYIMNetMeetingReservationInvalidReasonKick;
        } else if (netMeetingInfo.state == kYYIMNetMeetingStateNew
                   || netMeetingInfo.state == kYYIMNetMeetingStateReservationInvite
                   || netMeetingInfo.state == kYYIMNetMeetingStateReservationReady) {
            netMeetingInfo.waitBegin = YES;
            netMeetingInfo.reservationInvalidReason = YYIMNetMeetingReservationInvalidReasonNONE;
        }
        
        //获得当前老数据中时间最大的，如果大于新消息，新消息按照老数据更新。如果小于新消息，更新所有老数据
        if (oldInfoArray.count > 0) {
            YYNetMeetingInfo *lastInfo = [oldInfoArray objectAtIndex:0];
            
            if (lastInfo.notifyDate > netMeetingInfo.notifyDate) {
                //根据老的最大时间的数据更新当前这条数据，并执行插入
                if (lastInfo.state == kYYIMNetMeetingStateCancelReservation) {
                    //设置状态为预约会议已取消
                    netMeetingInfo.waitBegin = NO;
                    netMeetingInfo.reservationInvalidReason = YYIMNetMeetingReservationInvalidReasonCancel;
                } else if (lastInfo.state == kYYIMNetMeetingStateReservationKick) {
                    //设置状态为预约会议移除了自己
                    netMeetingInfo.waitBegin = NO;
                    netMeetingInfo.reservationInvalidReason = YYIMNetMeetingReservationInvalidReasonKick;
                } else if (lastInfo.state == kYYIMNetMeetingStateNew
                           || lastInfo.state == kYYIMNetMeetingStateReservationInvite
                           || lastInfo.state == kYYIMNetMeetingStateReservationReady) {
                    //设置状态为预约会议邀请了自己
                    netMeetingInfo.waitBegin = YES;
                    netMeetingInfo.reservationInvalidReason = YYIMNetMeetingReservationInvalidReasonNONE;
                } else if (lastInfo.state == kYYIMNetMeetingStateIng || lastInfo.state == kYYIMNetMeetingStateEnd) {
                    //设置状态为预约会议开始
                    netMeetingInfo.waitBegin = NO;
                    netMeetingInfo.reservationInvalidReason = YYIMNetMeetingReservationInvalidReasonBegin;
                }
                
                [[YYIMNetMeetingDBHelper sharedInstance] insertNetMeetingReservationNotice:netMeetingInfo];
            } else {
                //按照最新的这条消息更新所有老的消息的状态
                [[YYIMNetMeetingDBHelper sharedInstance] insertNetMeetingReservationNotice:netMeetingInfo];
                
                [[YYIMNetMeetingDBHelper sharedInstance] updateNetMeetingReservationNotice:netMeetingInfo.channelId wait:netMeetingInfo.waitBegin reason:netMeetingInfo.reservationInvalidReason];
                
            }
        } else {
            //没有老的消息，直接插入
            [[YYIMNetMeetingDBHelper sharedInstance] insertNetMeetingReservationNotice:netMeetingInfo];
        }
    }
    
    [[self activeDelegate] didNetMeetingNoticeReceive];
}

@end
