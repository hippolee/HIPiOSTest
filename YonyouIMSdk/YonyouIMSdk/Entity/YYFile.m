//
//  YYFile.m
//  YonyouIMSdk
//
//  Created by litfb on 15/7/6.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYFile.h"
#import "YYIMResourceUtility.h"
#import "YYIMChatHeader.h"

@implementation YYFile

+ (instancetype)fileWithFileId:(NSString *)fileId fileName:(NSString *)fileName fileSize:(long long)fileSize localPath:(NSString *)localPath {
    YYFile *file = [[YYFile alloc] init];
    file.fileId = fileId;
    file.fileName = fileName;
    file.fileSize = fileSize;
    file.localFilePath = localPath;
    return file;
}

- (NSString *)localFilePath {
    if (!_localFilePath) {
        YYAttach *attach = [[YYIMChat sharedInstance].chatManager getAttachState:self.fileId];
        if ([attach downloadState] == kYYIMAttachDownloadSuccess) {
            _localFilePath = [attach attachPath];
        }
        if (!_localFilePath) {
            _localFilePath = [YYIMResourceUtility resourceAttachRelaPathWithId:self.fileId ext:[self.fileName pathExtension]];
        }
    }
    return _localFilePath;
}

- (NSURL *)fileUrl {
    if ([self isDir]) {
        return nil;
    }
    return [NSURL fileURLWithPath:[YYIMResourceUtility fullPathWithResourceRelaPath:[self localFilePath]]];
}

@end
