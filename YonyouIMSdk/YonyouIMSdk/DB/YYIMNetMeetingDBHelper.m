//
//  YYIMNetMeetingDBHelper.m
//  YonyouIMSdk
//
//  Created by yanghaoc on 16/1/27.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYIMNetMeetingDBHelper.h"
#import "YYFMDB.h"
#import "YYIMDBHeader.h"
#import "YYIMStringUtility.h"
#import "YYIMConfig.h"
#import "YYIMJUMPHelper.h"
#import "YYIMDefs.h"

#define YM_NETMEETING_DB @"ym_netmeeting.sqlite"

@implementation YYIMNetMeetingDBHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (NSString *)defaultDBName {
    return YM_NETMEETING_DB;
}

- (void) updateDatabase {
    NSInteger dbVersion = [self getDbVersion];
    
    switch (dbVersion) {
        case YYIM_DB_VERSION_EMPTY:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_DBINFO_CREATE];
                [db executeUpdate:YYIM_NETMEETING_CREATE];
                [db executeUpdate:YYIM_NETMEETING_IDX_UNIQUE];
                [db executeUpdate:YYIM_NETMEETING_MEMBER_CREATE];
                [db executeUpdate:YYIM_NETMEETING_MEMBER_IDX_UNIQUE];
                [db executeUpdate:YYIM_NETMEETING_NOTIFY_CREATE];
                [db executeUpdate:YYIM_DBINFO_INIT];
            }];
        case YYIM_DB_VERSION_INITIAL:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_NETMEETING_NOTIFY_ADD_CREATER];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_1]];
            }];
        case YYIM_DB_VERSION_1:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_NETMEETING_NOTIFY_ADD_WAITBEGIN];
                [db executeUpdate:YYIM_NETMEETING_NOTIFY_ADD_RESERVATION_END];
                [db executeUpdate:YYIM_NETMEETING_ADD_CREATOR];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_2]];
            }];
        case YYIM_DB_VERSION_2:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_NETMEETING_NOTIFY_DELETE_INDEX];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_3]];
            }];
        case YYIM_DB_VERSION_3:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_NETMEETING_CALENDAR_CREATE];
                [db executeUpdate:YYIM_NETMEETING_CALENDAR_IDX_UNIQUE];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_4]];
            }];
        default:
            break;
    }
}

#pragma mark -
#pragma mark netmeeting

- (void)updateNetMeeting:(YYNetMeeting *)netMeeting {
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT count(*) FROM yyim_netmeeting WHERE user_id=? AND channel_id=? ";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:[netMeeting channelId]]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        NSInteger count = 0;
        
        @try {
            if ([rs next]) {
                count = [rs intForColumnIndex:0];
            }
        }
        @finally {
            [rs close];
        }
        
        if (count > 0) {
            NSMutableArray *argsArray = [NSMutableArray array];
            [argsArray addObject:[NSNumber numberWithInteger:[netMeeting netMeetingType]]];
            [argsArray addObject:[NSNumber numberWithInteger:[netMeeting netMeetingMode]]];
            [argsArray addObject:[YYIMStringUtility notNilString:[netMeeting inviterId]]];
            [argsArray addObject:[YYIMStringUtility notNilString:[netMeeting dynamicKey]]];
            [argsArray addObject:[NSNumber numberWithBool:[netMeeting muteAll]]];
            [argsArray addObject:[NSNumber numberWithBool:[netMeeting lock]]];
            [argsArray addObject:[YYIMStringUtility notNilString:[netMeeting topic]]];
            [argsArray addObject:[NSNumber numberWithLongLong:netMeeting.createTime]];
            [argsArray addObject:[YYIMStringUtility notNilString:[netMeeting creator]]];
            
            [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
            [argsArray addObject:[YYIMStringUtility notNilString:[netMeeting channelId]]];
            
            [db executeUpdate:YYIM_NETMEETING_UPDATE withArgumentsInArray:argsArray];
        } else {
            NSMutableArray *argsArray = [NSMutableArray array];
            [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
            [argsArray addObject:[YYIMStringUtility notNilString:[netMeeting channelId]]];
            [argsArray addObject:[NSNumber numberWithInteger:[netMeeting netMeetingType]]];
            [argsArray addObject:[NSNumber numberWithInteger:[netMeeting netMeetingMode]]];
            [argsArray addObject:[YYIMStringUtility notNilString:[netMeeting inviterId]]];
            [argsArray addObject:[YYIMStringUtility notNilString:[netMeeting dynamicKey]]];
            [argsArray addObject:[NSNumber numberWithBool:[netMeeting muteAll]]];
            [argsArray addObject:[NSNumber numberWithBool:[netMeeting lock]]];
            [argsArray addObject:[YYIMStringUtility notNilString:[netMeeting topic]]];
            [argsArray addObject:[NSNumber numberWithLongLong:netMeeting.createTime]];
            [argsArray addObject:[YYIMStringUtility notNilString:[netMeeting creator]]];
            
            [db executeUpdate:YYIM_NETMEETING_INSERT withArgumentsInArray:argsArray];
        }
    }];
}

- (YYNetMeeting *)getNetMeetingWithChannelId:(NSString *)channelId {
    __block YYNetMeeting *netMeeting = nil;
    
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT * FROM yyim_netmeeting WHERE user_id=? and channel_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:channelId]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        
        @try {
            if ([rs next]) {
                netMeeting = [[YYNetMeeting alloc] init];
                
                [netMeeting setChannelId:channelId];
                [netMeeting setNetMeetingType:[rs intForColumn:@"netmeeting_type"]];
                [netMeeting setNetMeetingMode:[rs intForColumn:@"netmeeting_mode"]];
                [netMeeting setInviterId:[rs stringForColumn:@"inviter_id"]];
                [netMeeting setDynamicKey:[rs stringForColumn:@"dynamic_key"]];
                [netMeeting setMuteAll:[rs boolForColumn:@"forbid_audio"]];
                [netMeeting setLock:[rs boolForColumn:@"lock"]];
                [netMeeting setTopic:[rs stringForColumn:@"topic"]];
                [netMeeting setCreateTime:[rs doubleForColumn:@"create_time"]];
                [netMeeting setCreator:[rs stringForColumn:@"creator"]];
            }
        }
        @finally {
            [rs close];
        }
    }];
    
    return netMeeting;
}

- (void)batchUpdateNetMeetingMember:(NSString *)channelId members:(NSArray *)memberArray {
    if ([YYIMStringUtility isEmpty:channelId]) {
        return;
    }
    
    __block NSMutableArray *memberIdArray = [NSMutableArray array];
    
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSString *sql = @"SELECT member_id FROM yyim_netmeeting_member WHERE user_id=? AND channel_id=?";
        
        YYFMResultSet *rs = [db executeQuery:sql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy], channelId];
        
        @try {
            while ([rs next]) {
                [memberIdArray addObject:[rs stringForColumn:@"member_id"]];
            }
        }
        @finally {
            [rs close];
        }
        
        for (YYNetMeetingMember *member in memberArray) {
            NSMutableArray *array = [NSMutableArray array];
            
            if ([memberIdArray containsObject:[member memberId]]) {
                [array addObject:[NSNumber numberWithUnsignedInteger:[member memberUid]]];
                [array addObject:[YYIMStringUtility notNilString:[member memberName]]];
                [array addObject:[YYIMStringUtility notNilString:[member memberRole]]];
                [array addObject:[NSNumber numberWithBool:[member enableVideo]]];
                [array addObject:[NSNumber numberWithBool:[member enableAudio]]];
                [array addObject:[NSNumber numberWithBool:[member forbidAudio]]];
                [array addObject:[NSNumber numberWithInteger:[member inviteState]]];
                
                [array addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
                [array addObject:[YYIMStringUtility notNilString:channelId]];
                [array addObject:[YYIMStringUtility notNilString:[member memberId]]];
                [db executeUpdate:YYIM_NETMEETING_MEMBER_UPDATE withArgumentsInArray:array];
                [memberIdArray removeObject:[member memberId]];
            } else {
                [array addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
                [array addObject:[YYIMStringUtility notNilString:channelId]];
                [array addObject:[YYIMStringUtility notNilString:[member memberId]]];
                [array addObject:[NSNumber numberWithUnsignedInteger:[member memberUid]]];
                [array addObject:[YYIMStringUtility notNilString:[member memberName]]];
                [array addObject:[YYIMStringUtility notNilString:[member memberRole]]];
                [array addObject:[NSNumber numberWithBool:[member enableVideo]]];
                [array addObject:[NSNumber numberWithBool:[member enableAudio]]];
                [array addObject:[NSNumber numberWithBool:[member forbidAudio]]];
                [array addObject:[NSNumber numberWithInteger:[member inviteState]]];
                
                [db executeUpdate:YYIM_NETMEETING_MEMBER_INSERT withArgumentsInArray:array];
            }
        }
        
        if ([memberIdArray count] > 0) {
            for (NSString *memberId in memberIdArray) {
                [db executeUpdate:YYIM_NETMEETING_MEMBER_DELETE,[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy],channelId,memberId];
            }
        }
    }];
}

#pragma mark -
#pragma mark netmeeting member

- (NSArray *)getNetMeetingMembersWithChannelId:(NSString *)channelId {
    return [self getNetMeetingMembersWithChannelId:channelId limit:0];
}

- (NSArray *)getNetMeetingMembersWithChannelId:(NSString *)channelId limit:(NSInteger)limit {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSMutableString *sql = [NSMutableString string];
        [sql appendString:@"SELECT * FROM yyim_netmeeting_member WHERE user_id=? AND channel_id=? ORDER BY member_id ASC"];
        
        // limit
        if (limit > 0) {
            [sql appendFormat:@" limit %ld", (long)limit];
        }
        
        YYFMResultSet *rs = [db executeQuery:sql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy], channelId];
        
        @try {
            while ([rs next]) {
                YYNetMeetingMember *member = [[YYNetMeetingMember alloc] init];
                [member setMemberId:[rs stringForColumn:@"member_id"]];
                [member setMemberName:[rs stringForColumn:@"member_name"]];
                [member setMemberRole:[rs stringForColumn:@"member_role"]];
                [member setMemberUid:[rs longForColumn:@"member_uid"]];
                [member setChannelId:[rs stringForColumn:@"channel_id"]];
                [member setEnableVideo:[rs boolForColumn:@"enable_video"]];
                [member setEnableAudio:[rs boolForColumn:@"enable_audio"]];
                [member setForbidAudio:[rs boolForColumn:@"forbid_audio"]];
                [member setInviteState:[rs intForColumn:@"invite_state"]];
                
                [array addObject:member];
            }
        }
        @finally {
            [rs close];
        }
    }];
    
    return array;
}

- (YYNetMeetingMember *)getNetMeetingMemberWithChannelId:(NSString *)channelId memberId:(NSString *)memberId {
    __block YYNetMeetingMember *member = [[YYNetMeetingMember alloc] init];
    
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSMutableString *sql = [NSMutableString string];
        [sql appendString:@"SELECT * FROM yyim_netmeeting_member WHERE user_id=? AND channel_id=? and member_id=? ORDER BY member_id ASC"];
        
        YYFMResultSet *rs = [db executeQuery:sql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy], channelId, memberId];
        
        @try {
            if ([rs next]) {
                [member setMemberId:[rs stringForColumn:@"member_id"]];
                [member setMemberName:[rs stringForColumn:@"member_name"]];
                [member setMemberRole:[rs stringForColumn:@"member_role"]];
                [member setMemberUid:[rs longForColumn:@"member_uid"]];
                [member setChannelId:[rs stringForColumn:@"channel_id"]];
                [member setEnableVideo:[rs boolForColumn:@"enable_video"]];
                [member setEnableAudio:[rs boolForColumn:@"enable_audio"]];
                [member setForbidAudio:[rs boolForColumn:@"forbid_audio"]];
                [member setInviteState:[rs intForColumn:@"invite_state"]];
            }
        }
        @finally {
            [rs close];
        }
    }];
    
    return member;
}

- (void)updateNetMeetingMember:(YYNetMeetingMember *)member channelId:(NSString *)channelId {
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSMutableArray *array = [NSMutableArray array];
        
        [array addObject:[NSNumber numberWithUnsignedInteger:[member memberUid]]];
        [array addObject:[YYIMStringUtility notNilString:[member memberName]]];
        [array addObject:[YYIMStringUtility notNilString:[member memberRole]]];
        [array addObject:[NSNumber numberWithBool:[member enableVideo]]];
        [array addObject:[NSNumber numberWithBool:[member enableAudio]]];
        [array addObject:[NSNumber numberWithBool:[member forbidAudio]]];
        [array addObject:[NSNumber numberWithInteger:[member inviteState]]];
        
        [array addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [array addObject:[YYIMStringUtility notNilString:channelId]];
        [array addObject:[YYIMStringUtility notNilString:[member memberId]]];
        [db executeUpdate:YYIM_NETMEETING_MEMBER_UPDATE withArgumentsInArray:array];
    }];
}

#pragma mark -
#pragma mark netmeeting notify

/**
 * 根据会议的id获取会议通知
 *
 *  @return
 */
- (NSArray *)getNetMeetingNoticeWithMeetingId:(NSString *)channelId {
    return [self getNetMeetingNoticeWithMeetingId:channelId state:-1];
}

/**
 * 根据会议的id和通知类型获取会议通知
 *
 *  @return
 */
- (NSArray *)getNetMeetingNoticeWithMeetingId:(NSString *)channelId state:(YYIMNetMeetingState)state {
    __block NSMutableArray *noticeArray = [NSMutableArray array];;
    
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT * FROM yyim_netmeeting_notify WHERE self_id=? and channel_id=?";
        
        if (state >= 0) {
            sql = [NSString stringWithFormat:@"%@ %@", sql, @"and state=?"];
        }
        
        sql = [NSString stringWithFormat:@"%@ %@", sql, @"ORDER BY date DESC"];
        
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:channelId]];
        
        if (state >= 0) {
            [argsArray addObject:[NSNumber numberWithInteger:state]];
        }
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        
        @try {
            while ([rs next]) {
                YYNetMeetingInfo *netMeetingInfo = [[YYNetMeetingInfo alloc] init];
                [self fillNetMeetingNotice:netMeetingInfo withResultSet:rs];
                
                [noticeArray addObject:netMeetingInfo];
            }
        }
        @finally {
            [rs close];
        }
    }];
    
    return noticeArray;
}

/**
 * 根据频道的id获取会议
 *
 *  @return
 */
- (YYNetMeetingInfo *)getNetMeetingNotifyWithPid:(NSString *)pid {
    __block YYNetMeetingInfo *netMeetingInfo = nil;
    
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT * FROM yyim_netmeeting_notify WHERE self_id=? and packet_id=?";
        
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:pid]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        
        @try {
            if ([rs next]) {
                netMeetingInfo = [[YYNetMeetingInfo alloc] init];
                
                [self fillNetMeetingNotice:netMeetingInfo withResultSet:rs];
            }
        }
        @finally {
            [rs close];
        }
    }];
    
    return netMeetingInfo;
}

- (NSArray *)getNetMeetingNoticeWithOffset:(NSInteger)offset limit:(NSInteger)limit {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        
        NSMutableString *sql = [NSMutableString string];
        [sql appendString:@"SELECT * FROM yyim_netmeeting_notify WHERE self_id=? ORDER BY date DESC"];
        [sql appendFormat:@" LIMIT %ld", (long)limit];
        [sql appendFormat:@" OFFSET %ld", (long)offset];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            while ([rs next]) {
                YYNetMeetingInfo *info = [[YYNetMeetingInfo alloc] init];
                [self fillNetMeetingNotice:info withResultSet:rs];
                [array addObject:info];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return array;
}

/**
 *  更新通知
 *
 *  @param netMeetingInfo 通知对象
 */
- (void)updateOrInsertNetMeetingCommonNotice:(YYNetMeetingInfo *)netMeetingInfo {
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT count(*) FROM yyim_netmeeting_notify WHERE self_id=? AND channel_id=? AND state=1";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:[netMeetingInfo channelId]]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        NSInteger count = 0;
        
        @try {
            if ([rs next]) {
                count = [rs intForColumnIndex:0];
            }
        }
        @finally {
            [rs close];
        }
        
        if (count > 0) {
            NSMutableArray *argsArray = [NSMutableArray array];
            
            NSString *sql = @"UPDATE yyim_netmeeting_notify SET topic=?,state=?,create_time=?,moderator=?,netmeeting_type=?,talk_time=?,date=?,creator=? WHERE self_id=? AND channel_id=? AND state=1";
            
            [argsArray addObject:[YYIMStringUtility notNilString:netMeetingInfo.topic]];
            [argsArray addObject:[NSNumber numberWithInteger:netMeetingInfo.state]];
            [argsArray addObject:[NSNumber numberWithLongLong:netMeetingInfo.date]];
            [argsArray addObject:[YYIMStringUtility notNilString:netMeetingInfo.moderator]];
            [argsArray addObject:[NSNumber numberWithInteger:netMeetingInfo.type]];
            [argsArray addObject:[NSNumber numberWithInteger:netMeetingInfo.duration]];
            [argsArray addObject:[NSNumber numberWithLongLong:netMeetingInfo.notifyDate]];
            [argsArray addObject:[YYIMStringUtility notNilString:netMeetingInfo.creator]];
            
            [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
            [argsArray addObject:[YYIMStringUtility notNilString:netMeetingInfo.channelId]];
            [argsArray addObject:[NSNumber numberWithInteger:netMeetingInfo.state]];
            
            [db executeUpdate:sql withArgumentsInArray:argsArray];
        } else {
            NSString *sql = @"INSERT INTO  yyim_netmeeting_notify(self_id,channel_id,topic,state,create_time,moderator,netmeeting_type,talk_time,date,creator,wait_begin,reservation_end) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";
            NSMutableArray *argsArray = [NSMutableArray array];
            
            [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
            [argsArray addObject:[YYIMStringUtility notNilString:netMeetingInfo.channelId]];
            [argsArray addObject:[YYIMStringUtility notNilString:netMeetingInfo.topic]];
            [argsArray addObject:[NSNumber numberWithInteger:netMeetingInfo.state]];
            [argsArray addObject:[NSNumber numberWithLongLong:netMeetingInfo.date]];
            [argsArray addObject:[YYIMStringUtility notNilString:netMeetingInfo.moderator]];
            [argsArray addObject:[NSNumber numberWithInteger:netMeetingInfo.type]];
            [argsArray addObject:[NSNumber numberWithInteger:netMeetingInfo.duration]];
            [argsArray addObject:[NSNumber numberWithLongLong:netMeetingInfo.notifyDate]];
            [argsArray addObject:[YYIMStringUtility notNilString:netMeetingInfo.creator]];
            [argsArray addObject:[NSNumber numberWithBool:netMeetingInfo.waitBegin]];
            [argsArray addObject:[NSNumber numberWithInteger:netMeetingInfo.reservationInvalidReason]];
            
            [db executeUpdate:sql withArgumentsInArray:argsArray];
        }
    }];
}

- (void)insertNetMeetingReservationNotice:(YYNetMeetingInfo *)netMeetingInfo {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSString *sql = @"INSERT INTO  yyim_netmeeting_notify(self_id,channel_id,topic,state,create_time,moderator,netmeeting_type,talk_time,date,creator,wait_begin,reservation_end) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";
        NSMutableArray *argsArray = [NSMutableArray array];
        
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:netMeetingInfo.channelId]];
        [argsArray addObject:[YYIMStringUtility notNilString:netMeetingInfo.topic]];
        [argsArray addObject:[NSNumber numberWithInteger:netMeetingInfo.state]];
        [argsArray addObject:[NSNumber numberWithLongLong:netMeetingInfo.date]];
        [argsArray addObject:[YYIMStringUtility notNilString:netMeetingInfo.moderator]];
        [argsArray addObject:[NSNumber numberWithInteger:netMeetingInfo.type]];
        [argsArray addObject:[NSNumber numberWithInteger:netMeetingInfo.duration]];
        [argsArray addObject:[NSNumber numberWithLongLong:netMeetingInfo.notifyDate]];
        [argsArray addObject:[YYIMStringUtility notNilString:netMeetingInfo.creator]];
        [argsArray addObject:[NSNumber numberWithBool:netMeetingInfo.waitBegin]];
        [argsArray addObject:[NSNumber numberWithInteger:netMeetingInfo.reservationInvalidReason]];
        
        [db executeUpdate:sql withArgumentsInArray:argsArray];
    }];
}

- (void)updateNetMeetingReservationNotice:(NSString *)channelId wait:(BOOL)wait reason:(YYIMNetMeetingReservationInvalidReason)reason {
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSMutableArray *argsArray = [NSMutableArray array];
        
        NSString *sql = @"UPDATE yyim_netmeeting_notify SET wait_begin=?,reservation_end=? WHERE self_id=? AND channel_id=?";
        
        [argsArray addObject:[NSNumber numberWithBool:wait]];
        [argsArray addObject:[NSNumber numberWithInteger:reason]];
        
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:channelId]];
        
        [db executeUpdate:sql withArgumentsInArray:argsArray];
    }];
}

/**
 *  清空通知
 */
- (void)cleanNetMeetingNotice {
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"DELETE FROM yyim_netmeeting_notify WHERE self_id=?";
        [db executeUpdate:sql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    }];
}

- (void)fillNetMeetingNotice:(YYNetMeetingInfo *)netMeetingInfo withResultSet:(YYFMResultSet *)rs {
    [netMeetingInfo setChannelId:[rs stringForColumn:@"channel_id"]];
    [netMeetingInfo setTopic:[rs stringForColumn:@"topic"]];
    [netMeetingInfo setState:[rs intForColumn:@"state"]];
    [netMeetingInfo setDate:[rs doubleForColumn:@"create_time"]];
    [netMeetingInfo setModerator:[rs stringForColumn:@"moderator"]];
    [netMeetingInfo setType:[rs intForColumn:@"netmeeting_type"]];
    [netMeetingInfo setDuration:[rs intForColumn:@"talk_time"]];
    [netMeetingInfo setNotifyDate:[rs doubleForColumn:@"date"]];
    [netMeetingInfo setCreator:[rs stringForColumn:@"creator"]];
    [netMeetingInfo setWaitBegin:[rs boolForColumn:@"wait_begin"]];
    [netMeetingInfo setReservationInvalidReason:[rs intForColumn:@"reservation_end"]];
}

#pragma mark -
#pragma mark NetMeetingCalendar

- (NSString *)getNetMeetingCalendarIdByChannelId:(NSString *)channelId {
    __block NSString *calendarId;
    
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT * FROM yyim_netmeeting_calendar WHERE channel_id=?";
        
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[YYIMStringUtility notNilString:channelId]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        
        @try {
            if ([rs next]) {
                calendarId = [rs stringForColumn:@"calendar_id"];
            }
        }
        @finally {
            [rs close];
        }
    }];
    
    return calendarId;
}

- (void)addNetMeetingCalendar:(NSString *)channelId calendarId:(NSString *)calendarId {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSString *sql = @"INSERT INTO  yyim_netmeeting_calendar(channel_id,calendar_id) VALUES (?,?)";
        NSMutableArray *argsArray = [NSMutableArray array];
        
        [argsArray addObject:[YYIMStringUtility notNilString:channelId]];
        [argsArray addObject:[YYIMStringUtility notNilString:calendarId]];
        
        [db executeUpdate:sql withArgumentsInArray:argsArray];
    }];
}

- (void)updateNetMeetingCalendar:(NSString *)channelId calendarId:(NSString *)calendarId {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSString *sql = @"UPDATE yyim_netmeeting_calendar SET calendar_id=? WHERE channel_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        
        [argsArray addObject:[YYIMStringUtility notNilString:calendarId]];
        [argsArray addObject:[YYIMStringUtility notNilString:channelId]];
        
        [db executeUpdate:sql withArgumentsInArray:argsArray];
    }];
}

- (void)removeNetMeetingCalendar:(NSString *)channelId {
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"DELETE FROM yyim_netmeeting_calendar WHERE channel_id=?";
        [db executeUpdate:sql, channelId];
    }];
}

@end
