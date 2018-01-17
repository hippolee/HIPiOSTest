//
//  JUMPPacket.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JUMPJID.h"
#import "JUMPHeader.h"

// 0001|AuthPacket|登录报文|1.0~
static const Byte JUMPAuthPacketOpCode[] = {0x00, 0x01};

// 0002|PingPacket|Ping报文|1.0~
static const Byte JUMPPingPacketOpCode[] = {0x00, 0x02};

// 0004|StreamEndPacket|连接关闭报文|1.0~
static const Byte JUMPStreamEndPacketOpCode[] = {0x00, 0x04};

// 3001|PresencePacket|在线状态报文|1.0~
static const Byte JUMPPresencePacketOpCode[] = {0x30, 0x01};

// 2021|IQResultPacket|IQ结果通知报文|1.0~
static const Byte JUMPIQResultPacketOpCode[] = {0x20, 0x21};

#pragma mark message
// 1002|MessageReceiptsPacket|消息回执报文|1.0~
static const Byte JUMPMessageReceiptsPacketOpCode[] = {0x10, 0x02};

// 1003|MessageNotifyPacket|未读消息通知报文|1.0~
static const Byte JUMPMessageNotifyPacketOpCode[] = {0x10, 0x03};

// 1010|MessagePacket|单聊消息报文|1.0~
static const Byte JUMPMessagePacketOpCode[] = {0x10, 0x10};
// 1030|MUCMessagePacket|群聊消息报文1.0~
static const Byte JUMPMUCMessagePacketOpCode[] = {0x10, 0x30};
// 1050|PubAccountMessagePacket|公共号消息报文1.0~
static const Byte JUMPPubAccountMessagePacketOpCode[] = {0x10, 0x50};
// 1070|MessageCarbonPacket|消息发送同步报文2.2~
static const Byte JUMPMessageCarbonPacketOpCode[] = {0x10, 0x70};

// 1301|MessageMUCInvitePacket|群组邀请报文|1.0~2.1
__deprecated static const Byte JUMPMessageMUCInvitePacketOpCode[] = {0x13, 0x01}; DEPRECATED_ATTRIBUTE

// 1510|PrivacyPacket|黑名单设置报文|2.3~|未支持
static const Byte JUMPPrivacyPacketOpCode[] = {0x15, 0x10};

#pragma mark vcard
// 2011|VCardPacket|用户信息报文|1.0~
static const Byte JUMPVCardPacketOpCode[] = {0x20, 0x11};
// 2012|RosterVCardsPacket|群组用户信息报文|1.0~
static const Byte JUMPRosterVCardsPacketOpCode[] = {0x20, 0x12};

// 2013|VcardVersionRequestPacket|用户信息请求报文，有时间戳|2.3~
static const Byte JUMPVcardVersionRequestPacketOpCode[] = {0x20, 0x13};
// 2014|VcardVersionResultPacket|用户信息请求结果报文，有时间戳|2.3~
static const Byte JUMPVcardVersionResultPacketOpCode[] = {0x20, 0x14};

// 2110|UserSearchRequestPacket|用户搜索报文|1.0~
static const Byte JUMPUserSearchRequestPacketOpCode[] = {0x21, 0x10};
// 2111|UserSearchResultPacket|用户搜索结果报文|1.0~
static const Byte JUMPUserSearchResultPacketOpCode[] = {0x21, 0x11};

#pragma mark roster
// 2220|RosterItemsRequestPacket|好友列表请求报文|1.0~
static const Byte JUMPRosterItemsRequestPacketOpCode[] = {0x22, 0x20};
// 2221|RosterItemsResultPacket|好友列表结果报文|1.0~
static const Byte JUMPRosterItemsResultPacketOpCode[] = {0x22, 0x21};

// 2520|RosterPacket|好友报文|1.0~
static const Byte JUMPRosterPacketOpCode[] = {0x25, 0x20};

// 2521|FavoritedRosterPacket|好友收藏报文|2.2~
static const Byte JUMPFavoritedRosterPacketOpCode[] = {0x25, 0x21};

#pragma mark muc
// 2230|MUCItemsRequestPacket|群组列表请求报文|1.0~
static const Byte JUMPMUCItemsRequestPacketOpCode[] = {0x22, 0x30};
// 2231|MUCItemsResultPacket|群组列表结果报文|1.0~
static const Byte JUMPMUCItemsResultPacketOpCode[] = {0x22, 0x31};

// 2232|MUCVersionItemsRequestPacket|增量群组列表请求报文|2.2~
static const Byte JUMPMUCVersionItemsRequestPacketOpCode[] = {0x22, 0x32};
// 2233|MUCVersionItemsResultPacket|增量群组列表结果报文|2.2~
static const Byte JUMPMUCVersionItemsResultPacketOpCode[] = {0x22, 0x33};

// 2330|MUCInfoRequestPacket|群组信息请求报文|1.0~|未支持
static const Byte JUMPMUCInfoRequestPacketOpCode[] = {0x23, 0x30};
// 2331|MUCInfoResultPacket|群组信息结果报文|1.0~|未支持
static const Byte JUMPMUCInfoResultPacketOpCode[] = {0x23, 0x31};

// 2332|MUCFilesRequestPacket|群组文件列表请求报文|1.0~|未支持
static const Byte JUMPMUCFilesRequestPacketOpCode[] = {0x23, 0x32};
// 2333|MUCFilesResultPacket|群组文件列表结果报文|1.0~|未支持
static const Byte JUMPMUCFilesResultPacketOpCode[] = {0x23, 0x33};

// 2240|MUCMemberItemsRequestPacket|群组成员请求报文|1.0~|未支持
static const Byte JUMPMUCMemberItemsRequestPacketOpCode[] = {0x22, 0x40};
// 2241|MUCMemberItemsResultPacket|群组成员结果报文|1.0~|未支持
static const Byte JUMPMUCMemberItemsResultPacketOpCode[] = {0x22, 0x41};

// 2130|MUCSearchRequestPacket|群组搜索报文|1.0~
static const Byte JUMPMUCSearchRequestPacketOpCode[] = {0x21, 0x30};
// 2131|MUCSearchResultPacket|群组搜索结果报文|1.0~
static const Byte JUMPMUCSearchResultPacketOpCode[] = {0x21, 0x31};

// 3301|PresenceMUCPacket|加入群组请求报文|1.0~2.1
static const Byte JUMPPresenceMUCPacketOpCode[] = {0x33, 0x01};
// 3302|PresenceMUCNotifyPacket|群组成员加入通知报文|1.0~2.1|仅接收
__deprecated static const Byte JUMPPresenceMUCNotifyPacketOpCode[] = {0x33, 0x02};

// 2530|MUCModifyPacket|修改群组请求报文|1.0~2.1
__deprecated static const Byte JUMPMUCModifyPacketOpCode[] = {0x25, 0x30};

// 2532|MUCCreatePacket|创建群组请求报文|2.1~
static const Byte JUMPMUCCreatePacketOpCode[] = {0x25, 0x32};
// 2533|MUCInvitePacket|邀请用户加入群组报文|2.1~
static const Byte JUMPMUCInvitePacketOpCode[] = {0x25, 0x33};
// 2534|MUCInfoModifyPacket|修改群组信息请求报文|2.1~
static const Byte JUMPMUCInfoModifyPacketOpCode[] = {0x25, 0x34};
// 2535|MUCKickOutMemberPacket|群组踢人报文|2.1~
static const Byte JUMPMUCKickOutMemberPacketOpCode[] = {0x25, 0x35};
// 2536|MUCMemberExitPacket|群成员退群报文|2.1~
static const Byte JUMPMUCMemberExitPacketOpCode[] = {0x25, 0x36};
// 2537|MUCCollectPacket|群组收藏报文|2.2~
static const Byte JUMPMUCCollectPacketOpCode[] = {0x25, 0x37};
// 2538|MUCDismissPacket|群组解散报文|2.3~
static const Byte JUMPMUCDismissPacketOpCode[] = {0x25, 0x38};
// 2539|MUCRoleConversionPacket|群组指定新的owner报文，由群中owner发送|2.3~
static const Byte JUMPMUCRoleConversionPacketOpCode[] = {0x25, 0x39};
// 2540|MUCFaceOperatePacket|面对面建群操作报文|2.6~
static const Byte JUMPMUCFaceOperatePacketOpCode[] = {0x25, 0x40};
// 2541|MUCFaceNotifyPacket|面对面建群通知报文|2.6~
static const Byte JUMPMUCFaceNotifyPacketOpCode[] = {0x25, 0x41};

// 2336|MUCRoleConversionResultPacket|群组指定owner结果报文|2.3~
static const Byte JUMPMUCRoleConversionResultPacketOpCode[] = {0x23, 0x36};
// 2334|MUCDetailInfoResultPacket|群组操作结果详细信息报文|2.1~
static const Byte JUMPMUCDetailInfoResultPacketOpCode[] = {0x23, 0x34};
// 2335|MUCOperateResultPacket|群成员离开群组通知报文|2.1~
static const Byte JUMPMUCOperateResultPacketOpCode[] = {0x23, 0x35};

#pragma mark pubaccount
// 2250|PubAccountRequestItemsPacket|公共号列表请求报文|1.0~
static const Byte JUMPPubAccountRequestItemsPacketOpCode[] = {0x22, 0x50};
// 2251|PubaccountItemsResultPacket|公共号列表结果报文|1.0~
static const Byte JUMPPubaccountItemsResultPacketOpCode[] = {0x22, 0x51};

// 2150|PubaccountSearchRequestPacket|公共号搜索报文|1.0~
static const Byte JUMPPubaccountSearchRequestPacketOpCode[] = {0x21, 0x50};
// 2151|PubaccountSearchResultPacket|公共号搜索结果报文|1.0~
static const Byte JUMPPubaccountSearchResultPacketOpCode[] = {0x21, 0x51};

#pragma mark org
// 2260|OrgItemsRequestPacket|组织请求报文|1.0~
static const Byte JUMPOrgItemsRequestPacketOpCode[] = {0x22, 0x60};
// 2261|OrgItemsResultPacket|组织请求结果报文|1.0~
static const Byte JUMPOrgItemsResultPacketOpCode[] = {0x22, 0x61};

#pragma mark attachment
// 2270|AttachmentRequestPacket|附件列表请求报文|1.0~
static const Byte JUMPAttachmentRequestPacketOpCode[] = {0x22, 0x70};
// 2271|AttachmentResultPacket|附件列表结果报文|1.0~
static const Byte JUMPAttachmentResultPacketOpCode[] = {0x22, 0x71};

// 2170|AttachmentSearchPacket|附件查找报文|1.0~
static const Byte JUMPAttachmentSearchPacketOpCode[] = {0x21, 0x70};
// 2171|AttachmentSearchResultPacket|附件查找结果报文|1.0~
static const Byte JUMPAttachmentSearchResultPacketOpCode[] = {0x21, 0x71};

// 2571|AttachmentOperationPacket|附件操作报文|1.0~
static const Byte JUMPAttachmentOperationPacketOpCode[] = {0x25, 0x71};
// 2572|DirectoryOperationPacket|目录操作报文|1.0~
static const Byte JUMPDirectoryOperationPacketOpCode[] = {0x25, 0x72};
// 2573|OperationResultPacket|文件或目录的操作结果报文|1.0~
static const Byte JUMPOperationResultPacketOpCode[] = {0x25, 0x73};

#pragma mark netmeeting
// 2880|NETMeetingCreatePacket|视频会议创建报文|2.4~
static const Byte JUMPNetMeetingCreatePacketOpCode[] = {0x28, (Byte)0x80};
// 2881|NETMeetingNotifyPacket|视频会议操作结果通知报文|2.4~
static const Byte JUMPNetMeetingNotifyPacketOpCode[] = {0x28, (Byte)0x81};
// 2882|NETMeetingManagePacket|视频会议的管理报文|2.4~
static const Byte JUMPNetMeetingManagePacketOpCode[] = {0x28, (Byte)0x82};
// 2884|NETMeetingBillPacket|视频会议的计费报文|2.4~
static const Byte JUMPNetMeetingBillPacketOpCode[] = {0x28, (Byte)0x84};

#pragma mark online deliver
// 1110|MucOnlineDeliverPacket|发送给群组成员的在线透传报文|2.6~
static const Byte JUMPMucOnlineDeliverPacketOpCode[] = {0x11, 0x10};
// 1130|PubOnlineDeliverPacket|发送给公共号成员的在线透传报文|2.6~
static const Byte JUMPPubOnlineDeliverPacketOpCode[] = {0x11, 0x30};
// 1150|UserOnlineDeliverPacket|发送给用户的在线透传报文|2.6~
static const Byte JUMPUserOnlineDeliverPacketOpCode[] = {0x11, 0x50};
// 1160|UserProfileOnlineDeliverPacket|发送给用户的profile相关在线透传报文|2.6~
static const Byte JUMPUserProfileOnlineDeliverPacketOpCode[] = {0x11, 0x60};

#pragma mark error
// 客户端仅接收
// 0x4000 ErrorPacket 一般报文错误，服务器不会断开连接
// 0x4100 StreamErrorPacket	流错误报文，服务器随后会关闭连接

#pragma mark sync
// 暂不考虑支持
// 0x2720 RosterSyncPacket 同步好友报文
// 0x2722 RosterIncrementalSyncPacket 增量同步好友
// 0x2730 MUCSyncPacket	同步群组报文
// 0x2732 MUCIncrementalSyncPacket 增量同步群组报文

#pragma mark sip
// 废弃
// 0x5001 SIPInitiatePacket 客户端发起SIP请求报文
// 0x5002 SIPInvitePacket 服务器通知客户端SIP请求报文
// 0x5003 SIPResponsePacket 客户端响应服务器的邀请，或服务器转发来自客户端的回应给发起者

/**
 * The JUMPPacket provides the base class for JUMPIQ, JUMPMessage & JUMPPresence.
 **/
@interface JUMPPacket : NSObject<NSCoding, NSCopying>

#pragma mark Common Methods

/**
 *  报文ID
 *
 *  @return NSString
 */
- (NSString *)packetID;

/**
 *  设置报文ID
 *
 *  @param packetID NSString
 */
- (void)setPacketID:(NSString *)packetID;

/**
 *  报文接收者
 *
 *  @return JUMPJID
 */
- (JUMPJID *)to;

/**
 *  报文接收者
 *
 *  @return NSString
 */
- (NSString *)toStr;

/**
 *  设置报文接收者
 *
 *  @param toJid JUMPJID
 */
- (void)setTo:(JUMPJID *)toJid;

/**
 *  报文发送者
 *
 *  @return JUMPJID
 */
- (JUMPJID *)from;

/**
 *  报文发送者
 *
 *  @return NSString
 */
- (NSString *)fromStr;

/**
 *  设置报文发送者
 *
 *  @param fromJid JUMPJID
 */
- (void)setFrom:(JUMPJID *)fromJid;

#pragma mark jump

/**
 *  根据操作码初始化
 *
 *  @param opData 操作码NSData
 *
 *  @return instance
 */
- (instancetype)initWithOpData:(NSData *)opData;

/**
 *  根据报文体和报文头初始化对象（自动压缩判断）
 *
 *  @param data   报文体NSData
 *  @param header 报文头NSData
 *  @param error  error
 *
 *  @return instance
 */
- (instancetype)initWithBodyData:(NSData *)data header:(JUMPHeader *)header error:(NSError **)error;

/**
 *  操作码Data
 *
 *  @return NSData
 */
- (NSData *)opData;

/**
 *  完整报文Data
 *
 *  @return NSData
 */
- (NSData *)packetData;

/**
 *  完整报文Data（gzip压缩）
 *
 *  @return NSData
 */
- (NSData *)gzipPacketData;

/**
 *  报文头Data
 *
 *  @return NSData
 */
- (NSData *)headerData;

/**
 *  报文体Data
 *
 *  @return NSData
 */
- (NSData *)jsonData;

/**
 *  报文体Data（gzip压缩）
 *
 *  @return NSData
 */
- (NSData *)gzipBodyData;

/**
 *  报文体JsonString
 *
 *  @return NSString
 */
- (NSString *)jsonString;

/**
 *  设置报文数据
 *
 *  @param anObject 数据对象
 *  @param aKey     数据Key
 */
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;

/**
 *  根据数据Key获取报文数据
 *
 *  @param aKey 数据Key
 *
 *  @return 数据对象
 */
- (id)objectForKey:(id)aKey;

/**
 *  批量设置报文数据
 *
 *  @param otherDictionary 报文数据
 */
- (void)setDictionary:(NSDictionary *)otherDictionary;

#pragma mark To and From Methods

- (BOOL)isTo:(JUMPJID *)to;
- (BOOL)isTo:(JUMPJID *)to options:(JUMPJIDCompareOptions)mask;

- (BOOL)isFrom:(JUMPJID *)from;
- (BOOL)isFrom:(JUMPJID *)from options:(JUMPJIDCompareOptions)mask;

- (BOOL)isToOrFrom:(JUMPJID *)toOrFrom;
- (BOOL)isToOrFrom:(JUMPJID *)toOrFrom options:(JUMPJIDCompareOptions)mask;

- (BOOL)isTo:(JUMPJID *)to from:(JUMPJID *)from;
- (BOOL)isTo:(JUMPJID *)to from:(JUMPJID *)from options:(JUMPJIDCompareOptions)mask;

#pragma mark judge

/**
 *  是否认证报文
 *
 *  @return BOOL
 */
- (BOOL)isAuthPacket;

/**
 *  是否Ping报文
 *
 *  @return BOOL
 */
- (BOOL)isPingPacket;

/**
 *  是否IQ报文
 *
 *  @return BOOL
 */
- (BOOL)isIqPacket;

/**
 *  是否Message报文
 *
 *  @return BOOL
 */
- (BOOL)isMessagePacket;

/**
 *  是否Presence报文
 *
 *  @return BOOL
 */
- (BOOL)isPresencePacket;

/**
 *  是否错误报文
 *
 *  @return BOOL
 */
- (BOOL)isErrorPacket;

/**
 *  是否流错误
 *
 *  @return BOOL
 */
- (BOOL)isStreamError;

/**
 *  是否包错误
 *
 *  @return BOOL
 */
- (BOOL)isPacketError;

/**
 *  检查操作码
 *
 *  @param opData 操作码
 *
 *  @return BOOL
 */
- (BOOL)checkOpData:(NSData *)opData;

@end
