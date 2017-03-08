//
//  HIPDBHelper.h
//  YonyouIM
//
//  Created by litfb on 15/1/4.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HIPBaseDBHelper.h"
#import "FMDB.h"
#import "HIPSvgInfo.h"

#pragma mark empty version

#define HIP_DB_VERSION_EMPTY       -1

// 数据库信息表创建
#define HIP_DBINFO_CREATE @"CREATE TABLE hip_dbinfo (version INTEGER)"
// 数据库信息表初始化
#define HIP_DBINFO_INIT @"INSERT INTO hip_dbinfo (version) VALUES (0)"
// 数据库信息表更新
#define HIP_DBINFO_UPDATE @"UPDATE hip_dbinfo SET version=?"

#pragma mark version 0

#define HIP_DB_VERSION_INITIAL     0

// 白板表创建
#define HIP_SVG_CREATE @"CREATE TABLE hip_svg (pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,svg_id TEXT,svg_name TEXT,svg_data TEXT,dateline INTEGER)"

#pragma mark version 1

#define HIP_DB_VERSION_1           1

#define HIP_SVG_TOOL_CREATE @"CREATE TABLE hip_svg_tool(pkid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,tool_id INTEGER,tool_name TEXT,tool_identity TEXT,is_enable INTEGER)"

@interface HIPDBHelper : HIPBaseDBHelper

+ (HIPDBHelper *) sharedInstance;

#pragma mark svg

- (HIPSvgInfo *)addSvg;

- (NSArray *)getSvgWithLimit:(NSInteger)limit offset:(NSInteger)offset;

- (HIPSvgInfo *)getSvgWithId:(NSString *)svgId;

- (void)deleteSvgWithId:(NSString *)svgId;

#pragma mark svgTool

- (NSArray *)getSvgTools;

- (NSArray *)getEnabledSvgTools;

- (void)setSvgToolWithId:(NSInteger)toolId isEnable:(BOOL)isEnable;

@end
