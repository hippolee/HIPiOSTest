//
//  HIPLayerController.m
//  litfb_test
//
//  Created by litfb on 16/6/17.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPLayerController.h"
#import "UIImageView+WebCache.h"
#import "HIPBubbleView.h"
#import "YKJBubbleView.h"

@interface HIPLayerController ()

@property (weak, nonatomic) HIPBubbleView *view1;
@property (weak, nonatomic) HIPBubbleView *view2;
@property (weak, nonatomic) YKJBubbleView *view3;
@property (weak, nonatomic) YKJBubbleView *view4;
@property (weak, nonatomic) UIImageView *imageView1;
@property (weak, nonatomic) UIImageView *imageView2;
@property (weak, nonatomic) UIImageView *imageView3;
@property (weak, nonatomic) UIImageView *imageView4;

@end

@implementation HIPLayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"layer"];
    
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.imageView1 sd_setImageWithURL:[NSURL URLWithString:@"https://imoss.yonyoucloud.com/upesn/esn/155359/20180116/1901/4af4ea91-42dd-45b1-b302-c4bb166379d3.png"]];
    [self.imageView2 sd_setImageWithURL:[NSURL URLWithString:@"https://imoss.yonyoucloud.com/upesn/esn/155359/20180116/1901/4af4ea91-42dd-45b1-b302-c4bb166379d3.png"]];
    [self.imageView3 sd_setImageWithURL:[NSURL URLWithString:@"https://imoss.yonyoucloud.com/upesn/esn/155359/20180116/1901/4af4ea91-42dd-45b1-b302-c4bb166379d3.png"]];
    [self.imageView4 sd_setImageWithURL:[NSURL URLWithString:@"https://imoss.yonyoucloud.com/upesn/esn/155359/20180116/1901/4af4ea91-42dd-45b1-b302-c4bb166379d3.png"]];
    // https://imoss.yonyoucloud.com/upesn/esn/155359/20180116/1703/5b7e90a8-3594-44f6-983f-16e4fba0087a.png
    // https://imoss.yonyoucloud.com/upesn/esn/155359/20180116/1901/4af4ea91-42dd-45b1-b302-c4bb166379d3.png
    // https://imoss.yonyoucloud.com/upesn/esn/155359/20180116/1901/4af4ea91-42dd-45b1-b302-c4bb166379d3.png
    // https://imoss.yonyoucloud.com/upesn/esn/155359/20180116/1901/a0c12e10-cf69-4cee-ac35-9ce47ef01e81.png
    // https://imoss.yonyoucloud.com/upesn/esn/155359/20180116/1901/45ae3b36-cf17-4eb8-9da8-9104f3cf6732.png
    
}

- (void)initView {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGFloat height = CGRectGetHeight(self.view.frame) - 76;
//    CGFloat imageHeight = height / 4 - 12.0f;
//    CGFloat imageWidth = imageHeight / 750.0f * 1200.0f;
    CGFloat imageHeight = 80.0f;
    CGFloat imageWidth = 130.0f;
    
    HIPBubbleView *view1 = [[HIPBubbleView alloc] initWithFrame:CGRectMake(8.0f, 12.0f, imageWidth, imageHeight)];
    [view1 setDirection:HIPBubbleDirectionRight];
    [self.view addSubview:view1];
    self.view1 = view1;
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageHeight)];
    [view1 addSubview:imageView1];
    self.imageView1 = imageView1;

    HIPBubbleView *view2 = [[HIPBubbleView alloc] initWithFrame:CGRectMake(8.0f, 24.0f + imageHeight, imageWidth, imageHeight)];
    [view2 setDirection:HIPBubbleDirectionLeft];
    [self.view addSubview:view2];
    self.view2 = view2;
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageHeight)];
    [view2 addSubview:imageView2];
    self.imageView2 = imageView2;
    
    YKJBubbleView *view3 = [[YKJBubbleView alloc] initWithFrame:CGRectMake(8.0f, 36.0f + imageHeight * 2, imageWidth, imageHeight)];
    [view3 setDirection:YKJBubbleDirectionRight];
    [self.view addSubview:view3];
    self.view3 = view3;
    
    UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageHeight)];
    [view3 addSubview:imageView3];
    self.imageView3 = imageView3;
    
    YKJBubbleView *view4 = [[YKJBubbleView alloc] initWithFrame:CGRectMake(8.0f, 48.0f + imageHeight * 3, imageWidth, imageHeight)];
    [view4 setDirection:YKJBubbleDirectionLeft];
    [self.view addSubview:view4];
    self.view4 = view4;
    
    UIImageView *imageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageHeight)];
    [view4 addSubview:imageView4];
    self.imageView4 = imageView4;
}

@end
