//
//  YYMicroVideoBrowserView.m
//  YonyouIM
//
//  Created by yanghaoc on 16/6/20.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYMicroVideoBrowserView.h"
#import "YYMicroVideoView.h"

#define YY_MICROVIDEO_BROWSERVIEW_PADDING 10

@interface YYMicroVideoBrowserView ()

@property (retain, nonatomic) UIScrollView *videoScrollView;

@property (retain, nonatomic) NSMutableSet *visibleVideoViews;
@property (retain, nonatomic) NSMutableSet *reusableVideoViews;

@end

@implementation YYMicroVideoBrowserView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initData];
        [self initSubView];
    }
    return self;
}

- (void)initData {
    self.visibleVideoViews = [NSMutableSet set];
    self.reusableVideoViews = [NSMutableSet set];
}

- (void)initSubView {
    UIScrollView *videoScrollView = [[UIScrollView alloc] init];
    videoScrollView.pagingEnabled = YES;
    videoScrollView.delegate = self;
    videoScrollView.showsHorizontalScrollIndicator = NO;
    videoScrollView.showsVerticalScrollIndicator = NO;
    videoScrollView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:videoScrollView];
    self.videoScrollView = videoScrollView;
}

- (void)layoutSubviews {
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    frame.origin.x -= YY_MICROVIDEO_BROWSERVIEW_PADDING;
    frame.size.width += (2 * YY_MICROVIDEO_BROWSERVIEW_PADDING);
    [self.videoScrollView setFrame:frame];
    
    self.videoScrollView.contentSize = CGSizeMake(CGRectGetWidth(frame) * [self numberOfVideos], 0);
    self.videoScrollView.contentOffset = CGPointMake(self.currentVideoIndex * CGRectGetWidth(frame), 0);
    
    [self showVideos];
}

- (void)layoutSubviews1 {
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    frame.origin.x -= YY_MICROVIDEO_BROWSERVIEW_PADDING;
    frame.size.width += (2 * YY_MICROVIDEO_BROWSERVIEW_PADDING);
    [self.videoScrollView setFrame:frame];
    
    self.videoScrollView.contentSize = CGSizeMake(CGRectGetWidth(frame) * [self numberOfVideos], 0);
    self.videoScrollView.contentOffset = CGPointMake(self.currentVideoIndex * CGRectGetWidth(frame), 0);
}

- (void)setCurrentVideoIndex:(NSUInteger)currentVideoIndex {
    _currentVideoIndex = currentVideoIndex;
    
    if (self.videoScrollView) {
        CGFloat width = self.videoScrollView.bounds.size.width;
        self.videoScrollView.contentOffset = CGPointMake(_currentVideoIndex * width, 0);
        
        [self showVideos];
    }
}

- (void)reloadData {
    [self layoutSubviews1];
    for (YYMicroVideoView *videoView in [self visibleVideoViews]) {
        [self showVideoView:videoView atIndex:[videoView index]];
    };
}

- (void)showVideos {
    CGRect visibleBounds = self.videoScrollView.bounds;
    NSInteger firstIndex = (int) floorf((CGRectGetMinX(visibleBounds) + YY_MICROVIDEO_BROWSERVIEW_PADDING * 2) / CGRectGetWidth(visibleBounds));
    NSInteger lastIndex  = (int) floorf((CGRectGetMaxX(visibleBounds) - YY_MICROVIDEO_BROWSERVIEW_PADDING * 2 - 1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) {
        firstIndex = 0;
    }
    if (firstIndex >= [self numberOfVideos]) {
        firstIndex = [self numberOfVideos] - 1;
    }
    if (lastIndex < 0) {
        lastIndex = 0;
    }
    if (lastIndex >= [self numberOfVideos]) {
        lastIndex = [self numberOfVideos] - 1;
    }
    
    // 回收不再显示的VideoView
    NSInteger videoViewIndex;
    for (YYMicroVideoView *videoView in self.visibleVideoViews) {
        videoViewIndex = videoView.index;
        if (videoViewIndex < firstIndex || videoViewIndex > lastIndex) {
            [self.reusableVideoViews addObject:videoView];
            [videoView removeFromSuperview];
        }
    }
    
    [self.visibleVideoViews minusSet:self.reusableVideoViews];
    
    while (self.reusableVideoViews.count > 2) {
        [self.reusableVideoViews removeObject:[self.reusableVideoViews anyObject]];
    }
    
    for (NSInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isShowingVideoViewAtIndex:index]) {
            [self CleanAllVideo];
            [self showVideoViewAtIndex:index];
        } else {
            // the following code will drop dead halt, when current image size changed
            // [self adjustShowingImageViewAtIndex:index];
        }
    }
}

// index 是否在显示
- (BOOL)isShowingVideoViewAtIndex:(NSUInteger)index {
    for (YYMicroVideoView *videoView in self.visibleVideoViews) {
        if (videoView.index == index) {
            return YES;
        }
    }
    return NO;
}

// 显示一个图片
- (void)showVideoViewAtIndex:(NSUInteger)index {
    YYMicroVideoView *videoView = [self dequeueReusableVideoView];
    if (!videoView) { // 添加新的图片view
        Class videoBrowserClass = [YYMicroVideoView class];
        if ([self.videoBrowserDelegate respondsToSelector:@selector(videoBrowservideoViewClass)]) {
            Class class = [self.videoBrowserDelegate videoBrowservideoViewClass];
            if ([class isSubclassOfClass:[YYMicroVideoView class]]) {
                videoBrowserClass = class;
            }
        }
        videoView = [[videoBrowserClass alloc] init];
        [videoView setVideoBrowserDelegate:self.videoBrowserDelegate];
    }
    [videoView prepareForReuse];
    
    [self showVideoView:videoView atIndex:index];
    
    [self.visibleVideoViews addObject:videoView];
    [self.videoScrollView addSubview:videoView];
}

- (void)showVideoView:(YYMicroVideoView *)videoView atIndex:(NSUInteger)index{
    // 调整当期页的frame
    CGRect bounds = self.videoScrollView.bounds;
    CGRect videoViewViewFrame = bounds;
    videoViewViewFrame.size.width -= (2 * YY_MICROVIDEO_BROWSERVIEW_PADDING);
    videoViewViewFrame.origin.x = (bounds.size.width * index) + YY_MICROVIDEO_BROWSERVIEW_PADDING;
    videoView.frame = videoViewViewFrame;
    videoView.index = index;
    
    if ([self.videoBrowserDelegate respondsToSelector:@selector(videoBrowser:willDisplayVideoAtIndex:inView:)]) {
        [self.videoBrowserDelegate videoBrowser:self willDisplayVideoAtIndex:index inView:videoView];
    }
    
    if ([self.videoBrowserDateSource respondsToSelector:@selector(videoBrowser:videoAtIndex:)]) {
        [videoView setVideoSource:[self.videoBrowserDateSource videoBrowser:self videoAtIndex:index]];
        
        if ([self.videoBrowserDelegate respondsToSelector:@selector(videoBrowser:didDisplayVideoAtIndex:inView:)]) {
            [self.videoBrowserDelegate videoBrowser:self didDisplayVideoAtIndex:index inView:videoView];
        }
    }
}

- (void)adjustShowingVideoViewAtIndex:(NSUInteger)index {
    YYMicroVideoView *videoView = [self showingVideoViewAtIndex:index];
    if (!videoView) {
        [self showVideoViewAtIndex:index];
        return;
    }
    
    [self showVideoView:videoView atIndex:index];
}

- (YYMicroVideoView *)showingVideoViewAtIndex:(NSUInteger)index {
    for (YYMicroVideoView *videoView in self.visibleVideoViews) {
        if (videoView.index == index) {
            return videoView;
        }
    }
    return nil;
}

- (void)CleanAllVideo {
    for (YYMicroVideoView *videoView in self.visibleVideoViews) {
        [videoView cleanVideo];
    }
    
    for (YYMicroVideoView *videoView in self.reusableVideoViews) {
        [videoView cleanVideo];
    }
}

#pragma mark func

- (NSUInteger)numberOfVideos {
    return [self.videoBrowserDateSource numberOfVideosInVideoBrowser:self];
}

// reuse
- (YYMicroVideoView *)dequeueReusableVideoView {
    YYMicroVideoView *videoView = [self.reusableVideoViews anyObject];
    if (videoView) {
        [self.reusableVideoViews removeObject:videoView];
    }
    return videoView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showVideos];
    _currentVideoIndex = self.videoScrollView.contentOffset.x / self.videoScrollView.frame.size.width;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

@end
