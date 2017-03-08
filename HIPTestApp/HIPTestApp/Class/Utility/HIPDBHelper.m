//
//  HIPDBHelper.m
//  YonyouIM
//
//  Created by litfb on 15/1/4.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "HIPDBHelper.h"
#import "HIPSvgInfo.h"
#import "HIPSvgToolInfo.h"
#import "HIPStringUtility.h"

#define HIP_DATA_DB @"hip_data.sqlite"

@implementation HIPDBHelper

+ (HIPDBHelper*)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (NSString *)defaultDBName {
    return HIP_DATA_DB;
}

- (void) updateDatabase {
    NSInteger dbVersion = [self getDbVersion];
    
    switch (dbVersion) {
        case HIP_DB_VERSION_EMPTY:
            [[self getDBQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
                [db executeUpdate:HIP_DBINFO_CREATE];
                [db executeUpdate:HIP_SVG_CREATE];
                [db executeUpdate:HIP_DBINFO_INIT];
            }];
        case HIP_DB_VERSION_INITIAL:
            [[self getDBQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
                [db executeUpdate:HIP_SVG_TOOL_CREATE];
                [[HIPDBHelper sharedInstance] initSvgTools:db];
                [db executeUpdate:HIP_DBINFO_UPDATE, [NSNumber numberWithInteger:HIP_DB_VERSION_1]];
            }];
            break;
        case HIP_DB_VERSION_1:
            break;
    }
}

#pragma mark svg

- (HIPSvgInfo *)addSvg {
    HIPSvgInfo *svgInfo = [[HIPSvgInfo alloc] init];
    [svgInfo setSvgId:[[NSUUID UUID] UUIDString]];
    NSDate *date = [NSDate date];
    // formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    [svgInfo setSvgName:[NSString stringWithFormat:@"白板_%@", [dateFormatter stringFromDate:date]]];
    [svgInfo setDateline:[date timeIntervalSince1970]];
    [[self getDBQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = @"INSERT INTO hip_svg (svg_id,svg_name,svg_data,dateline) VALUES (?,?,?,?)";
        NSMutableArray *argsArray = [NSMutableArray array];
        [argsArray addObject:[svgInfo svgId]];
        [argsArray addObject:[svgInfo svgName]];
        [argsArray addObject:[svgInfo svgDataXml] ? [svgInfo svgDataXml] : @""];
        [argsArray addObject:[NSNumber numberWithDouble:[svgInfo dateline]]];
        
        [db executeUpdate:sql withArgumentsInArray:argsArray];
    }];
    return svgInfo;
}

- (NSArray *)getSvgWithLimit:(NSInteger)limit offset:(NSInteger)offset {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql;
        if (limit > 0) {
            sql = [NSString stringWithFormat:@"SELECT * FROM hip_svg ORDER BY dateline LIMIT %ld OFFSET %ld", (long)limit, offset < 0 ? 0 : (long)offset];
        } else {
            sql = @"SELECT * FROM hip_svg ORDER BY dateline";
        }
        
        FMResultSet *rs = [db executeQuery:sql];
        @try {
            while ([rs next]) {
                HIPSvgInfo *svgInfo = [[HIPSvgInfo alloc] init];
                [svgInfo setSvgId:[rs stringForColumn:@"svg_id"]];
                [svgInfo setSvgName:[rs stringForColumn:@"svg_name"]];
                [svgInfo setSvgDataXml:[rs stringForColumn:@"svg_data"]];
                [svgInfo setDateline:[rs doubleForColumn:@"dateline"]];
                [array addObject:svgInfo];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return array;
}

- (HIPSvgInfo *)getSvgWithId:(NSString *)svgId {
    if ([HIPStringUtility isEmpty:svgId]) {
        return nil;
    }
    
    __block HIPSvgInfo *svgInfo;
    [[self getDBQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM hip_svg WHERE svg_id=?";
        NSArray *argsArray = [NSArray arrayWithObject:svgId];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argsArray];
        @try {
            while ([rs next]) {
                svgInfo = [[HIPSvgInfo alloc] init];
                [svgInfo setSvgId:[rs stringForColumn:@"svg_id"]];
                [svgInfo setSvgName:[rs stringForColumn:@"svg_name"]];
                [svgInfo setSvgDataXml:[rs stringForColumn:@"svg_data"]];
                [svgInfo setDateline:[rs doubleForColumn:@"dateline"]];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return svgInfo;
}

- (void)deleteSvgWithId:(NSString *)svgId {
    if ([HIPStringUtility isEmpty:svgId]) {
        return;
    }
    
    [[self getDBQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = @"DELETE FROM hip_svg WHERE svg_id=?";
        NSArray *argsArray = [NSArray arrayWithObject:svgId];
        [db executeUpdate:sql withArgumentsInArray:argsArray];
    }];
}

#pragma mark svgTool

- (void)initSvgTools:(FMDatabase *)db {
    NSMutableArray *dataArray = [NSMutableArray array];
    [dataArray addObject:[[HIPSvgToolInfo alloc] initWithToolId:1 toolName:@"笔" toolIdentity:@"pen" isEnable:YES]];
    [dataArray addObject:[[HIPSvgToolInfo alloc] initWithToolId:2 toolName:@"文字" toolIdentity:@"text" isEnable:YES]];
    [dataArray addObject:[[HIPSvgToolInfo alloc] initWithToolId:3 toolName:@"矩形" toolIdentity:@"rect" isEnable:YES]];
    [dataArray addObject:[[HIPSvgToolInfo alloc] initWithToolId:4 toolName:@"箭头" toolIdentity:@"arrow" isEnable:YES]];
    [dataArray addObject:[[HIPSvgToolInfo alloc] initWithToolId:5 toolName:@"高亮笔" toolIdentity:@"highlightpen" isEnable:YES]];
    [dataArray addObject:[[HIPSvgToolInfo alloc] initWithToolId:6 toolName:@"签名" toolIdentity:@"signature" isEnable:YES]];
    [dataArray addObject:[[HIPSvgToolInfo alloc] initWithToolId:7 toolName:@"橡皮" toolIdentity:@"eraser" isEnable:YES]];
    [dataArray addObject:[[HIPSvgToolInfo alloc] initWithToolId:8 toolName:@"气泡" toolIdentity:@"speechbubble" isEnable:YES]];
    [dataArray addObject:[[HIPSvgToolInfo alloc] initWithToolId:9 toolName:@"图片" toolIdentity:@"image" isEnable:YES]];
    [dataArray addObject:[[HIPSvgToolInfo alloc] initWithToolId:10 toolName:@"椭圆" toolIdentity:@"oval" isEnable:YES]];
    [dataArray addObject:[[HIPSvgToolInfo alloc] initWithToolId:11 toolName:@"线" toolIdentity:@"line" isEnable:YES]];
    [dataArray addObject:[[HIPSvgToolInfo alloc] initWithToolId:12 toolName:@"选择工具" toolIdentity:@"selector" isEnable:YES]];
    
    NSString *sql = @"INSERT INTO hip_svg_tool(tool_id,tool_name,tool_identity,is_enable)VALUES(?,?,?,?)";
    for (HIPSvgToolInfo *svgToolInfo in dataArray) {
        [db executeUpdate:sql, [NSNumber numberWithInteger:[svgToolInfo toolId]], [svgToolInfo toolName], [svgToolInfo toolIdentity], [NSNumber numberWithBool:[svgToolInfo isEnable]]];
    }
}

- (NSArray *)getSvgTools {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM hip_svg_tool ORDER BY tool_id";
        FMResultSet *rs = [db executeQuery:sql];
        @try {
            while ([rs next]) {
                HIPSvgToolInfo *svgToolInfo = [[HIPSvgToolInfo alloc] init];
                [svgToolInfo setToolId:[rs intForColumn:@"tool_id"]];
                [svgToolInfo setToolName:[rs stringForColumn:@"tool_name"]];
                [svgToolInfo setToolIdentity:[rs stringForColumn:@"tool_identity"]];
                [svgToolInfo setIsEnable:[rs boolForColumn:@"is_enable"]];
                [array addObject:svgToolInfo];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return array;
}

- (NSArray *)getEnabledSvgTools {
    __block NSMutableArray *array = [NSMutableArray array];
    [[self getDBQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM hip_svg_tool WHERE is_enable ORDER BY tool_id";
        FMResultSet *rs = [db executeQuery:sql];
        @try {
            while ([rs next]) {
                HIPSvgToolInfo *svgToolInfo = [[HIPSvgToolInfo alloc] init];
                [svgToolInfo setToolId:[rs intForColumn:@"tool_id"]];
                [svgToolInfo setToolName:[rs stringForColumn:@"tool_name"]];
                [svgToolInfo setToolIdentity:[rs stringForColumn:@"tool_identity"]];
                [svgToolInfo setIsEnable:[rs boolForColumn:@"is_enable"]];
                [array addObject:svgToolInfo];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return array;
}

- (void)setSvgToolWithId:(NSInteger)toolId isEnable:(BOOL)isEnable {
    [[self getDBQueue] inDatabase:^(FMDatabase *db) {
        NSString *sql = @"UPDATE hip_svg_tool SET is_enable=? WHERE tool_id=?";
        [db executeUpdate:sql, [NSNumber numberWithBool:isEnable], [NSNumber numberWithInteger:toolId]];
    }];
}

@end