//
//  YYImageBrowserView.h
//  YonyouIM
//
//  Created by litfb on 15/4/7.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YYImageBrowserDateSource;
@protocol YYImageBrowserDelegate;
@class YYImageView;

//@protocol YYImageBrowserDelegate <NSObject>
//
//@optional
//
//- (void)didImageViewSingleTap:(YYImage *)image;
//
//- (void)didImageViewLongPress:(YYImage *)image;
//
//- (void)willImageShow:(id)imageSource;
//
//- (void)didImageSwitchToIndex:(NSInteger)index;
//
//@required
//
//- (void)showImageWithImageSrouce:(UIImageView *)imageView imageSource:(id)imageSource completion:(void (^)(BOOL finished))completion;
//
//@end

@interface YYImageBrowserView : UIView<UIScrollViewDelegate>

// 当前展示的图片索引
@property (assign, nonatomic) NSUInteger currentImageIndex;

@property (weak, nonatomic) id<YYImageBrowserDelegate> imageBrowserDelegate;
@property (weak, nonatomic) id<YYImageBrowserDateSource> imageBrowserDateSource;

- (void)reloadData;

@end

@protocol YYImageBrowserDateSource <NSObject>

- (NSUInteger)numberOfImagesInImageBrowser:(YYImageBrowserView *)imageBrowser;

@optional

- (UIImage *)imageBrowser:(YYImageBrowserView *)imageBrowser imageAtIndex:(NSUInteger)index;

- (void)imageBrowser:(YYImageBrowserView *)imageBrowser imageAtIndex:(NSUInteger)index complete:(void (^)(UIImage *image))complete;

@end

@protocol YYImageBrowserDelegate <NSObject>

@optional

- (Class)imageBrowserImageViewClass;

- (void)imageBrowser:(YYImageBrowserView *)imageBrowser willDisplayImageAtIndex:(NSUInteger)index inView:(YYImageView *)imageView;
- (void)imageBrowser:(YYImageBrowserView *)imageBrowser didDisplayImageAtIndex:(NSUInteger)index inView:(YYImageView *)imageView;

- (BOOL)imageBrowser:(YYImageBrowserView *)imageBrowser acceptSingleTapForIndex:(NSUInteger)index;
- (BOOL)imageBrowser:(YYImageBrowserView *)imageBrowser acceptLongPressForIndex:(NSUInteger)index;

- (void)imageBrowser:(YYImageBrowserView *)imageBrowser didSingleTapForIndex:(NSUInteger)index;
- (void)imageBrowser:(YYImageBrowserView *)imageBrowser didLongPressForIndex:(NSUInteger)index;

@end
