//
//  YMConfig.h
//  YonyouIM
//
//  Created by litfb on 14/12/25.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYSettings.h"

@interface YYIMConfig : NSObject

+ (instancetype)sharedInstance;

#pragma mark AppKey & EtpKey

/**
 *  应用ID
 *
 *  @return 应用ID
 */
- (NSString *)getAppKey;

/**
 *  设置应用ID
 *
 *  @param appKey 应用ID
 */
- (void)setAppKey:(NSString *)appKey;

/**
 *  企业ID
 *
 *  @return 企业ID
 */
- (NSString *)getEtpKey;

/**
 *  设置企业ID
 *
 *  @param etpKey 企业ID
 */
- (void)setEtpKey:(NSString *)etpKey;

#pragma mark -
#pragma mark Server & Port

/**
 *  IM Server
 *
 *  @return IM Server
 */
- (NSString *)getIMServer;

/**
 *  设置IM Server
 *
 *  @param imServer IM Server
 */
- (void)setIMServer:(NSString *)imServer;

/**
 *  IM ServerName
 *
 *  @return IM ServerName
 */
- (NSString *)getIMServerName;

/**
 *  设置IM ServerName
 *
 *  @param imServerName IM ServerName
 */
- (void)setIMServerName:(NSString *)imServerName;

/**
 *  群组ServerName
 *
 *  @return 群组ServerName
 */
- (NSString *)getConferenceServerName;

/**
 *  公共号ServerName
 *
 *  @return 公共号ServerName
 */
- (NSString *)getPubAccountServerName;

/**
 *  搜索ServerName
 *
 *  @return 搜索ServerName
 */
- (NSString *)getSearchServerName;

/**
 *  IM Server端口
 *
 *  @return IM Server端口
 */
- (NSInteger)getIMServerPort;

/**
 *  设置IM Server端口
 *
 *  @param serverPort IM Server端口
 */
- (void)setIMServerPort:(NSInteger)serverPort;

/**
 *  IM Server SSL端口
 *
 *  @return IM Server SSL端口
 */
- (NSInteger)getIMServerSSLPort;

/**
 *  设置IM Server SSL端口
 *
 *  @param serverPort IM Server SSL端口
 */
- (void)setIMServerSSLPort:(NSInteger)serverPort;

/**
 *  IM Server是否开启SSL
 *
 *  @return IM Server是否开启SSL
 */
- (BOOL)isIMServerEnableSSL;

/**
 *  设置IM Server是否开启SSL
 *
 *  @param enable IM Server是否开启SSL
 */
- (void)setIMServerEnableSSL:(BOOL)enable;

/**
 *  IM RestServer
 *
 *  @return IM RestServer
 */
- (NSString *)getIMRestServer;

/**
 *  设置IM RestServer
 *
 *  @param server IM RestServer
 */
- (void)setIMRestServer:(NSString *)server;

/**
 *  IM RestServer是否https
 *
 *  @return IM RestServer是否https
 */
- (BOOL)isIMRestServerHTTPS;

/**
 *  设置IM RestServer是否https
 *
 *  @param isHTTPS IM RestServer是否https
 */
- (void)setIMRestServerHTTPS:(BOOL)isHTTPS;

/**
 *  IM RestResourceServer是否https
 *
 *  @return IM RestResourceServer是否https
 */
- (BOOL)isIMRestResourceServerHTTPS;
/**
 *  设置IM RestResourceServer是否https
 *
 *  @param isHTTPS IM RestResourceServer是否https
 */
- (void)setIMRestResourceServerHTTPS:(BOOL)isHTTPS;

#pragma mark -
#pragma mark Upload & Download

/**
 *  资源上传Server
 *
 *  @return 资源上传Server
 */
- (NSString *)getResourceUploadServer;

/**
 *  设置资源上传Server
 *
 *  @param uploadServer 资源上传Server
 */
- (void)setResourceUploadServer:(NSString *)uploadServer;

/**
 *  资源下载Server
 *
 *  @return 资源下载Server
 */
- (NSString *)getResourceDownloadServer;

/**
 *  设置资源下载Server
 *
 *  @param downloadServer 资源下载Server
 */
- (void)setResourceDownloadServer:(NSString *)downloadServer;

/**
 *  资源上传Servlet
 *
 *  @return Resource Upload Servlet
 */
- (NSString *)getResourceUploadServlet;

/**
 *  资源下载Servlet
 *
 *  @return Resource Download Servlet
 */
- (NSString *)getResourceDownloadServlet;

#pragma mark -
#pragma mark Current State

/**
 *  当前用户ID
 *
 *  @return 当前用户ID
 */
- (NSString *)getUser;

/**
 *  当前用户完整ID（userID.appKey.etpKey）
 *
 *  @return 当前用户完整ID
 */
- (NSString *)getFullUser;

/**
 *  当前用户完整ID（userID.appKey.etpKey）
 *  匿名用户（anonymous.appKey.etpKey）
 *
 *  @return 当前用户完整ID
 */
- (NSString *)getFullUserAnonymousSpecialy;

/**
 *  设置当前用户ID
 *
 *  @param user 当前用户ID
 */
- (void)setUser:(NSString *)user;

/**
 *  当前用户JID
 *
 *  @return 当前用户JID
 */
- (NSString *)getJid;

/**
 *  设置当前用户JID
 *
 *  @param jid 当前用户JID
 */
- (void)setJid:(NSString *)jid;

/**
 *  当前是否匿名用户
 *
 *  @return 当前是否匿名用户
 */
- (BOOL)isAnonymous;

/**
 *  设置当前是否匿名用户
 *
 *  @param anonymous 设置当前是否匿名用户
 */
- (void)setAnonymous:(BOOL)anonymous;

/**
 *  设置当前DeviceToken
 *
 *  @return 当前DeviceToken
 */
- (NSString *)getDeviceToken;

/**
 *  设置当前DeviceToken
 *
 *  @param deviceToken 当前DeviceToken
 */
- (void)setDeviceToken:(NSString *)deviceToken;

/**
 *  当前IM Token
 *
 *  @return 当前IM Token
 */
- (NSString *)getToken;

/**
 *  设置当前IM Token
 *
 *  @param token 当前IM Token
 */
- (void)setToken:(NSString *)token;

/**
 *  当前IM Token过期时间
 *
 *  @return 当前IM Token过期时间
 */
- (NSTimeInterval)getTokenExpiration;

/**
 *  设置当前IM Token过期时间
 *
 *  @param expiration 当前IM Token过期时间
 */
- (void)setTokenExpiration:(NSTimeInterval)expiration;

/**
 *  当前用户是否云盘管理员
 *
 *  @return 当前用户是否云盘管理员
 */
- (BOOL)isPanAdmin;

/**
 *  当前用户是否云盘管理员
 *
 *  @param isAdmin 当前用户是否云盘管理员
 */
- (void)setPanAdmin:(BOOL)isAdmin;

#pragma mark -
#pragma mark Settings

/**
 *  是否自动登录
 *
 *  @return 是否自动登录
 */
- (BOOL)isAutoLogin;

/**
 *  设置是否自动登录
 *
 *  @param isAutoLogin 是否自动登录
 *  默认清空当前用户登录信息
 */
- (void)setAutoLogin:(BOOL)isAutoLogin;

/**
 *  设置是否自动登录
 *
 *  @param isAutoLogin   是否自动登录
 *  @param clearUserInfo 清空当前用户登录信息
 */
- (void)setAutoLogin:(BOOL)isAutoLogin flag:(BOOL)clearUserInfo;

/**
 *  iOS推送证书名称
 *
 *  @return iOS推送证书名称
 */
- (NSString *)getApnsCerName;

/**
 *  设置iOS推送证书名称
 *
 *  @param apnsCerName iOS推送证书名称
 */
- (void)setApnsCerName:(NSString *)apnsCerName;

/**
 *  是否自动同意好友邀请
 *
 *  @return 是否自动同意好友邀请
 */
- (BOOL)isAutoAcceptRosterInvite;

/**
 *  是否自动同意好友邀请
 *
 *  @param isAutoAccept 是否自动同意好友邀请
 */
- (void)setAutoAcceptRosterInvite:(BOOL)isAutoAccept;

/**
 *  用户设置
 *
 *  @return 用户设置
 */
- (YYSettings *)getSettings;

/**
 *  用户设置
 *
 *  @param settings 用户设置
 */
- (void)setSettings:(YYSettings *)settings;

/**
 *  当前用户消息版本号
 *
 *  @return 当前消息版本号
 */
- (NSInteger)getMessageVersionNumber;

/**
 *  设置当前用户消息版本号
 *
 *  @param versionNumber 当前消息版本号
 */
- (void)setMessageVersionNumber:(NSInteger)versionNumber;

/**
 *  清空消息版本号
 */
- (void)clearMessageVersionNumbers;

/**
 *  群组版本号
 *
 *  @return 群组版本号
 */
- (NSNumber *)getChatGroupVersionNumber;

/**
 *  设置群组版本号
 *
 *  @param versionNumber 群组版本号
 */
- (void)setChatGroupVersionNumber:(NSNumber *)versionNumber;

/**
 *  清空群组版本号
 */
- (void)clearChatGroupVersionNumbers;

/**
 *  用户信息显示设置
 *
 *  @return 用户信息显示设置
 */
- (NSArray *)getUserSetting;

/**
 *  用户信息显示设置
 *
 *  @param userSetting 用户信息显示设置
 */
- (void)setUserSetting:(NSArray *)userSetting;

/**
 *  好友模式是否为收藏
 *
 *  @return 好友模式是否为收藏
 */
- (BOOL)isRosterCollect;

/**
 *  设置好友模式
 *
 *  @param isCollect 是否收藏
 */
- (void)setRosterCollect:(BOOL)isCollect;

/**
 *  群组模式是否为增量
 *
 *  @return 群组模式是否为增量
 */
- (BOOL)isChatGroupVersion;

/**
 *  设置群组模式
 *
 *  @param isVersion 是否增量
 */
- (void)setChatGroupVersion:(BOOL)isVersion;

/**
 *  是否强制同步同端消息
 *
 *  @return 是否强制同步同端消息
 */
- (BOOL)isForceMessageSync;

/**
 *  设置是否强制同步同端消息
 *
 *  @param isForce 是否强制同步同端消息
 */
- (void)setForceMessageSync:(BOOL)isForce;

#pragma mark -
#pragma mark REST -

#pragma mark DeviceToken

/**
 *  iOS DeviceToken Servlet
 *
 *  @return iOS DeviceToken Servlet
 */
- (NSString *)getDeviceTokenServlet;

#pragma mark Password

/**
 *  Password Servlet
 *
 *  @return Password Servlet
 */
- (NSString *)getPasswordServlet;

#pragma mark DemoToken

/**
 *  测试用TokenServlet
 *
 *  @return 测试用TokenServlet
 */
- (NSString *)getDemoTokenServlet;

#pragma mark Version

/**
 *  消息版本号Servlet
 *
 *  @param subpath 子路径
 *
 *  @return 消息版本号Servlet
 */
- (NSString *)getVersionServlet:(NSString *)subpath;

/**
 *  群组消息版本号Servlet
 *
 *  @return 群组消息版本号Servlet
 */
- (NSString *)getMUCVersionServlet;

#pragma mark Tele Conference

/**
 *  嘟嘟AccountIdentify
 *
 *  @return 嘟嘟AccountIdentify
 */
- (NSString *)getDuduAccountIdentify;

/**
 *  设置嘟嘟AccountIdentify
 *
 *  @param accountIdentify 嘟嘟AccountIdentify
 */
- (void)setDuduAccountIdentify:(NSString *)accountIdentify;

/**
 *  嘟嘟Appkeytemp
 *
 *  @return 嘟嘟Appkeytemp
 */
- (NSString *)getDuduAppkeytemp;

/**
 *  设置嘟嘟Appkeytemp
 *
 *  @param appkeytemp 嘟嘟Appkeytemp
 */
- (void)setDuduAppkeytemp:(NSString *)appkeytemp;

/**
 *  嘟嘟创建会议Servlet
 *
 *  @return 嘟嘟创建会议Servlet
 */
- (NSString *)getDuduCreateConferenceServlet;

/**
 *  电话会议接口
 *
 *  @return 电话会议接口
 */
- (NSString *)getTeleConfereneServlet;

#pragma mark MUC QRCode

/**
 *  群组二维码生成Servlet
 *
 *  @return 群组二维码生成Servlet
 */
- (NSString *)getMucQrCodeServlet;

/**
 *  群组二维码详情Servlet
 *
 *  @return 群组二维码详情Servlet
 */
- (NSString *)getMucQrCodeInfoServlet;

#pragma mark Net Meeting

/**
 *  视频会议动态KeyServlet
 *
 *  @return 视频会议动态KeyServlet
 */
- (NSString *)getNetMeetingKeyServlet;

/**
 *  视频会议Servlet
 *
 *  @return 视频会议Servlet
 */
- (NSString *)getNetMeetingInfoServlet;

/**
 *  视频会议详情Servlet
 *
 *  @param channelId 视频会议频道ID
 *
 *  @return 视频会议详情Servlet
 */
- (NSString *)getNetMeetingDetailServlet:(NSString *)channelId;

/**
 *  视频会议预约Servlet
 *
 *  @return 视频会议预约Servlet
 */
- (NSString *)getNetMeetingReservationServlet;

/**
 *  视频会议删除Servlet
 *
 *  @param channelId 视频会议频道ID
 *
 *  @return 视频会议删除Servlet
 */
- (NSString *)getNetMeetingRemoveServlet:(NSString *)channelId;

/**
 *  视频会议取消预约Servlet
 *
 *  @param channelId 视频会议频道ID
 *
 *  @return 视频会议取消预约Servlet
 */
- (NSString *)getNetMeetingCancelReservationServlet:(NSString *)channelId;

/**
 *  视频会议预约邀请Servlet
 *
 *  @return 视频会议预约邀请Servlet
 */
- (NSString *)getNetMeetingReservationInviteServlet;

/**
 *  视频会议预约踢人Servlet
 *
 *  @param channelId 视频会议频道ID
 *
 *  @return 视频会议预约踢人Servlet
 */
- (NSString *)getNetMeetingReservationKickServlet:(NSString *)channelId;

#pragma mark Message Revoke

/**
 *  群组消息撤回
 *
 *  @param packetId 消息ID
 *
 *  @return 群组消息撤回
 */
- (NSString *)getGroupMessageRevokeServlet:(NSString *)packetId;

/**
 *  个人消息撤回
 *
 *  @param packetId 消息ID
 *
 *  @return 个人消息撤回
 */
- (NSString *)getPersonalMessageRevokeServlet:(NSString *)packetId;

#pragma mark Group Member

/**
 *  获取群组成员的列表Servlet
 *
 *  @param groupId 群组ID
 *
 *  @return 获取群组成员的列表Servlet
 */
- (NSString *)getChatGroupMembersServlet:(NSString *)groupId;

#pragma mark Message File

/**
 *  单聊文件列表Servlet
 *
 *  @param chatId 用户ID
 *
 *  @return 单聊文件列表Servlet
 */
- (NSString *)getMessageFileChatListServlet:(NSString *)chatId;

/**
 *  单聊文件搜索Servlet
 *
 *  @param chatId 用户ID
 *
 *  @return 单聊文件搜索Servlet
 */
- (NSString *)getMessageFileChatSearchServlet:(NSString *)chatId;

/**
 *  群聊文件列表Servlet
 *
 *  @param groupId 群组ID
 *
 *  @return 群聊文件列表Servlet
 */
- (NSString *)getMessageFileChatGroupListServlet:(NSString *)groupId;

/**
 *  群聊文件搜索Servlet
 *
 *  @param groupId 群组ID
 *
 *  @return 群聊文件列表Servlet
 */
- (NSString *)getMessageFileChatGroupSearchServlet:(NSString *)groupId;

#pragma mark PubAccount Menu

/**
 *  获取公共号菜单
 *
 *  @param accountId 公共号ID
 *
 *  @return 获取公共号菜单
 */
- (NSString *)getPubAccountMenuServlet:(NSString *)accountId;

/**
 *  获取公共号推送命令的菜单
 *
 *  @param accountId 公共号ID
 *
 *  @return 获取公共号推送命令的菜单
 */
- (NSString *)getPubAccountMenuCommandServlet:(NSString *)accountId;

#pragma mark UserTag & RosterTag

/**
 *  设置用户的tag
 *
 *  @return 设置用户的tag
 */
- (NSString *)getUserTagAddServlet;

/**
 *  删除用户的tag
 *
 *  @return 删除用户的tag
 */
- (NSString *)getUserTagDeleteServlet;

/**
 *  设置好友的tag
 *
 *  @param rosterId 好友ID
 *
 *  @return 设置好友的tag
 */
- (NSString *)getRosterTagAddServlet:(NSString *)rosterId;

/**
 *  删除好友的tag
 *
 *  @param rosterId 好友ID
 *
 *  @return 删除好友的tag
 */
- (NSString *)getRosterTagDeleteServlet:(NSString *)rosterId;

#pragma mark UserProfile

/**
 *  用户设置接口
 *
 *  @return 用户设置接口
 */
- (NSString *)getUserProfileServlet;

/**
 *  用户设置免打扰接口
 *
 *  @return 用户设置免打扰接口
 */
- (NSString *)getUserProfileMuteServlet;

/**
 *  用户设置置顶接口
 *
 *  @return 用户设置置顶接口
 */
- (NSString *)getUserProfileStickServlet;

@end
