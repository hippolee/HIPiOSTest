//
//  YYMessageContent.h
//  YonyouIM
//
//  Created by litfb on 15/1/6.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYNetMeeting.h"

@class YYMessage;

@class YYPubAccountContent;

@class YYNetMeetingContent;

@interface YYMessageContent : NSObject

/**
 *  消息文本
 *  @contentType 文本
 */
@property NSString *message;

/**
 *  消息@用户列表
 *  @contentType 文本
 */
@property NSArray *atUserArray;

/**
 *  本地资源路径
 *  @contentType 文件/图片/语音/位置
 */
@property NSString *localResPath;

/**
 *  本地资源缩略图（目前只有短视频才需要发送者自己生成缩略图）
 *  @contentType 短视频
 */
@property NSString *localResThumbPath;

/**
 *  文件ID
 *  @contentType 文件/图片/语音/位置
 */
@property NSString *fileAttachId;

/**
 *  文件扩展名
 *  @contentType 文件/图片/语音/位置
 */
@property NSString *fileExtension;

/**
 *  文件大小
 *  @contentType 文件/图片/语音/位置
 */
@property long long fileSize;

/**
 *  文件名
 *  @contentType 文件/图片/语音/位置
 */
@property NSString *fileName;

/**
 *  语音时长
 *  @contentType 语音
 */
@property NSInteger duration;

/**
 *  地址
 *  @contentType 位置
 */
@property NSString *address;

/**
 *  经度
 *  @contentType 位置
 */
@property NSNumber *latitude;

/**
 *  纬度
 *  @contentType 位置
 */
@property NSNumber *longitude;

/**
 *  是否原图
 *  @contentType 图片
 */
@property NSInteger isOriginal;

/**
 *  分享标题
 *  @contentType 分享
 */
@property NSString *shareTitle;

/**
 *  分享描述
 *  @contentType 分享
 */
@property NSString *shareDesc;

/**
 *  分享链接
 *  @contentType 分享
 */
@property NSString *shareUrl;

/**
 *  分享图标
 *  @contentType 分享
 */
@property NSString *shareImageUrl;

/**
 *  扩展信息
 *  @contentType  文本/文件/图片/语音/位置/分享/自定义
 */
@property NSString *extendValue;

/**
 *  扩展信息
 *  @contentType  文本/文件/图片/语音/位置/分享/自定义
 */
@property NSDictionary *extendDic;

/**
 *  单图文消息内容
 *  @contentType  单图文
 */
@property YYPubAccountContent *paContent;

/**
 *  视频会议消息内容
 */
@property YYNetMeetingContent *netMeetingContent;

/**
 *  多图文消息内容
 *  @contentType  多图文
 */
@property NSArray *paArray;

/**
 *  自定义消息类型
 */
@property NSInteger customType;

/**
 *  自定义消息内容
 *  @contentType  自定义
 */
@property NSDictionary *customDictionary;

/**
 *  根据消息体生成YYMessageContent
 *
 *  @param message
 *
 *  @return YYMessageContent
 */
+ (YYMessageContent *)contentWithMessage:(YYMessage *)message;

/**
 *  根据消息文本和@用户列表生成YYMessageContent
 *
 *  @param text        消息文本
 *  @param atUserArray @用户列表
 *  @param extendValue 扩展信息
 *
 *  @return YYMessageContent
 */
+ (YYMessageContent *)contentWithText:(NSString *)text atUserArray:(NSArray *)atUserArray extendValue:(NSString *)extendValue;

+ (YYMessageContent *)contentWithNetMeeting:(YYNetMeeting *)netMeeting;

/**
 *  根据图片路径生成YYMessageContent
 *
 *  @param imagePath  图片路径
 *  @param isOriginal 是否原图
 *
 *  @return YYMessageContent
 */
+ (YYMessageContent *)contentWithImagePath:(NSString *)imagePath isOriginal:(BOOL)isOriginal;

/**
 *  根据短视频和缩略图的路径生成YYMessageContent
 *
 *  @param filePath  短视频的路径
 *  @param thumbPath 短视频缩略图的路径
 *
 *  @return
 */
+ (YYMessageContent *)contentWithMicroVideoPath:(NSString *)filePath thumbPath:(NSString *)thumbPath;

/**
 *  根据语音路径生成YYMessageContent
 *
 *  @param audioPath 语音路径
 *
 *  @return YYMessageContent
 */
+ (YYMessageContent *)contentWithAudioPath:(NSString *)audioPath;

/**
 *  根据文件路径生成YYMessageContent
 *
 *  @param filePath 文件路径
 *
 *  @return YYMessageContent
 */
+ (YYMessageContent *)contentWithFilePath:(NSString *)filePath;

/**
 *  根据位置信息生成YYMessageContent
 *
 *  @param imagePath 图片路径
 *  @param address   地址
 *  @param longitude 经度
 *  @param latitude  纬度
 *
 *  @return YYMessageContent
 */
+ (YYMessageContent *)contentWithLocation:(NSString *)imagePath address:(NSString *)address longitude:(float)longitude latitude:(float)latitude;

/**
 *  根据链接分享信息生成YYMessageContent
 *
 *  @param urlString      链接
 *  @param title          标题
 *  @param description    描述
 *  @param imageUrlString 图片url
 *  @param extendValue    扩展信息
 *
 *  @return YYMessageContent
 */
+ (YYMessageContent *)contentWithShareUrl:(NSString *)urlString title:(NSString *)title description:(NSString *)description imageUrlString:(NSString *)imageUrlString extendValue:(NSString *)extendValue;

/**
 *  根据自定义消息信息生成YYMessageContent
 *
 *  @param customType       自定义消息类型
 *  @param customDictionary 自定义消息内容
 *  @param extentValue      扩展信息
 *
 *  @return YYMessageContent
 */
+ (YYMessageContent *)contentWithCustomType:(NSInteger)customType customDictionary:(NSDictionary *)customDictionary extendValue:(NSString *)extentValue;

/**
 *  获得消息简单描述
 *
 *  @param message YYMessage
 *
 *  @return 消息简单描述
 */
- (NSString *)getSimpleMessage:(YYMessage *)message;

/**
 *  生成JSONString
 *
 *  @param contentType 消息内容类型
 *
 *  @return JSONString
 */
- (NSString *)jsonString:(NSInteger)contentType;

- (void)setAttribute:(id)value forKey:(NSString *)key;

- (id)attributeForKey:(NSString *)key;

- (void)setAttributesWithDictionary:(NSDictionary *)dic;

@end

/**
 *  公共号图文信息
 */
@interface YYPubAccountContent : NSObject

// 链接
@property (nonatomic) NSString *contentSourceUrl;

// 摘要
@property NSString *digest;

// 封面
@property BOOL showCoverPic;

// 封面ID
@property NSString *thumbId;

// 标题
@property NSString *title;

// 扩展信息
@property NSString *extendValue;

/**
 *  获得封面图片路径
 *
 *  @return NSString
 */
- (NSString *)getCoverPhoto;

@end

/**
 *  视频会议信息信息
 */
@interface YYNetMeetingContent : NSObject

// 频道id
@property NSString *channelId;

// 主题
@property NSString *topic;

//会议创建时间
@property NSTimeInterval createTime;

// 状态类型
@property YYIMNetMeetingContentType contentState;

// 主持人
@property NSString *moderator;

// 会议类型
@property YYIMNetMeetingType netMeetingType;

// 通知类型
@property YYIMNetMeetingMessageType messageType;

// 持续时间
@property NSInteger talkTime;

// 会议模式（视频还是语音）
@property YYIMNetMeetingMode netMeetingMode;

/**
 *  获得完整title
 *
 *  @return NSString
 */
- (NSString *)getSimpleMessage;

@end

