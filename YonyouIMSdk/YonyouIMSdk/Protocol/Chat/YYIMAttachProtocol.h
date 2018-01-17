//
//  YYIMAttachProtocol.h
//  YonyouIMSdk
//
//  Created by litfb on 15/7/15.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMAttachProgressDelegate.h"
#import "YYIMDefs.h"

@protocol YYIMAttachProtocol <YYIMBaseProtocol>

@required

- (void)addAttachProgressDelegate:(id<YYIMAttachProgressDelegate>)delegate;

- (void)downloadAttach:(NSString *)attachId targetPath:(NSString *)targetPath imageType:(YYIMImageType)imageType thumbnail:(BOOL)thumbnail fileSize:(long long)fileSize progress:(YYIMAttachDownloadProgressBlock)downloadProgress complete:(YYIMAttachDownloadCompleteBlock)downloadComplete;

- (void)uploadAttach:(NSString *)relaAttachPath fileName:(NSString *)fileName receiver:(NSString *)receiver mediaType:(YYIMUploadMediaType)mediaType isOriginal:(BOOL)isOriginal complete:(YYIMAttachUploadCompleteBlock)complete;

- (YYAttach *)getAttachState:(NSString *)attachId;

- (YYAttach *)getAttachState:(NSString *)attachId imageType:(YYIMImageType)imageType;

@end
