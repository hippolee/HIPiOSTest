//
//  HIPLayerController.m
//  litfb_test
//
//  Created by litfb on 16/6/17.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPLayerController.h"
#import "UIImageView+WebCache.h"
#import "HIPImageBubbleView.h"

@interface HIPLayerController ()

@property (weak, nonatomic) UIImageView *imageView1;
@property (weak, nonatomic) HIPImageBubbleView *imageView2;

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
    [self.imageView1 sd_setImageWithURL:[NSURL URLWithString:@"http://image.tianjimedia.com/uploadImages/2015/129/56/J63MI042Z4P8.jpg"]];
    [self.imageView2 sd_setImageWithURL:[NSURL URLWithString:@"http://image.tianjimedia.com/uploadImages/2015/129/56/J63MI042Z4P8.jpg"]];
    [self.imageView2 setDirection:YMImageBubbleDirectionRight];
    [self.imageView2 setShowArrow:NO];
}

- (void)initView {
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat imageWidth = width - 16.0f;
    CGFloat imageHeight = imageWidth / 1200.0f * 750.0f;
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(8.0f, 32.0f, imageWidth, imageHeight)];
    [imageView1 setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:imageView1];
    self.imageView1 = imageView1;
    
    HIPImageBubbleView *imageView2 = [[HIPImageBubbleView alloc] initWithFrame:CGRectMake(8.0f, 48.0f + imageHeight, imageWidth, imageHeight)];
    [imageView2 setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:imageView2];
    self.imageView2 = imageView2;
}

@end
