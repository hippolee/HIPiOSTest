//
//  YYIMMessageProtocol.h
//  YonyouIM
//
//  Created by litfb on 15/1/9.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYIMBaseProtocol.h"

@protocol YYIMMessageProtocol <YYIMBaseProtocol>

@required

/**
 *  获取一个聊天用户/群组的最新消息及未读消息数
 *
 *  @return NSArray<YYRecentMessage>
 */
- (NSArray *)getRecentMessage;

/**
 *  获取一个聊天用户/群组的最新消息及未读消息数
 *
 *  @param block
 */
- (void)getRecentMessageWithBlock:(void (^)(NSArray *messages))resultBlock;

/**
 *  获取最近的联系人
 *
 *  @return NSArray<YYRoster/YYUser>
 */
- (NSArray *)getRecentRoster;

/**
 *  获取未读的消息总数
 *
 *  @return NSInteger
 */
- (NSInteger)getUnreadMsgCount;

/**
 *  获取指定用户/群组的未读消息数量
 *
 *  @param chatId 用户/群组ID
 *
 *  @return NSInteger
 */
- (NSInteger)getUnreadMsgCount:(NSString *)chatId;

- (NSInteger)getUnreadMsgCountMyOtherClient;

/**
 *  获取同某个用户/群组聊天的消息记录
 *
 *  @param chatId 用户/群组ID
 *
 *  @return NSArray<YYMessage>
 */
- (NSArray *)getMessageWithId:(NSString *)chatId;

/**
 *  根据消息pid获取消息
 *
 *  @param pid 消息pid
 *
 *  @return YYMessage 消息
 */
- (YYMessage *)getMessageWithPid:(NSString *)pid;

/**
 *  分页获取同某个用户/群组聊天的消息记录，获取某条消息之前的pageSize条消息记录，消息pid为空，获取最近的pageSize条消息记录
 *
 *  @param chatId   用户/群组ID
 *  @param pid      消息pid
 *  @param pageSize 分页大小
 *
 *  @return NSArray<YYMessage>
 */
- (NSArray *)getMessageWithId:(NSString *)chatId beforePid:(NSString *)pid pageSize:(NSInteger)pageSize;

/**
 *  根据自定义消息类型分页获取同某个用户/群组聊天的自定义消息记录
 *  获取某条消息之前的pageSize条消息记录，消息pid为空，获取最近的pageSize条消息记录
 *
 *  @param chatId   用户/群组ID
 *  @param pid      消息pid
 *  @param pageSize 分页大小
 *
 *  @return NSArray<YYMessage>
 */
- (NSArray *)getCustomMessageWithId:(NSString *)chatId customType:(NSInteger)customType beforePid:(NSString *)pid pageSize:(NSInteger)pageSize;

/**
 *  获取同某个用户/群组在某条消息及其之后的所有消息
 *
 *  @param chatId 用户/群组ID
 *  @param pid    消息pid
 *
 *  @return NSArray<YYMessage>
 */
- (NSArray *)getMessageWithId:(NSString *)chatId afterPid:(NSString *)pid;

- (NSArray *)getChatUserWithChatId:(NSString *)chatId;

- (NSArray *)getMessageWithId:(NSString *)chatId contentType:(NSInteger)contentType;

- (NSArray *)getMessageWithKey:(NSString *)key;

- (NSArray *)getMessageWithKey:(NSString *)key limit:(NSInteger)limit;

- (NSArray *)getMessageWithKey:(NSString *)key chatId:(NSString *)chatId;

/**
 *  根据用户/群组ID删除与其所有的消息记录
 *
 *  @param chatId 用户/群组ID
 */
- (void)deleteMessageWithId:(NSString *)chatId;

/**
 *  根据消息pid删除单条消息记录
 *
 *  @param packetId 消息pid
 */
- (void)deleteMessageWithPid:(NSString *)packetId;

/**
 *  删除所有的消息记录
 */
- (void)deleteAllMessage;

- (NSArray *)getReceivedFileMessage;

/**
 *  更新语音消息已播放状态
 *
 *  @param packetId 消息pid
 */
- (void)updateAudioReaded:(NSString *)packetId;

/**
 *  根据消息pid更新单条消息已读状态
 *
 *  @param packetId 消息pid
 */
- (void)updateMessageReadedWithPid:(NSString *)packetId;

/**
 *  根据用户/群组ID更新消息已读状态
 *
 *  @param chatId 用户/群组ID
 */
- (void)updateMessageReadedWithId:(NSString *)chatId;

/**
 *  发送文本消息
 *
 *  @param chatId   用户/群组ID
 *  @param text     消息内容
 *  @param chatType 单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 */
- (void)sendTextMessage:(NSString *)chatId text:(NSString *)text chatType:(NSString *)chatType;

/**
 *  发送文本消息
 *
 *  @param chatId      用户/群组ID
 *  @param text        消息内容
 *  @param chatType    单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 *  @param atUserArray 群聊中@的用户IDArray，单聊无效
 */
- (void)sendTextMessage:(NSString *)chatId text:(NSString *)text chatType:(NSString *)chatType atUserArray:(NSArray *)atUserArray;

/**
 *  发送文本消息
 *
 *  @param chatId      用户/群组ID
 *  @param text        消息内容
 *  @param chatType    单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 *  @param atUserArray 群聊中@的用户IDArray，单聊无效
 *  @param extendValue 扩展信息
 */
- (void)sendTextMessage:(NSString *)chatId text:(NSString *)text chatType:(NSString *)chatType atUserArray:(NSArray *)atUserArray extendValue:(NSString *)extendValue;


/**
 *  发送视频会议或者直播的分享消息
 *
 *  @param chatId     用户/群组ID
 *  @param chatType   单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 *  @param netMeeting 会议对象
 */
- (void)sendNetMeetingMessage:(NSString *)chatId chatType:(NSString *)chatType netMeeting:(YYNetMeeting *)netMeeting;
/**
 *  发送图片消息
 *
 *  @param chatId         用户/群组ID
 *  @param imagePathArray 图片路径Array
 *  @param chatType       单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 */
- (void)sendImageMessage:(NSString *)chatId paths:(NSArray *)imagePathArray chatType:(NSString *)chatType;

/**
 *  发送图片消息
 *
 *  @param chatId     用户/群组ID
 *  @param assetArray 图片AssetArray
 *  @param chatType   单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 *  @param isOriginal 是否发送原图
 */
- (void)sendImageMessage:(NSString *)chatId assets:(NSArray *)assetArray chatType:(NSString *)chatType isOriginal:(BOOL)isOriginal;

/**
 *  发送图片消息
 *
 *  @param chatId      用户/群组ID
 *  @param assetArray  图片AssetArray
 *  @param chatType    单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 *  @param isOriginal  是否发送原图
 *  @param extendValue 扩展信息
 */
- (void)sendImageMessage:(NSString *)chatId assets:(NSArray *)assetArray chatType:(NSString *)chatType isOriginal:(BOOL)isOriginal extendValue:(NSString *)extendValue;

/**
 *  发送图片消息
 *
 *  @param chatId     用户/群组ID
 *  @param assetArray 图片AssetArray
 *  @param chatType   单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 */
- (void)sendImageMessage:(NSString *)chatId assets:(NSArray *)assetArray chatType:(NSString *)chatType;


/**
 *  发送短视频消息
 *
 *  @param chatId    用户/群组ID
 *  @param filePath  短视频的路径
 *  @param thumbNail 缩略图的路径
 *  @param chatType  单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 */
- (void)sendMicroVideoMessage:(NSString *)chatId filePath:(NSString *)filePath thumbPath:(NSString *)thumbPath chatType:(NSString *)chatType;

/**
 *  发送语音消息
 *
 *  @param chatId    用户/群组ID
 *  @param audioPath 语音路径
 *  @param chatType  单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 */
- (void)sendAudioMessage:(NSString *)chatId wavPath:(NSString *)audioPath chatType:(NSString *)chatType;

/**
 *  发送语音消息
 *
 *  @param chatId      用户/群组ID
 *  @param audioPath   语音路径
 *  @param chatType    单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 *  @param extendValue 扩展信息
 */
- (void)sendAudioMessage:(NSString *)chatId wavPath:(NSString *)audioPath chatType:(NSString *)chatType extendValue:(NSString *)extendValue;

- (void)sendFileMessage:(NSString *)chatId filePath:(NSString *)filePath chatType:(NSString *)chatType;

- (void)sendFileMessage:(NSString *)chatId filePath:(NSString *)filePath chatType:(NSString *)chatType extendValue:(NSString *)extendValue;

/**
 *  发送分享消息
 *
 *  @param chatId         用户/群组ID
 *  @param urlString      分享链接URL
 *  @param title          标题
 *  @param description    描述
 *  @param imageUrlString 图标URL
 *  @param extendValue    扩展信息
 *  @param chatType       单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 */
- (void)sendShareMessage:(NSString *)chatId url:(NSString *)urlString title:(NSString *)title description:(NSString *)description imageUrl:(NSString *)imageUrlString extendValue:(NSString *)extendValue chatType:(NSString *)chatType;

/**
 *  发送自定义消息
 *
 *  @param chatId           用户/群组ID
 *  @param customType       自定义消息类型
 *  @param customDictionary 自定义消息内容
 *  @param extendValue      扩展信息
 *  @param chatType         单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 */
- (void)sendCustomMessage:(NSString *)chatId customType:(NSInteger)customType customDictionary:(NSDictionary *)customDictionary extendValue:(NSString *)extendValue chatType:(NSString *)chatType;

/**
 *  转发文件消息
 *
 *  @param chatId   用户/群组ID
 *  @param packetId 源消息pid
 *  @param chatType 单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 */
- (void)forwardFileMessage:(NSString *)chatId pid:(NSString *)packetId chatType:(NSString *)chatType;

/**
 *  转发消息
 *
 *  @param chatId   用户/群组ID
 *  @param packetId 源消息pid
 *  @param chatType 单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 */
- (void)forwardMessage:(NSString *)chatId pid:(NSString *)packetId chatType:(NSString *)chatType;

/**
 *  发送位置消息
 *
 *  @param chatId    用户/群组ID
 *  @param imagePath 位置截图路径
 *  @param address   地址
 *  @param longitude 经度
 *  @param latitude  纬度
 *  @param chatType  单聊:YM_MESSAGE_TYPE_CHAT，群聊:YM_MESSAGE_TYPE_GROUPCHAT
 */
- (void)sendLocationManager:(NSString *)chatId imagePath:(NSString *)imagePath address:(NSString *) address longitude: (float) longitude latitude:(float) latitude chatType:(NSString *)chatType;

/**
 *  重发失败的消息
 *
 *  @param pid 消息pid
 */
- (void)resendMessage:(NSString *)pid;

/**
 *  下载消息资源（图片/语音/文件）
 *
 *  @param pid 消息pid
 */
- (void)downloadMessageRes:(NSString *)pid;

/**
 *  下载短视频的视频文件
 *
 *  @param pid              消息pid
 *  @param downloadProgress 进度回调block
 *  @param downloadComplete 完成回调block
 */
- (void)downloadMicroVideoMessageRes:(NSString *)pid progress:(YYIMAttachDownloadProgressBlock)downloadProgress complete:(YYIMAttachDownloadCompleteBlock)downloadComplete;

/**
 *  下载消息图片
 *
 *  @param pid              消息pid
 *  @param imageType        kYYIMImageTypeNormal:默认图，kYYIMImageTypeOriginal:原图，kYYIMImageTypeThumb:缩略图
 *  @param downloadProgress 进度回调block
 *  @param downloadComplete 完成回调block
 */
- (void)downloadImageMessageRes:(NSString *)pid imageType:(YYIMImageType)imageType progress:(YYIMAttachDownloadProgressBlock)downloadProgress complete:(YYIMAttachDownloadCompleteBlock)downloadComplete;


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
- (void)getChatMessageFileList:(NSString *)chatId chatType:(NSString *)chatType fileType:(YYIMMessageFileType)fileType offset:(NSUInteger)offset limit:(NSUInteger)limit complete:(void (^)(BOOL, NSArray *, YYIMError *))complete;

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
- (void)getChatMessageFileList:(NSString *)chatId chatType:(NSString *)chatType fileType:(YYIMMessageFileType)fileType keyword:(NSString *)keyword offset:(NSUInteger)offset limit:(NSUInteger)limit complete:(void (^)(BOOL, NSArray *, YYIMError *))complete;

/**
 *  撤回单聊
 *
 *  @param pid 消息ID
 */
- (void)revokeChatMessageWithId:(NSString *)pid;

/**
 *  撤回群聊
 *
 *  @param pid 消息ID
 */
- (void)revokeGroupChatMessageWithId:(NSString *)pid;

@end
