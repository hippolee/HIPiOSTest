//
//  HIPBaseDBHelper.h
//  YonyouIMSdk
//
//  Created by litfb on 15/6/24.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface HIPBaseDBHelper : NSObject

- (NSString *)defaultDBName;

- (void)resetDatabase;

- (void)setupDatabase;

- (void)setupDatabaseWithName:(NSString *) dbName;

- (NSString *)getDdName;

- (NSString *)getDdPath;

- (FMDatabaseQueue *)getDBQueue;

- (NSInteger) getDbVersion;

- (void)updateDbVersion:(NSInteger)dbVersion;

@end
