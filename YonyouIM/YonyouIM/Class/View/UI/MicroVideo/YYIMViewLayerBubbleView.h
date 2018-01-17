//
//  HIPImageBubbleView.h
//  YonyouIM
//
//  Created by litfb on 15/6/19.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YMViewLayerBubbleDirection) {
    kYMViewLayerBubbleDirectionLeft = 0,
    kYMViewLayerBubbleDirectionRight = 1
};

@interface YYIMViewLayerBubbleView : UIView

@property (nonatomic) YMViewLayerBubbleDirection direction;

@property (nonatomic) BOOL showArrow;

@end
