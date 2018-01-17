//
//  TableBackgroundView.h
//  YonyouIM
//
//  Created by litfb on 15/7/16.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YYIMTableBackgroundType) {
    kYYIMTableBackgroundTypeChat,
    kYYIMTableBackgroundTypeSearch,
    kYYIMTableBackgroundTypeNormal
};

@interface TableBackgroundView : UIView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title type:(YYIMTableBackgroundType)type;

- (void)addBtnTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

- (void)setTitleText:(NSString *)title;

@end
