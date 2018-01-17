//
//  AboutViewController.m
//  YonyouIM
//
//  Created by litfb on 15/7/1.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *verLabel;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"关于";
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app名称
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    // app版本
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // app build版本
    NSString *appBuild = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    [self.nameLabel setText:appName];
    [self.verLabel setText:[NSString stringWithFormat:@"%@(%@)", appVersion, appBuild]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
