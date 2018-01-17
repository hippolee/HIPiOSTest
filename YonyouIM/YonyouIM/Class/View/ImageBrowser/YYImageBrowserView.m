//
//  YYImageBrowserView.m
//  YonyouIM
//
//  Created by litfb on 15/4/7.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYImageBrowserView.h"
#import "UIColor+YYIMTheme.h"
#import "YYImageView.h"

#define kPadding 10

@interface YYImageBrowserView ()

@property (retain, nonatomic) UIScrollView *imageScrollView;

@property (retain, nonatomic) NSMutableSet *visibleImageViews;
@property (retain, nonatomic) NSMutableSet *reusableImageViews;

@end

@implementation YYImageBrowserView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initData];
        [self initSubView];
    }
    return self;
}

- (void)initData {
    self.visibleImageViews = [NSMutableSet set];
    self.reusableImageViews = [NSMutableSet set];
}

- (void)initSubView {
    UIScrollView *imageScrollView = [[UIScrollView alloc] init];
    imageScrollView.pagingEnabled = YES;
    imageScrollView.delegate = self;
    imageScrollView.showsHorizontalScrollIndicator = NO;
    imageScrollView.showsVerticalScrollIndicator = NO;
    imageScrollView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:imageScrollView];
    self.imageScrollView = imageScrollView;
}

- (void)layoutSubviews {
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    frame.origin.x -= kPadding;
    frame.size.width += (2 * kPadding);
    [self.imageScrollView setFrame:frame];
    
    self.imageScrollView.contentSize = CGSizeMake(CGRectGetWidth(frame) * [self numberOfImages], 0);
    self.imageScrollView.contentOffset = CGPointMake(self.currentImageIndex * CGRectGetWidth(frame), 0);
    
    [self showImages];
}

- (void)layoutSubviews1 {
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    frame.origin.x -= kPadding;
    frame.size.width += (2 * kPadding);
    [self.imageScrollView setFrame:frame];
    
    self.imageScrollView.contentSize = CGSizeMake(CGRectGetWidth(frame) * [self numberOfImages], 0);
    self.imageScrollView.contentOffset = CGPointMake(self.currentImageIndex * CGRectGetWidth(frame), 0);
}

- (void)setCurrentImageIndex:(NSUInteger)currentImageIndex {
    _currentImageIndex = currentImageIndex;
    
    if (self.imageScrollView) {
        CGFloat width = self.imageScrollView.bounds.size.width;
        self.imageScrollView.contentOffset = CGPointMake(self.currentImageIndex * width, 0);
        
        [self showImages];
    }
}

- (void)reloadData {
    [self layoutSubviews1];
    for (YYImageView *photoView in [self visibleImageViews]) {
        [self showImageView:photoView atIndex:[photoView index]];
    };
}

- (void)showImages {
    CGRect visibleBounds = self.imageScrollView.bounds;
    NSInteger firstIndex = (int) floorf((CGRectGetMinX(visibleBounds) + kPadding * 2) / CGRectGetWidth(visibleBounds));
    NSInteger lastIndex  = (int) floorf((CGRectGetMaxX(visibleBounds) - kPadding * 2 - 1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) {
        firstIndex = 0;
    }
    if (firstIndex >= [self numberOfImages]) {
        firstIndex = [self numberOfImages] - 1;
    }
    if (lastIndex < 0) {
        lastIndex = 0;
    }
    if (lastIndex >= [self numberOfImages]) {
        lastIndex = [self numberOfImages] - 1;
    }
    
    // 回收不再显示的ImageView
    NSInteger photoViewIndex;
    for (YYImageView *photoView in self.visibleImageViews) {
        photoViewIndex = photoView.index;
        if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
            [self.reusableImageViews addObject:photoView];
            [photoView removeFromSuperview];
        }
    }
    
    [self.visibleImageViews minusSet:self.reusableImageViews];
    while (self.reusableImageViews.count > 2) {
        [self.reusableImageViews removeObject:[self.reusableImageViews anyObject]];
    }
    
    for (NSInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isShowingPhotoViewAtIndex:index]) {
            [self showImageViewAtIndex:index];
        } else {
            // the following code will drop dead halt, when current image size changed
            // [self adjustShowingImageViewAtIndex:index];
        }
    }
}

// index 是否在显示
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
    for (YYImageView *photoView in self.visibleImageViews) {
        if (photoView.index == index) {
            return YES;
        }
    }
    return NO;
}

// 显示一个图片
- (void)showImageViewAtIndex:(NSUInteger)index {
    YYImageView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) { // 添加新的图片view
        Class imageBrowserClass = [YYImageView class];
        if ([self.imageBrowserDelegate respondsToSelector:@selector(imageBrowserImageViewClass)]) {
            Class class = [self.imageBrowserDelegate imageBrowserImageViewClass];
            if ([class isSubclassOfClass:[YYImageView class]]) {
                imageBrowserClass = class;
            }
        }
        photoView = [[imageBrowserClass alloc] init];
        photoView.imageBrowser = self;
        [photoView setImageBrowserDelegate:self.imageBrowserDelegate];
    }
    [photoView prepareForReuse];
    
    [self showImageView:photoView atIndex:index];
    
    [self.visibleImageViews addObject:photoView];
    [self.imageScrollView addSubview:photoView];
    
    //    [self prepareImageNearIndex:index];
}

- (void)showImageView:(YYImageView *)imageView atIndex:(NSUInteger)index{
    // 调整当期页的frame
    CGRect bounds = self.imageScrollView.bounds;
    CGRect imageViewFrame = bounds;
    imageViewFrame.size.width -= (2 * kPadding);
    imageViewFrame.origin.x = (bounds.size.width * index) + kPadding;
    imageView.frame = imageViewFrame;
    imageView.index = index;
    
    if ([self.imageBrowserDelegate respondsToSelector:@selector(imageBrowser:willDisplayImageAtIndex:inView:)]) {
        [self.imageBrowserDelegate imageBrowser:self willDisplayImageAtIndex:index inView:imageView];
    }
    
    if ([self.imageBrowserDateSource respondsToSelector:@selector(imageBrowser:imageAtIndex:)]) {
        [imageView setImage:[self.imageBrowserDateSource imageBrowser:self imageAtIndex:index]];
        
        if ([self.imageBrowserDelegate respondsToSelector:@selector(imageBrowser:didDisplayImageAtIndex:inView:)]) {
            [self.imageBrowserDelegate imageBrowser:self didDisplayImageAtIndex:index inView:imageView];
        }
    } else if ([self.imageBrowserDateSource respondsToSelector:@selector(imageBrowser:imageAtIndex:complete:)]) {
        imageView.scrollEnabled = NO;
        [self.imageBrowserDateSource imageBrowser:self imageAtIndex:index complete:^(UIImage *image) {
            [imageView setImage:image];
            imageView.scrollEnabled = YES;
            if ([self.imageBrowserDelegate respondsToSelector:@selector(imageBrowser:didDisplayImageAtIndex:inView:)]) {
                [self.imageBrowserDelegate imageBrowser:self didDisplayImageAtIndex:index inView:imageView];
            }
        }];
    }
}

- (void)adjustShowingImageViewAtIndex:(NSUInteger)index {
    YYImageView *photoView = [self showingImageViewAtIndex:index];
    if (!photoView) {
        [self showImageViewAtIndex:index];
        return;
    }
    
    [self showImageView:photoView atIndex:index];
}

- (YYImageView *)showingImageViewAtIndex:(NSUInteger)index {
    for (YYImageView *photoView in self.visibleImageViews) {
        if (photoView.index == index) {
            return photoView;
        }
    }
    return nil;
}

//// 准备数据
//- (void)loadImageNearIndex:(NSInteger)index {
//    if (index > 0) {
//        YYImage *image = _images[index - 1];
//        if ([self.imageBrowserDelegate respondsToSelector:@selector(willImageShow:)]) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                [self.imageBrowserDelegate willImageShow:image.imageSource];
//            });
//        }
//    }
//
//    if (index < _images.count - 1) {
//        YYImage *image = _images[index + 1];
//        if ([self.imageBrowserDelegate respondsToSelector:@selector(willImageShow:)]) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                [self.imageBrowserDelegate willImageShow:image.imageSource];
//            });
//        }
//    }
//}


#pragma mark func

- (NSUInteger)numberOfImages {
    return [self.imageBrowserDateSource numberOfImagesInImageBrowser:self];
}

// reuse
- (YYImageView *)dequeueReusablePhotoView {
    YYImageView *photoView = [self.reusableImageViews anyObject];
    if (photoView) {
        [self.reusableImageViews removeObject:photoView];
    }
    return photoView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showImages];
    _currentImageIndex = self.imageScrollView.contentOffset.x / self.imageScrollView.frame.size.width;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

@end
