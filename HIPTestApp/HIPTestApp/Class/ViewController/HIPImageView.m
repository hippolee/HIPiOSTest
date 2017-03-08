//
//  HIPImageView.m
//  YonyouIM
//
//  Created by litfb on 15/1/28.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "HIPImageView.h"
#import "UIImageView+WebCache.h"

@interface HIPImageView ()<UIScrollViewDelegate>

@property (retain, nonatomic) UIImageView *imageView;

@end

@implementation HIPImageView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.clipsToBounds = YES;
        // 图片
        self.imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        
        // 属性
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // 监听点击
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.delaysTouchesBegan = YES;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [self addGestureRecognizer:longPress];
        
        [singleTap requireGestureRecognizerToFail:longPress];
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return self;
}

#pragma mark image setter

- (void)setImage:(UIImage *)image {
    [self.imageView setImage:image];
    [self showImage];
}

- (void)prepareForReuse {
    [self.imageView setImage:nil];
}

#pragma mark 显示图片
- (void)showImage {
    // 调整frame参数
    [self adjustFrame];
}

#pragma mark 调整frame
- (void)adjustFrame {
    if (!self.imageView.image) {
        return;
    }
    
    // 基本尺寸参数
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize imageSize = self.imageView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    
    // 设置伸缩比例
    CGFloat widthRatio = imageWidth/boundsWidth;
    CGFloat heightRatio = imageHeight/boundsHeight;
    CGFloat maxScale = (widthRatio > heightRatio) ? widthRatio : heightRatio;
    CGFloat minScale = (widthRatio > heightRatio) ? heightRatio : widthRatio;
    if (minScale >= 1) {
        minScale = 0.8;
    }
    
    // CGFloat maxScale = 2.0;
    if (maxScale > 2) {
        maxScale = 2;
    }
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
    
    CGRect imageFrame;
    if (widthRatio >= heightRatio) {
        CGFloat height = imageHeight * boundsWidth / imageWidth;
        imageFrame = CGRectMake(0, (boundsHeight - height) / 2, boundsWidth, height);
    } else {
        CGFloat width = imageWidth * boundsHeight / imageHeight;
        imageFrame = CGRectMake((boundsWidth - width) / 2, 0, width, boundsHeight);
    }
    
    // 内容尺寸
    self.contentSize = CGSizeMake(0, imageFrame.size.height);
    
    self.imageView.frame = imageFrame;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

// 让UIImageView在UIScrollView缩放后居中显示
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                    scrollView.contentSize.height * 0.5 + offsetY);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    CGPoint touchPoint = [tap locationInView:self];
    if (self.zoomScale == self.maximumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        [self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    }
}

- (BOOL)acceptSingleTap {
    //    if ([self.imageBrowserDelegate respondsToSelector:@selector(imageBrowser:acceptSingleTapForIndex:)]) {
    //        return [self.imageBrowserDelegate imageBrowser:self.imageBrowser acceptSingleTapForIndex:self.index];
    //    }
    return NO;
}

- (BOOL)acceptLongPress {
    //    if ([self.imageBrowserDelegate respondsToSelector:@selector(imageBrowser:acceptLongPressForIndex:)]) {
    //        return [self.imageBrowserDelegate imageBrowser:self.imageBrowser acceptLongPressForIndex:self.index];
    //    }
    return NO;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    //    if ([self acceptSingleTap]) {
    //        // 通知代理
    //        if ([self.imageBrowserDelegate respondsToSelector:@selector(imageBrowser:didSingleTapForIndex:)]) {
    //            [self.imageBrowserDelegate imageBrowser:self.imageBrowser didSingleTapForIndex:self.index];
    //        }
    //    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    //    if (recognizer.state == UIGestureRecognizerStateBegan) {
    //        if ([self acceptLongPress]) {
    //            // 通知代理
    //            if ([self.imageBrowserDelegate respondsToSelector:@selector(imageBrowser:didLongPressForIndex:)]) {
    //                [self.imageBrowserDelegate imageBrowser:self.imageBrowser didLongPressForIndex:self.index];
    //            }
    //        }
    //    }
}

@end