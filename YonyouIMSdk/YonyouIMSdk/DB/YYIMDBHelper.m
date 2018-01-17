//
//  YYIMDBHelper.m
//  YonyouIM
//
//  Created by litfb on 15/1/4.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMDBHelper.h"
#import "YYIMConfig.h"
#import "YYIMDefs.h"
#import "YYIMJUMPHelper.h"
#import "YYIMStringUtility.h"
#import "YYIMDBHeader.h"
#import "YYIMChatGroupMemberDBHelper.h"
#import "YYIMLogger.h"
#import "YYSearchMessage.h"

#define YM_CHAT_DB @"ymchat.sqlite"

@implementation YYIMDBHelper

+ (YYIMDBHelper*)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (NSString *)defaultDBName {
    return YM_CHAT_DB;
}

- (void) updateDatabase {
    NSInteger dbVersion = [self getDbVersion];
    
    switch (dbVersion) {
        case YYIM_DB_VERSION_EMPTY:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_DBINFO_CREATE];
                [db executeUpdate:YYIM_ROSTER_CREATE];
                [db executeUpdate:YYIM_ROSTER_IDX_UNIQUE];
                [db executeUpdate:YYIM_MESSAGE_CREATE];
                [db executeUpdate:YYIM_MESSAGE_IDX_UNIQUE];
                [db executeUpdate:YYIM_CHATGROUP_CREATE];
                [db executeUpdate:YYIM_CHATGROUP_IDX_UNIQUE];
                [db executeUpdate:YYIM_CHATGROUPMEMBER_CREATE];
                [db executeUpdate:YYIM_CHATGROUPMEMBER_IDX_UNIQUE];
                [db executeUpdate:YYIM_USER_CREATE];
                [db executeUpdate:YYIM_USER_IDX_UNIQUE];
                [db executeUpdate:YYIM_DBINFO_INIT];
            }];
        case YYIM_DB_VERSION_INITIAL:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_ROSTER_ADD_ASTATE];
                [db executeUpdate:YYIM_ROSTER_ADD_ISTATE];
                [db executeUpdate:YYIM_ROSTER_ADD_WSTATE];
                [db executeUpdate:YYIM_ROSTER_ADD_DSTATE];
                [db executeUpdate:YYIM_USER_EXT_CREATE];
                [db executeUpdate:YYIM_USER_EXT_IDX_UNIQUE];
                [db executeUpdate:YYIM_CHATGROUP_EXT_CREATE];
                [db executeUpdate:YYIM_CHATGROUP_EXT_IDX_UNIQUE];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_1]];
            }];
        case YYIM_DB_VERSION_1:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_PUBACCOUNT_CREATE];
                [db executeUpdate:YYIM_PUBACCOUNT_IDX_UNIQUE];
                [db executeUpdate:YYIM_PUBACCOUNT_EXT_CREATE];
                [db executeUpdate:YYIM_PUBACCOUNT_EXT_IDX_UNIQUE];
                [db executeUpdate:YYIM_ROSTER_INVITE_CREATE];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_2]];
            }];
        case YYIM_DB_VERSION_2:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_USER_ADD_TELEPHONE];
                [db executeUpdate:YYIM_ROSTER_ADD_GROUPS];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_3]];
            }];
        case YYIM_DB_VERSION_3:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_MESSAGE_ADD_CLIENTTYPE];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_4]];
            }];
        case YYIM_DB_VERSION_4:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_USER_ADD_ORGID];
                [db executeUpdate:YYIM_USER_ADD_GENDER];
                [db executeUpdate:YYIM_USER_ADD_NUMBER];
                [db executeUpdate:YYIM_USER_ADD_LOCATION];
                [db executeUpdate:YYIM_MESSAGE_ADD_RES_ORIGINAL_LOCAL];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_5]];
            }];
        case YYIM_DB_VERSION_5:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_PUBACCOUNT_ADD_TYPE];
                [db executeUpdate:YYIM_MESSAGE_ADD_ISAT];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_6]];
            }];
        case YYIM_DB_VERSION_6:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_ROSTER_ADD_SUBSCRIPTION];
                [db executeUpdate:YYIM_ROSTER_ADD_ASK];
                [db executeUpdate:YYIM_ROSTER_ADD_RECV];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_7]];
            }];
        case YYIM_DB_VERSION_7:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_CHATGROUP_ADD_TAG];
                [db executeUpdate:YYIM_CHATGROUP_ADD_COLLECT];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_8]];
            }];
        case YYIM_DB_VERSION_8:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_CHATGROUP_ADD_TAG2];
                [db executeUpdate:YYIM_CHATGROUP_ADD_TAG3];
                [db executeUpdate:YYIM_CHATGROUP_ADD_TAG4];
                [db executeUpdate:YYIM_CHATGROUP_ADD_TAG5];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_9]];
            }];
        case YYIM_DB_VERSION_9:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_CHATGROUP_ADD_ISSUPER];
                [db executeUpdate:YYIM_CHATGROUP_ADD_MEMBERCOUNT];
                [db executeUpdate:YYIM_MESSAGE_ADD_VERSION];
                [db executeUpdate:YYIM_MESSAGE_ADD_MUCVERSION];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_10]];
            }];
        case YYIM_DB_VERSION_10:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_CHATGROUP_ADD_TS];
                [db executeUpdate:YYIM_CHATGROUP_ADD_ISOWNER];
                [db executeUpdate:YYIM_MESSAGE_ADD_CUSTOMTYPE];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_11]];
            }];
        case YYIM_DB_VERSION_11:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_MESSAGE_ADD_KEYINFO];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_12]];
            }];
            [self updateMessageKeyInfo];
        case YYIM_DB_VERSION_12:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_PUBACCOUNT_ADD_DESCRIPTION];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_13]];
            }];
        case YYIM_DB_VERSION_13:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_USER_TAG_CREATE];
                [db executeUpdate:YYIM_USER_TAG_IDX_UNIQUE];
                [db executeUpdate:YYIM_ROSTER_TAG_CREATE];
                [db executeUpdate:YYIM_ROSTER_TAG_IDX_UNIQUE];
                [db executeUpdate:YYIM_CHATGROUP_TAG_CREATE];
                [db executeUpdate:YYIM_CHATGROUP_TAG_IDX_UNIQUE];
                [db executeUpdate:YYIM_PUBACCOUNT_TAG_CREATE];
                [db executeUpdate:YYIM_PUBACCOUNT_TAG_IDX_UNIQUE];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_14]];
            }];
        case YYIM_DB_VERSION_14:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_PUBACCOUNT_MENU_CREATE];
                [db executeUpdate:YYIM_PUBACCOUNT_MENU_IDX_UNIQUE];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_15]];
            }];
        case YYIM_DB_VERSION_15:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_USER_PROFILE_CREATE];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_16]];
            }];
    }
}

#pragma mark -
#pragma mark roster

- (NSArray *)getAllRoster {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT * FROM yyim_roster WHERE user_id=? AND subscription=? ORDER BY roster_id";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        if ([[YYIMConfig sharedInstance] isRosterCollect]) {
            [argsArray addObject:YYIM_ROSTER_SUBSCRIPTION_FAVORITE];
        } else {
            [argsArray addObject:YYIM_ROSTER_SUBSCRIPTION_BOTH];
        }
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            while ([rs next]) {
                YYRoster *roster = [[YYRoster alloc] init];
                [roster setRosterId:[rs stringForColumn:@"roster_id"]];
                [roster setRosterAlias:[rs stringForColumn:@"roster_alias"]];
                [roster setRosterPhoto:[rs stringForColumn:@"roster_photo"]];
                [roster setGroupsWithStr:[rs stringForColumn:@"roster_groups"]];
                [roster setSubscription:[rs stringForColumn:@"subscription"]];
                [roster setAsk:[rs intForColumn:@"ask"]];
                [roster setRecv:[rs intForColumn:@"recv"]];
                [roster setAndroidState:[rs intForColumn:@"android_state"]];
                [roster setIosState:[rs intForColumn:@"ios_state"]];
                [roster setWebimState:[rs intForColumn:@"webim_state"]];
                [roster setDesktopState:[rs intForColumn:@"desktop_state"]];
                [array addObject:roster];
            }
        }
        @finally {
            [rs close];
        }
        
        if (array.count > 0) {
            for (YYRoster *roster in array) {
                [roster setRosterTag:[self getRosterTagsWithRosterId:roster.rosterId db:db]];
            }
        }
    }];
    return array;
}

- (NSArray *)getAllRosterWithAsk {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT * FROM yyim_roster WHERE user_id=? AND (subscription=? OR ask=?) ORDER BY roster_id";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        if ([[YYIMConfig sharedInstance] isRosterCollect]) {
            [argsArray addObject:YYIM_ROSTER_SUBSCRIPTION_FAVORITE];
        } else {
            [argsArray addObject:YYIM_ROSTER_SUBSCRIPTION_BOTH];
        }
        [argsArray addObject:[NSNumber numberWithInt:YYIM_ROSTER_ASK_SUB]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            while ([rs next]) {
                YYRoster *roster = [[YYRoster alloc] init];
                [roster setRosterId:[rs stringForColumn:@"roster_id"]];
                [roster setRosterAlias:[rs stringForColumn:@"roster_alias"]];
                [roster setRosterPhoto:[rs stringForColumn:@"roster_photo"]];
                [roster setGroupsWithStr:[rs stringForColumn:@"roster_groups"]];
                [roster setSubscription:[rs stringForColumn:@"subscription"]];
                [roster setAsk:[rs intForColumn:@"ask"]];
                [roster setRecv:[rs intForColumn:@"recv"]];
                [roster setAndroidState:[rs intForColumn:@"android_state"]];
                [roster setIosState:[rs intForColumn:@"ios_state"]];
                [roster setWebimState:[rs intForColumn:@"webim_state"]];
                [roster setDesktopState:[rs intForColumn:@"desktop_state"]];
                [array addObject:roster];
            }
        }
        @finally {
            [rs close];
        }
        
        if (array.count > 0) {
            for (YYRoster *roster in array) {
                [roster setRosterTag:[self getRosterTagsWithRosterId:roster.rosterId db:db]];
            }
        }
    }];
    return array;
}

- (NSInteger)newInviteCount {
    __block NSInteger result;
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT count(*) FROM yyim_roster WHERE user_id=? AND recv=? ORDER BY roster_id";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[NSNumber numberWithInt:YYIM_ROSTER_RECV_SUB]];
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            if ([rs next]) {
                result = [rs intForColumnIndex:0];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return result;
}

- (NSArray *)getAllRosterInvite {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT * FROM yyim_roster WHERE user_id=? AND recv=? ORDER BY roster_id";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[NSNumber numberWithInt:YYIM_ROSTER_RECV_SUB]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            while ([rs next]) {
                YYRoster *roster = [[YYRoster alloc] init];
                [roster setRosterId:[rs stringForColumn:@"roster_id"]];
                [roster setRosterAlias:[rs stringForColumn:@"roster_alias"]];
                [roster setRosterPhoto:[rs stringForColumn:@"roster_photo"]];
                [roster setGroupsWithStr:[rs stringForColumn:@"roster_groups"]];
                [roster setSubscription:[rs stringForColumn:@"subscription"]];
                [roster setAsk:[rs intForColumn:@"ask"]];
                [roster setRecv:[rs intForColumn:@"recv"]];
                [roster setAndroidState:[rs intForColumn:@"android_state"]];
                [roster setIosState:[rs intForColumn:@"ios_state"]];
                [roster setWebimState:[rs intForColumn:@"webim_state"]];
                [roster setDesktopState:[rs intForColumn:@"desktop_state"]];
                [array addObject:roster];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return array;
}

- (void)insertOrUpdateRoster:(YYRoster *)roster {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSInteger count = 0;
        NSString *sql = @"SELECT COUNT(*) FROM yyim_roster WHERE user_id=? AND roster_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:[roster rosterId]]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            if ([rs next]) {
                count = [rs intForColumnIndex:0];
                if (count > 0) {
                    [self innerUpdateRosterNoState:db roster:roster];
                    [self updateRosterTags:db roster:roster];
                } else {
                    [self innerInsertRoster:db roster:roster];
                    [self updateRosterTags:db roster:roster];
                }
            }
        }
        @finally {
            [rs close];
        }
    }];
}

- (void)deleteRoster:(NSString *)rosterId {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        [self innerDeleteRoster:db rosterId:rosterId];
        [self innerDeleteRosterTags:db rosterId:rosterId];
    }];
}

- (void)batchUpdateRoster:(NSArray *)rosterArray {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSMutableArray *rosterIdArray = [NSMutableArray array];
        NSString *sql = @"SELECT roster_id FROM yyim_roster WHERE user_id=?";
        YYFMResultSet *rs = [db executeQuery:sql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        @try {
            while ([rs next]) {
                [rosterIdArray addObject:[rs stringForColumn:@"roster_id"]];
            }
        }
        @finally {
            [rs close];
        }
        
        for (YYRoster *roster in rosterArray) {
            if ([rosterIdArray containsObject:[roster rosterId]]) {
                [self innerUpdateRoster:db roster:roster];
                [rosterIdArray removeObject:[roster rosterId]];
                [self updateRosterTags:db roster:roster];
            } else {
                [self innerInsertRoster:db roster:roster];
                [self updateRosterTags:db roster:roster];
            }
        }
        
        if ([rosterIdArray count] > 0) {
            for (NSString *rosterId in rosterIdArray) {
                [self innerDeleteRoster:db rosterId:rosterId];
                [self innerDeleteRosterTags:db rosterId:rosterId];
            }
        }
    }];
}

- (YYRoster *)getRosterWithId:(NSString *)rosterId {
    __block YYRoster *roster = nil;
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        roster = [self innerGetRoster:db rosterId:rosterId];
        if (roster) {
            [roster setRosterTag:[self getRosterTagsWithRosterId:rosterId db:db]];
        }
    }];
    return roster;
}

- (void)updateRosterState:(NSInteger)state roster:(NSString *)rosterId clientType:(YYIMClientType)clientType {
    NSString *columnName;
    switch (clientType) {
        case kYYIMClientTypeAndroid:
            columnName = @"android_state";
            break;
        case kYYIMClientTypeIOS:
            columnName = @"ios_state";
            break;
        case kYYIMClientTypePC:
            columnName = @"desktop_state";
            break;
        case kYYIMClientTypeWeb:
            columnName = @"webim_state";
            break;
        default:
            columnName = @"android_state";
            break;
    }
    
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE yyim_roster SET %@=? WHERE user_id=? AND roster_id=?", columnName];
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[NSNumber numberWithInteger:state]];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:rosterId]];
        [db executeUpdate:sql withArgumentsInArray:argsArray];
    }];
}

- (YYRoster *)innerGetRoster:(YYFMDatabase *)db rosterId:(NSString *) rosterId {
    NSString *sql = @"SELECT * FROM yyim_roster WHERE user_id=? and roster_id=?";
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [argsArray addObject:[YYIMStringUtility notNilString:rosterId]];
    
    YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
    @try {
        if ([rs next]) {
            YYRoster *roster = [[YYRoster alloc] init];
            [roster setRosterId:[rs stringForColumn:@"roster_id"]];
            [roster setRosterAlias:[rs stringForColumn:@"roster_alias"]];
            [roster setRosterPhoto:[rs stringForColumn:@"roster_photo"]];
            [roster setGroupsWithStr:[rs stringForColumn:@"roster_groups"]];
            [roster setSubscription:[rs stringForColumn:@"subscription"]];
            [roster setAsk:[rs intForColumn:@"ask"]];
            [roster setRecv:[rs intForColumn:@"recv"]];
            [roster setAndroidState:[rs intForColumn:@"android_state"]];
            [roster setIosState:[rs intForColumn:@"ios_state"]];
            [roster setWebimState:[rs intForColumn:@"webim_state"]];
            [roster setDesktopState:[rs intForColumn:@"desktop_state"]];
            return roster;
        }
    }
    @finally {
        [rs close];
    }
    return nil;
}

- (void)innerInsertRoster:(YYFMDatabase *)db roster:(YYRoster *)roster {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [array addObject:[YYIMStringUtility notNilString:[roster rosterId]]];
    [array addObject:[YYIMStringUtility notNilString:[roster rosterAlias]]];
    [array addObject:[YYIMStringUtility notNilString:[roster rosterPhoto]]];
    [array addObject:[YYIMStringUtility notNilString:[roster groupStr]]];
    [array addObject:[YYIMStringUtility notNilString:[roster subscription]]];
    [array addObject:[NSNumber numberWithInteger:[roster ask]]];
    [array addObject:[NSNumber numberWithInteger:[roster recv]]];
    [db executeUpdate:YYIM_ROSTER_INSERT withArgumentsInArray:array];
}

- (void)innerUpdateRoster:(YYFMDatabase *)db roster:(YYRoster *)roster {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[YYIMStringUtility notNilString:[roster rosterAlias]]];
    [array addObject:[YYIMStringUtility notNilString:[roster rosterPhoto]]];
    [array addObject:[YYIMStringUtility notNilString:[roster groupStr]]];
    [array addObject:[YYIMStringUtility notNilString:[roster subscription]]];
    [array addObject:[NSNumber numberWithInteger:[roster ask]]];
    [array addObject:[NSNumber numberWithInteger:[roster recv]]];
    [array addObject:[NSNumber numberWithInteger:kYYIMRosterStateOffline]];
    [array addObject:[NSNumber numberWithInteger:kYYIMRosterStateOffline]];
    [array addObject:[NSNumber numberWithInteger:kYYIMRosterStateOffline]];
    [array addObject:[NSNumber numberWithInteger:kYYIMRosterStateOffline]];
    [array addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [array addObject:[YYIMStringUtility notNilString:[roster rosterId]]];
    [db executeUpdate:YYIM_ROSTER_UPDATE withArgumentsInArray:array];
}

- (void)innerUpdateRosterNoState:(YYFMDatabase *)db roster:(YYRoster *)roster {
    NSString *sql = @"UPDATE yyim_roster SET roster_alias=?,roster_photo=?,roster_groups=?,subscription=?,ask=?,recv=? WHERE user_id=? AND roster_id=?";
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[YYIMStringUtility notNilString:[roster rosterAlias]]];
    [array addObject:[YYIMStringUtility notNilString:[roster rosterPhoto]]];
    [array addObject:[YYIMStringUtility notNilString:[roster groupStr]]];
    [array addObject:[YYIMStringUtility notNilString:[roster subscription]]];
    [array addObject:[NSNumber numberWithInteger:[roster ask]]];
    [array addObject:[NSNumber numberWithInteger:[roster recv]]];
    [array addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [array addObject:[YYIMStringUtility notNilString:[roster rosterId]]];
    [db executeUpdate:sql withArgumentsInArray:array];
}

- (void)innerDeleteRoster:(YYFMDatabase *)db rosterId:(NSString *)rosterId {
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [argsArray addObject:[YYIMStringUtility notNilString:rosterId]];
    
    [db executeUpdate:YYIM_ROSTER_DELETE withArgumentsInArray:argsArray];
}


/**
 *  增加好友的tag（会自动去重）
 *
 *  @param tagArray tag集合
 *  @param rosterId 好友Id
 */
- (void)insertRosterTags:(NSArray *)tagArray rosterId:(NSString *)rosterId {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSMutableArray *newTagArray = [NSMutableArray arrayWithArray:tagArray];
        NSMutableArray *oldTagArray = [NSMutableArray array];
        NSString *sql = @"SELECT tag FROM yyim_roster_tag WHERE user_id=? AND roster_id=?";
        YYFMResultSet *rs = [db executeQuery:sql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy], rosterId];
        
        @try {
            while ([rs next]) {
                [oldTagArray addObject:[rs stringForColumn:@"tag"]];
            }
        }
        @finally {
            [rs close];
        }
        
        [newTagArray removeObjectsInArray:oldTagArray];
        
        for (NSString *tag in newTagArray) {
            if (![YYIMStringUtility isEmpty:tag]) {
                NSMutableArray *argsArray = [NSMutableArray array];
                [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
                [argsArray addObject:[YYIMStringUtility notNilString:rosterId]];
                [argsArray addObject:tag];
                [db executeUpdate:YYIM_ROSTER_TAG_INSERT withArgumentsInArray:argsArray];
            }
        }
    }];
}

/**
 *  删除好友的tag
 *
 *  @param tagArray tag集合
 *  @param rosterId 好友Id
 */
- (void)deleteRosterTags:(NSArray *)tagArray rosterId:(NSString *)rosterId {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        for (NSString *tag in tagArray) {
            NSMutableArray *argsArray = [NSMutableArray array];
            [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
            [argsArray addObject:[YYIMStringUtility notNilString:rosterId]];
            [argsArray addObject:tag];
            [db executeUpdate:YYIM_ROSTER_TAG_DELETE withArgumentsInArray:argsArray];
        }
    }];
}

- (void)innerDeleteRosterTags:(YYFMDatabase *)db rosterId:(NSString *)rosterId {
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [argsArray addObject:[YYIMStringUtility notNilString:rosterId]];
    [db executeUpdate:@"DELETE FROM yyim_roster_tag WHERE user_id=? AND roster_id=?" withArgumentsInArray:argsArray];
}

/**
 *  更新好友的tag表
 *
 *  @param db     db
 *  @param roster 好友信息
 */
- (void)updateRosterTags:(YYFMDatabase *)db roster:(YYRoster *)roster {
    //删除相关所有的tag
    [self innerDeleteRosterTags:db rosterId:roster.rosterId];
    
    //如果有联系人的tag逐一的加入
    NSMutableArray *argsArray = [NSMutableArray array];
    if (roster.rosterTag && roster.rosterTag.count > 0) {
        for (NSString *tag in roster.rosterTag) {
            if (![YYIMStringUtility isEmpty:tag]) {
                [argsArray removeAllObjects];
                [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
                [argsArray addObject:[YYIMStringUtility notNilString:roster.rosterId]];
                [argsArray addObject:tag];
                [db executeUpdate:YYIM_ROSTER_TAG_INSERT withArgumentsInArray:argsArray];
            }
        }
    }
}

/**
 *  获得好友的tag集合
 *
 *  @param rosterId 好友id
 *  @param db       db
 *
 *  @return
 */
- (NSArray *)getRosterTagsWithRosterId:(NSString *)rosterId db:(YYFMDatabase *)db{
    NSMutableArray *array = [NSMutableArray array];
    NSString *sql = @"SELECT * FROM yyim_roster_tag WHERE user_id=? and roster_id=?";
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [argsArray addObject:[YYIMStringUtility notNilString:rosterId]];
    
    YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
    @try {
        while ([rs next]) {
            [array addObject:[rs stringForColumn:@"tag"]];
        }
    }
    @finally {
        [rs close];
    }
    return array;
}

/**
 *  通过tag获取好友集合
 *
 *  @param tag tag
 *
 *  @return 好友集合
 */
- (NSArray *)getRostersWithTag:(NSString *)tag {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT roster_id FROM yyim_roster_tag WHERE user_id=? AND tag=? GROUP BY roster_id";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:tag]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        NSMutableArray *rosterIdArray = [NSMutableArray array];
        
        @try {
            while ([rs next]) {
                [rosterIdArray addObject:[rs stringForColumn:@"roster_id"]];
            }
        }
        @finally {
            [rs close];
        }
        
        if (rosterIdArray.count > 0) {
            for (NSString *rosterId in rosterIdArray) {
                YYRoster *roster = [self innerGetRoster:db rosterId:rosterId];
                
                if (roster) {
                    [array addObject:roster];
                }
            }
        }
    }];
    
    return array;
}

#pragma mark message

- (BOOL)isMessageReceived:(NSString *)pid fromId:(NSString *)fromId {
    __block BOOL isReceived = NO;
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"select count(*) from yyim_message where packet_id=? and self_id=? and room_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[YYIMStringUtility notNilString:pid]];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:fromId]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            if ([rs next]) {
                NSInteger count = [rs intForColumnIndex:0];
                isReceived = count > 0;
            }
        }
        @finally {
            [rs close];
        }
    }];
    return isReceived;
}

- (YYMessage *)insertMessage:(YYMessage *) message {
    __block NSInteger pkid;
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[YYIMStringUtility notNilString:[message pid]]];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE) {
            [argsArray addObject:[YYIMStringUtility notNilString:[message fromId]]];
        } else {
            [argsArray addObject:[YYIMStringUtility notNilString:[message toId]]];
        }
        [argsArray addObject:[YYIMStringUtility notNilString:[message rosterId]]];
        [argsArray addObject:[NSNumber numberWithInteger:[message direction]]];
        [argsArray addObject:[YYIMStringUtility notNilString:[message message]]];
        [argsArray addObject:[NSNumber numberWithInteger:[message status]]];
        [argsArray addObject:[NSNumber numberWithInteger:[message downloadStatus]]];
        [argsArray addObject:[NSNumber numberWithInteger:[message uploadStatus]]];
        [argsArray addObject:[NSNumber numberWithInteger:[message specificStatus]]];
        [argsArray addObject:[NSNumber numberWithInteger:[message type]]];
        [argsArray addObject:[YYIMStringUtility notNilString:[message chatType]]];
        [argsArray addObject:[YYIMStringUtility notNilString:[message resLocal]]];
        [argsArray addObject:[YYIMStringUtility notNilString:[message resThumbLocal]]];
        [argsArray addObject:[YYIMStringUtility notNilString:[message resOriginalLocal]]];
        [argsArray addObject:[NSNumber numberWithLongLong:[message date]]];
        [argsArray addObject:[NSNumber numberWithInt:[message clientType]]];
        [argsArray addObject:[NSNumber numberWithInt:[message isAtMe] ? 1 : 0]];
        [argsArray addObject:[NSNumber numberWithInteger:[message version]]];
        [argsArray addObject:[NSNumber numberWithInteger:[message mucVersion]]];
        [argsArray addObject:[NSNumber numberWithInteger:[message customType]]];
        [argsArray addObject:[YYIMStringUtility notNilString:[message keyInfo]]];
        [db executeUpdate:YYIM_MESSAGE_INSERT withArgumentsInArray:argsArray];
        YYFMResultSet *rs = [db executeQuery:@"select last_insert_rowid()"];
        @try {
            if ([rs next]) {
                pkid = [rs intForColumnIndex:0];
            }
        }
        @finally {
            [rs close];
        }
    }];
    [message setPkid:pkid];
    return message;
}

- (BOOL)updateMessage:(YYMessage *)message {
    __block BOOL result;
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[YYIMStringUtility notNilString:[message message]]];
        [argsArray addObject:[NSNumber numberWithInteger:[message status]]];
        [argsArray addObject:[NSNumber numberWithInteger:[message downloadStatus]]];
        [argsArray addObject:[NSNumber numberWithInteger:[message uploadStatus]]];
        [argsArray addObject:[NSNumber numberWithInteger:[message specificStatus]]];
        [argsArray addObject:[YYIMStringUtility notNilString:[message resLocal]]];
        [argsArray addObject:[YYIMStringUtility notNilString:[message resThumbLocal]]];
        [argsArray addObject:[YYIMStringUtility notNilString:[message resOriginalLocal]]];
        [argsArray addObject:[NSNumber numberWithInteger:[message pkid]]];
        result = [db executeUpdate:@"update yyim_message set message=?,status=?,download_status=?,upload_status=?,specific_status=?,res_local=?,res_thumb_local=?,res_original_local=? where pkid=?" withArgumentsInArray:argsArray];
    }];
    return result;
}

- (YYMessage *)getMessageWithPid:(NSString *)pid {
    __block YYMessage *message;
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"select * from yyim_message where self_id=? and packet_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:pid]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            if ([rs next]) {
                message = [[YYMessage alloc] init];
                [self fillMessage:message withResultSet:rs];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return message;
}

- (NSArray *)getRecentMessage {
    if (![[YYIMConfig sharedInstance] getUser]) {
        return nil;
    }
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSDictionary *newMsgCountDic = [self getUnreadMessageCountDic:db];
        NSDictionary *atCountDic = [self getAtCountDic:db];
        
        NSMutableString *sql = [[NSMutableString alloc] init];
        [sql appendString:@"select max(yyim_message.pkid),yyim_message.*"];
        [sql appendString:@" ,(case yyim_message.chat_type when ? then yyim_user_ext.stick_top when ? then yyim_chatgroup_ext.stick_top when ? then yyim_pubaccount_ext.stick_top end) sticktop"];
        [sql appendString:@" from yyim_message"];
        [sql appendString:@" left join yyim_user_ext on yyim_user_ext.user_id = yyim_message.self_id and yyim_user_ext.ext_id = yyim_message.room_id "];
        [sql appendString:@" left join yyim_pubaccount_ext on yyim_pubaccount_ext.user_id = yyim_message.self_id and yyim_pubaccount_ext.account_id = yyim_message.room_id "];
        [sql appendString:@" left join yyim_chatgroup_ext on yyim_chatgroup_ext.user_id = yyim_message.self_id and yyim_chatgroup_ext.chatgroup_id = yyim_message.room_id "];
        [sql appendString:@" join (select max(date) as maxdate,room_id,self_id from yyim_message where yyim_message.self_id=? and yyim_message.room_id<>? group by room_id) tm on tm.room_id=yyim_message.room_id and tm.self_id=yyim_message.self_id and tm.maxdate=yyim_message.date"];
        [sql appendString:@" group by tm.room_id,tm.self_id "];
        [sql appendString:@" order by ifnull(sticktop,0) desc, date desc"];
        
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:YM_MESSAGE_TYPE_CHAT];
        [argsArray addObject:YM_MESSAGE_TYPE_GROUPCHAT];
        [argsArray addObject:YM_MESSAGE_TYPE_PUBACCOUNT];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:[[YYIMConfig sharedInstance] getUser]]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            while ([rs next]) {
                YYRecentMessage *message = [[YYRecentMessage alloc] init];
                [self fillMessage:message withResultSet:rs];
                NSString *roomId = [rs stringForColumn:@"room_id"];
                [message setNewMessageCount:[[newMsgCountDic objectForKey:roomId] integerValue]];
                [message setAtCount:[[atCountDic objectForKey:roomId] integerValue]];
                [array addObject:message];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return array;
}

- (NSDictionary *)getUnreadMessageCountDic:(YYFMDatabase *)db {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *sql = @"select count(pkid) newmsg_count,room_id from yyim_message where self_id=? and direction=? and status=? group by room_id";
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_DIRECTION_RECEIVE]];
    [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_STATE_NEW]];
    
    YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
    @try {
        while ([rs next]) {
            NSString *roomId = [rs stringForColumn:@"room_id"];
            NSNumber *newMessageCount = [NSNumber numberWithInt:[rs intForColumn:@"newmsg_count"]];
            
            if (![YYIMStringUtility isEmpty:roomId]) {
                [dic setObject:newMessageCount forKey:roomId];
            }
        }
    }
    @finally {
        [rs close];
    }
    return dic;
}

- (NSDictionary *)getAtCountDic:(YYFMDatabase *)db {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *sql = @"select count(pkid) at_count,room_id from yyim_message where self_id=? and direction=? and status=? and isat=1 group by room_id";
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_DIRECTION_RECEIVE]];
    [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_STATE_NEW]];
    
    YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
    @try {
        while ([rs next]) {
            NSString *roomId = [rs stringForColumn:@"room_id"];
            NSNumber *newMessageCount = [NSNumber numberWithInt:[rs intForColumn:@"at_count"]];
            
            if (![YYIMStringUtility isEmpty:roomId]) {
                [dic setObject:newMessageCount forKey:roomId];
            }
        }
    }
    @finally {
        [rs close];
    }
    return dic;
}

- (NSArray *)getRecentMessage2 {
    if (![[YYIMConfig sharedInstance] getUser]) {
        return nil;
    }
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSMutableString *sql = [[NSMutableString alloc] init];
        [sql appendString:@"select max(yyim_message.pkid),yyim_message.*"];
        [sql appendString:@" ,yyim_user_ext.stick_top"];
        [sql appendString:@" from yyim_message"];
        [sql appendString:@" left join yyim_user_ext on yyim_user_ext.user_id = yyim_message.self_id and yyim_user_ext.ext_id = yyim_message.room_id "];
        [sql appendString:@" join (select max(date) as maxdate,room_id,self_id from yyim_message where yyim_message.self_id=? and yyim_message.chat_type=? and yyim_message.room_id<>? group by room_id) tm on tm.room_id=yyim_message.room_id and tm.self_id=yyim_message.self_id and tm.maxdate=yyim_message.date"];
        [sql appendString:@" group by tm.room_id,tm.self_id "];
        [sql appendString:@" order by ifnull(stick_top,0) desc, date desc"];
        
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:YM_MESSAGE_TYPE_CHAT];
        [argsArray addObject:[YYIMStringUtility notNilString:[[YYIMConfig sharedInstance] getUser]]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            while ([rs next]) {
                YYRecentMessage *message = [[YYRecentMessage alloc] init];
                [self fillMessage:message withResultSet:rs];
                [array addObject:message];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return array;
}

- (NSInteger)getUnreadMsgCount {
    if (![[YYIMConfig sharedInstance] getUser]) {
        return 0;
    }
    
    __block NSInteger unreadMsgCount = 0;
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSMutableString *sql = [[NSMutableString alloc] init];
        [sql appendString:@"select count(pkid) newmsg_count from yyim_message where self_id=? and direction=? and status=? "];
        [sql appendString:@" and room_id <> ? "];
        
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_DIRECTION_RECEIVE]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_STATE_NEW]];
        [argsArray addObject:[YYIMStringUtility notNilString:[[YYIMConfig sharedInstance] getUser]]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            if ([rs next]) {
                unreadMsgCount = [rs intForColumn:@"newmsg_count"];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return unreadMsgCount;
}

- (NSInteger)getUnreadMsgCount:(NSString *)chatId {
    if (![[YYIMConfig sharedInstance] getUser]) {
        return 0;
    }
    
    if ([YYIMStringUtility isEmpty:chatId]) {
        return 0;
    }
    
    __block NSInteger unreadMsgCount = 0;
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSMutableString *sql = [[NSMutableString alloc] init];
        [sql appendString:@"select count(pkid) newmsg_count from yyim_message where self_id=? and direction=? and status=? and room_id=? "];
        
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_DIRECTION_RECEIVE]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_STATE_NEW]];
        [argsArray addObject:[YYIMStringUtility notNilString:chatId]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            if ([rs next]) {
                unreadMsgCount = [rs intForColumn:@"newmsg_count"];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return unreadMsgCount;
}

- (NSInteger)getUnreadMsgCountMyOtherClient {
    if (![[YYIMConfig sharedInstance] getUser]) {
        return 0;
    }
    __block NSInteger unreadMsgCount = 0;
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSMutableString *sql = [[NSMutableString alloc] init];
        [sql appendString:@"select count(pkid) newmsg_count from yyim_message where self_id=? and direction=? and status=? "];
        [sql appendString:@" and room_id=? "];
        
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_DIRECTION_RECEIVE]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_STATE_NEW]];
        [argsArray addObject:[YYIMStringUtility notNilString:[[YYIMConfig sharedInstance] getUser]]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            if ([rs next]) {
                unreadMsgCount = [rs intForColumn:@"newmsg_count"];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return unreadMsgCount;
}

- (NSArray *)getMessageWithId:(NSString *)chatId {
    return [self getMessageWithId:chatId contentType:-1];
}

- (NSArray *)getMessageWithId:(NSString *)chatId beforePid:(NSString *)pid pageSize:(NSInteger)pageSize {
    if (pageSize <= 0) {
        pageSize = 20;
    }
    
    YYMessage *message;
    if (![YYIMStringUtility isEmpty:pid]) {
        message = [self getMessageWithPid:pid];
    }
    
    __block long long dateline = -1;
    __block long pkid;
    if (message) {
        dateline = [message date];
        pkid = [message pkid];
    }
    
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:chatId]];
        if (dateline > 0) {
            [argsArray addObject:[NSNumber numberWithLongLong:dateline]];
            [argsArray addObject:[NSNumber numberWithLongLong:dateline]];
            [argsArray addObject:[NSNumber numberWithLong:pkid]];
        }
        
        NSMutableString *sql = [NSMutableString string];
        [sql appendString:@"select * from ("];
        
        [sql appendString:@"select * from yyim_message where self_id=? and room_id=?"];
        if (dateline > 0) {
            [sql appendString:@" and (date<? or (date=? and pkid<?))"];
        }
        [sql appendString:@" order by date desc, pkid desc"];
        [sql appendFormat:@" limit %ld offset 0", (long)pageSize];
        
        [sql appendString:@") t order by t.date asc,t.pkid asc"];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            while ([rs next]) {
                YYMessage *message = [[YYMessage alloc] init];
                [self fillMessage:message withResultSet:rs];
                [array addObject:message];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return array;
}

- (NSArray *)getCustomMessageWithId:(NSString *)chatId customType:(NSInteger)customType beforePid:(NSString *)pid pageSize:(NSInteger)pageSize {
    if (pageSize <= 0) {
        pageSize = 20;
    }
    
    YYMessage *message;
    if (![YYIMStringUtility isEmpty:pid]) {
        message = [self getMessageWithPid:pid];
    }
    
    __block long long dateline = -1;
    __block long pkid;
    if (message) {
        dateline = [message date];
        pkid = [message pkid];
    }
    
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:chatId]];
        [argsArray addObject:[NSNumber numberWithInteger:customType]];
        if (dateline > 0) {
            [argsArray addObject:[NSNumber numberWithLongLong:dateline]];
            [argsArray addObject:[NSNumber numberWithLongLong:dateline]];
            [argsArray addObject:[NSNumber numberWithLong:pkid]];
        }
        
        NSMutableString *sql = [NSMutableString string];
        [sql appendString:@"select * from ("];
        
        [sql appendString:@"select * from yyim_message where self_id=? and room_id=? and custom_type=?"];
        if (dateline > 0) {
            [sql appendString:@" and (date<? or (date=? and pkid<?))"];
        }
        [sql appendString:@" order by date desc, pkid desc"];
        [sql appendFormat:@" limit %ld offset 0", (long)pageSize];
        
        [sql appendString:@") t order by t.date asc,t.pkid asc"];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            while ([rs next]) {
                YYMessage *message = [[YYMessage alloc] init];
                [self fillMessage:message withResultSet:rs];
                [array addObject:message];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return array;
}

- (NSArray *)getMessageWithId:(NSString *)chatId afterPid:(NSString *)pid {
    YYMessage *message;
    if (![YYIMStringUtility isEmpty:pid]) {
        message = [self getMessageWithPid:pid];
    }
    
    __block long long dateline = -1;
    __block long pkid;
    if (message) {
        dateline = [message date];
        pkid = [message pkid];
    }
    
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:chatId]];
        if (dateline > 0) {
            [argsArray addObject:[NSNumber numberWithLongLong:dateline]];
            [argsArray addObject:[NSNumber numberWithLongLong:dateline]];
            [argsArray addObject:[NSNumber numberWithLong:pkid]];
        }
        
        NSMutableString *sql = [NSMutableString string];
        [sql appendString:@"select * from yyim_message where self_id=? and room_id=?"];
        if (dateline > 0) {
            [sql appendString:@" and (date>? or (date=? and pkid>=?))"];
        }
        [sql appendString:@" order by date asc,pkid asc"];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            while ([rs next]) {
                YYMessage *message = [[YYMessage alloc] init];
                [self fillMessage:message withResultSet:rs];
                [array addObject:message];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return array;
}

- (NSArray *)getMessageWithId:(NSString *)chatId contentType:(NSInteger)contentType {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:chatId]];
        if (contentType > 0) {
            [argsArray addObject:[NSNumber numberWithInteger:contentType]];
        }
        NSString *sql = @"select * from yyim_message where self_id=? and room_id=?";
        if (contentType > 0) {
            sql = [sql stringByAppendingString:@" and type=?"];
        }
        sql = [sql stringByAppendingString:@" order by date asc"];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            while ([rs next]) {
                YYMessage *message = [[YYMessage alloc] init];
                [self fillMessage:message withResultSet:rs];
                [array addObject:message];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return array;
}


/**
 *  根据关键字获取消息集合
 *
 *  @param key   关键字
 *
 *  @return 消息集合
 */
- (NSArray *)getMessageWithKey:(NSString *)key limit:(NSInteger)limit {
    __block NSMutableArray *array = [NSMutableArray array];
    
    NSMutableString *searchKey = [[NSMutableString alloc] initWithString:@"%"];
    [searchKey appendString:key];
    [searchKey appendString:@"%"];
    
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[[YYIMConfig sharedInstance] getUser]];
        [argsArray addObject:searchKey];
        
        NSMutableString *sql = [[NSMutableString alloc] init];
        [sql appendString:@"select yyim_message.*, tm.msgcount as message_count from"];
        [sql appendString:@" (select count(*) as msgcount, max(date) as maxdate, room_id,self_id from yyim_message where yyim_message.self_id=? and yyim_message.room_id<>? and key_info like ? group by room_id) tm "];
        [sql appendString:@" join yyim_message on tm.room_id=yyim_message.room_id and tm.self_id=yyim_message.self_id and tm.maxdate=yyim_message.date group by tm.room_id,tm.self_id order by date desc"];
        
        if (limit > 0) {
            [argsArray addObject:[NSNumber numberWithInteger:limit]];
            [sql appendString:@" limit ?"];
        }
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        
        @try {
            while ([rs next]) {
                YYSearchMessage *message = [[YYSearchMessage alloc] init];
                [self fillMessage:message withResultSet:rs];
                [message setMergeCount:[rs intForColumn:@"message_count"]];
                
                [array addObject:message];
            }
        }
        @finally {
            [rs close];
        }
    }];
    
    return array;
}

- (NSArray *)getMessageWithKey:(NSString *)key chatId:(NSString *)chatId {
    __block NSMutableArray *array = [NSMutableArray array];
    
    NSMutableString *searchKey = [[NSMutableString alloc] initWithString:@"%"];
    [searchKey appendString:key];
    [searchKey appendString:@"%"];
    
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:chatId];
        [argsArray addObject:searchKey];
        
        NSString *sql = @"select yyim_message.* from yyim_message where self_id=? and room_id=? and key_info like ? order by date desc";
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        
        @try {
            while ([rs next]) {
                YYMessage *message = [[YYMessage alloc] init];
                [self fillMessage:message withResultSet:rs];
                [array addObject:message];
            }
        }
        @finally {
            [rs close];
        }
    }];
    
    return array;
}

- (NSArray *)getRosterIdArrayWithChatId:(NSString *)chatId {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:chatId]];
        
        NSString *sql = @"select distinct roster_id from yyim_message where self_id=? and room_id=?";
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            while ([rs next]) {
                [array addObject:[rs objectForColumnName:@"roster_id"]];
            }
        }
        @finally {
            [rs close];
        }
        
    }];
    return array;
}

- (void)deleteMessageWithId:(NSString *)chatId {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        [self innerDeleteMessageWithId:db chatId:chatId];
    }];
}

- (void)deleteMessageWithPid:(NSString *)packetId {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"delete from yyim_message where self_id=? and packet_id=?",[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy], packetId];
    }];
}

- (void)deleteAllMessage {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"delete from yyim_message where self_id=?",[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    }];
}

- (void)innerDeleteMessageWithId:(YYFMDatabase *)db chatId:(NSString *)chatId {
    [db executeUpdate:@"delete from yyim_message where self_id=? and room_id=?",[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy], chatId];
}

- (NSArray *)getReceivedFileMessage {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"select * from yyim_message where self_id=? and direction=? and type=?";
        
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_DIRECTION_RECEIVE]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_CONTENT_FILE]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        
        @try {
            while ([rs next]) {
                YYMessage *message = [[YYMessage alloc] init];
                [self fillMessage:message withResultSet:rs];
                [array addObject:message];
            }
        }
        @finally {
            [rs close];
        }
        
    }];
    return array;
}

- (void)updateMessageDateline:(NSTimeInterval)dateline pid:(NSString *)packetId {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[NSNumber numberWithLongLong:dateline]];
        [argsArray addObject:[YYIMStringUtility notNilString:packetId]];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        NSString *sql = @"update yyim_message set date=? where packet_id=? and self_id=?";
        [db executeUpdate:sql withArgumentsInArray:argsArray];
    }];
}

- (void)updateMessageState:(NSInteger)state pid:(NSString *)packetId {
    [self updateMessageState:state pid:packetId force:NO];
}

- (void)updateMessageState:(NSInteger)state pid:(NSString *)packetId force:(BOOL)force {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSString *sql = @"update yyim_message set status=? where packet_id=? and self_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[NSNumber numberWithInteger:state]];
        [argsArray addObject:[YYIMStringUtility notNilString:packetId]];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        if (!force) {
            sql = [sql stringByAppendingString:@" and status<?"];
            [argsArray addObject:[NSNumber numberWithInteger:state]];
        }
        [db executeUpdate:sql withArgumentsInArray:argsArray];
    }];
}

- (void)updateMessageReadedWithPid:(NSString *)packetId {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_STATE_SENT_OR_READ]];
        [argsArray addObject:[YYIMStringUtility notNilString:packetId]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_STATE_SENT_OR_READ]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_DIRECTION_RECEIVE]];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        NSString *sql = @"update yyim_message set status=? where packet_id=? and status<? and direction=? and self_id=?";
        [db executeUpdate:sql withArgumentsInArray:argsArray];
    }];
}

- (void)updateMessageReadedWithId:(NSString *)chatId {
    if ([YYIMStringUtility isEmpty:chatId]) {
        return;
    }
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_STATE_SENT_OR_READ]];
        [argsArray addObject:[YYIMStringUtility notNilString:chatId]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_STATE_SENT_OR_READ]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_DIRECTION_RECEIVE]];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        NSString *sql = @"update yyim_message set status=? where room_id=? and status<? and direction=? and self_id=?";
        [db executeUpdate:sql withArgumentsInArray:argsArray];
    }];
}

- (void)updateMessageDeliveredWithId:(NSString *)chatId {
    if ([YYIMStringUtility isEmpty:chatId]) {
        return;
    }
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_STATE_DELIVERED]];
        [argsArray addObject:[YYIMStringUtility notNilString:chatId]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_STATE_DELIVERED]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_STATE_SENT_OR_READ]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_DIRECTION_SEND]];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        NSString *sql = @"update yyim_message set status=? where room_id=? and status<? and status>=? and direction=? and self_id=?";
        [db executeUpdate:sql withArgumentsInArray:argsArray];
    }];
}

- (void)updateMessageSpecState:(NSInteger)state pid:(NSString *)packetId {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[NSNumber numberWithInteger:state]];
        [argsArray addObject:[YYIMStringUtility notNilString:packetId]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_DIRECTION_RECEIVE]];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        NSString *sql = @"update yyim_message set specific_status=? where packet_id=? and direction=? and self_id=?";
        [db executeUpdate:sql withArgumentsInArray:argsArray];
    }];
}

- (void)updateFaildMessage {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSString *sql = @"update yyim_message set status=? where direction=? and status=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_STATE_FAILD]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_DIRECTION_SEND]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_STATE_NEW]];
        [db executeUpdate:sql withArgumentsInArray:argsArray];
        
        sql = @"update yyim_message set download_status=? where download_status=?";
        argsArray = [NSMutableArray array];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_DOWNLOADSTATE_FAILD]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_DOWNLOADSTATE_ING]];
        [db executeUpdate:sql withArgumentsInArray:argsArray];
        
        sql = @"update yyim_message set upload_status=? where upload_status=?";
        argsArray = [NSMutableArray array];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_UPLOADSTATE_FAILD]];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_UPLOADSTATE_ING]];
        [db executeUpdate:sql withArgumentsInArray:argsArray];
    }];
}

/**
 *  数据库更新，将关键内容更新
 */
- (void)updateMessageKeyInfo {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //复制一张临时表
        [self copyToMessageTmpTable];
        //将临时表进行update
        [self updateMessageTmpForKeyInfo];
        //然后在写回原表
        [self updateMessageWithMessageTmp];
    });
}

- (void)copyToMessageTmpTable {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        [db executeUpdate:YYIM_MESSAGE_TMP_CREATE];
        [db executeUpdate:YYIM_MESSAGE_TMP_INIT];
    }];
}

- (void)updateMessageTmpForKeyInfo {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSString *querySql = @"select * from yyim_message_tmp";
        NSString *updateSql = @"UPDATE yyim_message_tmp SET key_info=? WHERE pkid=?";
        
        YYFMResultSet *rs = [db executeQuery:querySql];
        
        YYMessageContent *content;
        NSString *keyInfo;
        NSMutableArray *array = [NSMutableArray array];
        @try {
            while ([rs next]) {
                YYMessage *message = [[YYMessage alloc] init];
                [self fillTMPMessage:message withResultSet:rs];
                content = [message getMessageContent];
                keyInfo = [self getKeyInfoWithType:[rs intForColumn:@"type"] content:content];
                
                [array removeAllObjects];
                [array addObject:[YYIMStringUtility notNilString:keyInfo]];
                [array addObject:[NSNumber numberWithInt:[rs intForColumn:@"pkid"]]];
                
                [db executeUpdate:updateSql withArgumentsInArray:array];
            }
        }
        @finally {
            [rs close];
        }
    }];
}

- (void)updateMessageWithMessageTmp {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSString *updateSql = @"UPDATE yyim_message SET key_info=(select key_info from yyim_message_tmp where yyim_message.pkid= yyim_message_tmp.pkid)";
        
        [db executeUpdate:updateSql];
    }];
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
            
        default:
            return @"";
    }
    
    return @"";
}

- (NSInteger)getGroupVersionWithId:(NSString *)groupId {
    __block NSInteger version = 0;
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT MAX(muc_version) FROM yyim_message WHERE self_id=? AND room_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:groupId]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            if ([rs next]) {
                version = [rs intForColumnIndex:0];
            }
        }
        @finally {
            [rs close];
        }
        
    }];
    return version;
}

- (YYMessage *)revokeMessageWithPid:(NSString *)pid {
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"UPDATE yyim_message SET message=?,key_info=?,type=?,res_local=?,res_thumb_local=?,res_original_local=? WHERE self_id=? and packet_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:@"{\"content\":\"\"}"];
        [argsArray addObject:@""];
        [argsArray addObject:[NSNumber numberWithInteger:YM_MESSAGE_CONTENT_REVOKE]];
        [argsArray addObject:@""];
        [argsArray addObject:@""];
        [argsArray addObject:@""];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:pid]];
        
        [db executeUpdate:sql withArgumentsInArray:argsArray];
    }];
    return [self getMessageWithPid:pid];
}

#pragma mark -
#pragma mark chatgroup

- (void)insertChatGroup:(YYChatGroup *) group {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSArray *argsArray = [self chatGroupInsertArgsArray:group];
        //插入群组
        [db executeUpdate:YYIM_CHATGROUP_INSERT withArgumentsInArray:argsArray];
        //更新群组tag
        [self updateChatGroupTags:db group:group];
    }];
}

- (YYChatGroup *)getChatGroupWithId:(NSString *)groupId {
    __block YYChatGroup *group = nil;
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT * FROM yyim_chatgroup WHERE user_id=? and chatgroup_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:groupId]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            if ([rs next]) {
                group = [[YYChatGroup alloc] init];
                [self fillChatGroup:group withResultSet:rs];
            }
        }
        @finally {
            [rs close];
        }
        
        if (group) {
            [group setGroupTag:[self getChatGroupTagsWithGroupId:group.groupId db:db]];
        }
    }];
    
    return group;
}

- (NSArray *)getAllGroup {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT * FROM yyim_chatgroup WHERE user_id=? ORDER BY chatgroup_name ASC";
        YYFMResultSet *rs = [db executeQuery:sql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        @try {
            while ([rs next]) {
                YYChatGroup *group = [[YYChatGroup alloc] init];
                [self fillChatGroup:group withResultSet:rs];
                [array addObject:group];
            }
        }
        @finally {
            [rs close];
        }
        
        if (array.count > 0) {
            for (YYChatGroup *group in array) {
                [group setGroupTag:[self getChatGroupTagsWithGroupId:group.groupId db:db]];
            }
        }
    }];
    
    return array;
}

- (NSArray *)getAllCollectGroup {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT * FROM yyim_chatgroup WHERE user_id=? AND chatgroup_collect=? ORDER BY chatgroup_name ASC";
        YYFMResultSet *rs = [db executeQuery:sql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy], [NSNumber numberWithBool:YES]];
        @try {
            while ([rs next]) {
                YYChatGroup *group = [[YYChatGroup alloc] init];
                [self fillChatGroup:group withResultSet:rs];
                [array addObject:group];
            }
        }
        @finally {
            [rs close];
        }
        
        if (array.count > 0) {
            for (YYChatGroup *group in array) {
                [group setGroupTag:[self getChatGroupTagsWithGroupId:group.groupId db:db]];
            }
        }
    }];
    return array;
}

- (NSArray *)getAllSuperGroup {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT * FROM yyim_chatgroup WHERE user_id=? AND is_super=? ORDER BY chatgroup_name ASC";
        YYFMResultSet *rs = [db executeQuery:sql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy], [NSNumber numberWithBool:YES]];
        @try {
            while ([rs next]) {
                YYChatGroup *group = [[YYChatGroup alloc] init];
                [self fillChatGroup:group withResultSet:rs];
                [array addObject:group];
            }
        }
        @finally {
            [rs close];
        }
        
        if (array.count > 0) {
            for (YYChatGroup *group in array) {
                [group setGroupTag:[self getChatGroupTagsWithGroupId:group.groupId db:db]];
            }
        }
    }];
    return array;
}

- (void)batchUpdateChatGroup:(NSArray *)chatGroupArray {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSMutableArray *groupIdArray = [NSMutableArray array];
        NSString *sql = @"SELECT chatgroup_id FROM yyim_chatgroup WHERE user_id=?";
        YYFMResultSet *rs = [db executeQuery:sql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        @try {
            while ([rs next]) {
                [groupIdArray addObject:[rs stringForColumn:@"chatgroup_id"]];
            }
        }
        @finally {
            [rs close];
        }
        
        for (YYChatGroup *group in chatGroupArray) {
            if ([groupIdArray containsObject:[group groupId]]) {
                NSArray *argsArray = [self chatGroupUpdateArgsArray:group];
                [db executeUpdate:YYIM_CHATGROUP_UPDATE withArgumentsInArray:argsArray];
                [groupIdArray removeObject:[group groupId]];
                
                [self updateChatGroupTags:db group:group];
            } else {
                NSArray *argsArray = [self chatGroupInsertArgsArray:group];
                [db executeUpdate:YYIM_CHATGROUP_INSERT withArgumentsInArray:argsArray];
                [self updateChatGroupTags:db group:group];
            }
        }
        
        if ([groupIdArray count] > 0) {
            for (NSString *groupId in groupIdArray) {
                [self innerDeleteChatGroup:db groupId:groupId];
                [self innerDeleteChatGroupTags:db groupId:groupId];
            }
        }
    }];
}

- (void)batchUpdateChatGroup:(NSArray *)chatGroupArray allGroups:(NSArray *)groupIds collectedGroups:(NSArray *)collectedGroupIds {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSMutableArray *groupIdArray = [NSMutableArray array];
        NSString *sql = @"SELECT chatgroup_id FROM yyim_chatgroup WHERE user_id=?";
        YYFMResultSet *rs = [db executeQuery:sql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        @try {
            while ([rs next]) {
                [groupIdArray addObject:[rs stringForColumn:@"chatgroup_id"]];
            }
        }
        @finally {
            [rs close];
        }
        
        for (YYChatGroup *group in chatGroupArray) {
            if ([groupIdArray containsObject:[group groupId]]) {
                NSArray *argsArray = [self chatGroupUpdateArgsArray:group];
                [db executeUpdate:YYIM_CHATGROUP_UPDATE withArgumentsInArray:argsArray];
                [self updateChatGroupTags:db group:group];
            } else {
                NSArray *argsArray = [self chatGroupInsertArgsArray:group];
                [db executeUpdate:YYIM_CHATGROUP_INSERT withArgumentsInArray:argsArray];
                [self updateChatGroupTags:db group:group];
            }
        }
        
        for (NSString *groupId in groupIdArray) {
            if (![groupIds containsObject:groupId]) {
                [self innerDeleteChatGroup:db groupId:groupId];
                [self innerDeleteChatGroupTags:db groupId:groupId];
            }
        }
        
        [db executeUpdate:@"update yyim_chatgroup set chatgroup_collect=? where user_id=? ", [NSNumber numberWithBool:NO], [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        for (NSString *groupId in collectedGroupIds) {
            [db executeUpdate:@"update yyim_chatgroup set chatgroup_collect=? where user_id=? and chatgroup_id=? ", [NSNumber numberWithBool:YES], [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy], groupId];
        }
    }];
}

- (void)updateChatGroup:(YYChatGroup *)group {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSString *sql = @"SELECT * FROM yyim_chatgroup WHERE user_id=? AND chatgroup_id=? ";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:[group groupId]]];
        
        YYChatGroup *existGroup;
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            while ([rs next]) {
                existGroup = [[YYChatGroup alloc] init];
                [self fillChatGroup:existGroup withResultSet:rs];
            }
        }
        @finally {
            [rs close];
        }
        
        if (existGroup) {
            [group setIsCollect:[existGroup isCollect]];
            NSArray *argsArray = [self chatGroupUpdateArgsArray:group];
            [db executeUpdate:YYIM_CHATGROUP_UPDATE withArgumentsInArray:argsArray];
            [self updateChatGroupTags:db group:group];
        } else {
            NSArray *argsArray = [self chatGroupInsertArgsArray:group];
            [db executeUpdate:YYIM_CHATGROUP_INSERT withArgumentsInArray:argsArray];
            [self updateChatGroupTags:db group:group];
        }
    }];
}

- (void)deleteChatGroup:(NSString *)groupId {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        [self innerDeleteChatGroup:db groupId:groupId];
        [self innerDeleteChatGroupTags:db groupId:groupId];
    }];
    [[YYIMChatGroupMemberDBHelper sharedInstance] deleteChatGroupMembers:groupId];
}

- (void)updateChatGroupCollect:(NSString *)groupId collect:(BOOL)isCollect {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSString *sql = @"UPDATE yyim_chatgroup SET chatgroup_collect=? WHERE user_id=? AND chatgroup_id=? ";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[NSNumber numberWithBool:isCollect]];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:groupId]];
        
        [db executeUpdate:sql withArgumentsInArray:argsArray];
    }];
}

- (void)innerDeleteChatGroup:(YYFMDatabase *)db groupId:(NSString *)groupId {
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [argsArray addObject:[YYIMStringUtility notNilString:groupId]];
    
    [db executeUpdate:YYIM_CHATGROUP_DELETE withArgumentsInArray:argsArray];
    
    [self innerDeleteMessageWithId:db chatId:groupId];
}

/**
 *  更新群组的tag表
 *
 *  @param db    db
 *  @param group 群组信息
 */
- (void)updateChatGroupTags:(YYFMDatabase *)db group:(YYChatGroup *)group {
    //删除相关所有的tag
    [self innerDeleteChatGroupTags:db groupId:group.groupId];
    //如果有群组的tag逐一的加入
    NSMutableArray *argsArray = [NSMutableArray array];
    if (group.groupTag && group.groupTag.count > 0) {
        for (NSString *tag in group.groupTag) {
            if (![YYIMStringUtility isEmpty:tag]) {
                [argsArray removeAllObjects];
                [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
                [argsArray addObject:[YYIMStringUtility notNilString:group.groupId]];
                [argsArray addObject:tag];
                [db executeUpdate:YYIM_CHATGROUP_TAG_INSERT withArgumentsInArray:argsArray];
            }
        }
    }
}

- (void)innerDeleteChatGroupTags:(YYFMDatabase *)db groupId:(NSString *)groupId {
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [argsArray addObject:[YYIMStringUtility notNilString:groupId]];
    [db executeUpdate:YYIM_CHATGROUP_TAG_DELETE withArgumentsInArray:argsArray];
}

/**
 *  通过群组id查询群组的tag集合
 *
 *  @param groupId 群组id
 *
 *  @return
 */
- (NSArray *)getChatGroupTagsWithGroupId:(NSString *)groupId db:(YYFMDatabase *)db{
    NSMutableArray *array = [NSMutableArray array];
    NSString *sql = @"SELECT * FROM yyim_chatgroup_tag WHERE user_id=? and chatgroup_id=?";
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [argsArray addObject:[YYIMStringUtility notNilString:groupId]];
    
    YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
    @try {
        while ([rs next]) {
            [array addObject:[rs stringForColumn:@"tag"]];
        }
    }
    @finally {
        [rs close];
    }
    return array;
}

/**
 *  通过tag获取群组集合
 *
 *  @param tag tag
 *
 *  @return 群组集合
 */
- (NSArray *)getChatGroupsWithTag:(NSString *)tag {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT chatgroup_id FROM yyim_chatgroup_tag WHERE user_id=? AND tag=? GROUP BY chatgroup_id";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:tag]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        NSMutableArray *groupIdArray = [NSMutableArray array];
        
        @try {
            while ([rs next]) {
                [groupIdArray addObject:[rs stringForColumn:@"chatgroup_id"]];
            }
        }
        @finally {
            [rs close];
        }
        
        if (groupIdArray.count > 0) {
            for (NSString *groupId in groupIdArray) {
                YYChatGroup *group = [self innerGetChatGroup:db groupId:groupId];
                
                if (group) {
                    [array addObject:group];
                }
            }
        }
    }];
    
    return array;
}

- (YYChatGroup *)innerGetChatGroup:(YYFMDatabase *)db groupId:(NSString *) groupId {
    NSString *sql = @"SELECT * FROM yyim_chatgroup WHERE user_id=? and chatgroup_id=?";
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [argsArray addObject:[YYIMStringUtility notNilString:groupId]];
    
    YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
    YYChatGroup *group = nil;
    
    @try {
        if ([rs next]) {
            group = [[YYChatGroup alloc] init];
            [self fillChatGroup:group withResultSet:rs];
        }
    }
    @finally {
        [rs close];
    }
    
    if (group) {
        [group setGroupTag:[self getChatGroupTagsWithGroupId:group.groupId db:db]];
    }
    
    return  group;
}

#pragma mark -
#pragma mark user

- (YYUser *)getUserWithId:(NSString *)userId {
    if ([YYIMStringUtility isEmpty:userId]) {
        return nil;
    }
    
    NSString *fullUser = [YYIMJUMPHelper genFullUser:userId];
    __block YYUser *user = nil;
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT * FROM yyim_user WHERE user_id=?";
        YYFMResultSet *rs = [db executeQuery:sql, fullUser];
        @try {
            while ([rs next]) {
                user = [[YYUser alloc] init];
                NSString *fullUser = [rs stringForColumn:@"user_id"];
                [user setUserId:[YYIMJUMPHelper parseUser:fullUser]];
                [user setUserName:[rs stringForColumn:@"user_name"]];
                [user setUserEmail:[rs stringForColumn:@"user_email"]];
                [user setUserOrg:[rs stringForColumn:@"user_org"]];
                [user setUserUnit:[rs stringForColumn:@"user_unit"]];
                [user setUserOrgId:[rs stringForColumn:@"user_orgid"]];
                [user setUserPhoto:[rs stringForColumn:@"user_photo"]];
                [user setUserMobile:[rs stringForColumn:@"user_mobile"]];
                [user setUserTitle:[rs stringForColumn:@"user_title"]];
                [user setUserGender:[rs stringForColumn:@"user_gender"]];
                [user setUserNumber:[rs stringForColumn:@"user_number"]];
                [user setUserTelephone:[rs stringForColumn:@"user_telephone"]];
                [user setUserLocation:[rs stringForColumn:@"user_location"]];
                [user setUserDesc:[rs stringForColumn:@"user_desc"]];
                [user setLastUpdate:[rs longForColumn:@"last_update"]];
            }
        }
        @finally {
            [rs close];
        }
        
        if (user) {
            [user setUserTag:[self getUserTagsWithUserId:user.userId db:db]];
        }
    }];
    
    return user;
}

- (void)insertOrUpdateUser:(YYUser *)user {
    if ([YYIMStringUtility isEmpty:[user userId]]) {
        return;
    }
    
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSString *fullUser = [YYIMJUMPHelper genFullUser:[user userId]];
        NSInteger count = 0;
        NSString *sql = @"SELECT COUNT(*) FROM yyim_user WHERE user_id=?";
        YYFMResultSet *rs = [db executeQuery:sql,[YYIMStringUtility notNilString:fullUser]];
        @try {
            if ([rs next]) {
                count = [rs intForColumnIndex:0];
                NSMutableArray *array = [NSMutableArray array];
                if (count > 0) {
                    [array addObject:[YYIMStringUtility notNilString:[user userName]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userEmail]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userOrg]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userUnit]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userOrgId]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userPhoto]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userMobile]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userTitle]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userGender]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userNumber]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userTelephone]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userLocation]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userDesc]]];
                    [array addObject:[NSNumber numberWithLongLong:[user lastUpdate]]];
                    [array addObject:[YYIMStringUtility notNilString:fullUser]];
                    [db executeUpdate:YYIM_USER_UPDATE withArgumentsInArray:array];
                    [self updateUserTags:db user:user];
                } else {
                    [array addObject:[YYIMStringUtility notNilString:fullUser]];
                    [array addObject:[YYIMStringUtility notNilString:[user userName]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userEmail]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userOrg]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userUnit]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userOrgId]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userPhoto]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userMobile]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userTitle]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userGender]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userNumber]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userTelephone]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userLocation]]];
                    [array addObject:[YYIMStringUtility notNilString:[user userDesc]]];
                    [array addObject:[NSNumber numberWithLongLong:[user lastUpdate]]];
                    [db executeUpdate:YYIM_USER_INSERT withArgumentsInArray:array];
                    [self updateUserTags:db user:user];
                }
            }
        }
        @finally {
            [rs close];
        }
    }];
}

- (void)deleteUnExistUser:(NSString *)userId {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        // delete user
        NSString *fullUser = [YYIMJUMPHelper genFullUser:userId];
        NSString *sql = @"delete from yyim_user where user_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[YYIMStringUtility notNilString:fullUser]];
        [db executeUpdate:sql withArgumentsInArray:argsArray];
        // delete message about
        [db executeUpdate:@"delete from yyim_message where self_id=? and roster_id=?",[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy], userId];
    }];
}

/**
 *  增加用户的tag（会自动去重）
 *
 *  @param tagArray tag集合
 *  @param rosterId 用户Id
 */
- (void)insertUserTags:(NSArray *)tagArray userId:(NSString *)userId {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSMutableArray *newTagArray = [NSMutableArray arrayWithArray:tagArray];
        NSMutableArray *oldTagArray = [NSMutableArray array];
        NSString *sql = @"SELECT tag FROM yyim_user_tag WHERE self_id=? AND user_id=?";
        YYFMResultSet *rs = [db executeQuery:sql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy], userId];
        
        @try {
            while ([rs next]) {
                [oldTagArray addObject:[rs stringForColumn:@"tag"]];
            }
        }
        @finally {
            [rs close];
        }
        
        [newTagArray removeObjectsInArray:oldTagArray];
        
        for (NSString *tag in newTagArray) {
            if (![YYIMStringUtility isEmpty:tag]) {
                NSMutableArray *argsArray = [NSMutableArray array];
                [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
                [argsArray addObject:[YYIMStringUtility notNilString:userId]];
                [argsArray addObject:tag];
                [db executeUpdate:YYIM_USER_TAG_INSERT withArgumentsInArray:argsArray];
            }
        }
    }];
}

/**
 *  删除用户的tag
 *
 *  @param tagArray tag集合
 *  @param rosterId 用户Id
 */
- (void)deletetUserTags:(NSArray *)tagArray userId:(NSString *)userId {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        for (NSString *tag in tagArray) {
            NSMutableArray *argsArray = [NSMutableArray array];
            [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
            [argsArray addObject:[YYIMStringUtility notNilString:userId]];
            [argsArray addObject:tag];
            [db executeUpdate:YYIM_USER_TAG_DELETE withArgumentsInArray:argsArray];
        }
    }];
}

/**
 *  更新用户的tag表
 *
 *  @param db   db
 *  @param user 用户信息
 */
- (void)updateUserTags:(YYFMDatabase *)db user:(YYUser *)user {
    //目前只有用户自己的tag需要使用用户tag功能
    if (![user.userId isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        return;
    }
    
    //删除相关所有的tag
    [self innerDeleteUserTags:db userId:user.userId];
    
    //如果有用户的tag逐一的加入
    if (user.userTag && user.userTag.count > 0) {
        NSMutableArray *argsArray = [NSMutableArray array];
        for (NSString *tag in user.userTag) {
            if (![YYIMStringUtility isEmpty:tag]) {
                [argsArray removeAllObjects];
                [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
                [argsArray addObject:[YYIMStringUtility notNilString:user.userId]];
                [argsArray addObject:tag];
                [db executeUpdate:YYIM_USER_TAG_INSERT withArgumentsInArray:argsArray];
            }
        }
    }
}

- (void)innerDeleteUserTags:(YYFMDatabase *)db userId:(NSString *)userId {
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [argsArray addObject:[YYIMStringUtility notNilString:userId]];
    [db executeUpdate:@"DELETE FROM yyim_user_tag WHERE self_id=? AND user_id=?" withArgumentsInArray:argsArray];
}

/**
 *  获得用户tag集合
 *
 *  @param userId 用户id
 *  @param db     db
 *
 *  @return
 */
- (NSArray *)getUserTagsWithUserId:(NSString *)userId db:(YYFMDatabase *)db {
    //目前只有用户自己的tag需要使用用户tag功能
    if (![userId isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        return [NSArray array];
    }
    
    NSMutableArray *array = [NSMutableArray array];
    NSString *sql = @"SELECT * FROM yyim_user_tag WHERE self_id=? and user_id=?";
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [argsArray addObject:[YYIMStringUtility notNilString:userId]];
    
    YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
    @try {
        while ([rs next]) {
            [array addObject:[rs stringForColumn:@"tag"]];
        }
    }
    @finally {
        [rs close];
    }
    return array;
}

#pragma mark -
#pragma mark ext

- (YYUserExt *)getUserExtWithId:(NSString *)userId {
    if ([YYIMStringUtility isEmpty:userId]) {
        return nil;
    }
    
    __block YYUserExt *userExt;
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT * FROM yyim_user_ext WHERE user_id=? AND ext_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:userId]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            if ([rs next]) {
                userExt = [[YYUserExt alloc] init];
                [userExt setUserId:[rs stringForColumn:@"ext_id"]];
                [userExt setNoDisturb:[rs intForColumn:@"no_disturb"]];
                [userExt setStickTop:[rs intForColumn:@"stick_top"]];
            }
        }
        @finally {
            [rs close];
        }
        if (!userExt) {
            userExt = [YYUserExt defaultUserExt:userId];
        }
    }];
    return userExt;
}

- (void)updateUserExt:(YYUserExt *)userExt {
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSInteger count = 0;
        NSString *sql = @"SELECT COUNT(*) FROM yyim_user_ext WHERE user_id=? AND ext_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:[userExt userId]]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            if ([rs next]) {
                count = [rs intForColumnIndex:0];
            }
        }
        @finally {
            [rs close];
        }
        if (count > 0) {
            [argsArray removeAllObjects];
            [argsArray addObject:[NSNumber numberWithInteger:[userExt noDisturb]]];
            [argsArray addObject:[NSNumber numberWithInteger:[userExt stickTop]]];
            [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
            [argsArray addObject:[YYIMStringUtility notNilString:[userExt userId]]];
            [db executeUpdate:YYIM_USER_EXT_UPDATE withArgumentsInArray:argsArray];
        } else {
            [argsArray removeAllObjects];
            [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
            [argsArray addObject:[YYIMStringUtility notNilString:[userExt userId]]];
            [argsArray addObject:[NSNumber numberWithInteger:[userExt noDisturb]]];
            [argsArray addObject:[NSNumber numberWithInteger:[userExt stickTop]]];
            [db executeUpdate:YYIM_USER_EXT_INSERT withArgumentsInArray:argsArray];
        }
    }];
}

- (YYChatGroupExt *)getChatGroupExtWithId:(NSString *)groupId {
    if ([YYIMStringUtility isEmpty:groupId]) {
        return nil;
    }
    
    __block YYChatGroupExt *groupExt;
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT * FROM yyim_chatgroup_ext WHERE user_id=? AND chatgroup_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:groupId]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            if ([rs next]) {
                groupExt = [[YYChatGroupExt alloc] init];
                [groupExt setGroupId:[rs stringForColumn:@"chatgroup_id"]];
                [groupExt setNoDisturb:[rs intForColumn:@"no_disturb"]];
                [groupExt setStickTop:[rs intForColumn:@"stick_top"]];
                [groupExt setShowName:[rs intForColumn:@"show_name"]];
            }
        }
        @finally {
            [rs close];
        }
        if (!groupExt) {
            groupExt = [YYChatGroupExt defaultChatGroupExt:groupId];
        }
    }];
    return groupExt;
}

- (void)updateChatGroupExt:(YYChatGroupExt *)chatGroupExt {
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSInteger count = 0;
        NSString *sql = @"SELECT COUNT(*) FROM yyim_chatgroup_ext WHERE user_id=? AND chatgroup_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:[chatGroupExt groupId]]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            if ([rs next]) {
                count = [rs intForColumnIndex:0];
            }
        }
        @finally {
            [rs close];
        }
        if (count > 0) {
            [argsArray removeAllObjects];
            [argsArray addObject:[NSNumber numberWithInteger:[chatGroupExt noDisturb]]];
            [argsArray addObject:[NSNumber numberWithInteger:[chatGroupExt stickTop]]];
            [argsArray addObject:[NSNumber numberWithInteger:[chatGroupExt showName]]];
            [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
            [argsArray addObject:[YYIMStringUtility notNilString:[chatGroupExt groupId]]];
            [db executeUpdate:YYIM_CHATGROUP_EXT_UPDATE withArgumentsInArray:argsArray];
        } else {
            [argsArray removeAllObjects];
            [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
            [argsArray addObject:[YYIMStringUtility notNilString:[chatGroupExt groupId]]];
            [argsArray addObject:[NSNumber numberWithInteger:[chatGroupExt noDisturb]]];
            [argsArray addObject:[NSNumber numberWithInteger:[chatGroupExt stickTop]]];
            [argsArray addObject:[NSNumber numberWithInteger:[chatGroupExt showName]]];
            [db executeUpdate:YYIM_CHATGROUP_EXT_INSERT withArgumentsInArray:argsArray];
        }
    }];
}

- (YYPubAccountExt *)getPubAccountExtWithId:(NSString *)accountId {
    if ([YYIMStringUtility isEmpty:accountId]) {
        return nil;
    }
    
    __block YYPubAccountExt *accountExt;
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT * FROM yyim_pubaccount_ext WHERE user_id=? AND account_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:accountId]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            if ([rs next]) {
                accountExt = [[YYPubAccountExt alloc] init];
                [accountExt setAccountId:[rs stringForColumn:@"account_id"]];
                [accountExt setNoDisturb:[rs intForColumn:@"no_disturb"]];
                [accountExt setStickTop:[rs intForColumn:@"stick_top"]];
            }
        }
        @finally {
            [rs close];
        }
        
        if (!accountExt) {
            accountExt = [YYPubAccountExt defaultPubAccountExt:accountId];
        }
    }];
    return accountExt;
}

- (void)updatePubAccountExt:(YYPubAccountExt *)accountExt {
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSInteger count = 0;
        NSString *sql = @"SELECT COUNT(*) FROM yyim_pubaccount_ext WHERE user_id=? AND account_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:[accountExt accountId]]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            if ([rs next]) {
                count = [rs intForColumnIndex:0];
            }
        }
        @finally {
            [rs close];
        }
        if (count > 0) {
            [argsArray removeAllObjects];
            [argsArray addObject:[NSNumber numberWithInteger:[accountExt noDisturb]]];
            [argsArray addObject:[NSNumber numberWithInteger:[accountExt stickTop]]];
            [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
            [argsArray addObject:[YYIMStringUtility notNilString:[accountExt accountId]]];
            [db executeUpdate:YYIM_PUBACCOUNT_EXT_UPDATE withArgumentsInArray:argsArray];
        } else {
            [argsArray removeAllObjects];
            [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
            [argsArray addObject:[YYIMStringUtility notNilString:[accountExt accountId]]];
            [argsArray addObject:[NSNumber numberWithInteger:[accountExt noDisturb]]];
            [argsArray addObject:[NSNumber numberWithInteger:[accountExt stickTop]]];
            [db executeUpdate:YYIM_PUBACCOUNT_EXT_INSERT withArgumentsInArray:argsArray];
        }
    }];
}

- (void)clearNoDisturb {
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"UPDATE yyim_user_ext SET no_disturb=? WHERE user_id=? ";
        [db executeUpdate:sql, [NSNumber numberWithBool:NO], [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        sql = @"UPDATE yyim_chatgroup_ext SET no_disturb=? WHERE user_id=? ";
        [db executeUpdate:sql, [NSNumber numberWithBool:NO], [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        sql = @"UPDATE yyim_pubaccount_ext SET no_disturb=? WHERE user_id=? ";
        [db executeUpdate:sql, [NSNumber numberWithBool:NO], [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    }];
}

- (void)clearStickTop {
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"UPDATE yyim_user_ext SET stick_top=? WHERE user_id=? ";
        [db executeUpdate:sql, [NSNumber numberWithBool:NO], [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        sql = @"UPDATE yyim_chatgroup_ext SET stick_top=? WHERE user_id=? ";
        [db executeUpdate:sql, [NSNumber numberWithBool:NO], [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        sql = @"UPDATE yyim_pubaccount_ext SET stick_top=? WHERE user_id=? ";
        [db executeUpdate:sql, [NSNumber numberWithBool:NO], [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    }];
}

- (void)updateUserProfile:(NSDictionary<NSString *, NSString *> *)profileDic {
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *deleteSql = @"DELETE FROM yyim_user_profile WHERE user_id=? ";
        [db executeUpdate:deleteSql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        
        NSString *insertSql = @"INSERT INTO yyim_user_profile(user_id,profile_key,profile_value) VALUES (?,?,?) ";
        for (NSString *profileKey in profileDic.allKeys) {
            [db executeUpdate:insertSql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy], profileKey, [profileDic objectForKey:profileKey]];
        }
    }];
}

- (NSDictionary<NSString *, NSString *> *)getUserProfiles {
    __block NSMutableDictionary<NSString *, NSString *> *profileDic = [NSMutableDictionary dictionary];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT * FROM yyim_user_profile WHERE user_id=? ";
        YYFMResultSet *rs = [db executeQuery:sql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        @try {
            while ([rs next]) {
                NSString *profileKey = [rs stringForColumn:@"profile_key"];
                NSString *profileValue = [rs stringForColumn:@"profile_value"];
                [profileDic setObject:profileValue forKey:profileKey];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return profileDic;
}

#pragma mark -
#pragma mark pub account

- (NSArray *)getAllPubAccount {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT * FROM yyim_pubaccount WHERE user_id=? ORDER BY account_id";
        YYFMResultSet *rs = [db executeQuery:sql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        @try {
            while ([rs next]) {
                YYPubAccount *account = [[YYPubAccount alloc] init];
                [account setAccountId:[rs stringForColumn:@"account_id"]];
                [account setAccountName:[rs stringForColumn:@"account_name"]];
                [account setAccountPhoto:[rs stringForColumn:@"account_photo"]];
                [account setAccountType:[rs intForColumn:@"account_type"]];
                [account setAccountDesc:[rs stringForColumn:@"account_description"]];
                [array addObject:account];
            }
        }
        @finally {
            [rs close];
        }
        
        if (array.count > 0) {
            for (YYPubAccount *account in array) {
                [account setAccountTag:[self getPubAccountTagsWithAccountId:account.accountId db:db]];
            }
        }
    }];
    
    return array;
}

- (void)insertOrUpdatePubAccount:(YYPubAccount *)account {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSInteger count = 0;
        NSString *sql = @"SELECT COUNT(*) FROM yyim_pubaccount WHERE user_id=? AND account_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:[account accountId]]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            if ([rs next]) {
                count = [rs intForColumnIndex:0];
                if (count > 0) {
                    [self innerUpdatePubAccount:db account:account];
                    [self updatePubAccountTags:db account:account];
                } else {
                    [self innerInsertPubAccount:db account:account];
                    [self updatePubAccountTags:db account:account];
                }
            }
        }
        @finally {
            [rs close];
        }
    }];
}

- (void)deletePubAccount:(NSString *)accountId {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        [self innerDeletePubAccount:db accountId:accountId];
        [self innerDeleteMessageWithId:db chatId:accountId];
    }];
}

- (void)batchUpdatePubAccount:(NSArray *)accountArray {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSMutableArray *accountIdArray = [NSMutableArray array];
        NSString *sql = @"SELECT account_id FROM yyim_pubaccount WHERE user_id=?";
        YYFMResultSet *rs = [db executeQuery:sql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        @try {
            while ([rs next]) {
                [accountIdArray addObject:[rs stringForColumn:@"account_id"]];
            }
        }
        @finally {
            [rs close];
        }
        
        for (YYPubAccount *account in accountArray) {
            if ([accountIdArray containsObject:[account accountId]]) {
                [self innerUpdatePubAccount:db account:account];
                [accountIdArray removeObject:[account accountId]];
                [self updatePubAccountTags:db account:account];
            } else {
                [self innerInsertPubAccount:db account:account];
                [self updatePubAccountTags:db account:account];
            }
        }
        
        if ([accountIdArray count] > 0) {
            for (NSString *accountId in accountIdArray) {
                [self innerDeletePubAccount:db accountId:accountId];
                [self innerDeletePubAccountTags:db accountId:accountId];
                [self innerDeleteMessageWithId:db chatId:accountId];
            }
        }
    }];
}

- (YYPubAccount *)getPubAccountWithId:(NSString *)accountId {
    __block YYPubAccount *account = nil;
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        account = [self innerGetPubAccount:db accountId:accountId];
        if (account) {
            [account setAccountTag:[self getPubAccountTagsWithAccountId:accountId db:db]];
        }
    }];
    return account;
}

- (void)innerInsertPubAccount:(YYFMDatabase *)db account:(YYPubAccount *)account {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [array addObject:[YYIMStringUtility notNilString:[account accountId]]];
    [array addObject:[YYIMStringUtility notNilString:[account accountName]]];
    [array addObject:[YYIMStringUtility notNilString:[account accountPhoto]]];
    [array addObject:[NSNumber numberWithInteger:[account accountType]]];
    [array addObject:[YYIMStringUtility notNilString:[account accountDesc]]];
    [db executeUpdate:YYIM_PUBACCOUNT_INSERT withArgumentsInArray:array];
}

- (void)innerUpdatePubAccount:(YYFMDatabase *)db account:(YYPubAccount *)account {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[YYIMStringUtility notNilString:[account accountName]]];
    [array addObject:[YYIMStringUtility notNilString:[account accountPhoto]]];
    [array addObject:[NSNumber numberWithInteger:[account accountType]]];
    [array addObject:[YYIMStringUtility notNilString:[account accountDesc]]];
    [array addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [array addObject:[YYIMStringUtility notNilString:[account accountId]]];
    [db executeUpdate:YYIM_PUBACCOUNT_UPDATE withArgumentsInArray:array];
}

- (void)innerDeletePubAccount:(YYFMDatabase *)db accountId:(NSString *)accountId {
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [argsArray addObject:[YYIMStringUtility notNilString:accountId]];
    
    [db executeUpdate:YYIM_PUBACCOUNT_DELETE withArgumentsInArray:argsArray];
}

- (YYPubAccount *)innerGetPubAccount:(YYFMDatabase *)db accountId:(NSString *)accountId {
    NSString *sql = @"SELECT * FROM yyim_pubaccount WHERE user_id=? and account_id=?";
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [argsArray addObject:[YYIMStringUtility notNilString:accountId]];
    
    YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
    @try {
        if ([rs next]) {
            YYPubAccount *account = [[YYPubAccount alloc] init];
            [account setAccountId:[rs stringForColumn:@"account_id"]];
            [account setAccountName:[rs stringForColumn:@"account_name"]];
            [account setAccountPhoto:[rs stringForColumn:@"account_photo"]];
            [account setAccountType:[rs intForColumn:@"account_type"]];
            [account setAccountDesc:[rs stringForColumn:@"account_description"]];
            return account;
        }
    }
    @finally {
        [rs close];
    }
    return nil;
}

/**
 *  更新公共号的tag表
 *
 *  @param db    db
 *  @param account公共号信息
 */
- (void)updatePubAccountTags:(YYFMDatabase *)db account:(YYPubAccount *)account {
    //删除相关所有的tag
    [self innerDeletePubAccountTags:db accountId:account.accountId];
    
    //如果有公共号的tag逐一的加入
    if (account.accountTag && account.accountTag.count > 0) {
        NSMutableArray *argsArray = [NSMutableArray array];
        for (NSString *tag in account.accountTag) {
            if (![YYIMStringUtility isEmpty:tag]) {
                [argsArray removeAllObjects];
                [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
                [argsArray addObject:[YYIMStringUtility notNilString:account.accountId]];
                [argsArray addObject:tag];
                [db executeUpdate:YYIM_PUBACCOUNT_TAG_INSERT withArgumentsInArray:argsArray];
            }
        }
    }
}

- (void)innerDeletePubAccountTags:(YYFMDatabase *)db accountId:(NSString *)accountId {
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [argsArray addObject:[YYIMStringUtility notNilString:accountId]];
    [db executeUpdate:YYIM_PUBACCOUNT_TAG_DELETE withArgumentsInArray:argsArray];
}

/**
 *  通过公共号id查询公共号的tag集合
 *
 *  @param accountId公共号id
 *
 *  @return
 */
- (NSArray *)getPubAccountTagsWithAccountId:(NSString *)accountId db:(YYFMDatabase *)db{
    NSMutableArray *array = [NSMutableArray array];
    NSString *sql = @"SELECT * FROM yyim_pubaccount_tag WHERE user_id=? and account_id=?";
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [argsArray addObject:[YYIMStringUtility notNilString:accountId]];
    
    YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
    @try {
        while ([rs next]) {
            [array addObject:[rs stringForColumn:@"tag"]];
        }
    }
    @finally {
        [rs close];
    }
    return array;
}

/**
 *  通过tag获取公共号集合
 *
 *  @param tag tag
 *
 *  @return公共号集合
 */
- (NSArray *)getPubAccountsWithTag:(NSString *)tag {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSString *sql = @"SELECT account_id FROM yyim_pubaccount_tag WHERE user_id=? AND tag=? GROUP BY account_id";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:tag]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        NSMutableArray *accountIdArray = [NSMutableArray array];
        
        @try {
            while ([rs next]) {
                [accountIdArray addObject:[rs stringForColumn:@"account_id"]];
            }
        }
        @finally {
            [rs close];
        }
        
        if (accountIdArray.count > 0) {
            for (NSString *accoutId in accountIdArray) {
                YYPubAccount *accout = [self innerGetPubAccount:db accountId:accoutId];
                
                if (accout) {
                    [array addObject:accout];
                }
            }
        }
    }];
    
    return array;
}

/**
 *  获得公共号菜单
 *
 *  @param accountId公共号id
 *
 *  @return
 */
- (YYPubAccountMenu *)getPubAccountMenu:(NSString *)accountId {
    __block YYPubAccountMenu *accountMenu = nil;
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        
        NSString *sql = @"SELECT * FROM yyim_pubaccount_menu WHERE user_id=? and account_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:accountId]];
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        
        @try {
            if ([rs next]) {
                accountMenu = [[YYPubAccountMenu alloc] init];
                [accountMenu setAccountId:[rs stringForColumn:@"account_id"]];
                [accountMenu setMenuJson:[rs stringForColumn:@"menu"]];
                [accountMenu setLastUpdate:[rs longForColumn:@"last_update"]];
                [accountMenu setTs:[rs longLongIntForColumn:@"ts"]];
            }
        }
        @finally {
            [rs close];
        }
    }];
    
    return accountMenu;
}

/**
 *  插入公共号菜单
 *
 *  @param menu      菜单json
 *  @param accountId公共号id
 */
- (void)insertOrUpdatePubAccountMenu:(YYPubAccountMenu *)menu accountId:(NSString *)accountId {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSInteger count = 0;
        NSString *sql = @"SELECT COUNT(*) FROM yyim_pubaccount_menu WHERE user_id=? AND account_id=?";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:accountId]];
        
        YYFMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            if ([rs next]) {
                count = [rs intForColumnIndex:0];
                if (count > 0) {
                    NSMutableArray *array = [NSMutableArray array];
                    [array addObject:[YYIMStringUtility notNilString:menu.menuJson]];
                    [array addObject:[NSNumber numberWithLongLong:[menu lastUpdate]]];
                    [array addObject:[NSNumber numberWithLongLong:[menu ts]]];
                    [array addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
                    [array addObject:[YYIMStringUtility notNilString:accountId]];
                    [db executeUpdate:YYIM_PUBACCOUNT_MENU_UPDATE withArgumentsInArray:array];
                } else {
                    NSMutableArray *array = [NSMutableArray array];
                    [array addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
                    [array addObject:[YYIMStringUtility notNilString:accountId]];
                    [array addObject:[YYIMStringUtility notNilString:menu.menuJson]];
                    [array addObject:[NSNumber numberWithLongLong:[menu lastUpdate]]];
                    [array addObject:[NSNumber numberWithLongLong:[menu ts]]];
                    [db executeUpdate:YYIM_PUBACCOUNT_MENU_INSERT withArgumentsInArray:array];
                    
                }
            }
        }
        @finally {
            [rs close];
        }
    }];
}

/**
 *  删除公共号菜单
 *
 *  @param accountId公共号id
 */
- (void)deletePubAccountMenu:(NSString *)accountId {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
        [argsArray addObject:[YYIMStringUtility notNilString:accountId]];
        
        [db executeUpdate:YYIM_PUBACCOUNT_MENU_DELETE withArgumentsInArray:argsArray];
    }];
}

#pragma mark -
#pragma mark assist

- (void)fillMessage:(YYMessage *)message withResultSet:(YYFMResultSet *)rs {
    [message setPkid:[rs intForColumn:@"pkid"]];
    [message setPid:[rs stringForColumn:@"packet_id"]];
    [message setDirection:[rs intForColumn:@"direction"]];
    if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE) {
        [message setFromId:[rs stringForColumn:@"room_id"]];
        [message setToId:[YYIMJUMPHelper parseUser:[rs stringForColumn:@"self_id"]]];
    } else {
        [message setFromId:[YYIMJUMPHelper parseUser:[rs stringForColumn:@"self_id"]]];
        [message setToId:[rs stringForColumn:@"room_id"]];
    }
    [message setRosterId:[rs stringForColumn:@"roster_id"]];
    [message setMessage:[rs stringForColumn:@"message"]];
    [message setKeyInfo:[rs stringForColumn:@"key_info"]];
    [message setStatus:[rs intForColumn:@"status"]];
    [message setDownloadStatus:[rs intForColumn:@"download_status"]];
    [message setUploadStatus:[rs intForColumn:@"upload_status"]];
    [message setSpecificStatus:[rs intForColumn:@"specific_status"]];
    [message setType:[rs intForColumn:@"type"]];
    [message setChatType:[rs stringForColumn:@"chat_type"]];
    [message setResLocal:[rs stringForColumn:@"res_local"]];
    [message setResThumbLocal:[rs stringForColumn:@"res_thumb_local"]];
    [message setResOriginalLocal:[rs stringForColumn:@"res_original_local"]];
    [message setDate:[rs doubleForColumn:@"date"]];
    [message setClientType:[rs intForColumn:@"client_type"]];
    [message setVersion:[rs longForColumn:@"version"]];
    [message setMucVersion:[rs longForColumn:@"muc_version"]];
    [message setCustomType:[rs intForColumn:@"custom_type"]];
}

- (void)fillTMPMessage:(YYMessage *)message withResultSet:(YYFMResultSet *)rs {
    [message setPkid:[rs intForColumn:@"pkid"]];
    [message setMessage:[rs stringForColumn:@"message"]];
    [message setKeyInfo:[rs stringForColumn:@"key_info"]];
    [message setType:[rs intForColumn:@"type"]];
}

- (void)fillChatGroup:(YYChatGroup *)group withResultSet:(YYFMResultSet *)rs {
    [group setGroupId:[rs stringForColumn:@"chatgroup_id"]];
    [group setGroupName:[rs stringForColumn:@"chatgroup_name"]];
    [group setIsCollect:[rs boolForColumn:@"chatgroup_collect"]];
    [group setIsSuper:[rs boolForColumn:@"is_super"]];
    [group setMemberCount:[rs intForColumn:@"member_count"]];
    [group setIsOwner:[rs boolForColumn:@"is_owner"]];
    [group setTs:[rs longLongIntForColumn:@"ts"]];
}

- (NSArray *)chatGroupInsertArgsArray:(YYChatGroup *)group {
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [argsArray addObject:[YYIMStringUtility notNilString:[group groupId]]];
    [argsArray addObject:[YYIMStringUtility notNilString:[group groupName]]];
    
    //因为sqlite不支持删除列，所以tag的5个列，还在，默认都设置成空字符串
    for (int i = 0; i < 5; i++) {
        [argsArray addObject:@""];
    }
    
    [argsArray addObject:[NSNumber numberWithInt:[group isCollect] ? 1 : 0]];
    [argsArray addObject:[NSNumber numberWithInt:[group isSuper] ? 1: 0]];
    [argsArray addObject:[NSNumber numberWithInteger:[group memberCount]]];
    [argsArray addObject:[NSNumber numberWithInt:[group isOwner] ? 1 : 0]];
    [argsArray addObject:[NSNumber numberWithLongLong:[group ts]]];
    return argsArray;
}

- (NSArray *)chatGroupUpdateArgsArray:(YYChatGroup *)group {
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObject:[YYIMStringUtility notNilString:[group groupName]]];
    
    //因为sqlite不支持删除列，所以tag的5个列，还在，默认都设置成空字符串
    for (int i = 0; i < 5; i++) {
        [argsArray addObject:@""];
    }
    
    [argsArray addObject:[NSNumber numberWithInt:[group isCollect] ? 1 : 0]];
    [argsArray addObject:[NSNumber numberWithInt:[group isSuper] ? 1: 0]];
    [argsArray addObject:[NSNumber numberWithInteger:[group memberCount]]];
    [argsArray addObject:[NSNumber numberWithInt:[group isOwner] ? 1 : 0]];
    [argsArray addObject:[NSNumber numberWithLongLong:[group ts]]];
    
    [argsArray addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
    [argsArray addObject:[YYIMStringUtility notNilString:[group groupId]]];
    return argsArray;
}

@end