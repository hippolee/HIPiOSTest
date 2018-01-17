//
//  YYMessage+YYIMCatagory.h
//  YonyouIM
//
//  Created by litfb on 15/4/8.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYMessage.h"

@interface YYMessage (YYIMCatagory)

- (NSMutableAttributedString *)getAttributedString;

// set height
- (void)setContentHeight:(CGFloat)contentHeight;

- (void)clearContentHeight;

// get height nocalc
- (CGFloat)getContentHeight;

// calc
- (CGFloat)contentHeight;

- (UIImage *)getMessageThumbImage;

- (UIImage *)getMessageImage;

- (UIImage *)getMessageOriginalImage;

- (UIImage *)getMessageMicroVideoThumb;

- (NSURL *)getMessageMicroVideoFile;

@end
