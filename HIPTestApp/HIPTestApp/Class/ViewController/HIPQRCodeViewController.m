//
//  HIPQRCodeViewController.m
//  litfb_test
//
//  Created by litfb on 16/1/8.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPQRCodeViewController.h"
#import "HIPUtility.h"
#import "HIPQRCodeUtility.h"
#import "HIPColorHelper.h"

@interface HIPQRCodeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *dataTextField;
@property (weak, nonatomic) IBOutlet UIButton *genButton;
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;
- (IBAction)genAction:(id)sender;

@end

@implementation HIPQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // title
    [self setTitle:@"二维码"];
    
    // data
    [self.dataTextField setText:@"http://www.baidu.com"];
    // button color
    [self.genButton setBackgroundColor:HIP_THEME_BLUE];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self genAction:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)genAction:(id)sender {
    [self.dataTextField resignFirstResponder];
    CGFloat dimension = CGRectGetWidth([UIScreen mainScreen].bounds) - 40;
    UIImage *image = [HIPQRCodeUtility createQRCodeImageWithSource:self.dataTextField.text dimension:dimension];
//    UIImage *image1 = [HIPQRCodeUtility createQRCodeImageWithSource:self.dataTextField.text foregroundColor:HIP_THEME_ORANGE backgroundColor:HIP_THEME_BLUE dimension:dimension];
    UIImage *image2 = [HIPQRCodeUtility decorateQRCodeImage:image withIcon:[UIImage imageNamed:@"image_yyim"] scale:0.2f];
    [self.qrImageView setImage:image2];
    
}

@end
