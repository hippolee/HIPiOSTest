//
//  YYMicroVideoView.h
//  YonyouIM
//
//  Created by yanghaoc on 16/6/20.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYMicroVideoBrowserView.h"

@protocol YYMicroVideoBrowserDelegate;

@interface YYMicroVideoView : UIView

// browser
@property (weak, nonatomic) YYMicroVideoBrowserView *videoBrowser;

// index
@property (assign, nonatomic) NSUInteger index;
// delegate
@property (assign, nonatomic) id<YYMicroVideoBrowserDelegate> videoBrowserDelegate;

- (void)setVideoSource:(NSDictionary *)source;

- (void)prepareForReuse;

- (void)cleanVideo;

extern NSString * const YMMicroVideoViewImageSource;
extern NSString * const YMMicroVideoViewVideoSource;

@end
