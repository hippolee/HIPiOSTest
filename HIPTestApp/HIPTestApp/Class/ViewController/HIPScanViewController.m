//
//  HIPScanViewController.m
//  litfb_test
//
//  Created by litfb on 16/1/13.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "HIPUtility.h"
#import "HIPScanBoxView.h"
#import "HIPStringUtility.h"
#import "HIPWebViewController.h"

@interface HIPScanViewController ()<AVCaptureMetadataOutputObjectsDelegate, CAAnimationDelegate>

// 预览View
@property (weak, nonatomic) UIView *previewView;
// 预览图层
@property (weak, nonatomic) CALayer *previewLayer;
// 扫描框View
@property (weak, nonatomic) UIView *scanView;
// 扫描线
@property (weak, nonatomic) UIImageView *lineView;

// 会话
@property (nonatomic, strong) AVCaptureSession *captureSession;

@end

@implementation HIPScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // title
    self.title = @"二维码/条码";
    // 初始化View
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startScaning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark init

- (void)initView {
    // 背景色
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    // 预览View
    CGRect previewRect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64);
    UIView *previewView = [[UIView alloc] initWithFrame:previewRect];
    [previewView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:previewView];
    self.previewView = previewView;
    
    // 扫描框
    HIPScanBoxView *scanView = [[HIPScanBoxView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64) scanRect:[self scanRect]];
    [self.view addSubview:scanView];
    self.scanView = scanView;
    
    // 扫描线
    CGRect rect = [self scanRect];
    rect.size.height = 1;
    UIImageView *lineView = [[UIImageView alloc] initWithFrame:rect];
    [lineView setImage:[UIImage imageNamed:@"scan_line"]];
    [lineView setContentMode:UIViewContentModeScaleAspectFill];
    [lineView setBackgroundColor:[UIColor clearColor]];
    [[lineView layer] setMasksToBounds:YES];
    [self.view addSubview:lineView];
    self.lineView = lineView;
    [lineView setHidden:NO];
}

#pragma scan

- (BOOL)startScaning {
    // 初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 用captureDevice创建输入流
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"启动扫描失败:%@", [error localizedDescription]);
        return NO;
    }
    
    // 创建媒体数据输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    // 实例化Session
    self.captureSession = [[AVCaptureSession alloc] init];
    // 采集率1080p
    [self.captureSession setSessionPreset:AVCaptureSessionPreset1920x1080];
    // 添加输入输出流
    [self.captureSession addInput:input];
    [self.captureSession addOutput:output];
    
    // 输出流设置代理
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // 输出流设置输出媒体数据类型为二维码
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]];
    // 输出流设置扫描范围
    [output setRectOfInterest:[self outputRectOfInterest]];
    
    // 实例化预览图层
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    // 设置预览图层填充方式
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    // 设置图层的frame
    [previewLayer setFrame:self.previewView.layer.bounds];
    // 将图层添加到预览view的图层上
    [self.previewView.layer insertSublayer:previewLayer atIndex:0];
    self.previewLayer = previewLayer;
    
    // 监听扫描状态
    [self.captureSession addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];
    // 开始扫描
    [self.captureSession startRunning];
    return YES;
}

- (void)stopScaning {
    // 停止会话
    [self.captureSession stopRunning];
    [self.captureSession removeObserver:self forKeyPath:@"running"];
    self.captureSession = nil;
    [self.previewLayer removeFromSuperlayer];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // 判断是否有数据
    if (metadataObjects.count > 0) {
        // 停止扫描
        [self stopScaning];
        // 输出扫描字符串
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        
        NSString *qrCodeStr = metadataObj.stringValue;
        NSURL *url = [NSURL URLWithString:[HIPStringUtility encodeToEscapeString:qrCodeStr]];
        if ([[url scheme] isEqualToString:@"http"]) {
            HIPWebViewController *webViewController = [[HIPWebViewController alloc] init];
            [webViewController setUrl:url];
            
            NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
            [viewControllers removeObject:self];
            [viewControllers addObject:webViewController];
            UIViewController *viewController = [viewControllers lastObject];
            [viewController setHidesBottomBarWhenPushed:YES];
            [self.navigationController setViewControllers:viewControllers animated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
            
            if ([[url scheme] isEqualToString:@"hippo"]) {
                NSString *alertStr = [HIPStringUtility getValueFromUrl:url forParam:@"alert"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"二维码" message:alertStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"二维码" message:qrCodeStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
    }
}

#pragma observe captureSession isRunning, control animation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == self.captureSession) {
        BOOL isRunning = [self.captureSession isRunning];
        if (isRunning) {
            [self addAnimation];
        }else{
            [self removeAnimation];
        }
    }
}

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

#pragma mark scanRect and outputRectOfInterest

- (CGRect)scanRect {
    return CGRectMake(CGRectGetWidth(self.previewView.frame) * 0.15f, CGRectGetHeight(self.previewView.frame) * 0.15f, CGRectGetWidth(self.previewView.frame) * 0.7f, CGRectGetWidth(self.previewView.frame) * 0.7f);
}

- (CGRect)outputRectOfInterest {
    // 扫描框Rect
    CGRect cropRect = [self scanRect];
    // 预览View尺寸
    CGSize size = self.previewView.frame.size;
    // 尺寸比例
    CGFloat p1 = size.height / size.width;
    // 使用1080p的图像输出
    CGFloat p2 = 1920.0f / 1080.0f;
    if (p1 < p2) {
        CGFloat fixHeight = size.width * 1920.0f / 1080.0f;
        CGFloat fixPadding = (fixHeight - size.height) / 2;
        return CGRectMake((cropRect.origin.y + fixPadding) / fixHeight,
                          cropRect.origin.x / size.width,
                          cropRect.size.height / fixHeight,
                          cropRect.size.width / size.width);
    } else {
        CGFloat fixWidth = size.height * 1080.0f / 1920.0f;
        CGFloat fixPadding = (fixWidth - size.width) / 2;
        return CGRectMake(cropRect.origin.y / size.height,
                          (cropRect.origin.x + fixPadding) / fixWidth,
                          cropRect.size.height / size.height,
                          cropRect.size.width / fixWidth);
    }
}

- (void)dealloc {
    if (self.captureSession) {
        [self stopScaning];
    }
}

@end
