//
//  YYMicroVideoBrowserView.h
//  YonyouIM
//
//  Created by yanghaoc on 16/6/20.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYMicroVideoView;
@protocol YYMicroVideoBrowserDateSource;
@protocol YYMicroVideoBrowserDelegate;

@interface YYMicroVideoBrowserView : UIView <UIScrollViewDelegate>

// 当前展示的图片索引
@property (assign, nonatomic) NSUInteger currentVideoIndex;

@property (weak, nonatomic) id<YYMicroVideoBrowserDelegate> videoBrowserDelegate;
@property (weak, nonatomic) id<YYMicroVideoBrowserDateSource> videoBrowserDateSource;

- (void)reloadData;

- (void)CleanAllVideo;

@end

@protocol YYMicroVideoBrowserDateSource <NSObject>

/**
 *  获得视频总数量
 *
 *  @param videoBrowser YYMicroVideoBrowserView
 *
 *  @return 视频总数量
 */
- (NSUInteger)numberOfVideosInVideoBrowser:(YYMicroVideoBrowserView *)videoBrowser;

@optional

/**
 *  获得指定位置的视频地址
 *
 *  @param videoBrowser YYMicroVideoBrowserView
 *  @param index        位置
 *
 *  @return 视频地址
 */
- (NSDictionary *)videoBrowser:(YYMicroVideoBrowserView *)videoBrowser videoAtIndex:(NSUInteger)index;
/**
 *  获得指定位置的视频地址
 *
 *  @param videoBrowser YYMicroVideoBrowserView
 *  @param index        位置
 *  @param complete     视频地址的回调
 */
- (void)videoBrowser:(YYMicroVideoBrowserView *)videoBrowser videoAtIndex:(NSUInteger)index complete:(void (^)(NSDictionary  *videoSource))complete;

@end

@protocol YYMicroVideoBrowserDelegate <NSObject>

@optional

- (Class)videoBrowservideoViewClass;

/**
 *  将要展示指定位置的视频
 *
 *  @param videoBrowser YYMicroVideoBrowserView
 *  @param index        位置
 *  @param videoPath    视频地址
 */
- (void)videoBrowser:(YYMicroVideoBrowserView *)videoBrowser willDisplayVideoAtIndex:(NSUInteger)index inView:(YYMicroVideoView *)videoView;

/**
 *  展示指定位置的视频
 *
 *  @param videoBrowser YYMicroVideoBrowserView
 *  @param index        位置
 *  @param videoPath    视频地址YYMicroVideoView
 */
- (void)videoBrowser:(YYMicroVideoBrowserView *)videoBrowser didDisplayVideoAtIndex:(NSUInteger)index inView:(YYMicroVideoView *)videoView;

/**
 *  是否允许单击事件
 *
 *  @param videoBrowser YYMicroVideoBrowserView
 *  @param index        位置
 *
 *  @return 
 */
- (BOOL)videoBrowser:(YYMicroVideoBrowserView *)videoBrowser acceptSingleTapForIndex:(NSUInteger)index;

/**
 *  单击事件
 *
 *  @param videoBrowser YYMicroVideoBrowserView
 *  @param index        位置
 */
- (void)videoBrowser:(YYMicroVideoBrowserView *)videoBrowser didSingleTapForIndex:(NSUInteger)index;

@end
