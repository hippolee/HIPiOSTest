//
//  YYIMPanDBHelper.h
//  YonyouIMSdk
//
//  Created by litfb on 15/7/7.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMBaseDBHelper.h"
#import "YYAttach.h"

@interface YYIMPanDBHelper : YYIMBaseDBHelper

+ (instancetype) sharedInstance;

- (YYAttach *)getAttachWithId:(NSString *)attachId;

- (YYAttach *)getAttachWithUploadKey:(NSString *)uploadKey;

- (void)createAttach:(YYAttach *)attach;

- (void)updateAttachDownloadState:(NSString *)attachId downloadState:(YYIMAttachDownloadState)downloadState path:(NSString *)path;

- (void)updateAttachUploadState:(NSString *)uploadKey attachId:(NSString *)attachId uploadState:(YYIMAttachUploadState)uploadState;

- (void)updateFaildAttach;

@end
