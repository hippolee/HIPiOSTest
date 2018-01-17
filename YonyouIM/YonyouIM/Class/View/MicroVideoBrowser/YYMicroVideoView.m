//
//  YYMicroVideoView.m
//  YonyouIM
//
//  Created by yanghaoc on 16/6/20.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYMicroVideoView.h"
#import "SCRecorder.h"

NSString * const YMMicroVideoViewImageSource = @"YMMicroVideoViewImageSource";
NSString * const YMMicroVideoViewVideoSource = @"YMMicroVideoViewVideoSource";

@interface YYMicroVideoView ()

@property (retain, nonatomic) SCPlayer *player;
@property (retain, nonatomic) SCVideoPlayerView *videoPlayerView;

@property (retain, nonatomic) UIImageView *defaultImageView;

@end

@implementation YYMicroVideoView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.clipsToBounds = YES;
        // 属性
        self.backgroundColor = [UIColor clearColor];
        self.defaultImageView = [[UIImageView alloc] init];
        [self addSubview:self.defaultImageView];
        
        // 监听点击
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.delaysTouchesBegan = YES;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
    }
    
    return self;
}

#pragma mark image setter

- (void)setVideoSource:(NSDictionary *)source {
    if (self.player && self.player.isPlaying) {
        [self.player pause];
    }
    
    self.player = nil;
    
    [self.videoPlayerView removeFromSuperview];
    self.videoPlayerView = nil;
    
    self.defaultImageView.image = nil;
    self.defaultImageView.hidden = YES;
    
    NSURL *url = [source objectForKey:YMMicroVideoViewVideoSource];
    
    CGFloat videoWith = CGRectGetWidth(self.frame);
    CGFloat videoHeight = CGRectGetWidth(self.frame) / 4 * 3;
    
    //设置视频并播放
    if (url) {
        self.player = [SCPlayer player];
        self.videoPlayerView = [[SCVideoPlayerView alloc] initWithPlayer:self.player];
        // 视频显示的区域
        self.videoPlayerView.frame = CGRectMake(0, (CGRectGetHeight(self.frame) - videoHeight) / 2, videoWith, videoHeight);
        
        [self addSubview:self.videoPlayerView];
        
        self.videoPlayerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.player.loopEnabled = YES;
        self.player.volume = 1;
        [self.player setItemByUrl:url];
        [self.player play];
    } else {
        UIImage *image = [source objectForKey:YMMicroVideoViewImageSource];
        //如果没有缩略图
        if (!image) {
            image = [UIImage imageNamed:@"icon_image"];
        }
        
        self.defaultImageView.frame = CGRectMake(0, (CGRectGetHeight(self.frame) - videoHeight) / 2, videoWith, videoHeight);
        self.defaultImageView.image = image;
        self.defaultImageView.hidden = NO;
    }
}

- (void)cleanVideo {
    if (self.player && self.player.isPlaying) {
        [self.player pause];
    }
    
    self.player = nil;
    
    [self.videoPlayerView removeFromSuperview];
    self.videoPlayerView = nil;
}

- (void)prepareForReuse {
    //清空之前的播放
    [self.videoPlayerView setBackgroundColor:[UIColor whiteColor]];
}

- (BOOL)acceptSingleTap {
    if ([self.videoBrowserDelegate respondsToSelector:@selector(videoBrowser:acceptSingleTapForIndex:)]) {
        return [self.videoBrowserDelegate videoBrowser:self.videoBrowser acceptSingleTapForIndex:self.index];
    }
    return NO;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    if ([self acceptSingleTap]) {
        // 通知代理
        if ([self.videoBrowserDelegate respondsToSelector:@selector(videoBrowser:didSingleTapForIndex:)]) {
            [self.videoBrowserDelegate videoBrowser:self.videoBrowser didSingleTapForIndex:self.index];
        }
    }
}

@end
