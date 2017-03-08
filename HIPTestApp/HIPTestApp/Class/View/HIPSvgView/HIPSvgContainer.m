//
//  HIPSvgContainer.m
//  litfb_test
//
//  Created by litfb on 16/7/2.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPSvgContainer.h"
#import "HIPSvgEditor.h"

@interface HIPSvgContainer ()<UIScrollViewDelegate>

@property (weak, nonatomic) HIPSvgEditor *svgView;

@end

@implementation HIPSvgContainer

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        // 图片
        HIPSvgEditor *svgView = [[HIPSvgEditor alloc] init];
        [self addSubview:svgView];
        self.svgView = svgView;
        
        // 属性
        [self setDelegate:self];
        [self setBackgroundColor:[UIColor redColor]];
        [self setShowsVerticalScrollIndicator:YES];
        [self setShowsHorizontalScrollIndicator:YES];
        [self setDecelerationRate:UIScrollViewDecelerationRateFast];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

- (void)setSvgData:(HIPSvgData *)svgData {
    [self.svgView setSvgData:svgData];
    [self showSvg];
}

- (void)prepareForReuse {
    [self.svgView setSvgData:nil];
}

#pragma mark 显示Svg
- (void)showSvg {
    // 调整frame参数
    [self adjustFrame];
}

#pragma mark 调整frame
- (void)adjustFrame {
    if (![self.svgView svgData]) {
        return;
    }
    
    // 基本尺寸参数
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize svgSize = [self.svgView svgData].size;
    CGFloat svgWidth = svgSize.width;
    CGFloat svgHeitht = svgSize.height;
    
    // 设置伸缩比例
    CGFloat widthRatio = svgWidth/boundsWidth;
    CGFloat heightRatio = svgHeitht/boundsHeight;

    CGFloat minScale = (widthRatio > heightRatio) ? heightRatio : widthRatio;
    CGFloat maxScale = 12.0;
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
    
    CGRect svgFrame;
    if (widthRatio >= heightRatio) {
        CGFloat height = svgHeitht * boundsWidth / svgWidth;
        svgFrame = CGRectMake(0, (boundsHeight - height) / 2, boundsWidth, height);
    } else {
        CGFloat width = svgWidth * boundsHeight / svgHeitht;
        svgFrame = CGRectMake((boundsWidth - width) / 2, 0, width, boundsHeight);
    }
    
    // 内容尺寸
    self.contentSize = CGSizeMake(0, svgFrame.size.height);
    
    [self.svgView setFrame:svgFrame];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.svgView;
}

// 让UIImageView在UIScrollView缩放后居中显示
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    _svgView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                  scrollView.contentSize.height * 0.5 + offsetY);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
