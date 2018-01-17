//
//  YYIMConfig.m
//  YonyouIM
//
//  Created by litfb on 14/12/25.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import "YYIMConfig.h"

#import "YYIMDefs.h"
#import "YYIMStringUtility.h"
#import "YYIMJUMPHelper.h"
#import "YYIMLogger.h"

#pragma mark AppKey & EtpKey

// app & etp key
#define YM_APP_KEY                          @"YM_APP_KEY"
#define YM_ETP_KEY                          @"YM_ETP_KEY"

#pragma mark -
#pragma mark Server & Port

// im server
#define YM_IM_SERVER                        @"YM_IM_SERVER"
#define YM_IM_SERVER_NAME                   @"YM_IM_SERVER_NAME"
#define YM_IM_SERVER_PORT                   @"YM_IM_SERVER_PORT"
#define YM_IM_SERVER_SSLPORT                @"YM_IM_SERVER_SSLPORT"
#define YM_IM_SERVER_ENABLESSL              @"YM_IM_SERVER_ENABLESSL"
// rest server
#define YM_IM_REST_SERVER                   @"YM_IM_REST_SERVER"
#define YM_IM_REST_SERVER_HTTPS             @"YM_IM_REST_SERVER_HTTPS"
#define YM_IM_REST_RESOURCE_SERVER_HTTPS    @"YM_IM_REST_RESOURCE_SERVER_HTTPS"

#pragma mark -
#pragma mark Upload & Download

// upload & download server
#define YM_RESOURCE_UPLOAD_SERVER           @"YM_RESOURCE_UPLOAD_SERVER"
#define YM_RESOURCE_DOWNLOAD_SERVER         @"YM_RESOURCE_DOWNLOAD_SERVER"

#pragma mark -
#pragma mark Current State

// user
#define YM_LAST_ACCOUNT                     @"YM_LAST_ACCOUNT"
#define YM_LAST_JID                         @"YM_LAST_JID"
// anonymous
#define YM_ANONYMOUS                        @"YM_ANONYMOUS"
// device token
#define YM_DEVICE_TOKEN                     @"YM_DEVICE_TOKEN"
// token
#define YM_TOKEN                            @"YM_TOKEN"
#define YM_TOKEN_EXPIRATION                 @"YM_TOKEN_EXPIRATION"
// pan admin
#define YM_PAN_ADMIN                        @"YM_PAN_ADMIN"

#pragma mark -
#pragma mark Settings

// auto login
#define YM_IS_AUTO_LOGIN                    @"YM_IS_AUTO_LOGIN"
// apns
#define YM_APNS_CER_NAME                    @"YM_APNS_CER_NAME"
// is auto accept roster invete
#define YM_AUTO_ACCEPT_ROSTER_INVITE        @"YM_AUTO_ACCEPT_ROSTER_INVITE"
// settings
#define YM_SETTINGS_INIT                    @"YM_SETTINGS_INIT"
#define YM_SETTINGS_NEWMSG_REMIND           @"YM_SETTINGS_NEWMSG_REMIND"
#define YM_SETTINGS_PLAY_SOUND              @"YM_SETTINGS_PLAY_SOUND"
#define YM_SETTINGS_PLAY_VIBRATE            @"YM_SETTINGS_PLAY_VIBRATE"
#define YM_SETTINGS_SHOW_DETAIL             @"YM_SETTINGS_SHOW_DETAIL"
// message version number
#define YM_MESSAGE_VERSION_NUMBER           @"YM_MESSAGE_VERSION_NUMBER"
// chatgroup version number
#define YM_CHATGROUP_VERSION_NUMBER         @"YM_CHATGROUP_VERSION_NUMBER"
// vcard setting
#define YM_VCARD_SETTING                    @"YM_VCARD_SETTING"
// is roster collect
#define YM_IS_ROSTER_COLLECT                @"YM_IS_ROSTER_COLLECT"
// is chatgroup version
#define YM_IS_CHATGROUP_VERSION             @"YM_IS_CHATGROUP_VERSION"
// is force message sync
#define YM_IS_FORCE_MESSAGE_SYNC            @"YM_IS_FORCE_MESSAGE_SYNC"

#pragma mark -
#pragma mark Tele Conference

// dudu params
#define YM_DUDU_ACCOUNTIDENTIFY             @"YM_DUDU_ACCOUNTIDENTIFY"
#define YM_DUDU_APPKEYTEMP                  @"YM_DUDU_APPKEYTEMP"

#pragma mark -
#pragma mark Default Server & Port

/** default im server */
#define DEFAULT_IM_SERVER                   @"stellar.yyuap.com"
/** default im server name */
#define DEFAULT_IM_SERVER_NAME              @"im.yyuap.com"
/** default im server port */
#define DEFAULT_IM_SERVER_PORT              5227
#define DEFAULT_IM_SERVER_SSLPORT           5223

/** default im rest server */
#define DEFAULT_IM_REST_SERVER              @"im.yyuap.com"
#define DEFAULT_IM_REST_SERVER_HTTPS        YES
#define DEFAULT_IM_REST_RESOURCE_SERVER_HTTPS        NO

/** default resource server */
#define DEFAULT_RESOURCE_UPLOAD_SERVER      @"up.im.yyuap.com"
#define DEFAULT_RESOURCE_DOWNLOAD_SERVER    @"down.im.yyuap.com"



#pragma mark -
#pragma mark Default Rest Servlet -

#define DEFAULT_RESOURCE_SERVLET                        @"{scheme}://{restServer}/sysadmin/rest/resource/{etpId}/{appId}"

#pragma mark DeviceToken

/** default device token service */
#define DEFAULT_DEVICETOKEN_SERVLET                     @"{scheme}://{restServer}/sysadmin/rest/ios/token/"

#pragma mark Password

/** default password service */
#define DEFAULT_PASSWORD_SERVLET                        @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/{username}/password"

#pragma mark DemoToken

/** default demo token service */
#define DEFAULT_DEMO_TOKEN_SERVLET                      @"{scheme}://{restServer}/sysadmin/rest/demo/token"


#pragma mark Version

/** default version service */
#define DEFAULT_VERSION_SERVLET                         @"{scheme}://{restServer}/sysadmin/rest/version/{etpId}/{appId}/{username}"
/** default muc version service */
#define DEFAULT_MUC_VERSION_SERVLET                     @"{scheme}://{restServer}/sysadmin/rest/user/version/room"

#pragma mark Tele Conference

/** default dudu create conference */
#define DEFAULT_DUDU_CREATE_CONFERENCE                  @"http://dudu.yonyoutelecom.cn/httpIntf/createConference.do"
/** default tele conferene service */
#define DEFAULT_TELECONFERENCE_SERVLET                  @"{scheme}://{restServer}/sysadmin/rest/user/voip/make"

#pragma mark MUC QRCode

/** default muc qrcode service */
#define DEFAULT_MUCQRCODE_SERVLET                       @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/mucqrcode"
/** default muc qrcode info service */
#define DEFAULT_MUCQRCODE_INFO_SERVLET                  @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/mucqrcode/info"

#pragma mark Net Meeting

/** default netmeeting key service */
#define DEFAULT_NETMEETING_KEY_SERVLET                  @"{scheme}://{restServer}/sysadmin/rest/user/phosvraccount/{etpId}/{appId}/{userId}/vendorkey"
/** default netmeeting info service */
#define DEFAULT_NETMEETING_INFO_SERVLET                 @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/netconference/{userId}"
/** default netmeeting detail service */
#define DEFAULT_NETMEETING_DETAIL_SERVLET               @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/netconference/{userId}/{channelId}/record/info"
/** default netmeeting reservation service */
#define DEFAULT_NETMEETING_RESERVATION_SERVLET          @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/netconference/reservation"
/** default netmeeting remove service */
#define DEFAULT_NETMEETING_REMOVE_SERVLET               @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/netconference/{userId}/{channelId}/record"
/** default netmeeting cancel service */
#define DEFAULT_NETMEETING_CANCEL_RESERVATION_SERVLET   @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/netconference/reservation/{channelId}"
/** default netmeeting reservation invite service */
#define DEFAULT_NETMEETING_RESERVATION_INVITE_SERVLET   @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/netconference/reservation/members"
/** default netmeeting reservation kick service */
#define DEFAULT_NETMEETING_RESERVATION_KICK_SERVLET     @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/netconference/reservation/{channelId}/members"

#pragma mark Message Revoke

/** default group message revoke service */
#define DEFAULT_GROUP_MESSAGE_REVOKE_SERVLET            @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/revokeservice/groupmessage/{packetId}"
/** default personal message revoke service */
#define DEFAULT_PERSONAL_MESSAGE_REVOKE_SERVLET         @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/revokeservice/personalmessage/{packetId}"

#pragma mark Group Member

/** chatgroup  memberlist serv */
#define DEFAULT_CHATGROUP_MEMBER_LIST_SERVLET           @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/rooms/{roomId}/{userId}/version/members"

#pragma mark Message File

/** default mssage file search chat list serv */
#define DEFAULT_MESSAGE_FILE_CHAT_LIST_SERVLET          @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/shareattachment/persional/attachment/{userId}/{chatId}"
/** default mssage file search chat search serv */
#define DEFAULT_MESSAGE_FILE_CHAT_SEARCH_SERVLET        @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/shareattachment/persional/attachment/searching/{userId}/{chatId}"
/** default mssage file search chatgroup list serv */
#define DEFAULT_MESSAGE_FILE_CHATGROUP_LIST_SERVLET     @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/shareattachment/room/attachment/{roomId}/{userId}"
/** default mssage file search chatgroup search serv */
#define DEFAULT_MESSAGE_FILE_CHATGROUP_SEARCH_SERVLET   @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/shareattachment/room/attachment/searching/{roomId}/{userId}"

#pragma mark PubAccount Menu

/** pubaccount menu serv */
#define DEFAULT_PUBACCOUNT_MENU_SERVLET                 @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/{pubId}/{userId}/pubaccountmenu/menu"
/** pubaccount menu command serv */
#define DEFAULT_PUBACCOUNT_MENU_COMMAND_SERVLET         @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/{pubId}/{userId}/pubaccountmenu/event"

#pragma mark UserTag & RosterTag

/** user tag add serv */
#define DEFAULT_USER_TAG_ADD_SERVLET                    @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/{userId}/vcard/tag"
/** user tag delete serv */
#define DEFAULT_USER_TAG_DELETE_SERVLET                 @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/{userId}/vcard/tag"
/** roster tag add serv */
#define DEFAULT_ROSTER_TAG_ADD_SERVLET                  @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/{userId}/{rosterId}/roster/tag"
/** roster tag delete serv */
#define DEFAULT_ROSTER_TAG_DELETE_SERVLET               @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/{userId}/{rosterId}/roster/tag"

#pragma mark UserProfile

#define DEFAULT_USER_PROFILE_SERVLET                    @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/{userId}/profile"
#define DEFAULT_USER_PROFILE_MUTE_SERVLET                    @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/{userId}/profile/mute"
#define DEFAULT_USER_PROFILE_STICK_SERVLET                    @"{scheme}://{restServer}/sysadmin/rest/user/{etpId}/{appId}/{userId}/profile/stick"

@implementation YYIMConfig

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setIMServer:DEFAULT_IM_SERVER];
        [self setIMServerName:DEFAULT_IM_SERVER_NAME];
        [self setIMServerPort:DEFAULT_IM_SERVER_PORT];
        [self setIMServerSSLPort:DEFAULT_IM_SERVER_SSLPORT];
        [self setIMServerEnableSSL:YES];
        
        [self setIMRestServer:DEFAULT_IM_REST_SERVER];
        [self setIMRestServerHTTPS:DEFAULT_IM_REST_SERVER_HTTPS];
        [self setIMRestResourceServerHTTPS:DEFAULT_IM_REST_RESOURCE_SERVER_HTTPS];
        
        [self setResourceUploadServer:DEFAULT_RESOURCE_UPLOAD_SERVER];
        [self setResourceDownloadServer:DEFAULT_RESOURCE_DOWNLOAD_SERVER];
        
        [self setChatGroupVersion:YES];
    }
    return self;
}


#pragma mark AppKey & EtpKey

/**
 *  应用ID
 *
 *  @return 应用ID
 */
- (NSString *)getAppKey {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:YM_APP_KEY];
}

/**
 *  设置应用ID
 *
 *  @param appKey 应用ID
 */
- (void)setAppKey:(NSString *)appKey {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:appKey forKey:YM_APP_KEY];
    [userDefaults synchronize];
}

/**
 *  企业ID
 *
 *  @return 企业ID
 */
- (NSString *)getEtpKey {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:YM_ETP_KEY];
}

/**
 *  设置企业ID
 *
 *  @param etpKey 企业ID
 */
- (void)setEtpKey:(NSString *)etpKey {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:etpKey forKey:YM_ETP_KEY];
    [userDefaults synchronize];
}

#pragma mark -
#pragma mark Server & Port

/**
 *  IM Server
 *
 *  @return IM Server
 */
- (NSString *)getIMServer {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:YM_IM_SERVER];
}

/**
 *  设置IM Server
 *
 *  @param imServer IM Server
 */
- (void)setIMServer:(NSString *)imServer {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:imServer forKey:YM_IM_SERVER];
    [userDefaults synchronize];
}

/**
 *  IM ServerName
 *
 *  @return IM ServerName
 */
- (NSString *)getIMServerName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:YM_IM_SERVER_NAME];
}

/**
 *  设置IM ServerName
 *
 *  @param imServerName IM ServerName
 */
- (void)setIMServerName:(NSString *)imServerName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:imServerName forKey:YM_IM_SERVER_NAME];
    [userDefaults synchronize];
}

/**
 *  群组ServerName
 *
 *  @return 群组ServerName
 */
- (NSString *)getConferenceServerName {
    return [NSString stringWithFormat:@"conference.%@", [[YYIMConfig sharedInstance] getIMServerName]];
}

/**
 *  公共号ServerName
 *
 *  @return 公共号ServerName
 */
- (NSString *)getPubAccountServerName {
    return [NSString stringWithFormat:@"pubaccount.%@", [[YYIMConfig sharedInstance] getIMServerName]];
}

/**
 *  搜索ServerName
 *
 *  @return 搜索ServerName
 */
- (NSString *)getSearchServerName {
    return [NSString stringWithFormat:@"search.%@", [[YYIMConfig sharedInstance] getIMServerName]];
}

/**
 *  IM Server端口
 *
 *  @return IM Server端口
 */
- (NSInteger)getIMServerPort {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:YM_IM_SERVER_PORT];
}

/**
 *  设置IM Server端口
 *
 *  @param serverPort IM Server端口
 */
- (void)setIMServerPort:(NSInteger)serverPort {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:serverPort forKey:YM_IM_SERVER_PORT];
    [userDefaults synchronize];
}

/**
 *  IM Server SSL端口
 *
 *  @return IM Server SSL端口
 */
- (NSInteger)getIMServerSSLPort {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:YM_IM_SERVER_SSLPORT];
}

/**
 *  设置IM Server SSL端口
 *
 *  @param serverPort IM Server SSL端口
 */
- (void)setIMServerSSLPort:(NSInteger)serverPort {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:serverPort forKey:YM_IM_SERVER_SSLPORT];
    [userDefaults synchronize];
}

/**
 *  IM Server是否开启SSL
 *
 *  @return IM Server是否开启SSL
 */
- (BOOL)isIMServerEnableSSL {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:YM_IM_SERVER_ENABLESSL];
}

/**
 *  设置IM Server是否开启SSL
 *
 *  @param enable IM Server是否开启SSL
 */
- (void)setIMServerEnableSSL:(BOOL)enable {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:enable forKey:YM_IM_SERVER_ENABLESSL];
    [userDefaults synchronize];
}

/**
 *  IM RestServer
 *
 *  @return IM RestServer
 */
- (NSString *)getIMRestServer {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:YM_IM_REST_SERVER];
}

/**
 *  设置IM RestServer
 *
 *  @param server IM RestServer
 */
- (void)setIMRestServer:(NSString *)server {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:server forKey:YM_IM_REST_SERVER];
    [userDefaults synchronize];
}

/**
 *  IM RestServer是否https
 *
 *  @return IM RestServer是否https
 */
- (BOOL)isIMRestServerHTTPS {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:YM_IM_REST_SERVER_HTTPS];
}

/**
 *  设置IM RestServer是否https
 *
 *  @param isHTTPS IM RestServer是否https
 */
- (void)setIMRestServerHTTPS:(BOOL)isHTTPS {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isHTTPS forKey:YM_IM_REST_SERVER_HTTPS];
    [userDefaults synchronize];
}

/**
 *  IM RestResourceServer是否https
 *
 *  @return IM RestResourceServer是否https
 */
- (BOOL)isIMRestResourceServerHTTPS {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:YM_IM_REST_RESOURCE_SERVER_HTTPS];
}

/**
 *  设置IM RestResourceServer是否https
 *
 *  @param isHTTPS IM RestResourceServer是否https
 */
- (void)setIMRestResourceServerHTTPS:(BOOL)isHTTPS {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isHTTPS forKey:YM_IM_REST_RESOURCE_SERVER_HTTPS];
    [userDefaults synchronize];
}

- (NSString *)getIMRestServerScheme {
    return [self isIMRestServerHTTPS] ? @"https" : @"http";
}

- (NSString *)getIMRestResourceServerScheme {
    return [self isIMRestResourceServerHTTPS] ? @"https" : @"http";
}

#pragma mark -
#pragma mark Upload & Download

/**
 *  资源上传Server
 *
 *  @return 资源上传Server
 */
- (NSString *)getResourceUploadServer {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:YM_RESOURCE_UPLOAD_SERVER];
}

/**
 *  设置资源上传Server
 *
 *  @param uploadServer 资源上传Server
 */
- (void)setResourceUploadServer:(NSString *)uploadServer {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:uploadServer forKey:YM_RESOURCE_UPLOAD_SERVER];
    [userDefaults synchronize];
}

/**
 *  资源下载Server
 *
 *  @return 资源下载Server
 */
- (NSString *)getResourceDownloadServer {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:YM_RESOURCE_DOWNLOAD_SERVER];
}

/**
 *  设置资源下载Server
 *
 *  @param downloadServer 资源下载Server
 */
- (void)setResourceDownloadServer:(NSString *)downloadServer {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:downloadServer forKey:YM_RESOURCE_DOWNLOAD_SERVER];
    [userDefaults synchronize];
}

/**
 *  资源上传Servlet
 *
 *  @return Resource Upload Servlet
 */
- (NSString *)getResourceUploadServlet {
    NSString *servlet = DEFAULT_RESOURCE_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestResourceServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getResourceUploadServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByAppendingString:@"/upload"];
    return servlet;
}

/**
 *  资源下载Servlet
 *
 *  @return Resource Download Servlet
 */
- (NSString *)getResourceDownloadServlet {
    NSString *servlet = DEFAULT_RESOURCE_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestResourceServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getResourceDownloadServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByAppendingString:@"/download"];
    return servlet;
}

#pragma mark -
#pragma mark Current State

/**
 *  当前用户ID
 *
 *  @return 当前用户ID
 */
- (NSString *)getUser {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:YM_LAST_ACCOUNT];
}

/**
 *  当前用户完整ID（userID.appKey.etpKey）
 *
 *  @return 当前用户完整ID
 */
- (NSString *)getFullUser {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        return @"";
    }
    if ([self isAnonymous]) {
        return [NSString stringWithFormat:@"%@@%@/ANONYMOUS", user, [[YYIMConfig sharedInstance] getIMServerName]];
    }
    return [NSString stringWithFormat:@"%@.%@.%@", user, [self getAppKey], [self getEtpKey]];
}

/**
 *  当前用户完整ID（userID.appKey.etpKey）
 *  匿名用户（anonymous.appKey.etpKey）
 *
 *  @return 当前用户完整ID
 */
- (NSString *)getFullUserAnonymousSpecialy {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        return @"";
    }
    if ([self isAnonymous]) {
        return [NSString stringWithFormat:@"anonymous.%@.%@", [self getAppKey], [self getEtpKey]];
    }
    return [NSString stringWithFormat:@"%@.%@.%@", user, [self getAppKey], [self getEtpKey]];
}

/**
 *  设置当前用户ID
 *
 *  @param user 当前用户ID
 */
- (void)setUser:(NSString *)user {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:user forKey:YM_LAST_ACCOUNT];
    [userDefaults synchronize];
}

/**
 *  当前用户JID
 *
 *  @return 当前用户JID
 */
- (NSString *)getJid {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:YM_LAST_JID];
}

/**
 *  设置当前用户JID
 *
 *  @param jid 当前用户JID
 */
- (void)setJid:(NSString *)jid {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:jid forKey:YM_LAST_JID];
    [userDefaults synchronize];
}

/**
 *  当前是否匿名用户
 *
 *  @return 当前是否匿名用户
 */
- (BOOL)isAnonymous {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:YM_ANONYMOUS];
}

/**
 *  设置当前是否匿名用户
 *
 *  @param anonymous 设置当前是否匿名用户
 */
- (void)setAnonymous:(BOOL)anonymous {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:anonymous forKey:YM_ANONYMOUS];
    [userDefaults synchronize];
}

/**
 *  设置当前DeviceToken
 *
 *  @return 当前DeviceToken
 */
- (NSString *)getDeviceToken {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:YM_DEVICE_TOKEN];
}

/**
 *  设置当前DeviceToken
 *
 *  @param deviceToken 当前DeviceToken
 */
- (void)setDeviceToken:(NSString *)deviceToken {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (deviceToken) {
        [userDefaults setObject:deviceToken forKey:YM_DEVICE_TOKEN];
    } else {
        [userDefaults removeObjectForKey:YM_DEVICE_TOKEN];
    }
    [userDefaults synchronize];
}

/**
 *  当前IM Token
 *
 *  @return 当前IM Token
 */
- (NSString *)getToken {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:YM_TOKEN];
}

/**
 *  设置当前IM Token
 *
 *  @param token 当前IM Token
 */
- (void)setToken:(NSString *)token {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:token forKey:YM_TOKEN];
    [userDefaults synchronize];
}

/**
 *  当前IM Token过期时间
 *
 *  @return 当前IM Token过期时间
 */
- (NSTimeInterval)getTokenExpiration {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults doubleForKey:YM_TOKEN_EXPIRATION];
}

/**
 *  设置当前IM Token过期时间
 *
 *  @param expiration 当前IM Token过期时间
 */
- (void)setTokenExpiration:(NSTimeInterval)expiration {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (expiration > 0) {
        [userDefaults setDouble:expiration forKey:YM_TOKEN_EXPIRATION];
    } else {
        [userDefaults removeObjectForKey:YM_TOKEN_EXPIRATION];
    }
    [userDefaults synchronize];
}

/**
 *  当前用户是否云盘管理员
 *
 *  @return 当前用户是否云盘管理员
 */
- (BOOL)isPanAdmin {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userDefaults dictionaryForKey:YM_PAN_ADMIN];
    NSNumber *number = [dic objectForKey:[[YYIMConfig sharedInstance] getFullUser]];
    if (!number) {
        return NO;
    }
    return [number boolValue];
}

/**
 *  当前用户是否云盘管理员
 *
 *  @param isAdmin 当前用户是否云盘管理员
 */
- (void)setPanAdmin:(BOOL)isAdmin {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[userDefaults dictionaryForKey:YM_PAN_ADMIN]];
    if (!dic) {
        dic = [NSMutableDictionary dictionary];
    }
    [dic setObject:[NSNumber numberWithBool:isAdmin] forKey:[[YYIMConfig sharedInstance] getFullUser]];
    [userDefaults setObject:dic forKey:YM_PAN_ADMIN];
    [userDefaults synchronize];
}

#pragma mark -
#pragma mark Settings

/**
 *  是否自动登录
 *
 *  @return 是否自动登录
 */
- (BOOL)isAutoLogin {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:YM_IS_AUTO_LOGIN];
}

/**
 *  设置是否自动登录
 *
 *  @param isAutoLogin 是否自动登录
 *  默认清空当前用户登录信息
 */
- (void)setAutoLogin:(BOOL)isAutoLogin {
    [self setAutoLogin:isAutoLogin flag:YES];
}

/**
 *  设置是否自动登录
 *
 *  @param isAutoLogin   是否自动登录
 *  @param clearUserInfo 清空当前用户登录信息
 */
- (void)setAutoLogin:(BOOL)isAutoLogin flag:(BOOL)clearUserInfo {
    if (!isAutoLogin && clearUserInfo) {
        [self setUser:nil];
        [self setJid:nil];
        [self setToken:nil];
        [self setTokenExpiration:0];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isAutoLogin forKey:YM_IS_AUTO_LOGIN];
    [userDefaults synchronize];
}

/**
 *  iOS推送证书名称
 *
 *  @return iOS推送证书名称
 */
- (NSString *)getApnsCerName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:YM_APNS_CER_NAME];
}

/**
 *  设置iOS推送证书名称
 *
 *  @param apnsCerName iOS推送证书名称
 */
- (void)setApnsCerName:(NSString *)apnsCerName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:apnsCerName forKey:YM_APNS_CER_NAME];
    [userDefaults synchronize];
}

/**
 *  是否自动同意好友邀请
 *
 *  @return 是否自动同意好友邀请
 */
- (BOOL)isAutoAcceptRosterInvite {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:YM_AUTO_ACCEPT_ROSTER_INVITE];
}

/**
 *  是否自动同意好友邀请
 *
 *  @param isAutoAccept 是否自动同意好友邀请
 */
- (void)setAutoAcceptRosterInvite:(BOOL)isAutoAccept {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isAutoAccept forKey:YM_AUTO_ACCEPT_ROSTER_INVITE];
    [userDefaults synchronize];
}

/**
 *  用户设置
 *
 *  @return 用户设置
 */
- (YYSettings *)getSettings {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isSettingsInit = [userDefaults boolForKey:YM_SETTINGS_INIT];
    YYSettings *settings;
    if (!isSettingsInit) {
        settings = [YYSettings defaultSettings];
        [self setSettings:settings];
    } else {
        settings = [[YYSettings alloc] init];
        [settings setNewMsgRemind:[userDefaults boolForKey:YM_SETTINGS_NEWMSG_REMIND]];
        [settings setPlaySound:[userDefaults boolForKey:YM_SETTINGS_PLAY_SOUND]];
        [settings setPlayVibrate:[userDefaults boolForKey:YM_SETTINGS_PLAY_VIBRATE]];
        [settings setShowDetail:[userDefaults boolForKey:YM_SETTINGS_SHOW_DETAIL]];
    }
    return settings;
}

/**
 *  用户设置
 *
 *  @param settings 用户设置
 */
- (void)setSettings:(YYSettings *)settings {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:[settings newMsgRemind] forKey:YM_SETTINGS_NEWMSG_REMIND];
    [userDefaults setBool:[settings playSound] forKey:YM_SETTINGS_PLAY_SOUND];
    [userDefaults setBool:[settings playVibrate] forKey:YM_SETTINGS_PLAY_VIBRATE];
    [userDefaults setBool:[settings showDetail] forKey:YM_SETTINGS_SHOW_DETAIL];
    [userDefaults setBool:YES forKey:YM_SETTINGS_INIT];
    [userDefaults synchronize];
}

/**
 *  当前用户消息版本号
 *
 *  @return 当前消息版本号
 */
- (NSInteger)getMessageVersionNumber {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userDefaults dictionaryForKey:YM_MESSAGE_VERSION_NUMBER];
    NSNumber *versionNumber = [dic objectForKey:[[YYIMConfig sharedInstance] getFullUser]];
    return [versionNumber integerValue];
}

/**
 *  设置当前用户消息版本号
 *
 *  @param versionNumber 当前消息版本号
 */
- (void)setMessageVersionNumber:(NSInteger)versionNumber {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[userDefaults dictionaryForKey:YM_MESSAGE_VERSION_NUMBER]];
    if (!dic) {
        dic = [NSMutableDictionary dictionary];
    }
    [dic setObject:[NSNumber numberWithInteger:versionNumber] forKey:[[YYIMConfig sharedInstance] getFullUser]];
    [userDefaults setObject:dic forKey:YM_MESSAGE_VERSION_NUMBER];
    [userDefaults synchronize];
}

/**
 *  清空消息版本号
 */
- (void)clearMessageVersionNumbers {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:YM_MESSAGE_VERSION_NUMBER];
    [userDefaults synchronize];
}

/**
 *  群组版本号
 *
 *  @return 群组版本号
 */
- (NSNumber *)getChatGroupVersionNumber {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userDefaults dictionaryForKey:YM_CHATGROUP_VERSION_NUMBER];
    NSNumber *versionNumber = [dic objectForKey:[[YYIMConfig sharedInstance] getFullUser]];
    if (!versionNumber) {
        versionNumber = [NSNumber numberWithLongLong:0];
    }
    return versionNumber;
}

/**
 *  设置群组版本号
 *
 *  @param versionNumber 群组版本号
 */
- (void)setChatGroupVersionNumber:(NSNumber *)versionNumber {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[userDefaults dictionaryForKey:YM_CHATGROUP_VERSION_NUMBER]];
    if (!dic) {
        dic = [NSMutableDictionary dictionary];
    }
    [dic setObject:versionNumber forKey:[[YYIMConfig sharedInstance] getFullUser]];
    [userDefaults setObject:dic forKey:YM_CHATGROUP_VERSION_NUMBER];
    [userDefaults synchronize];
}

/**
 *  清空群组版本号
 */
- (void)clearChatGroupVersionNumbers {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:YM_CHATGROUP_VERSION_NUMBER];
    [userDefaults synchronize];
}

/**
 *  用户信息显示设置
 *
 *  @return 用户信息显示设置
 */
- (NSArray *)getUserSetting {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%@.%@", YM_VCARD_SETTING, [[YYIMConfig sharedInstance] getAppKey], [[YYIMConfig sharedInstance] getEtpKey]];
    return [userDefaults objectForKey:key];
}

/**
 *  用户信息显示设置
 *
 *  @param userSetting 用户信息显示设置
 */
- (void)setUserSetting:(NSArray *)userSetting {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%@.%@", YM_VCARD_SETTING, [[YYIMConfig sharedInstance] getAppKey], [[YYIMConfig sharedInstance] getEtpKey]];
    [userDefaults setObject:userSetting forKey:key];
    [userDefaults synchronize];
}

/**
 *  好友模式是否为收藏
 *
 *  @return 好友模式是否为收藏
 */
- (BOOL)isRosterCollect {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:YM_IS_ROSTER_COLLECT];
}

/**
 *  设置好友模式
 *
 *  @param isCollect 是否收藏
 */
- (void)setRosterCollect:(BOOL)isCollect {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isCollect forKey:YM_IS_ROSTER_COLLECT];
    [userDefaults synchronize];
}

/**
 *  群组模式是否为增量
 *
 *  @return 群组模式是否为增量
 */
- (BOOL)isChatGroupVersion {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:YM_IS_CHATGROUP_VERSION];
}

/**
 *  设置群组模式
 *
 *  @param isVersion 是否增量
 */
- (void)setChatGroupVersion:(BOOL)isVersion {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isVersion forKey:YM_IS_CHATGROUP_VERSION];
    [userDefaults synchronize];
}

/**
 *  是否强制同步同端消息
 *
 *  @return 是否强制同步同端消息
 */
- (BOOL)isForceMessageSync {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:YM_IS_FORCE_MESSAGE_SYNC];
}

/**
 *  设置是否强制同步同端消息
 *
 *  @param isForce 是否强制同步同端消息
 */
- (void)setForceMessageSync:(BOOL)isForce {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isForce forKey:YM_IS_FORCE_MESSAGE_SYNC];
    [userDefaults synchronize];
}

#pragma mark -
#pragma mark REST -

#pragma mark DeviceToken

/**
 *  iOS DeviceToken Servlet
 *
 *  @return iOS DeviceToken Servlet
 */
- (NSString *)getDeviceTokenServlet {
    NSString *servlet = DEFAULT_DEVICETOKEN_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    return servlet;
}

/**
 *  Password Servlet
 *
 *  @return Password Servlet
 */
- (NSString *)getPasswordServlet {
    if ([YYIMStringUtility isEmpty:[self getUser]]) {
        YYIMLogError(@"unexpected empty user when getPasswordServlet");
        return nil;
    }
    
    NSString *servlet = DEFAULT_PASSWORD_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{username}" withString:[self getUser]];
    return servlet;
}

/**
 *  测试用TokenServlet
 *
 *  @return 测试用TokenServlet
 */
- (NSString *)getDemoTokenServlet {
    NSString *servlet = DEFAULT_DEMO_TOKEN_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    return servlet;
}

/**
 *  消息版本号Servlet
 *
 *  @param subpath 子路径
 *
 *  @return 消息版本号Servlet
 */
- (NSString *)getVersionServlet:(NSString *)subpath {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getVersionServlet:%@", subpath);
        return nil;
    }
    
    NSString *servlet = DEFAULT_VERSION_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{username}" withString:user];
    if (subpath.length > 0) {
        servlet = [servlet stringByAppendingString:@"/"];
        servlet = [servlet stringByAppendingString:subpath];
    }
    return servlet;
}

/**
 *  群组消息版本号Servlet
 *
 *  @return 群组消息版本号Servlet
 */
- (NSString *)getMUCVersionServlet {
    NSString *servlet = DEFAULT_MUC_VERSION_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    return servlet;
}

#pragma mark Tele Conference

/**
 *  嘟嘟AccountIdentify
 *
 *  @return 嘟嘟AccountIdentify
 */
- (NSString *)getDuduAccountIdentify {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:YM_DUDU_ACCOUNTIDENTIFY];
}

/**
 *  设置嘟嘟AccountIdentify
 *
 *  @param accountIdentify 嘟嘟AccountIdentify
 */
- (void)setDuduAccountIdentify:(NSString *)accountIdentify {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:accountIdentify forKey:YM_DUDU_ACCOUNTIDENTIFY];
    [userDefaults synchronize];
}

/**
 *  嘟嘟Appkeytemp
 *
 *  @return 嘟嘟Appkeytemp
 */
- (NSString *)getDuduAppkeytemp {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:YM_DUDU_APPKEYTEMP];
}

/**
 *  设置嘟嘟Appkeytemp
 *
 *  @param appkeytemp 嘟嘟Appkeytemp
 */
- (void)setDuduAppkeytemp:(NSString *)appkeytemp {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:appkeytemp forKey:YM_DUDU_APPKEYTEMP];
    [userDefaults synchronize];
}

/**
 *  嘟嘟创建会议Servlet
 *
 *  @return 嘟嘟创建会议Servlet
 */
- (NSString *)getDuduCreateConferenceServlet {
    return DEFAULT_DUDU_CREATE_CONFERENCE;
}

/**
 *  电话会议接口
 *
 *  @return 电话会议接口
 */
- (NSString *)getTeleConfereneServlet {
    NSString *servlet = DEFAULT_TELECONFERENCE_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    return servlet;
}

#pragma mark MUC QRCode

/**
 *  群组二维码生成Servlet
 *
 *  @return 群组二维码生成Servlet
 */
- (NSString *)getMucQrCodeServlet {
    NSString *servlet = DEFAULT_MUCQRCODE_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    return servlet;
}

/**
 *  群组二维码详情Servlet
 *
 *  @return 群组二维码详情Servlet
 */
- (NSString *)getMucQrCodeInfoServlet {
    NSString *servlet = DEFAULT_MUCQRCODE_INFO_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    return servlet;
}

#pragma mark Net Meeting

/**
 *  视频会议动态KeyServlet
 *
 *  @return 视频会议动态KeyServlet
 */
- (NSString *)getNetMeetingKeyServlet {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getNetMeetingKeyServlet");
        return nil;
    }
    
    NSString *servlet = DEFAULT_NETMEETING_KEY_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{userId}" withString:user];
    return servlet;
}

/**
 *  视频会议Servlet
 *
 *  @return 视频会议Servlet
 */
- (NSString *)getNetMeetingInfoServlet {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getNetMeetingInfoServlet");
        return nil;
    }
    
    NSString *servlet = DEFAULT_NETMEETING_INFO_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{userId}" withString:user];
    return servlet;
}

/**
 *  视频会议详情Servlet
 *
 *  @param channelId 视频会议频道ID
 *
 *  @return 视频会议详情Servlet
 */
- (NSString *)getNetMeetingDetailServlet:(NSString *)channelId {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getNetMeetingInfoServlet");
        return nil;
    }
    
    NSString *servlet = DEFAULT_NETMEETING_DETAIL_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{userId}" withString:user];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{channelId}" withString:channelId];
    return servlet;
}

/**
 *  视频会议预约Servlet
 *
 *  @return 视频会议预约Servlet
 */
- (NSString *)getNetMeetingReservationServlet {
    NSString *servlet = DEFAULT_NETMEETING_RESERVATION_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    return servlet;
}

/**
 *  视频会议删除Servlet
 *
 *  @param channelId 视频会议频道ID
 *
 *  @return 视频会议删除Servlet
 */
- (NSString *)getNetMeetingRemoveServlet:(NSString *)channelId {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getNetMeetingRemoveServlet:%@", channelId);
        return nil;
    }
    
    NSString *servlet = DEFAULT_NETMEETING_REMOVE_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{userId}" withString:user];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{channelId}" withString:channelId];
    return servlet;
}

/**
 *  视频会议取消预约Servlet
 *
 *  @param channelId 视频会议频道ID
 *
 *  @return 视频会议取消预约Servlet
 */
- (NSString *)getNetMeetingCancelReservationServlet:(NSString *)channelId {
    NSString *servlet = DEFAULT_NETMEETING_CANCEL_RESERVATION_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{channelId}" withString:channelId];
    return servlet;
}

/**
 *  视频会议预约邀请Servlet
 *
 *  @return 视频会议预约邀请Servlet
 */
- (NSString *)getNetMeetingReservationInviteServlet {
    NSString *servlet = DEFAULT_NETMEETING_RESERVATION_INVITE_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    return servlet;
}

/**
 *  视频会议预约踢人Servlet
 *
 *  @param channelId 视频会议频道ID
 *
 *  @return 视频会议预约踢人Servlet
 */
- (NSString *)getNetMeetingReservationKickServlet:(NSString *)channelId {
    NSString *servlet = DEFAULT_NETMEETING_RESERVATION_KICK_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{channelId}" withString:channelId];
    return servlet;
}

#pragma mark Message Revoke

/**
 *  群组消息撤回
 *
 *  @param packetId 消息ID
 *
 *  @return 群组消息撤回
 */
- (NSString *)getGroupMessageRevokeServlet:(NSString *)packetId {
    NSString *servlet = DEFAULT_GROUP_MESSAGE_REVOKE_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{packetId}" withString:packetId];
    return servlet;
}

/**
 *  个人消息撤回
 *
 *  @param packetId 消息ID
 *
 *  @return 个人消息撤回
 */
- (NSString *)getPersonalMessageRevokeServlet:(NSString *)packetId {
    NSString *servlet = DEFAULT_PERSONAL_MESSAGE_REVOKE_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{packetId}" withString:packetId];
    return servlet;
}

#pragma mark Group Member

/**
 *  获取群组成员的列表Servlet
 *
 *  @param groupId 群组ID
 *
 *  @return 获取群组成员的列表Servlet
 */
- (NSString *)getChatGroupMembersServlet:(NSString *)groupId {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getChatGroupMembersServlet");
        return nil;
    }
    
    NSString *servlet = DEFAULT_CHATGROUP_MEMBER_LIST_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{userId}" withString:user];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{roomId}" withString:groupId];
    return servlet;
}

#pragma mark Message File

/**
 *  单聊文件列表Servlet
 *
 *  @param chatId 用户ID
 *
 *  @return 单聊文件列表Servlet
 */
- (NSString *)getMessageFileChatListServlet:(NSString *)chatId {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getMessageFileChatListServlet");
        return nil;
    }
    
    NSString *servlet = DEFAULT_MESSAGE_FILE_CHAT_LIST_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{userId}" withString:user];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{chatId}" withString:chatId];
    return servlet;
}

/**
 *  单聊文件搜索Servlet
 *
 *  @param chatId 用户ID
 *
 *  @return 单聊文件搜索Servlet
 */
- (NSString *)getMessageFileChatSearchServlet:(NSString *)chatId {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getMessageFileChatSearchServlet");
        return nil;
    }
    
    NSString *servlet = DEFAULT_MESSAGE_FILE_CHAT_SEARCH_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{userId}" withString:user];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{chatId}" withString:chatId];
    return servlet;
}

/**
 *  群聊文件列表Servlet
 *
 *  @param groupId 群组ID
 *
 *  @return 群聊文件列表Servlet
 */
- (NSString *)getMessageFileChatGroupListServlet:(NSString *)groupId {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getMessageFileChatGroupListServlet");
        return nil;
    }
    
    NSString *servlet = DEFAULT_MESSAGE_FILE_CHATGROUP_LIST_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{userId}" withString:user];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{roomId}" withString:groupId];
    return servlet;
}

/**
 *  群聊文件搜索Servlet
 *
 *  @param groupId 群组ID
 *
 *  @return 群聊文件列表Servlet
 */
- (NSString *)getMessageFileChatGroupSearchServlet:(NSString *)groupId {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getMessageFileChatGroupSearchServlet");
        return nil;
    }
    
    NSString *servlet = DEFAULT_MESSAGE_FILE_CHATGROUP_SEARCH_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{userId}" withString:user];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{roomId}" withString:groupId];
    return servlet;
}

#pragma mark PubAccount Menu

/**
 *  获取公共号菜单
 *
 *  @param accountId 公共号ID
 *
 *  @return 获取公共号菜单
 */
- (NSString *)getPubAccountMenuServlet:(NSString *)accountId {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getPubAccountMenuServlet");
        return nil;
    }
    
    NSString *servlet = DEFAULT_PUBACCOUNT_MENU_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{userId}" withString:user];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{pubId}" withString:accountId];
    return servlet;
}

/**
 *  获取公共号推送命令的菜单
 *
 *  @param accountId 公共号ID
 *
 *  @return 获取公共号推送命令的菜单
 */
- (NSString *)getPubAccountMenuCommandServlet:(NSString *)accountId {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getPubAccountMenuCommandServlet");
        return nil;
    }
    
    NSString *servlet = DEFAULT_PUBACCOUNT_MENU_COMMAND_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{userId}" withString:user];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{pubId}" withString:accountId];
    return servlet;
}

#pragma mark UserTag & RosterTag

/**
 *  设置用户的tag
 *
 *  @return 设置用户的tag
 */
- (NSString *)getUserTagAddServlet {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getUserTagAddServlet");
        return nil;
    }
    
    NSString *servlet = DEFAULT_USER_TAG_ADD_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{userId}" withString:user];
    return servlet;
}

/**
 *  删除用户的tag
 *
 *  @return 删除用户的tag
 */
- (NSString *)getUserTagDeleteServlet {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getUserTagAddServlet");
        return nil;
    }
    
    NSString *servlet = DEFAULT_USER_TAG_DELETE_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{userId}" withString:user];
    return servlet;
}

/**
 *  设置好友的tag
 *
 *  @param rosterId 好友ID
 *
 *  @return 设置好友的tag
 */
- (NSString *)getRosterTagAddServlet:(NSString *)rosterId {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getUserTagAddServlet");
        return nil;
    }
    
    NSString *servlet = DEFAULT_ROSTER_TAG_ADD_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{userId}" withString:user];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{rosterId}" withString:rosterId];
    return servlet;
}

/**
 *  删除好友的tag
 *
 *  @param rosterId 好友ID
 *
 *  @return 删除好友的tag
 */
- (NSString *)getRosterTagDeleteServlet:(NSString *)rosterId {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getUserTagAddServlet");
        return nil;
    }
    
    NSString *servlet = DEFAULT_ROSTER_TAG_DELETE_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{userId}" withString:user];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{rosterId}" withString:rosterId];
    return servlet;
}

#pragma mark UserProfile

/**
 *  用户设置接口
 *
 *  @return 用户设置接口
 */
- (NSString *)getUserProfileServlet {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getUserTagAddServlet");
        return nil;
    }
    
    NSString *servlet = DEFAULT_USER_PROFILE_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{userId}" withString:user];
    return servlet;
}

/**
 *  用户设置免打扰接口
 *
 *  @return 用户设置免打扰接口
 */
- (NSString *)getUserProfileMuteServlet {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getUserTagAddServlet");
        return nil;
    }
    
    NSString *servlet = DEFAULT_USER_PROFILE_MUTE_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{userId}" withString:user];
    return servlet;
}

/**
 *  用户设置置顶接口
 *
 *  @return 用户设置置顶接口
 */
- (NSString *)getUserProfileStickServlet {
    NSString *user = [self getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        YYIMLogError(@"unexpected empty user when getUserTagAddServlet");
        return nil;
    }
    
    NSString *servlet = DEFAULT_USER_PROFILE_STICK_SERVLET;
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{scheme}" withString:[self getIMRestServerScheme]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{restServer}" withString:[self getIMRestServer]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{etpId}" withString:[self getEtpKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{appId}" withString:[self getAppKey]];
    servlet = [servlet stringByReplacingOccurrencesOfString:@"{userId}" withString:user];
    return servlet;
}

@end
