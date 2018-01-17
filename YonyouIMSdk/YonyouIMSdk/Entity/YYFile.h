//
//  YYFile.h
//  YonyouIMSdk
//
//  Created by litfb on 15/7/6.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMDefs.h"
#import "YYUser.h"

@interface YYFile : NSObject

@property NSString *fileId;

@property NSString *fileName;

@property NSString *parentDirId;

@property BOOL isDir;

#pragma mark for dir only

@property NSTimeInterval ts;

#pragma mark for attachment only

@property long long fileSize;

@property NSString *fileCreator;

@property NSInteger downloadCount;

@property NSTimeInterval createDate;

@property NSInteger downloadState;

#pragma mark user

@property YYUser *user;

#pragma mark localPath;

@property (copy, nonatomic) NSString *localFilePath;

+ (instancetype)fileWithFileId:(NSString *)fileId fileName:(NSString *)fileName fileSize:(long long)fileSize localPath:(NSString *)localPath;

- (NSURL *)fileUrl;

@end
