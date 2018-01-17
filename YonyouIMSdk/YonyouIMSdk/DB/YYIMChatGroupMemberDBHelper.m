//
//  YYIMChatGroupMemberDBHelper.m
//  YonyouIMSdk
//
//  Created by litfb on 15/5/25.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMChatGroupMemberDBHelper.h"
#import "YYFMDB.h"
#import "YYIMDBHeader.h"
#import "YYIMStringUtility.h"
#import "YYIMConfig.h"

#define YM_CHAT_MEMBER_DB @"ym_member.sqlite"

@implementation YYIMChatGroupMemberDBHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (NSString *)defaultDBName {
    return YM_CHAT_MEMBER_DB;
}

- (void) updateDatabase {
    NSInteger dbVersion = [self getDbVersion];
    
    switch (dbVersion) {
        case YYIM_DB_VERSION_EMPTY:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_DBINFO_CREATE];
                [db executeUpdate:YYIM_CHATGROUPMEMBER_CREATE];
                [db executeUpdate:YYIM_CHATGROUPMEMBER_IDX_UNIQUE];
                [db executeUpdate:YYIM_DBINFO_INIT];
            }];
        case YYIM_DB_VERSION_INITIAL:
            [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
                [db executeUpdate:YYIM_CHATGROUPMEMBER_ADD_AFFILIATION];
                [db executeUpdate:YYIM_DBINFO_UPDATE, [NSNumber numberWithInteger:YYIM_DB_VERSION_1]];
            }];
    }
}

#pragma mark chatgroup member

- (void)batchUpdateChatGroupMember:(NSString *)groupId members:(NSArray *)memberArray {
    if ([YYIMStringUtility isEmpty:groupId]) {
        return;
    }
    
    __block NSMutableArray *memberIdArray = [NSMutableArray array];
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        NSString *sql = @"SELECT member_id FROM yyim_chatgroup_member WHERE user_id=? AND chatgroup_id=?";
        YYFMResultSet *rs = [db executeQuery:sql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy], groupId];
        @try {
            while ([rs next]) {
                [memberIdArray addObject:[rs stringForColumn:@"member_id"]];
            }
        }
        @finally {
            [rs close];
        }
        
        for (YYChatGroupMember *member in memberArray) {
            NSMutableArray *array = [NSMutableArray array];
            if ([memberIdArray containsObject:[member memberId]]) {
                [array addObject:[YYIMStringUtility notNilString:[member memberName]]];
                [array addObject:[YYIMStringUtility notNilString:[member memberPhoto]]];
                [array addObject:[YYIMStringUtility notNilString:[member memberRole]]];
                [array addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
                [array addObject:[YYIMStringUtility notNilString:groupId]];
                [array addObject:[YYIMStringUtility notNilString:[member memberId]]];
                [db executeUpdate:YYIM_CHATGROUPMEMBER_UPDATE withArgumentsInArray:array];
                [memberIdArray removeObject:[member memberId]];
            } else {
                [array addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
                [array addObject:[YYIMStringUtility notNilString:groupId]];
                [array addObject:[YYIMStringUtility notNilString:[member memberId]]];
                [array addObject:[YYIMStringUtility notNilString:[member memberName]]];
                [array addObject:[YYIMStringUtility notNilString:[member memberPhoto]]];
                [array addObject:[YYIMStringUtility notNilString:[member memberRole]]];
                [db executeUpdate:YYIM_CHATGROUPMEMBER_INSERT withArgumentsInArray:array];
            }
        }
        
        if ([memberIdArray count] > 0) {
            for (NSString *memberId in memberIdArray) {
                [db executeUpdate:YYIM_CHATGROUPMEMBER_DELETE,[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy],groupId,memberId];
            }
        }
    }];
}

- (void)updateChatGroupMember:(NSString *)groupId members:(NSArray *)memberArray {
    if ([YYIMStringUtility isEmpty:groupId]) {
        return;
    }
    
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        for (YYChatGroupMember *member in memberArray) {
            NSMutableArray *array = [NSMutableArray array];
            [array addObject:[YYIMStringUtility notNilString:[member memberName]]];
            [array addObject:[YYIMStringUtility notNilString:[member memberPhoto]]];
            [array addObject:[YYIMStringUtility notNilString:[member memberRole]]];
            [array addObject:[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy]];
            [array addObject:[YYIMStringUtility notNilString:groupId]];
            [array addObject:[YYIMStringUtility notNilString:[member memberId]]];
            [db executeUpdate:YYIM_CHATGROUPMEMBER_UPDATE withArgumentsInArray:array];
        }
    }];
}

- (void)deleteChatGroupMembers:(NSString *)groupId {
    [[self getDBQueue] inTransaction:^(YYFMDatabase *db, BOOL *rollback) {
        [db executeUpdate:YYIM_CHATGROUPMEMBER_DELETEALL,[[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy],groupId];
    }];
}

- (NSArray *)getChatGroupMembersWithGroupId:(NSString *)groupId {
    return [self getChatGroupMembersWithGroupId:groupId limit:0];
}

- (NSArray *)getChatGroupMembersWithGroupId:(NSString *)groupId limit:(NSInteger)limit {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSMutableString *sql = [NSMutableString string];
        [sql appendString:@"SELECT * FROM yyim_chatgroup_member WHERE user_id=? AND chatgroup_id=? ORDER BY affiliation DESC, member_id ASC"];
        // limit
        if (limit > 0) {
            [sql appendFormat:@" limit %ld", (long)limit];
        }
        
        YYFMResultSet *rs = [db executeQuery:sql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy], groupId];
        @try {
            while ([rs next]) {
                YYChatGroupMember *member = [[YYChatGroupMember alloc] init];
                [member setMemberId:[rs stringForColumn:@"member_id"]];
                [member setMemberName:[rs stringForColumn:@"member_name"]];
                [member setMemberPhoto:[rs stringForColumn:@"member_photo"]];
                [member setMemberRole:[rs stringForColumn:@"affiliation"]];
                [array addObject:member];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return array;
}

- (YYChatGroupMember *)getChatGroupMemberWithGroupId:(NSString *)groupId memberId:(NSString *)memberId {
    __block YYChatGroupMember *member = [[YYChatGroupMember alloc] init];
    
    [[self getDBQueue] inDatabase:^(YYFMDatabase *db) {
        NSMutableString *sql = [NSMutableString string];
        [sql appendString:@"SELECT * FROM yyim_chatgroup_member WHERE user_id=? AND chatgroup_id=? AND member_id=?"];
        
        YYFMResultSet *rs = [db executeQuery:sql, [[YYIMConfig sharedInstance] getFullUserAnonymousSpecialy], groupId, memberId];
        
        @try {
            while ([rs next]) {
                [member setMemberId:[rs stringForColumn:@"member_id"]];
                [member setMemberName:[rs stringForColumn:@"member_name"]];
                [member setMemberPhoto:[rs stringForColumn:@"member_photo"]];
                [member setMemberRole:[rs stringForColumn:@"affiliation"]];
            }
        }
        @finally {
            [rs close];
        }
    }];

    return member;
}

@end
