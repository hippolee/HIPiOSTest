//
//  YKJBubbleView.h
//  YonyouIM
//
//  Created by litfb on 15/6/19.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YKJBubbleDirection) {
    YKJBubbleDirectionLeft = 0,
    YKJBubbleDirectionRight = 1
};

@interface YKJBubbleView : UIImageView

@property (nonatomic) YKJBubbleDirection direction;

@end
