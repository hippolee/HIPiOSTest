//
//  HIPRefreshView.m
//  litfb_test
//
//  Created by litfb on 15/12/31.
//  Copyright © 2015年 yonyou. All rights reserved.
//

#import "HIPRefreshView.h"
#import "UIImage+GIF.h"

@implementation HIPRefreshView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    UIImageView *gifView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [gifView setImage:[UIImage sd_animatedGIFNamed:@"yyim_hud"]];
    [gifView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    gifView.center = self.center;
    [self addSubview:gifView];
}

@end
