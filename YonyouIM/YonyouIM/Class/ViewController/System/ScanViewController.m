//
//  ScanViewController.m
//  YonyouIM
//
//  Created by litfb on 16/3/16.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "YMScanBoxView.h"
#import "WebViewController.h"
#import "YYIMUtility.h"
#import "GroupScanViewController.h"
#import "ChatViewController.h"
#import "ZXingObjC.h"
#import "YYIMQRCodeUtility.h"
#import "YYIMColorHelper.h"

@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

// 预览View
@property (weak, nonatomic) UIView *previewView;
// 预览图层
@property (weak, nonatomic) CALayer *previewLayer;
// 扫描框View
@property (weak, nonatomic) UIView *scanView;
// 扫描线
@property (weak, nonatomic) UIImageView *lineView;
// 提示View
@property (weak, nonatomic) UIView *promptView;

// 会话
@property (nonatomic, strong) AVCaptureSession *captureSession;
// 输出流
@property (nonatomic, strong) AVCaptureMetadataOutput *output;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // title
    self.title = @"二维码扫描";
    
    [YYIMUtility clearBackButtonText:self];
    // 初始化View
    [self initView];
    // 准备
    [self prepareScaning];
    // start scan
    [self startScaning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopScaning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark init

- (void)initView {
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(scanImageAction:)]];
    
    // 背景色
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    // 预览View
    CGRect previewRect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64);
    UIView *previewView = [[UIView alloc] initWithFrame:previewRect];
    [previewView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:previewView];
    self.previewView = previewView;
    
    // 扫描框
    YMScanBoxView *scanView = [[YMScanBoxView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64) scanRect:[self scanRect]];
    [self.view addSubview:scanView];
    self.scanView = scanView;
    
    // 扫描线
    CGRect lineRect = [self scanRect];
    lineRect.size.height = 2;
    UIImageView *lineView = [[UIImageView alloc] initWithFrame:lineRect];
    [lineView setImage:[UIImage imageNamed:@"scan_line"]];
    [lineView setContentMode:UIViewContentModeScaleAspectFill];
    [lineView setBackgroundColor:[UIColor clearColor]];
    [[lineView layer] setMasksToBounds:YES];
    [self.view addSubview:lineView];
    self.lineView = lineView;
    [lineView setHidden:NO];
    
    // 未发现
    UIView *promptView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    [promptView setBackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
    CGRect scanRect = [self scanRect];
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(scanRect.origin.x, scanRect.origin.y + CGRectGetHeight(scanRect) / 2.0f - 20.0f, CGRectGetWidth(scanRect), 16)];
    [label1 setText:@"未发现二维码"];
    [label1 setTextColor:[UIColor whiteColor]];
    [label1 setFont:[UIFont systemFontOfSize:16.0f]];
    [label1 setTextAlignment:NSTextAlignmentCenter];
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(scanRect.origin.x, scanRect.origin.y + CGRectGetHeight(scanRect) / 2.0f + 4.0f, CGRectGetWidth(scanRect), 10)];
    [label2 setText:@"轻触屏幕继续扫描"];
    [label2 setTextColor:[UIColor lightGrayColor]];
    [label2 setFont:[UIFont systemFontOfSize:14.0f]];
    [label2 setTextAlignment:NSTextAlignmentCenter];
    [promptView addSubview:label1];
    [promptView addSubview:label2];
    [promptView setHidden:YES];
    [self.view addSubview:promptView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startScaning)];
    [promptView addGestureRecognizer:tapGestureRecognizer];
    
    self.promptView = promptView;
}

#pragma scan

- (void)prepareScaning {
    // 初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 用captureDevice创建输入流
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"启动扫描设备失败:%@", [error localizedDescription]);
        return;
    }
    
    // 创建媒体数据输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    self.output = output;
    
    // 实例化Session
    self.captureSession = [[AVCaptureSession alloc] init];
    // 采集率1080p
    [self.captureSession setSessionPreset:AVCaptureSessionPreset1920x1080];
    // 添加输入流
    [self.captureSession addInput:input];
    // 添加输出流
    [self.captureSession addOutput:self.output];
    
    // 输出流设置输出媒体数据类型为二维码//,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code
    [self.output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    // 输出流设置扫描范围// 全屏幕
    //    [output setRectOfInterest:[self outputRectOfInterest]];
    
    // 实例化预览图层
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    // 设置预览图层填充方式
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    // 设置图层的frame
    [previewLayer setFrame:self.previewView.layer.bounds];
    // 将图层添加到预览view的图层上
    [self.previewView.layer insertSublayer:previewLayer atIndex:0];
    self.previewLayer = previewLayer;
    
    // 开始扫描
    [self.captureSession startRunning];
}

- (void)startScaning {
    [self.promptView setHidden:YES];
    
    // 输出流设置代理
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 开始扫描动画
    [self addAnimation];
}

- (void)stopScaning {
    // 停止输出
    [self.output setMetadataObjectsDelegate:nil queue:nil];
    // 停止扫描动画
    [self removeAnimation];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // 判断是否有数据
    if (metadataObjects.count > 0) {
        // 停止扫描
        [self stopScaning];
        // 输出扫描字符串
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        // 处理二维码
        [YYIMQRCodeUtility dealQrCodeWithText:metadataObj.stringValue atVC:self closeVC:YES];
    }
}

#pragma animation

- (void)addAnimation{
    [self.lineView setHidden:NO];
    CGRect rect = [self scanRect];
    CABasicAnimation *animation = [self animationWithDuration:3.0f fromY:[NSNumber numberWithFloat:0] toY:[NSNumber numberWithFloat:CGRectGetHeight(rect) - 1] repeatCount:OPEN_MAX];
    [[self.lineView layer] addAnimation:animation forKey:@"ScanAnimation"];
}

- (void)removeAnimation{
    [[self.lineView layer] removeAnimationForKey:@"ScanAnimation"];
    [self.lineView setHidden:YES];
}

- (CABasicAnimation *)animationWithDuration:(float)duration fromY:(NSNumber *)fromY toY:(NSNumber *)toY repeatCount:(int)repeatCount {
    CABasicAnimation *animationMove = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [animationMove setFromValue:fromY];
    [animationMove setToValue:toY];
    [animationMove setDuration:duration];
    [animationMove setDelegate:self];
    [animationMove setRepeatCount:repeatCount];
    [animationMove setFillMode:kCAFillModeForwards];
    [animationMove setRemovedOnCompletion:NO];
    animationMove.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animationMove;
}

#pragma mark photo

- (void)scanImageAction:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [self openImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"没有相册权限" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)openImagePicker:(UIImagePickerControllerSourceType)sourceType {
    [self stopScaning];
    // 跳转相册或相机页面
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [YYIMUtility genThemeNavController:imagePicker];
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:sourceType];
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    }
    NSMutableArray *mediaTypes = [NSMutableArray array];
    [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
    imagePicker.mediaTypes = mediaTypes;
    
    [imagePicker setAllowsEditing:NO];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 得到图片
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    // scan image
    ZXResult *result = [YYIMQRCodeUtility attemptScanQRCodeImage:originalImage];
    
    if (result && kBarcodeFormatQRCode == result.barcodeFormat) {
        [self dismissViewControllerAnimated:YES completion:^{
            // 处理二维码
            [YYIMQRCodeUtility dealQrCodeWithText:result.text atVC:self closeVC:YES];
        }];
    } else {
        [self.promptView setHidden:NO];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self startScaning];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark deal qrcode



#pragma mark scanRect and outputRectOfInterest

- (CGRect)scanRect {
    return CGRectMake(CGRectGetWidth(self.previewView.frame) * 0.15f, CGRectGetHeight(self.previewView.frame) * 0.15f, CGRectGetWidth(self.previewView.frame) * 0.7f, CGRectGetWidth(self.previewView.frame) * 0.7f);
}

// 匹配扫描框的扫描Rect计算
//- (CGRect)outputRectOfInterest {
//    // 扫描框Rect
//    CGRect cropRect = [self scanRect];
//    // 预览View尺寸
//    CGSize size = self.previewView.frame.size;
//    // 尺寸比例
//    CGFloat p1 = size.height / size.width;
//    // 使用1080p的图像输出
//    CGFloat p2 = 1920.0f / 1080.0f;
//    if (p1 < p2) {
//        CGFloat fixHeight = size.width * 1920.0f / 1080.0f;
//        CGFloat fixPadding = (fixHeight - size.height) / 2;
//        return CGRectMake((cropRect.origin.y + fixPadding) / fixHeight,
//                          cropRect.origin.x / size.width,
//                          cropRect.size.height / fixHeight,
//                          cropRect.size.width / size.width);
//    } else {
//        CGFloat fixWidth = size.height * 1080.0f / 1920.0f;
//        CGFloat fixPadding = (fixWidth - size.width) / 2;
//        return CGRectMake(cropRect.origin.y / size.height,
//                          (cropRect.origin.x + fixPadding) / fixWidth,
//                          cropRect.size.height / size.height,
//                          cropRect.size.width / fixWidth);
//    }
//}

@end
