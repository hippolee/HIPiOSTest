//
//  UIImageView+YYIMCatagory.h
//  YonyouIM
//
//  Created by litfb on 15/4/22.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImagePrefetcher.h"
#import "YYIMChatHeader.h"

@interface UIImageView (YYIMCatagory)

- (void)ym_setImageWithGroupId:(NSString *)groupId placeholderImage:(UIImage *)placeholder;

- (void)ym_setImageWithGroupInfo:(YYChatGroupInfo *)groupInfo placeholderImage:(UIImage *)placeholder;

@end