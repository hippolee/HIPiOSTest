//
//  GroupQRCCodeExpiredViewController.m
//  YonyouIM
//
//  Created by yanghaoc on 16/6/16.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "GroupQRCCodeExpiredViewController.h"
#import "YYIMUtility.h"
#import "ScanViewController.h"

@interface GroupQRCCodeExpiredViewController ()

@end

@implementation GroupQRCCodeExpiredViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"加入群组";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)reDoAction:(id)sender {
    if (self.needReturnScan) {
        ScanViewController *scanViewController = [[ScanViewController alloc] init];
        [YYIMUtility pushFromController:self toController:scanViewController];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
