//
//  NetworkViewController.m
//  YonyouIM
//
//  Created by litfb on 15/7/31.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "NetworkViewController.h"
#import "YYIMColorHelper.h"

@interface NetworkViewController ()

@end

@implementation NetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"未能连接到互联网";
    
    [self initSubView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSubView {
    [self.view setBackgroundColor:UIColorFromRGB(0xf6f6f6)];
    
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat labelY = 32;
    NSString *text1 = @"您的设备未启用移动网络或Wi-Fi网络";
    NSString *text2 = @"如需要连接到互联网，可以参照一下办法：";
    NSString *text3 = @"在设备的“设置”-“Wi-Fi网络”设置面板中选择一个可用的Wi-Fi热点接入。";
    NSString *text4 = @"在设备的“设置”-“通用”-“网络”设置面板中启用蜂窝数据（启用后运营商可能会收取数据通信费用）";
    NSString *text5 = @"如果您已接入Wi-Fi网络：";
    NSString *text6 = @"请检查您所连接的Wi-Fi热点是否已接入互联网，或该热点是否已允许您的设备访问互联网。";
    UILabel *label1 = [self labelWithText:text1 frame:CGRectMake(16, labelY, width - 32, 0) font:[UIFont boldSystemFontOfSize:16.0f]];
    [self.view addSubview:label1];
    labelY += CGRectGetHeight(label1.frame);
    labelY += 16;
    UILabel *label2 = [self labelWithText:text2 frame:CGRectMake(16, labelY, width - 32, 0) font:[UIFont systemFontOfSize:15.0f]];
    [self.view addSubview:label2];
    labelY += CGRectGetHeight(label2.frame);
    labelY += 8;
    UILabel *label3 = [self labelWithText:text3 frame:CGRectMake(16, labelY, width - 32, 0) font:[UIFont systemFontOfSize:15.0f]];
    [self.view addSubview:label3];
    labelY += CGRectGetHeight(label3.frame);
    labelY += 4;
    UILabel *label4 = [self labelWithText:text4 frame:CGRectMake(16, labelY, width - 32, 0) font:[UIFont systemFontOfSize:15.0f]];
    [self.view addSubview:label4];
    labelY += CGRectGetHeight(label4.frame);
    labelY += 32;
    UILabel *label5 = [self labelWithText:text5 frame:CGRectMake(16, labelY, width - 32, 0) font:[UIFont systemFontOfSize:15.0f]];
    [self.view addSubview:label5];
    labelY += CGRectGetHeight(label5.frame);
    labelY += 8;
    UILabel *label6 = [self labelWithText:text6 frame:CGRectMake(16, labelY, width - 32, 0) font:[UIFont systemFontOfSize:15.0f]];
    [self.view addSubview:label6];
}

- (UILabel *)labelWithText:(NSString *)text frame:(CGRect)frame font:(UIFont *)font {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor blackColor]];
    [label setFont:font];
    [label setNumberOfLines:0];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    // 调整行间距
    [paragraphStyle setLineSpacing:6];
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    [label setAttributedText:attributedString];
    [label sizeToFit];
    return label;
}

@end
