//
//  TableBackgroundView.m
//  YonyouIM
//
//  Created by litfb on 15/7/16.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "TableBackgroundView.h"
#import "UIColor+YYIMTheme.h"
#import "YYIMUIDefs.h"
#import "YYIMColorHelper.h"

@interface TableBackgroundView ()

@property (weak, nonatomic) UILabel *titleLabel;

@property (weak, nonatomic) UIImageView *bgImageView;

@property (weak, nonatomic) UIButton *button;

@property NSString *title;

@property YYIMTableBackgroundType type;

@end

@implementation TableBackgroundView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title type:(YYIMTableBackgroundType)type {
    if (self = [super initWithFrame:frame]) {
        self.title = title;
        self.type = type;
        [self initSubView];
    }
    return self;
}

- (void)initSubView {
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = self.title;
    label.textColor = [UIColor themeBlueColor];
    label.font = [UIFont systemFontOfSize:16.0f];
    // 文字居中显示
    label.textAlignment = NSTextAlignmentCenter;
    // 自动折行设置
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    [self addSubview:label];
    self.titleLabel = label;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    switch (self.type) {
        case kYYIMTableBackgroundTypeChat:
        case kYYIMTableBackgroundTypeNormal:
            [imageView setImage:[UIImage imageNamed:@"bg_empty_normal"]];
            break;
        case kYYIMTableBackgroundTypeSearch:
            [imageView setImage:[UIImage imageNamed:@"bg_empty_search"]];
            break;
        default:
            break;
    }
    [self addSubview:imageView];
    self.bgImageView = imageView;
    
    UIButton *button = [[UIButton alloc] init];
    [button.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    switch (self.type) {
        case kYYIMTableBackgroundTypeChat:
            [button setBackgroundImage:[UIImage imageNamed:@"icon_empty_bubble"] forState:UIControlStateNormal];
            [button setTitle:@"开始聊天" forState:UIControlStateNormal];
            break;
        case kYYIMTableBackgroundTypeNormal: {
            [button setImage:[UIImage imageNamed:@"icon_empty_add"] forState:UIControlStateNormal];
            [button setBackgroundColor:UIColorFromRGB(0x6ac66f)];
            break;
        }
        case kYYIMTableBackgroundTypeSearch: {
            [button setImage:[UIImage imageNamed:@"icon_empty_search"] forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor themeBlueColor]];
            break;
        }
        default:
            break;
    }
    
    [self addSubview:button];
    self.button = button;
}

- (void)layoutSubviews {
    CGFloat width = CGRectGetWidth(self.frame);
    
    CGFloat titleLabelY = 50;
    CGFloat titleLabelWidth = width - 80;
    
    CGSize size = YM_MULTILINE_TEXTSIZE(self.title, self.titleLabel.font, CGSizeMake(titleLabelWidth, 80));
    CGFloat titleLabelHeight = size.height;
    
    [self.titleLabel setFrame:CGRectMake(40, titleLabelY, titleLabelWidth, titleLabelHeight)];
    
    CGFloat bgImageY = titleLabelY + titleLabelHeight + 10;
    CGFloat bgImageWidth = width / 3;
    CGFloat bgImageHeight = bgImageWidth * 2.5f;
    
    [self.bgImageView setFrame:CGRectMake((width - bgImageWidth) / 2, bgImageY, bgImageWidth, bgImageHeight)];
    
    CGFloat buttonOffset = bgImageWidth / 6;
    CGFloat buttonY = bgImageY + bgImageHeight - bgImageWidth + buttonOffset;
    CGFloat buttonWidth = bgImageWidth;

    [self.button setFrame:CGRectMake((width - buttonWidth) / 2, buttonY, buttonWidth, buttonWidth)];
    
    switch (self.type) {
        case kYYIMTableBackgroundTypeChat:
            [self.button.titleLabel setFont:[UIFont systemFontOfSize:width / 22.5]];
            break;
        case kYYIMTableBackgroundTypeNormal: {
            CALayer *layer = [self.button layer];
            [layer setMasksToBounds:YES];
            [layer setCornerRadius:buttonWidth / 2];
            CGFloat inset = buttonWidth / 3;
            [self.button setImageEdgeInsets:UIEdgeInsetsMake(inset, inset, inset, inset)];
            break;
        }
        case kYYIMTableBackgroundTypeSearch: {
            CALayer *layer = [self.button layer];
            [layer setMasksToBounds:YES];
            [layer setCornerRadius:buttonWidth / 2];
            CGFloat inset = buttonWidth / 3;
            [self.button setImageEdgeInsets:UIEdgeInsetsMake(inset, inset, inset, inset)];
            break;
        }
        default:
            break;
    }
}

- (void)addBtnTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [self.button addTarget:target action:action forControlEvents:controlEvents];
}

- (void)setTitleText:(NSString *)title {
    self.title = title;
    [self.titleLabel setText:title];
}

@end
