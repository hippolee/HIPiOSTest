//
//  HIPImageBubbleView.h
//  YonyouIM
//
//  Created by litfb on 15/6/19.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YMImageBubbleDirection) {
    YMImageBubbleDirectionLeft = 0,
    YMImageBubbleDirectionRight = 1
};

@interface HIPImageBubbleView : UIImageView

@property (nonatomic) YMImageBubbleDirection direction;

@property (nonatomic) BOOL showArrow;

@end
