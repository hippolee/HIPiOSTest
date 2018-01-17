//
//  PanToolView.m
//  YonyouIM
//
//  Created by litfb on 15/7/8.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "PanToolView.h"

@interface PanToolView ()

@property (weak, nonatomic) UIImageView *iconView;

@property (weak, nonatomic) UILabel *titleLabel;

@end

@implementation PanToolView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame icon:(NSString *)iconName title:(NSString *)title {
    self = [self initWithFrame:frame];
    if (self) {
        [self.iconView setImage:[UIImage imageNamed:iconName]];
        [self.titleLabel setText:title];
    }
    return self;
}

- (void)initSubView {
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 24) / 2, 4, 24, 24)];
    [self addSubview:iconView];
    self.iconView = iconView;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 28, CGRectGetWidth(self.frame) - 8, 17)];
    [titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
