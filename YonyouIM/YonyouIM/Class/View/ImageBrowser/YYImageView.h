//
//  YYImageView.h
//  YonyouIM
//
//  Created by litfb on 15/1/28.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYImageBrowserView.h"

@protocol YYImageBrowserDelegate;

@interface YYImageView : UIScrollView <UIScrollViewDelegate>

// index
@property (assign, nonatomic) NSUInteger index;
// browser
@property (retain, nonatomic) YYImageBrowserView *imageBrowser;
// delegate
@property (assign, nonatomic) id<YYImageBrowserDelegate> imageBrowserDelegate;

- (void)setImage:(UIImage *)image;

- (void)prepareForReuse;

@end