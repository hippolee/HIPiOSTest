//
//  HIPSvgBrowser.m
//  litfb_test
//
//  Created by litfb on 16/7/2.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPSvgBrowser.h"

#define kHIPSvgBrowserPadding 10

@interface HIPSvgBrowser ()<UIScrollViewDelegate>

@property (retain, nonatomic) UIScrollView *scrollView;

@property (retain, nonatomic) NSMutableSet *visibleViews;
@property (retain, nonatomic) NSMutableSet *reusableViews;

@end

@implementation HIPSvgBrowser

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initData];
        [self initSubView];
    }
    return self;
}

- (void)initData {
    self.visibleViews = [NSMutableSet set];
    self.reusableViews = [NSMutableSet set];
}

- (void)initSubView {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [scrollView setPagingEnabled:YES];
    [scrollView setDelegate:self];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    
    [self addSubview:scrollView];
    self.scrollView = scrollView;
}

- (void)layoutSubviews {
    [self layoutSubviews:YES];
}

- (void)layoutSubviews:(BOOL)doShowSvgs {
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    frame.origin.x -= kHIPSvgBrowserPadding;
    frame.size.width += (2 * kHIPSvgBrowserPadding);
    [self.scrollView setFrame:frame];
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(frame) * [self numberOfSvgs], 0);
    self.scrollView.contentOffset = CGPointMake(self.currentIndex * CGRectGetWidth(frame), 0);
    
    if (doShowSvgs) {
        [self showSvgContainers];
    }
}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    _currentIndex = currentIndex;
    
    if (self.scrollView) {
        CGFloat width = self.scrollView.bounds.size.width;
        self.scrollView.contentOffset = CGPointMake(self.currentIndex * width, 0);
        
        [self showSvgContainers];
    }
}

- (void)reloadData {
    [self layoutSubviews:NO];
    for (HIPSvgContainer *svgContainer in [self visibleViews]) {
        [self showSvgContainer:svgContainer atIndex:[svgContainer index]];
    };
}

- (void)showSvgContainers {
    CGRect visibleBounds = self.scrollView.bounds;
    NSInteger firstIndex = (int) floorf((CGRectGetMinX(visibleBounds) + kHIPSvgBrowserPadding * 2) / CGRectGetWidth(visibleBounds));
    NSInteger lastIndex  = (int) floorf((CGRectGetMaxX(visibleBounds) - kHIPSvgBrowserPadding * 2 - 1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) {
        firstIndex = 0;
    }
    if (firstIndex >= [self numberOfSvgs]) {
        firstIndex = [self numberOfSvgs] - 1;
    }
    if (lastIndex < 0) {
        lastIndex = 0;
    }
    if (lastIndex >= [self numberOfSvgs]) {
        lastIndex = [self numberOfSvgs] - 1;
    }
    
    // 回收不再显示的ImageView
    NSInteger viewIndex;
    for (HIPSvgContainer *svgContainer in self.visibleViews) {
        viewIndex = svgContainer.index;
        if (viewIndex < firstIndex || viewIndex > lastIndex) {
            [self.reusableViews addObject:svgContainer];
            [svgContainer removeFromSuperview];
        }
    }
    
    [self.visibleViews minusSet:self.reusableViews];
    while (self.reusableViews.count > 2) {
        [self.reusableViews removeObject:[self.reusableViews anyObject]];
    }
    
    for (NSInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isShowingPhotoViewAtIndex:index]) {
            [self showSvgContainerAtIndex:index];
        }
    }
}

- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
    for (HIPSvgContainer *svgContainer in self.visibleViews) {
        if (svgContainer.index == index) {
            return YES;
        }
    }
    return NO;
}

- (void)showSvgContainerAtIndex:(NSUInteger)index {
    HIPSvgContainer *svgContainer = [self dequeueReusablePhotoView];
    if (!svgContainer) {
        svgContainer = [[HIPSvgContainer alloc] init];
    }
    [svgContainer prepareForReuse];
    
    [self showSvgContainer:svgContainer atIndex:index];
    
    [self.visibleViews addObject:svgContainer];
    [self.scrollView addSubview:svgContainer];
    
    //    [self prepareImageNearIndex:index];
}

- (void)showSvgContainer:(HIPSvgContainer *)svgContainer atIndex:(NSUInteger)index{
    // 调整当期页的frame
    CGRect bounds = self.scrollView.bounds;
    CGRect svgContainerFrame = bounds;
    svgContainerFrame.size.width -= (2 * kHIPSvgBrowserPadding);
    svgContainerFrame.origin.x = (bounds.size.width * index) + kHIPSvgBrowserPadding;
    svgContainer.frame = svgContainerFrame;
    svgContainer.index = index;
    
    if ([self.delegate respondsToSelector:@selector(svgBrowser:willDisplaySvgAtIndex:inView:)]) {
        [self.delegate svgBrowser:self willDisplaySvgAtIndex:index inView:svgContainer];
    }
    
    if ([self.dataSource respondsToSelector:@selector(svgBrowser:svgAtIndex:)]) {
        [svgContainer setSvgData:[self.dataSource svgBrowser:self svgAtIndex:index]];
        
        if ([self.delegate respondsToSelector:@selector(svgBrowser:didDisplaySvgAtIndex:inView:)]) {
            [self.delegate svgBrowser:self didDisplaySvgAtIndex:index inView:svgContainer];
        }
    } else if ([self.dataSource respondsToSelector:@selector(svgBrowser:svgAtIndex:complete:)]) {
        svgContainer.scrollEnabled = NO;
        [self.dataSource svgBrowser:self svgAtIndex:index complete:^(HIPSvgData *data) {
            [svgContainer setSvgData:data];
            svgContainer.scrollEnabled = YES;
            if ([self.delegate respondsToSelector:@selector(svgBrowser:didDisplaySvgAtIndex:inView:)]) {
                [self.delegate svgBrowser:self didDisplaySvgAtIndex:index inView:svgContainer];
            }
        }];
    }
}

- (void)adjustShowingImageViewAtIndex:(NSUInteger)index {
    HIPSvgContainer *svgContainer = [self showingSvgContainerAtIndex:index];
    if (!svgContainer) {
        [self showSvgContainerAtIndex:index];
        return;
    }
    
    [self showSvgContainer:svgContainer atIndex:index];
}

- (HIPSvgContainer *)showingSvgContainerAtIndex:(NSUInteger)index {
    for (HIPSvgContainer *svgContainer in self.visibleViews) {
        if (svgContainer.index == index) {
            return svgContainer;
        }
    }
    return nil;
}

//// 准备数据
//- (void)loadImageNearIndex:(NSInteger)index {
//    if (index > 0) {
//        YYImage *image = _images[index - 1];
//        if ([self.svgBrowserDelegate respondsToSelector:@selector(willImageShow:)]) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                [self.svgBrowserDelegate willImageShow:image.imageSource];
//            });
//        }
//    }
//
//    if (index < _images.count - 1) {
//        YYImage *image = _images[index + 1];
//        if ([self.svgBrowserDelegate respondsToSelector:@selector(willImageShow:)]) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                [self.svgBrowserDelegate willImageShow:image.imageSource];
//            });
//        }
//    }
//}

- (NSUInteger)numberOfSvgs {
    return [self.dataSource numberOfSvgsInSvgBrowser:self];
}

// reuse
- (HIPSvgContainer *)dequeueReusablePhotoView {
    HIPSvgContainer *svgContainer = [self.reusableViews anyObject];
    if (svgContainer) {
        [self.reusableViews removeObject:svgContainer];
    }
    return svgContainer;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showSvgContainers];
    _currentIndex = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
}

@end
