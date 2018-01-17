//
//  YYIMDBHeader.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/9.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#ifndef YonyouIMSdk_YYIMDBHeader_h
#define YonyouIMSdk_YYIMDBHeader_h

#pragma mark empty version

#define YYIM_DB_VERSION_EMPTY       -1

#pragma mark current version

#define YYIM_CURRENT_DB_VERSION     YYIM_DB_VERSION_2

#pragma mark version 0

#define YYIM_DB_VERSION_INITIAL     0

// 数据库信息表创建
#define YYIM_DBINFO_CREATE @"CREATE TABLE yyim_dbinfo (version INTEGER)"
// 数据库信息表初始化
#define YYIM_DBINFO_INIT @"INSERT INTO yyim_dbinfo (version) VALUES (0)"

// 联系人表创建
#define YYIM_ROSTER_CREATE @"CREATE TABLE yyim_roster (pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT,roster_id TEXT,roster_alias TEXT,roster_photo TEXT)"
// 联系人表索引
#define YYIM_ROSTER_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_roster_unique ON yyim_roster(user_id,roster_id)"

// 消息表创建
#define YYIM_MESSAGE_CREATE @"CREATE TABLE yyim_message (pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,packet_id TEXT,self_id TEXT,roster_id TEXT,room_id TEXT,direction INTEGER,message TEXT,status INTEGER,download_status INTEGER,upload_status INTEGER,specific_status INTEGER,type INTEGER,chat_type TEXT,res_local TEXT,res_thumb_local TEXT,date INTEGER)"
// 消息表索引
#define YYIM_MESSAGE_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_message_unique ON yyim_message (packet_id,self_id,room_id)"

// 群组表创建
#define YYIM_CHATGROUP_CREATE @"CREATE TABLE yyim_chatgroup(pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT,chatgroup_id TEXT,chatgroup_name TEXT,chatgroup_photo TEXT)"
// 群组表索引
#define YYIM_CHATGROUP_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_chatgroup_unique ON yyim_chatgroup(user_id,chatgroup_id)"

// 群组成员表创建
#define YYIM_CHATGROUPMEMBER_CREATE @"CREATE TABLE yyim_chatgroup_member(pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT,chatgroup_id TEXT,member_id TEXT,member_name TEXT,member_photo TEXT)"
// 群组成员表索引
#define YYIM_CHATGROUPMEMBER_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_chatgroup_member_unique ON yyim_chatgroup_member(user_id,chatgroup_id,member_id)"

// 个人信息表创建
#define YYIM_USER_CREATE @"CREATE TABLE yyim_user(pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT,user_name TEXT,user_org TEXT,user_unit TEXT,user_desc TEXT,user_title TEXT,user_email TEXT,user_photo TEXT,user_mobile TEXT,last_update INTEGER)"
// 个人信息表索引
#define YYIM_USER_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_user_unique ON yyim_user(user_id)"

// 组织信息表创建
#define YYIM_ORG_CREATE @"CREATE TABLE yyim_org(pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,app_id TEXT,org_id TEXT,parent_id TEXT,org_name TEXT,is_leaf INTEGER,is_user INTEGER,user_email TEXT,user_photo TEXT)"
// 组织信息表索引
#define YYIM_ORG_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_org_unique ON yyim_org(app_id,org_id,parent_id)"

// 文件表创建
#define YYIM_FILE_CREATE @"CREATE TABLE yyim_file(pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT,file_set INTEGER,group_id TEXT, file_id TEXT,file_name TEXT,parent_dir_id TEXT,is_dir INTEGER,ts INTEGER,file_size INTEGER,file_creator TEXT,download_count INTEGER,create_date INTEGER)"
// ATTACH状态表
#define YYIM_ATTACH_STATE_CREATE @"CREATE TABLE yyim_attach_state(pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,attach_id TEXT,download_state INTEGER)"

// 视频会议表创建
#define YYIM_NETMEETING_CREATE @"CREATE TABLE yyim_netmeeting(pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT,channel_id TEXT,netmeeting_type INTEGER,netmeeting_mode INTEGER,inviter_id TEXT,dynamic_key TEXT,forbid_audio INTEGER,lock INTEGER,topic TEXT,create_time INTEGER)"
// 视频会议表索引
#define YYIM_NETMEETING_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_netmeeting_unique ON yyim_netmeeting(user_id,channel_id)"

// 视频会议成员表创建
#define YYIM_NETMEETING_MEMBER_CREATE @"CREATE TABLE yyim_netmeeting_member(pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT,channel_id TEXT,member_id TEXT,member_uid INTEGER,member_name TEXT,member_role TEXT,enable_video INTEGER,enable_audio INTEGER,forbid_audio INTEGER,invite_state INTEGER)"
// 视频会议成员表索引
#define YYIM_NETMEETING_MEMBER_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_netmeeting_member_unique ON yyim_netmeeting_member(user_id,channel_id,member_id)"

// 视频会议通知表创建
#define YYIM_NETMEETING_NOTIFY_CREATE @"CREATE TABLE yyim_netmeeting_notify(pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,self_id TEXT,channel_id TEXT,topic TEXT,state INTEGER,create_time INTEGER,moderator TEXT,netmeeting_type INTEGER,talk_time INTEGER,date INTEGER)"

// 视频会议通知表索引
#define YYIM_NETMEETING_NOTIFY_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_netmeeting_notify_unique ON yyim_netmeeting_notify(self_id,channel_id,state)"

// 消息表临时表创建，用于更新keyinfo
#define YYIM_MESSAGE_TMP_CREATE @"CREATE TABLE yyim_message_tmp (pkid INTEGER PRIMARY KEY NOT NULL,message TEXT,type INTEGER,key_info TEXT)"
#define YYIM_MESSAGE_TMP_INIT @"insert into yyim_message_tmp select pkid,message,type,key_info from yyim_message where type in(2,4,16,32,128,256)"
#define YYIM_MESSAGE_TMP_DELETE @"DROP TABLE yyim_message_tmp"

#pragma mark version 1

#define YYIM_DB_VERSION_1       1

// 联系人表添加android在线状态
#define YYIM_ROSTER_ADD_ASTATE @"ALTER TABLE yyim_roster ADD android_state INTEGER"
// 联系人表添加ios在线状态
#define YYIM_ROSTER_ADD_ISTATE @"ALTER TABLE yyim_roster ADD ios_state INTEGER"
// 联系人表添加webim在线状态
#define YYIM_ROSTER_ADD_WSTATE @"ALTER TABLE yyim_roster ADD webim_state INTEGER"
// 联系人表添加desktop在线状态
#define YYIM_ROSTER_ADD_DSTATE @"ALTER TABLE yyim_roster ADD desktop_state INTEGER"

// 个人信息表扩展表
#define YYIM_USER_EXT_CREATE @"CREATE TABLE yyim_user_ext(user_id TEXT,ext_id TEXT,no_disturb INTEGER,stick_top INTEGER)"
// 个人信息表扩展表索引
#define YYIM_USER_EXT_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_user_ext_unique ON yyim_user_ext(user_id,ext_id)"
// 群组信息表扩展表
#define YYIM_CHATGROUP_EXT_CREATE @"CREATE TABLE yyim_chatgroup_ext(user_id TEXT,chatgroup_id TEXT,no_disturb INTEGER,stick_top INTEGER,show_name INTEGER)"
// 群组信息表扩展表索引
#define YYIM_CHATGROUP_EXT_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_chatgroup_ext_unique ON yyim_chatgroup_ext(user_id,chatgroup_id)"

// ATTACH状态表新增path
#define YYIM_ATTACH_STATE_ADD_PATH @"ALTER TABLE yyim_attach_state ADD path TEXT"

// 群组成员表新增appiliation
#define YYIM_CHATGROUPMEMBER_ADD_AFFILIATION @"ALTER TABLE yyim_chatgroup_member ADD affiliation TEXT"

// 会议通知增加创建者
#define YYIM_NETMEETING_NOTIFY_ADD_CREATER @"ALTER TABLE yyim_netmeeting_notify ADD creator TEXT"

#pragma mark version 2

#define YYIM_DB_VERSION_2       2

//公共号表创建
#define YYIM_PUBACCOUNT_CREATE @"CREATE TABLE yyim_pubaccount (pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT,account_id TEXT,account_name TEXT,account_photo TEXT)"
//公共号表索引
#define YYIM_PUBACCOUNT_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_pubaccount_unique ON yyim_pubaccount(user_id,account_id)"

//公共号扩展表
#define YYIM_PUBACCOUNT_EXT_CREATE @"CREATE TABLE yyim_pubaccount_ext(user_id TEXT,account_id TEXT,no_disturb INTEGER,stick_top INTEGER)"
//公共号扩展表索引
#define YYIM_PUBACCOUNT_EXT_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_pubaccount_ext_unique ON yyim_pubaccount_ext(user_id,account_id)"

// 好友邀请
#define YYIM_ROSTER_INVITE_CREATE @"CREATE TABLE yyim_roster_invite (pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT,from_id TEXT,date INTEGER,state INTEGER)"

// ATTACH状态表新增上传状态
#define YYIM_ATTACH_STATE_ADD_UPLOAD_STATE @"ALTER TABLE yyim_attach_state ADD upload_state INTEGER"
// ATTACH状态表新增MD5
#define YYIM_ATTACH_STATE_ADD_MD5 @"ALTER TABLE yyim_attach_state ADD mdfive TEXT"
// ATTACH状态表新增上传Key
#define YYIM_ATTACH_STATE_ADD_UPLOAD_KEY @"ALTER TABLE yyim_attach_state ADD upload_key TEXT"
// ATTACH状态表新增文件大小
#define YYIM_ATTACH_STATE_ADD_FILESIZE @"ALTER TABLE yyim_attach_state ADD file_size INTEGER"
// ATTACH状态表新增文件后缀
#define YYIM_ATTACH_STATE_ADD_FILE_EXT @"ALTER TABLE yyim_attach_state ADD file_ext TEXT"

// 会议通知增加是否等待预约会议
#define YYIM_NETMEETING_NOTIFY_ADD_WAITBEGIN @"ALTER TABLE yyim_netmeeting_notify ADD wait_begin INTEGER"
// 会议通知增加是否预约会议无效
#define YYIM_NETMEETING_NOTIFY_ADD_RESERVATION_END @"ALTER TABLE yyim_netmeeting_notify ADD reservation_end INTEGER"

#define YYIM_NETMEETING_ADD_CREATOR @"ALTER TABLE yyim_netmeeting ADD creator TEXT"

#pragma mark version 3

#define YYIM_DB_VERSION_3       3

// 个人信息表添加telephone
#define YYIM_USER_ADD_TELEPHONE @"ALTER TABLE yyim_user ADD user_telephone TEXT"
// 联系人表天假groups
#define YYIM_ROSTER_ADD_GROUPS @"ALTER TABLE yyim_roster ADD roster_groups TEXT"

// 会议通知表删除索引
#define YYIM_NETMEETING_NOTIFY_DELETE_INDEX @"DROP INDEX yyim_idx_netmeeting_notify_unique"

#pragma mark version 4

#define YYIM_DB_VERSION_4       4

// 消息标新增客户端类型
#define YYIM_MESSAGE_ADD_CLIENTTYPE @"ALTER TABLE yyim_message ADD client_type TEXT"

// 视频会议日历通知映射表创建
#define YYIM_NETMEETING_CALENDAR_CREATE @"CREATE TABLE yyim_netmeeting_calendar(pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,calendar_id TEXT,channel_id TEXT)"
// 视频会议日历通知映射表索引
#define YYIM_NETMEETING_CALENDAR_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_netmeeting_calendar_unique ON yyim_netmeeting_calendar(channel_id)"

#pragma mark version 5

#define YYIM_DB_VERSION_5       5

// 个人信息表新增orgid,性别,工号,办公地点字段
#define YYIM_USER_ADD_ORGID @"ALTER TABLE yyim_user ADD user_orgid TEXT"
#define YYIM_USER_ADD_GENDER @"ALTER TABLE yyim_user ADD user_gender TEXT"
#define YYIM_USER_ADD_NUMBER @"ALTER TABLE yyim_user ADD user_number TEXT"
#define YYIM_USER_ADD_LOCATION @"ALTER TABLE yyim_user ADD user_location TEXT"

#define YYIM_MESSAGE_ADD_RES_ORIGINAL_LOCAL @"ALTER TABLE yyim_message ADD res_original_local TEXT"

#pragma mark version 6

#define YYIM_DB_VERSION_6       6

//公共号表新增字段type
#define YYIM_PUBACCOUNT_ADD_TYPE @"ALTER TABLE yyim_pubaccount ADD account_type INTEGER"
#define YYIM_MESSAGE_ADD_ISAT @"ALTER TABLE yyim_message ADD isat INTEGER"

#pragma mark version 7

#define YYIM_DB_VERSION_7       7

#define YYIM_ROSTER_ADD_SUBSCRIPTION @"ALTER TABLE yyim_roster ADD subscription TEXT"
#define YYIM_ROSTER_ADD_ASK @"ALTER TABLE yyim_roster ADD ask INTEGER"
#define YYIM_ROSTER_ADD_RECV @"ALTER TABLE yyim_roster ADD recv INTEGER"

#pragma mark version 8

#define YYIM_DB_VERSION_8       8

#define YYIM_CHATGROUP_ADD_TAG @"ALTER TABLE yyim_chatgroup ADD chatgroup_tag TEXT"
#define YYIM_CHATGROUP_ADD_COLLECT @"ALTER TABLE yyim_chatgroup ADD chatgroup_collect INTEGER"

#pragma mark version 9

#define YYIM_DB_VERSION_9       9

#define YYIM_CHATGROUP_ADD_TAG2 @"ALTER TABLE yyim_chatgroup ADD chatgroup_tag2 TEXT"
#define YYIM_CHATGROUP_ADD_TAG3 @"ALTER TABLE yyim_chatgroup ADD chatgroup_tag3 TEXT"
#define YYIM_CHATGROUP_ADD_TAG4 @"ALTER TABLE yyim_chatgroup ADD chatgroup_tag4 TEXT"
#define YYIM_CHATGROUP_ADD_TAG5 @"ALTER TABLE yyim_chatgroup ADD chatgroup_tag5 TEXT"

#pragma mark version 10

#define YYIM_DB_VERSION_10      10

#define YYIM_CHATGROUP_ADD_ISSUPER @"ALTER TABLE yyim_chatgroup ADD is_super INTEGER"
#define YYIM_CHATGROUP_ADD_MEMBERCOUNT @"ALTER TABLE yyim_chatgroup ADD member_count INTEGER"
#define YYIM_MESSAGE_ADD_VERSION @"ALTER TABLE yyim_message ADD version INTEGER"
#define YYIM_MESSAGE_ADD_MUCVERSION @"ALTER TABLE yyim_message ADD muc_version INTEGER"

#pragma mark version 11

#define YYIM_DB_VERSION_11      11

#define YYIM_CHATGROUP_ADD_TS @"ALTER TABLE yyim_chatgroup ADD ts INTEGER"
#define YYIM_CHATGROUP_ADD_ISOWNER @"ALTER TABLE yyim_chatgroup ADD is_owner INTEGER"
#define YYIM_MESSAGE_ADD_CUSTOMTYPE @"ALTER TABLE yyim_message ADD custom_type INTEGER"

#pragma mark version 12

#define YYIM_DB_VERSION_12      12
#define YYIM_MESSAGE_ADD_KEYINFO @"ALTER TABLE yyim_message ADD key_info TEXT"

#pragma mark version 13

#define YYIM_DB_VERSION_13      13
//公共号表新增字段description
#define YYIM_PUBACCOUNT_ADD_DESCRIPTION @"ALTER TABLE yyim_pubaccount ADD account_description TEXT"

#pragma mark version 14

#define YYIM_DB_VERSION_14      14

// 新增联系人的tag表
#define YYIM_ROSTER_TAG_CREATE @"CREATE TABLE yyim_roster_tag (pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT,roster_id TEXT,tag TEXT)"
// 新增联系人的tag表索引
#define YYIM_ROSTER_TAG_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_roster_tag_unique ON yyim_roster_tag(user_id,roster_id,tag)"
// 新增用户的tag表
#define YYIM_USER_TAG_CREATE @"CREATE TABLE yyim_user_tag(pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,self_id TEXT,user_id TEXT,tag TEXT)"
// 新增用户的tag表索引
#define YYIM_USER_TAG_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_user_tag_unique ON yyim_user_tag(self_id,user_id,tag)"
// 新增群组的tag表
#define YYIM_CHATGROUP_TAG_CREATE @"CREATE TABLE yyim_chatgroup_tag(pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT,chatgroup_id TEXT,tag TEXT)"
// 新增群组的tag表索引
#define YYIM_CHATGROUP_TAG_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_chatgroup_tag_unique ON yyim_chatgroup_tag(user_id,chatgroup_id,tag)"
// 新增公共号的tag表
#define YYIM_PUBACCOUNT_TAG_CREATE @"CREATE TABLE yyim_pubaccount_tag (pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT,account_id TEXT,tag TEXT)"
// 新增公共号的tag表索引
#define YYIM_PUBACCOUNT_TAG_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_pubaccount_tag_unique ON yyim_pubaccount_tag(user_id,account_id,tag)"

#pragma mark version 15

#define YYIM_DB_VERSION_15      15

// 新增公共号的menu表
#define YYIM_PUBACCOUNT_MENU_CREATE @"CREATE TABLE yyim_pubaccount_menu (pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT,account_id TEXT,menu TEXT,last_update INTEGER,ts INTEGER)"
// 新增公共号的menu表索引
#define YYIM_PUBACCOUNT_MENU_IDX_UNIQUE @"CREATE UNIQUE INDEX yyim_idx_pubaccount_menu_unique ON yyim_pubaccount_menu(user_id,account_id)"

#pragma mark version 16

#define YYIM_DB_VERSION_16      16

#define YYIM_USER_PROFILE_CREATE @"CREATE TABLE yyim_user_profile (pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT,profile_key TEXT,profile_value TEXT)"

#pragma mark db update sql

#define YYIM_DBINFO_UPDATE @"UPDATE yyim_dbinfo SET version=?"

// 联系人表插入
#define YYIM_ROSTER_INSERT @"INSERT INTO yyim_roster(user_id,roster_id,roster_alias,roster_photo,roster_groups,subscription,ask,recv) VALUES (?,?,?,?,?,?,?,?)"
// 联系人表更新
#define YYIM_ROSTER_UPDATE @"UPDATE yyim_roster SET roster_alias=?,roster_photo=?,roster_groups=?,subscription=?,ask=?,recv=?,android_state=?,ios_state=?,webim_state=?,desktop_state=? WHERE user_id=? AND roster_id=?"
// 联系人表删除
#define YYIM_ROSTER_DELETE @"DELETE FROM yyim_roster WHERE user_id=? AND roster_id=?"

// 消息表插入
#define YYIM_MESSAGE_INSERT @"INSERT INTO yyim_message (packet_id,self_id,room_id,roster_id,direction,message,status,download_status,upload_status,specific_status,type,chat_type,res_local,res_thumb_local,res_original_local,date,client_type,isat,version,muc_version,custom_type,key_info) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
// 消息表删除
#define YYIM_MESSAGE_DELETE @"DELETE FROM yyim_message WHERE self_id=?"

// 群组表插入
#define YYIM_CHATGROUP_INSERT @"INSERT INTO yyim_chatgroup(user_id,chatgroup_id,chatgroup_name,chatgroup_tag,chatgroup_tag2,chatgroup_tag3,chatgroup_tag4,chatgroup_tag5,chatgroup_collect,is_super,member_count,is_owner,ts) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)"
// 群组表更新
#define YYIM_CHATGROUP_UPDATE @"UPDATE yyim_chatgroup SET chatgroup_name=?,chatgroup_tag=?,chatgroup_tag2=?,chatgroup_tag3=?,chatgroup_tag4=?,chatgroup_tag5=?,chatgroup_collect=?,is_super=?,member_count=?,is_owner=?,ts=? WHERE user_id=? AND chatgroup_id=?"
// 群组表删除
#define YYIM_CHATGROUP_DELETE @"DELETE FROM yyim_chatgroup WHERE user_id=? AND chatgroup_id=?"

// 群组成员表插入
#define YYIM_CHATGROUPMEMBER_INSERT @"INSERT INTO yyim_chatgroup_member(user_id,chatgroup_id,member_id,member_name,member_photo,affiliation) VALUES (?,?,?,?,?,?)"
// 群组成员表更新
#define YYIM_CHATGROUPMEMBER_UPDATE @"UPDATE yyim_chatgroup_member SET member_name=?,member_photo=?,affiliation=? WHERE user_id=? AND chatgroup_id=? AND member_id=?"
// 群组成员表删除
#define YYIM_CHATGROUPMEMBER_DELETE @"DELETE FROM yyim_chatgroup_member WHERE user_id=? AND chatgroup_id=? AND member_id=?"
// 群组成员表删除
#define YYIM_CHATGROUPMEMBER_DELETEALL @"DELETE FROM yyim_chatgroup_member WHERE user_id=? AND chatgroup_id=?"

// 个人信息表插入
#define YYIM_USER_INSERT @"INSERT INTO yyim_user(user_id,user_name,user_email,user_org,user_unit,user_orgid,user_photo,user_mobile,user_title,user_gender,user_number,user_telephone,user_location,user_desc,last_update) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
// 个人信息表更新
#define YYIM_USER_UPDATE @"UPDATE yyim_user SET user_name=?,user_email=?,user_org=?,user_unit=?,user_orgid=?,user_photo=?,user_mobile=?,user_title=?,user_gender=?,user_number=?,user_telephone=?,user_location=?,user_desc=?,last_update=? WHERE user_id=?"

// 个人信息表扩展表插入
#define YYIM_USER_EXT_INSERT @"INSERT INTO yyim_user_ext(user_id,ext_id,no_disturb,stick_top) VALUES (?,?,?,?)"
// 个人信息表扩展表更新
#define YYIM_USER_EXT_UPDATE @"UPDATE yyim_user_ext SET no_disturb=?,stick_top=? WHERE user_id=? AND ext_id=?"

// 群组信息表扩展表插入
#define YYIM_CHATGROUP_EXT_INSERT @"INSERT INTO yyim_chatgroup_ext(user_id,chatgroup_id,no_disturb,stick_top,show_name) VALUES (?,?,?,?,?)"
// 群组信息表扩展表更新
#define YYIM_CHATGROUP_EXT_UPDATE @"UPDATE yyim_chatgroup_ext SET no_disturb=?,stick_top=?,show_name=? WHERE user_id=? AND chatgroup_id=?"

//公共号表插入
#define YYIM_PUBACCOUNT_INSERT @"INSERT INTO yyim_pubaccount(user_id,account_id,account_name,account_photo,account_type,account_description) VALUES (?,?,?,?,?,?)"
//公共号表更新
#define YYIM_PUBACCOUNT_UPDATE @"UPDATE yyim_pubaccount SET account_name=?,account_photo=?,account_type=?,account_description=? WHERE user_id=? AND account_id=?"
//公共号表删除
#define YYIM_PUBACCOUNT_DELETE @"DELETE FROM yyim_pubaccount WHERE user_id=? AND account_id=?"

//公共号扩展表插入
#define YYIM_PUBACCOUNT_EXT_INSERT @"INSERT INTO yyim_pubaccount_ext(user_id,account_id,no_disturb,stick_top) VALUES (?,?,?,?)"
//公共号扩展表更新
#define YYIM_PUBACCOUNT_EXT_UPDATE @"UPDATE yyim_pubaccount_ext SET no_disturb=?,stick_top=? WHERE user_id=? AND account_id=?"

// 好友邀请
#define YYIM_ROSTER_INVITE_INSERT @"INSERT INTO yyim_roster_invite (user_id,from_id,date,state) VALUES (?,?,?,?)"

// 组织信息表插入
#define YYIM_ORG_INSERT @"INSERT INTO yyim_org(app_id,org_id,parent_id,org_name,is_leaf,is_user,user_email,user_photo) VALUES (?,?,?,?,?,?,?,?)"
// 组织信息表更新
#define YYIM_ORG_UPDATE @"UPDATE yyim_org SET org_name=?,is_leaf=?,is_user=?,user_email=?,user_photo=? WHERE app_id=? AND parent_id=? AND org_id=?"
#define YYIM_ORG_DELETE @"DELETE FROM yyim_org WHERE app_id=? AND parent_id=? AND org_id=?"

// 视频会议表插入
#define YYIM_NETMEETING_INSERT @"INSERT INTO  yyim_netmeeting(user_id,channel_id,netmeeting_type,netmeeting_mode,inviter_id,dynamic_key,forbid_audio,lock,topic,create_time,creator) VALUES (?,?,?,?,?,?,?,?,?,?,?)"
// 视频会议表更新
#define YYIM_NETMEETING_UPDATE @"UPDATE yyim_netmeeting SET netmeeting_type=?,netmeeting_mode=?,inviter_id=?,dynamic_key=?,forbid_audio=?,lock=?,topic=?,create_time=?,creator=? WHERE user_id=? AND channel_id=?"

// 视频会议成员表插入
#define YYIM_NETMEETING_MEMBER_INSERT @"INSERT INTO  yyim_netmeeting_member(user_id,channel_id,member_id,member_uid,member_name,member_role,enable_video, enable_audio,forbid_audio,invite_state) VALUES (?,?,?,?,?,?,?,?,?,?)"
// 视频会议成员表更新
#define YYIM_NETMEETING_MEMBER_UPDATE @"UPDATE yyim_netmeeting_member SET member_uid=?,member_name=?,member_role=?,enable_video=?,enable_audio=?,forbid_audio=?,invite_state=? WHERE user_id=? AND channel_id=? AND member_id=?"
// 视频会议成员表删除
#define YYIM_NETMEETING_MEMBER_DELETE @"DELETE FROM yyim_netmeeting_member WHERE user_id=? AND channel_id=? AND member_id=?"

// 群组tag表的插入
#define YYIM_CHATGROUP_TAG_INSERT @"INSERT INTO yyim_chatgroup_tag(user_id,chatgroup_id,tag) VALUES (?,?,?)"
// 群组tag表的删除
#define YYIM_CHATGROUP_TAG_DELETE @"DELETE FROM yyim_chatgroup_tag WHERE user_id=? AND chatgroup_id=?"

// 用户的tag表的插入
#define YYIM_USER_TAG_INSERT @"INSERT INTO yyim_user_tag(self_id,user_id,tag) VALUES (?,?,?)"
// 用户的tag表的删除
#define YYIM_USER_TAG_DELETE @"DELETE FROM yyim_user_tag WHERE self_id=? AND user_id=? AND tag=?"

//公共号的tag表的插入
#define YYIM_PUBACCOUNT_TAG_INSERT @"INSERT INTO yyim_pubaccount_tag(user_id,account_id,tag) VALUES (?,?,?)"
//公共号的tag表的删除
#define YYIM_PUBACCOUNT_TAG_DELETE @"DELETE FROM yyim_pubaccount_tag WHERE user_id=? AND account_id=?"

// 联系人的tag表的插入
#define YYIM_ROSTER_TAG_INSERT @"INSERT INTO yyim_roster_tag(user_id,roster_id,tag) VALUES (?,?,?)"
// 联系人的tag表的删除
#define YYIM_ROSTER_TAG_DELETE @"DELETE FROM yyim_roster_tag WHERE user_id=? AND roster_id=? AND tag=?"

//公共号的menu表插入
#define YYIM_PUBACCOUNT_MENU_INSERT @"INSERT INTO yyim_pubaccount_menu(user_id,account_id,menu,last_update,ts) VALUES (?,?,?,?,?)"
//公共号的menu表更新
#define YYIM_PUBACCOUNT_MENU_UPDATE @"UPDATE yyim_pubaccount_menu SET menu=?,last_update=?,ts=? WHERE user_id=? AND account_id=?"
//公共号的menu表删除
#define YYIM_PUBACCOUNT_MENU_DELETE @"DELETE FROM yyim_pubaccount_menu WHERE user_id=? AND account_id=?"

#endif
