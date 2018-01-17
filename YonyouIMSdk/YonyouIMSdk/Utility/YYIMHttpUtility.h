//
//  YYIMHttpUtility.h
//  YonyouIM
//
//  Created by litfb on 15/2/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMDefs.h"

@interface YYIMHttpUtility : NSObject

+ (void)uploadResourceWithSourcePath:(NSString *)sourcePath fileName:(NSString *)fileName fileSize:(long long)fileSize receiver:(NSString *)receiver mediaType:(YYIMUploadMediaType)mediaType isOriginal:(BOOL)isOriginal completion:(void (^)(NSInteger resultCode, YYIMError *error, id responseObject))completion;

+ (void)downloadResourceWithAttachId:(NSString *)attachId targetPath:(NSString *)targetPath imageType:(YYIMImageType)imageType thumbnail:(BOOL)thumbnail fileSize:(long long)fileSize progress:(YYIMAttachDownloadProgressBlock)progress completion:(void (^)(NSInteger resultCode, YYIMError *error, id responseObject))completion;

+ (void)updateDeviceToken;

+ (void)removeDeviceToken;

@end
