//
//  HIPCusCodeViewController.m
//  litfb_test
//
//  Created by litfb on 16/1/27.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPCusCodeViewController.h"
#import "HIPColorHelper.h"
#import "HIPQRCodeUtility.h"
#import "HIPStringUtility.h"

@interface HIPCusCodeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *dataTextField;
@property (weak, nonatomic) IBOutlet UIButton *genButton;
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;

@end

@implementation HIPCusCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // title
    self.title = @"自定义二维码";
    // init
    [self initView];
    // data
    [self.dataTextField setText:@"哈哈"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self genAction:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initView {
    // background
    [self.view setBackgroundColor:HIP_THEME_GRAY];
    // view width
    CGFloat width = CGRectGetWidth(self.view.frame);
    // textView
    UITextField *dataTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, 20.0f, width - 40.0f, 32.0f)];
    [dataTextField setBorderStyle:UITextBorderStyleLine];
    [dataTextField setFont:[UIFont systemFontOfSize:16.0f]];
    [self.view addSubview:dataTextField];
    self.dataTextField = dataTextField;
    // genButton
    UIButton *genButton = [[UIButton alloc] initWithFrame:CGRectMake((width - 128.0f) / 2, 72.0f, 128.0f, 32.0f)];
    [genButton setTitle:@"生成" forState:UIControlStateNormal];
    [genButton setBackgroundColor:HIP_THEME_BLUE];
    [genButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[genButton titleLabel] setFont:[UIFont systemFontOfSize:15.0f]];
    [genButton addTarget:self action:@selector(genAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:genButton];
    self.genButton = genButton;
    // imageView
    UIImageView *qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 124.0f, width - 40.0f, width - 40.0f)];
    [self.view addSubview:qrImageView];
    self.qrImageView = qrImageView;
}

- (void)genAction:(id)sender {
    [self.dataTextField resignFirstResponder];
    // dataText
    NSString *dataText = [HIPStringUtility trimString:[self.dataTextField text]];
    if ([HIPStringUtility isEmpty:dataText]) {
        return;
    }
    // custom url
    NSString *dataStr = [NSString stringWithFormat:@"hippo://www.hippo.com?alert=%@", dataText];
    // qrcode dimension
    CGFloat dimension = CGRectGetWidth(self.view.frame) - 40;
    // gen qrcode
    UIImage *image = [HIPQRCodeUtility createQRCodeImageWithSource:dataStr dimension:dimension];
    //    UIImage *image1 = [HIPQRCodeUtility createQRCodeImageWithSource:self.dataTextField.text foregroundColor:HIP_THEME_ORANGE backgroundColor:HIP_THEME_BLUE dimension:dimension];
    UIImage *imageWithIcon = [HIPQRCodeUtility decorateQRCodeImage:image withIcon:[UIImage imageNamed:@"image_yyim"] scale:0.2f];
    [self.qrImageView setImage:imageWithIcon];
}

@end
