//
//  HIPBaseDBHelper.m
//  YonyouIMSdk
//
//  Created by litfb on 15/6/24.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "HIPBaseDBHelper.h"
#import <sqlite3.h>

#define YM_CHAT_DB @"hip_data.sqlite"

@interface HIPBaseDBHelper () {

    FMDatabaseQueue *_dbQueue;

    NSString *_dbName;

    NSString *_dbPath;
    
}
@end

@implementation HIPBaseDBHelper

#pragma mark -
#pragma mark interface

- (NSString *)defaultDBName {
    return YM_CHAT_DB;
}

- (void)resetDatabase {
    [_dbQueue close];
    [self setupDatabase];
}

- (void)setupDatabase {
    _dbName = [self defaultDBName];
    
    [self createDatabase];
}

- (void)setupDatabaseWithName:(NSString*)dbName {
    _dbName = dbName;
    [self createDatabase];
}

- (NSString*)getDdName {
    if (_dbName == nil) {
        [self createDatabase];
    }
    return _dbName;
}

- (void)setDbName:(NSString *)dbName {
    _dbName = dbName;
}

- (NSString*)getDdPath {
    if (_dbPath == nil) {
        [self createDatabase];
    }
    return _dbPath;
}

- (FMDatabaseQueue *)getDBQueue {
    if (_dbQueue == nil) {
        [self createDatabase];
    }
    return _dbQueue;
}

#pragma mark create&update

- (void)createDatabase {
    if (_dbName == nil) {
        _dbName = YM_CHAT_DB;
    }
    
    NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    _dbPath = [documentdir stringByAppendingPathComponent:_dbName];
    
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:_dbPath flags:SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE];
    
    [self updateDatabase];
}

- (void) updateDatabase {
    
}

- (BOOL)databaseExists {
    if (_dbPath != nil) {
        BOOL isDirectory = NO;
        return [[NSFileManager defaultManager] fileExistsAtPath:_dbPath isDirectory:&isDirectory];
    } else {
        return NO;
    }
}

- (BOOL)removeDatabase {
    if (_dbPath != nil) {
        
        if (_dbQueue != nil) {
            [_dbQueue close];
        }
        
        NSError *error = nil;
        
        [[NSFileManager defaultManager] removeItemAtPath:_dbPath error:&error];
        
        if (error == nil) {
            _dbQueue = nil;
            return YES;
        } else {
            NSLog(@"%@", [error localizedDescription]);
            return NO;
        }
        
    } else {
        return NO;
    }
}

#pragma mark -
#pragma mark dbVersion

- (NSInteger) getDbVersion {
    __block NSInteger version = -1;
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM hip_dbinfo";
        FMResultSet *rs = [db executeQuery:sql];
        @try {
            if ([rs next]) {
                version = [rs intForColumn:@"version"];
            }
        }
        @finally {
            [rs close];
        }
    }];
    return version;
}

- (void)updateDbVersion:(NSInteger)dbVersion {
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"UPDATE hip_dbinfo SET version=?";
        [db executeUpdate:sql, dbVersion];
    }];
}

@end
