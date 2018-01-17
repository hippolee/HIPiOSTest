//
//  ChatMicroVideoBrowserController.m
//  YonyouIM
//
//  Created by litfb on 16/3/17.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "ChatMicroVideoBrowserController.h"
#import "YYMicroVideoBrowserView.h"
#import "YMRoundProgressView.h"
#import "YYIMChatHeader.h"
#import "UIColor+YYIMTheme.h"
#import "YYMessage+YYIMCatagory.h"
#import "YYIMUtility.h"
#import "UIViewController+HUDCategory.h"
#import "YYMessage+YYIMCatagory.h"
#import "YYMicroVideoView.h"

@interface ChatMicroVideoBrowserController ()<YYMicroVideoBrowserDelegate, YYMicroVideoBrowserDateSource>

@property (nonatomic, weak) YYMicroVideoBrowserView *browserView;

@end

@implementation ChatMicroVideoBrowserController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSubView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)initSubView {
    [self.view setBackgroundColor:[UIColor blueColor]];
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    YYMicroVideoBrowserView *browserView = [[YYMicroVideoBrowserView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [browserView setBackgroundColor:[UIColor themeColor]];
    [browserView setVideoBrowserDateSource:self];
    [browserView setVideoBrowserDelegate:self];
    [self.view addSubview:browserView];
    self.browserView = browserView;
    
    if (self.videoIndex) {
        [self.browserView setCurrentVideoIndex:self.videoIndex];
    }
}

- (void)setVideoSourceArray:(NSArray *)imageSourceArray {
    _videoSourceArray = imageSourceArray;
    [self reloadData];
}

- (void)setVideoIndex:(NSInteger)imageIndex {
    _videoIndex = imageIndex;
    [self.browserView setCurrentVideoIndex:imageIndex];
}

- (void)reloadData {
    [self.browserView reloadData];
}

#pragma mark -
#pragma mark YYImageBrowserDateSource

- (NSUInteger)numberOfVideosInVideoBrowser:(YYMicroVideoBrowserView *)videoBrowser {
    return [self.videoSourceArray count];
}

- (NSDictionary *)videoBrowser:(YYMicroVideoBrowserView *)videoBrowser videoAtIndex:(NSUInteger)index {
    YYMessage *message = [self.videoSourceArray objectAtIndex:index];
    
    NSDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:2];
    [dic setValue:[message getMessageMicroVideoThumb] forKey:YMMicroVideoViewImageSource];
    
    NSURL *url = [message getMessageMicroVideoFile];
    if (url) {
        [dic setValue:url forKey:YMMicroVideoViewVideoSource];
    }
    
    return dic;
}

#pragma mark -
#pragma mark YYImageBrowserDelegate

- (void)videoBrowser:(YYMicroVideoBrowserView *)videoBrowser willDisplayVideoAtIndex:(NSUInteger)index inView:(YYMicroVideoView *)videoView {
    //可以在这里判断一下是否显示文件丢失等提示
}

- (BOOL)videoBrowser:(YYMicroVideoBrowserView *)videoBrowser acceptSingleTapForIndex:(NSUInteger)index {
    return YES;
}


- (void)videoBrowser:(YYMicroVideoBrowserView *)videoBrowser didSingleTapForIndex:(NSUInteger)index {
    //所有的cell都要清楚视频
    [self.browserView CleanAllVideo];
    [self.navigationController popViewControllerAnimated:NO];
}

- (Class)videoBrowservideoViewClass {
    return [YYMicroVideoView class];
}

#pragma mark visible

- (BOOL)isVisible {
    return (self.isViewLoaded && self.view.window);
}

@end
