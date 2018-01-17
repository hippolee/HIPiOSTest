//
//  YYIMAttachProgressDelegate.h
//  YonyouIMSdk
//
//  Created by litfb on 15/7/14.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMError.h"

@protocol YYIMAttachProgressDelegate <NSObject>

- (void)attachDownloadProgress:(float)progress totalSize:(long long)totalSize readedSize:(long long)readedSize withAttachKey:(NSString *)attachKey;

- (void)attachDownloadComplete:(BOOL)result withAttachKey:(NSString *)attachKey error:(YYIMError *)error;

@end
