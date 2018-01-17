//
//  YMRefreshView.m
//  YonyouIM
//
//  Created by litfb on 15/12/31.
//  Copyright © 2015年 yonyou. All rights reserved.
//

#import "YMRefreshView.h"
#import "UIImage+GIF.h"

@implementation YMRefreshView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    UIImageView *gifView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [gifView setImage:[UIImage sd_animatedGIFNamed:@"yyim_hud"]];
    [gifView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    gifView.center = self.center;
    [self addSubview:gifView];
    self.gifView = gifView;
}

@end
