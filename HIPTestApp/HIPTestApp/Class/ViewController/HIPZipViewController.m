//
//  HIPZipViewController.m
//  litfb_test
//
//  Created by litfb on 16/1/25.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPZipViewController.h"
#import "HIPGZipUtility.h"
#import "HIPStringUtility.h"

@interface HIPZipViewController ()

@property (weak, nonatomic) IBOutlet UITextView *originalTextView;

@property (weak, nonatomic) IBOutlet UITextView *cipherTextView;

- (IBAction)encryptAction:(id)sender;

- (IBAction)decryptAction:(id)sender;

@end

@implementation HIPZipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // title
    self.title = @"压缩解压缩测试";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark zip/unzip

- (IBAction)encryptAction:(id)sender {
    // 收键盘
    [self.originalTextView resignFirstResponder];
    [self.cipherTextView resignFirstResponder];
    // 原文
    NSString *originalStr = [HIPStringUtility trimString:[self.originalTextView text]];
    if ([HIPStringUtility isEmpty:originalStr]) {
        return;
    }
    // 原数据
    NSData *originalData = [originalStr dataUsingEncoding:NSUTF8StringEncoding];
    // 压缩数据
    NSData *cipherData = [HIPGZipUtility gzipData:originalData];
    // 转字符串
    NSString *cipherStr = [HIPStringUtility convertDataToHexStr:cipherData];
    // 设值
    [self.originalTextView setText:nil];
    [self.cipherTextView setText:cipherStr];
}

- (IBAction)decryptAction:(id)sender {
    // 收键盘
    [self.originalTextView resignFirstResponder];
    [self.cipherTextView resignFirstResponder];
    // 压缩数据
    NSString *cipherStr = [HIPStringUtility trimString:[self.cipherTextView text]];
    if ([HIPStringUtility isEmpty:cipherStr]) {
        return;
    }
    // 压缩数据
    NSData *cipherData = [HIPStringUtility convertHexStrToData:cipherStr];
    // 解压缩数据
    NSData *originalData = [HIPGZipUtility unGzipData:cipherData];
    // 转字符串
    NSString *originalStr = [[NSString alloc] initWithData:originalData encoding:NSUTF8StringEncoding];
    // 设值
    [self.originalTextView setText:originalStr];
    [self.cipherTextView setText:nil];
}

@end
