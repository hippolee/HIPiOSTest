//
//  HIPBubbleView.h
//  YonyouIM
//
//  Created by litfb on 15/6/19.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HIPBubbleDirection) {
    HIPBubbleDirectionLeft = 0,
    HIPBubbleDirectionRight = 1
};

@interface HIPBubbleView : UIView

@property (nonatomic) HIPBubbleDirection direction;

@end
