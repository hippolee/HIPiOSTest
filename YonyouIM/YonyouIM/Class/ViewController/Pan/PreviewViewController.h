//
//  PreviewViewController.h
//  YonyouIM
//
//  Created by litfb on 15/7/14.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import "YYIMChatHeader.h"

@interface PreviewViewController : QLPreviewController

@property YYFile *file;

@end

@interface YYFile (QLPreviewConvenienceAdditions) <QLPreviewItem>
@end