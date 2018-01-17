//
//  YYMessageContent.m
//  YonyouIM
//
//  Created by litfb on 15/1/6.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYMessageContent.h"
#import "YYIMStringUtility.h"
#import "YYMessage.h"
#import "YYIMJUMPHelper.h"
#import "YYIMLogger.h"
#import "YYIMConfig.h"

@interface YYMessageContent ()

@property NSMutableDictionary *attributes;

@end

@implementation YYMessageContent

- (id)init {
    if ((self = [super init])) {
        self.attributes = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (YYMessageContent *)contentWithMessage:(YYMessage *)message {
    // message body
    NSString *body = [message message];
    // 消息内容类型
    NSInteger contentType = [message type];
    
    // 消息
    YYMessageContent *content = [[YYMessageContent alloc] init];
    // 解析JSONString到JSONObject
    NSError *error;
    id contentObj = [YYIMStringUtility decodeJsonString:body error:&error];
    if (error) {
        YYIMLogError(@"decode message error:%@|%@", body, error.localizedDescription);
        [content setMessage:@"不支持的消息格式"];
        return content;
    }
    
    if ([contentObj isKindOfClass:[NSDictionary class]]) {
        // 扩展信息
        id extendValue = [contentObj objectForKey:@"extend"];
        
        if ([extendValue isKindOfClass:[NSString class]]) {
            if (![YYIMStringUtility isEmpty:extendValue]) {
                [content setExtendValue:extendValue];
            }
        }
        
        if ([extendValue isKindOfClass:[NSDictionary class]]) {
            [content setExtendDic:extendValue];
        }
        
    }
    // 根据不同的消息类型处理不同类型的消息
    switch (contentType) {
        case YM_MESSAGE_CONTENT_TEXT: {
            if (![contentObj isKindOfClass:[NSDictionary class]]) {
                [content setMessage:@""];
                break;
            }
            // content dictionary
            NSDictionary *contentDic = (NSDictionary *)contentObj;
            
            // 文本消息内容
            id textStr = [contentDic objectForKey:@"content"];
            // 处理空消息
            if (!textStr) {
                textStr = @"";
            }
            // 处理异常类型消息
            if (![textStr isKindOfClass:[NSString class]]) {
                textStr = [NSString stringWithFormat:@"%@", textStr];
            }
            // 处理回车
//            NSString *text = [(NSString *)textStr stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            [content setMessage:textStr];
            
            // @人员列表
            NSArray *atUserArray = [contentDic objectForKey:@"atuser"];
            if ([atUserArray count] > 0) {
                [content setAtUserArray:atUserArray];
            }
            break;
        }
        case YM_MESSAGE_CONTENT_FILE:
        case YM_MESSAGE_CONTENT_AUDIO:
        case YM_MESSAGE_CONTENT_IMAGE:
        case YM_MESSAGE_CONTENT_MICROVIDEO:
        case YM_MESSAGE_CONTENT_LOCATION: {
            if (![contentObj isKindOfClass:[NSDictionary class]]) {
                [content setMessage:@""];
                break;
            }
            // content dictionary
            NSDictionary *contentDic = (NSDictionary *)contentObj;
            
            // 消息内容
            NSDictionary *subDic = [contentDic objectForKey:@"content"];
            // 文件ID
            [content setFileAttachId:[subDic objectForKey:@"path"]];
            // 文件扩展名
            [content setFileExtension:[subDic objectForKey:@"type"]];
            // 文件名
            [content setFileName:[subDic objectForKey:@"name"]];
            // 文件大小
            [content setFileSize:[[subDic objectForKey:@"size"] integerValue]];
            
            // 图片是否原图
            if (contentType == YM_MESSAGE_CONTENT_IMAGE && [subDic objectForKey:@"original"]) {
                [content setIsOriginal:[[subDic objectForKey:@"original"] intValue] == 1];
            }
            
            // 语音时长
            if (contentType == YM_MESSAGE_CONTENT_AUDIO) {
                [content setDuration:[[subDic objectForKey:@"duration"] integerValue]];
            }
            
            // 位置信息
            if (contentType == YM_MESSAGE_CONTENT_LOCATION) {
                // 位置地址
                [content setAddress:[subDic objectForKey:@"address"]];
                // 位置经度
                [content setLongitude:[NSNumber numberWithDouble:[[subDic objectForKey:@"longitude"] doubleValue]]];
                // 位置纬度
                [content setLatitude:[NSNumber numberWithDouble:[[subDic objectForKey:@"latitude"] doubleValue]]];
            }
            break;
        }
        case YM_MESSAGE_CONTENT_SINGLE_MIXED: {
            if (![contentObj isKindOfClass:[NSDictionary class]]) {
                [content setMessage:@""];
                break;
            }
            // content dictionary
            NSDictionary *contentDic = (NSDictionary *)contentObj;
            
            // 图文内容
            YYPubAccountContent *paContent = [[YYPubAccountContent alloc] init];
            [paContent setContentSourceUrl:[contentDic objectForKey:@"contentSourceUrl"]];
            [paContent setDigest:[contentDic objectForKey:@"digest"]];
            [paContent setShowCoverPic:[[contentDic objectForKey:@"showCoverPic"] boolValue]];
            [paContent setThumbId:[contentDic objectForKey:@"thumbId"]];
            [paContent setTitle:[contentDic objectForKey:@"title"]];
            [paContent setExtendValue:[contentDic objectForKey:@"extend"]];
            
            if (![YYIMStringUtility isEmpty:[paContent extendValue]]) {
                [content setExtendValue:[paContent extendValue]];
            }
            [content setPaContent:paContent];
        }
        case YM_MESSAGE_CONTENT_BATCH_MIXED: {
            if (![contentObj isKindOfClass:[NSArray class]]) {
                [content setMessage:@""];
                break;
            }
            // 解析JSON到Array
            NSArray *contentArray = (NSArray *)contentObj;
            
            NSMutableArray *paArray = [NSMutableArray array];
            for (NSDictionary *subDic in contentArray) {
                YYPubAccountContent *paContent = [[YYPubAccountContent alloc] init];
                [paContent setContentSourceUrl:[subDic objectForKey:@"contentSourceUrl"]];
                [paContent setDigest:[subDic objectForKey:@"digest"]];
                [paContent setShowCoverPic:[[subDic objectForKey:@"showCoverPic"] boolValue]];
                [paContent setThumbId:[subDic objectForKey:@"thumbId"]];
                [paContent setTitle:[subDic objectForKey:@"title"]];
                [paContent setExtendValue:[subDic objectForKey:@"extend"]];
                
                if ([paContent showCoverPic] && ![YYIMStringUtility isEmpty:[paContent extendValue]]) {
                    [content setExtendValue:[paContent extendValue]];
                }
                [paArray addObject:paContent];
            }
            [content setPaArray:paArray];
        }
        case YM_MESSAGE_CONTENT_SHARE: {
            if (![contentObj isKindOfClass:[NSDictionary class]]) {
                [content setMessage:@""];
                break;
            }
            // content dictionary
            NSDictionary *contentDic = (NSDictionary *)contentObj;
            
            // 分享消息内容
            NSDictionary *fileDic = [contentDic objectForKey:@"content"];
            // 标题
            [content setShareTitle:[fileDic objectForKey:@"shareTitle"]];
            // 描述
            [content setShareDesc:[fileDic objectForKey:@"shareDesc"]];
            // 链接地址
            [content setShareUrl:[fileDic objectForKey:@"shareUrl"]];
            // 图标
            [content setShareImageUrl:[fileDic objectForKey:@"shareImageUrl"]];
            break;
        }
        case YM_MESSAGE_CONTENT_CUSTOM: {
            if (![contentObj isKindOfClass:[NSDictionary class]]) {
                [content setMessage:@""];
                break;
            }
            
            // content dictionary
            NSDictionary *contentDic = (NSDictionary *)contentObj;
            
            // 自定义消息类型
            [content setCustomType:[[contentDic objectForKey:@"customType"] integerValue]];
            // 自定义消息内容
            id customContent = [contentDic objectForKey:@"content"];
            
            if ([customContent isKindOfClass:[NSDictionary class]]) {
                NSDictionary *customDic = (NSDictionary *)customContent;
                [content setCustomDictionary:customDic];
            } else if ([customContent isKindOfClass:[NSString class]]) {
                NSString *textStr = [contentDic objectForKey:@"content"];
                // 处理空消息
                if (!textStr) {
                    textStr = @"";
                }
                [content setMessage:textStr];
            }
            break;
        }
        case YM_MESSAGE_CONTENT_PROMPT: {
            if (![contentObj isKindOfClass:[NSDictionary class]]) {
                [content setMessage:@""];
                break;
            }
            // content dictionary
            NSDictionary *contentDic = (NSDictionary *)contentObj;
            
            // 提示消息内容
            NSDictionary *subDic = [contentDic objectForKey:@"content"];
            [content.attributes setDictionary:subDic];
            break;
        }
        case YM_MESSAGE_CONTENT_NETMEETING: {
            if (![contentObj isKindOfClass:[NSDictionary class]]) {
                [content setMessage:@""];
                break;
            }
            // content dictionary
            NSDictionary *contentDic = (NSDictionary *)contentObj;
            NSDictionary *subDic = [contentDic objectForKey:@"content"];
            
            YYNetMeetingContent *netMeetingContent = [[YYNetMeetingContent alloc] init];
            [netMeetingContent setChannelId:[subDic objectForKey:@"channelId"]];
            [netMeetingContent setTopic:[subDic objectForKey:@"topic"]];
            [netMeetingContent setModerator:[YYIMJUMPHelper parseUser:[subDic objectForKey:@"operator"]]];
            [netMeetingContent setCreateTime:[[subDic objectForKey:@"createTime"] doubleValue]];
            
            NSInteger messageType = [[subDic objectForKey:@"messageType"] integerValue];
            switch (messageType) {
                case 1:
                    [netMeetingContent setMessageType:kYYIMNetMeetingMessageTypeConferenceNotify];
                    break;
                case 2:
                    [netMeetingContent setMessageType:kYYIMNetMeetingMessageTypeSingelChatNotify];
                    break;
                case 3:
                    [netMeetingContent setMessageType:kYYIMNetMeetingMessageTypeConferenceShare];
                    break;
                default:
                    [netMeetingContent setMessageType:kYYIMNetMeetingMessageTypeConferenceShare];
                    break;
            }
            
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
            [netMeetingContent setNetMeetingType:netMeetingType];
            
            NSString *netMeetingModeStr = [subDic objectForKey:@"conferenceMode"];
            YYIMNetMeetingMode netMeetingMode = kYYIMNetMeetingModeDefault;
            if ([netMeetingModeStr isEqualToString:@"voice"]) {
                netMeetingMode = kYYIMNetMeetingModeAudio;
            } else if ([netMeetingTypeStr isEqualToString:@"video"]) {
                netMeetingMode = kYYIMNetMeetingModeVideo;
            } else {
                netMeetingMode = kYYIMNetMeetingModeDefault;
            }
            [netMeetingContent setNetMeetingMode:netMeetingMode];
            
            NSString *conferenceStateStr = [subDic objectForKey:@"type"];
            YYIMNetMeetingContentType conferenceState = kYYIMNetMeetingContentTypeCreate;
            if ([conferenceStateStr isEqualToString:@"create"]) {
                conferenceState = kYYIMNetMeetingContentTypeCreate;
            } else if ([conferenceStateStr isEqualToString:@"end"]) {
                conferenceState = kYYIMNetMeetingContentTypeEnd;
            } else if ([conferenceStateStr isEqualToString:@"cancel"]) {
                conferenceState = kYYIMNetMeetingContentTypeCancel;
            } else if ([conferenceStateStr isEqualToString:@"refuse"]) {
                conferenceState = kYYIMNetMeetingContentTypeRefuse;
            } else if ([conferenceStateStr isEqualToString:@"timeout"]) {
                conferenceState = kYYIMNetMeetingContentTypeTimeout;
            } else if ([conferenceStateStr isEqualToString:@"busy"]) {
                conferenceState = kYYIMNetMeetingContentTypeBusy;
            } else {
                conferenceState = kYYIMNetMeetingContentTypeCreate;
            }
            [netMeetingContent setContentState:conferenceState];
            
            NSString *talkTime = [subDic objectForKey:@"talktime"];
            [netMeetingContent setTalkTime:[talkTime integerValue]];
            
            [content setNetMeetingContent:netMeetingContent];
            
            break;
        }
        default: {
            [content setMessage:@"不支持的消息类型"];
            break;
        }
    }
    return content;
}

+ (YYMessageContent *)contentWithText:(NSString *)text atUserArray:(NSArray *)atUserArray extendValue:(NSString *)extendValue {
    // 文本消息
    YYMessageContent *content = [[YYMessageContent alloc] init];
    [content setMessage:text];
    if ([atUserArray count] > 0) {
        [content setAtUserArray:atUserArray];
    }
    if (![YYIMStringUtility isEmpty:extendValue]) {
        [content setExtendValue:extendValue];
    }
    return content;
}

+ (YYMessageContent *)contentWithNetMeeting:(YYNetMeeting *)netMeeting {
    // 文本消息
    YYMessageContent *content = [[YYMessageContent alloc] init];
    YYNetMeetingContent *conference = [[YYNetMeetingContent alloc] init];
    
    [conference setChannelId:netMeeting.channelId];
    [conference setTopic:netMeeting.topic];
    [conference setNetMeetingType:netMeeting.netMeetingType];
    [conference setMessageType:kYYIMNetMeetingMessageTypeConferenceShare];
    [conference setCreateTime:netMeeting.createTime];
    [conference setModerator:netMeeting.creator];
    
    [content setNetMeetingContent:conference];
    
    return content;
}

+ (YYMessageContent *)contentWithImagePath:(NSString *)imagePath isOriginal:(BOOL)isOriginal {
    YYMessageContent *content = [[YYMessageContent alloc] init];
    [content setLocalResPath:imagePath];
    [content setIsOriginal:isOriginal];
    return content;
}

+ (YYMessageContent *)contentWithMicroVideoPath:(NSString *)filePath thumbPath:(NSString *)thumbPath {
    YYMessageContent *content = [[YYMessageContent alloc] init];
    [content setLocalResPath:filePath];
    [content setLocalResThumbPath:thumbPath];
    return content;
}

+ (YYMessageContent *)contentWithAudioPath:(NSString *)audioPath {
    YYMessageContent *content = [[YYMessageContent alloc] init];
    [content setLocalResPath:audioPath];
    return content;
}

+ (YYMessageContent *)contentWithFilePath:(NSString *)filePath {
    YYMessageContent *content = [[YYMessageContent alloc] init];
    [content setLocalResPath:filePath];
    return content;
}

+ (YYMessageContent *)contentWithLocation:(NSString *)imagePath address:(NSString *)address longitude:(float)longitude latitude:(float)latitude {
    YYMessageContent *content = [[YYMessageContent alloc] init];
    [content setLocalResPath:imagePath];
    [content setAddress:address];
    [content setLongitude:[NSNumber numberWithFloat:longitude]];
    [content setLatitude:[NSNumber numberWithFloat:latitude]];
    return content;
}

+ (YYMessageContent *)contentWithShareUrl:(NSString *)urlString title:(NSString *)title description:(NSString *)description imageUrlString:(NSString *)imageUrlString extendValue:(NSString *)extendValue {
    YYMessageContent *content = [[YYMessageContent alloc] init];
    [content setShareTitle:title];
    [content setShareDesc:description];
    [content setShareUrl:urlString];
    [content setShareImageUrl:imageUrlString];
    [content setExtendValue:extendValue];
    return content;
}

+ (YYMessageContent *)contentWithCustomType:(NSInteger)customType customDictionary:(NSDictionary *)customDictionary extendValue:(NSString *)extentValue {
    YYMessageContent *content = [[YYMessageContent alloc] init];
    [content setCustomType:customType];
    [content setCustomDictionary:customDictionary];
    [content setExtendValue:extentValue];
    return content;
}

- (NSString *)getSimpleMessage:(YYMessage *)message {
    NSString *prefix;
    if ([[message chatType] isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT]) {
        if ([message isSystemMessage]) {
            prefix = nil;
        } else if ([message user]) {
            prefix = [[message user] userName];
        }
    }
    
    NSString *simpleMessage;
    switch ([message type]) {
        case YM_MESSAGE_CONTENT_TEXT:
            if (self.message) {
                simpleMessage = [self.message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
//                simpleMessage = self.message;
            } else {
                simpleMessage = @"";
            }
            break;
        case YM_MESSAGE_CONTENT_IMAGE:
            simpleMessage = @"[图片]";
            break;
        case YM_MESSAGE_CONTENT_MICROVIDEO:
            simpleMessage = @"[小视频]";
            break;
        case YM_MESSAGE_CONTENT_AUDIO:
            simpleMessage = @"[语音]";
            break;
        case YM_MESSAGE_CONTENT_FILE:
            simpleMessage = @"[文件]";
            break;
        case YM_MESSAGE_CONTENT_LOCATION:
            if ([self address]) {
                simpleMessage = [@"[位置]:" stringByAppendingString:[self address]];
            } else {
                simpleMessage = @"[位置]";
            }
            break;
        case YM_MESSAGE_CONTENT_SINGLE_MIXED:
            simpleMessage = self.paContent.title;
            break;
        case YM_MESSAGE_CONTENT_BATCH_MIXED:
            for (YYPubAccountContent *paContent in self.paArray) {
                if ([paContent showCoverPic]) {
                    simpleMessage = paContent.title;
                    break;
                }
            }
            break;
        case YM_MESSAGE_CONTENT_SHARE:
            simpleMessage = @"[链接]";
            break;
        case YM_MESSAGE_CONTENT_NETMEETING:
            simpleMessage = [self.netMeetingContent getSimpleMessage];
            break;
        case YM_MESSAGE_CONTENT_CUSTOM:
            if (self.message) {
                simpleMessage = [self.message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            } else {
                simpleMessage = @"";
            }
            break;
        default:
            simpleMessage = @"";
            break;
    }
    if (![YYIMStringUtility isEmpty:prefix] && ![YYIMStringUtility isEmpty:simpleMessage]) {
        simpleMessage = [NSString stringWithFormat:@"%@:%@", prefix, simpleMessage];
    }
    return simpleMessage;
}

- (NSString *)jsonString:(NSInteger)contentType {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    // 扩展信息
    if (self.extendValue) {
        [dic setObject:self.extendValue forKey:@"extend"];
    }
    
    // 根据内容类型生成jsonString
    switch (contentType) {
        case YM_MESSAGE_CONTENT_TEXT:
            // 消息文本content
            [dic setObject:self.message forKey:@"content"];
            // @用户列表
            if ([self.atUserArray count] > 0) {
                [dic setObject:self.atUserArray forKey:@"atuser"];
            }
            break;
        case YM_MESSAGE_CONTENT_NETMEETING: {
            NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
            YYNetMeetingContent *netMeetingContent = self.netMeetingContent;
            
            [contentDic setObject:[YYIMStringUtility notNilString:netMeetingContent.channelId] forKey:@"channelId"];
            [contentDic setObject:[YYIMStringUtility notNilString:netMeetingContent.topic] forKey:@"topic"];
            [contentDic setObject:[YYIMStringUtility notNilString:netMeetingContent.moderator] forKey:@"operator"];
            
            NSString *type;
            switch (netMeetingContent.netMeetingType) {
                case kYYIMNetMeetingTypeMeeting:
                    type = @"conference";
                    break;
                case kYYIMNetMeetingTypeLive:
                    type = @"live";
                    break;
                case kYYIMNetMeetingTypeSingleChat:
                    type = @"singleChat";
                    break;
                case kYYIMNetMeetingTypeGroupChat:
                    type = @"groupChat";
                    break;
                default:
                    type = @"conference";
                    break;
            }
            
            [contentDic setObject:type forKey:@"conferenceType"];
            [contentDic setObject:[NSNumber numberWithLongLong:netMeetingContent.createTime] forKey:@"createTime"];
            [contentDic setObject:[NSNumber numberWithInteger:netMeetingContent.messageType] forKey:@"messageType"];
            [dic setObject:contentDic forKey:@"content"];
            break;
        }
        case YM_MESSAGE_CONTENT_PROMPT:
            [dic setObject:self.attributes forKey:@"content"];
            break;
        case YM_MESSAGE_CONTENT_AUDIO: {
            NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
            [contentDic setObject:[YYIMStringUtility notNilString:self.fileAttachId] forKey:@"path"];
            [contentDic setObject:[YYIMStringUtility notNilString:self.fileExtension] forKey:@"type"];
            [contentDic setObject:[YYIMStringUtility notNilString:self.fileName] forKey:@"name"];
            [contentDic setObject:[NSString stringWithFormat:@"%ld", (long)self.fileSize] forKey:@"size"];
            [contentDic setObject:[NSString stringWithFormat:@"%ld", (long)self.duration] forKey:@"duration"];
            [dic setObject:contentDic forKey:@"content"];
            break;
        }
        case YM_MESSAGE_CONTENT_IMAGE: {
            NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
            [contentDic setObject:[YYIMStringUtility notNilString:self.fileAttachId] forKey:@"path"];
            [contentDic setObject:[YYIMStringUtility notNilString:self.fileExtension] forKey:@"type"];
            [contentDic setObject:[YYIMStringUtility notNilString:self.fileName] forKey:@"name"];
            [contentDic setObject:[NSString stringWithFormat:@"%ld", (long)self.fileSize] forKey:@"size"];
            [contentDic setObject:[NSNumber numberWithInt:self.isOriginal ? 1 : 0] forKey:@"original"];
            [dic setObject:contentDic forKey:@"content"];
            break;
        }
        case YM_MESSAGE_CONTENT_MICROVIDEO: {
            NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
            [contentDic setObject:[YYIMStringUtility notNilString:self.fileAttachId] forKey:@"path"];
            [contentDic setObject:[YYIMStringUtility notNilString:self.fileExtension] forKey:@"type"];
            [contentDic setObject:[YYIMStringUtility notNilString:self.fileName] forKey:@"name"];
            [contentDic setObject:[NSString stringWithFormat:@"%ld", (long)self.fileSize] forKey:@"size"];
            [dic setObject:contentDic forKey:@"content"];
            break;
        }
        case YM_MESSAGE_CONTENT_FILE: {
            NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
            [contentDic setObject:[YYIMStringUtility notNilString:self.fileAttachId] forKey:@"path"];
            [contentDic setObject:[YYIMStringUtility notNilString:self.fileExtension] forKey:@"type"];
            [contentDic setObject:[YYIMStringUtility notNilString:self.fileName] forKey:@"name"];
            [contentDic setObject:[NSString stringWithFormat:@"%ld", (long) self.fileSize] forKey:@"size"];
            [dic setObject:contentDic forKey:@"content"];
            break;
        }
        case YM_MESSAGE_CONTENT_LOCATION: {
            NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
            [contentDic setObject:self.latitude forKey:@"latitude"];
            [contentDic setObject:self.longitude forKey:@"longitude"];
            [contentDic setObject:self.address forKey:@"address"];
            [contentDic setObject:[YYIMStringUtility notNilString:self.fileAttachId] forKey:@"path"];
            [contentDic setObject:[YYIMStringUtility notNilString:self.fileExtension] forKey:@"type"];
            [contentDic setObject:[YYIMStringUtility notNilString:self.fileName] forKey:@"name"];
            [contentDic setObject:[NSString stringWithFormat:@"%ld", (long)self.fileSize] forKey:@"size"];
            [dic setObject:contentDic forKey:@"content"];
            break;
        }
        case YM_MESSAGE_CONTENT_SHARE: {
            NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
            [contentDic setObject:[YYIMStringUtility notNilString:self.shareTitle] forKey:@"shareTitle"];
            [contentDic setObject:[YYIMStringUtility notNilString:self.shareDesc] forKey:@"shareDesc"];
            [contentDic setObject:[YYIMStringUtility notNilString:self.shareUrl] forKey:@"shareUrl"];
            [contentDic setObject:[YYIMStringUtility notNilString:self.shareImageUrl] forKey:@"shareImageUrl"];
            [dic setObject:contentDic forKey:@"content"];
            break;
        }
        case YM_MESSAGE_CONTENT_CUSTOM: {
            [dic setObject:[NSNumber numberWithInteger:self.customType] forKey:@"customType"];
            if (self.customDictionary) {
                [dic setObject:self.customDictionary forKey:@"content"];
            }
            break;
        }
        default:
            break;
    }
    NSError *error;
    NSString *jsonString = [YYIMStringUtility encodeJsonObject:dic error:&error];
    if (error) {
        YYIMLogError(@"encode message error:%@", error.localizedDescription);
    }
    return jsonString;
}

- (void)setAttribute:(id)value forKey:(NSString *)key {
    if (value) {
        [self.attributes setObject:value forKey:key];
    } else {
        [self.attributes removeObjectForKey:key];
    }
}

- (id)attributeForKey:(NSString *)key {
    return [self.attributes objectForKey:key];
}

- (void)setAttributesWithDictionary:(NSDictionary *)dic {
    [self.attributes setValuesForKeysWithDictionary:dic];
}

@end

@implementation YYPubAccountContent

- (NSString *)getCoverPhoto {
    return [YYIMStringUtility genFullPathRes:[self thumbId]];
}

- (NSString *)contentSourceUrl {
    if ([_contentSourceUrl hasPrefix:@"http:"] || [_contentSourceUrl hasPrefix:@"https:"]) {
        return _contentSourceUrl;
    }
    return [NSString stringWithFormat:@"%@%@", @"http://", _contentSourceUrl];
}

@end

@implementation YYNetMeetingContent

- (NSString *)getSimpleMessage {
    if (self.messageType == kYYIMNetMeetingMessageTypeSingelChatNotify) {
        if (self.netMeetingMode == kYYIMNetMeetingModeAudio) {
            return @"[语音聊天]";
        } else {
            return @"[视频聊天]";
        }
    } else {
        if (self.netMeetingType == kYYIMNetMeetingTypeGroupChat) {
            return @"[视频聊天]";
        } else if (self.netMeetingType == kYYIMNetMeetingTypeMeeting) {
            return @"[视频会议]";
        } else if (self.netMeetingType == kYYIMNetMeetingTypeLive) {
            return @"[视频直播]";
        }
    }
    
    return @"";
}


@end
