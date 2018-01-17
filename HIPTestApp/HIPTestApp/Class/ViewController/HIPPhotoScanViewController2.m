//
//  HIPPhotoScanViewController.m
//  litfb_test
//
//  Created by litfb on 16/1/14.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPPhotoScanViewController2.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "HIPUtility.h"
#import "HIPQRCodeUtility.h"
#import "HIPColorHelper.h"

@interface HIPPhotoScanViewController2 ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation HIPPhotoScanViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // title
    self.title = @"测试扫描图片二维码";
    
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initView {
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) / 2 - 100, 200, 200, 44)];
    [button setTitle:@"扫描相册图片" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:HIP_THEME_BLUE];
    [button addTarget:self action:@selector(scanImageAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)scanImageAction:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [self openImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"没有相册权限" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)openImagePicker:(UIImagePickerControllerSourceType)sourceType {
    // 跳转相册或相机页面
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
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

#pragma mark image picker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        // 得到图片
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        CIImage *ciImage = [[CIImage alloc] initWithImage:originalImage];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
        NSArray *features = [detector featuresInImage:ciImage];
        
        NSString *contents = nil;
        for (CIQRCodeFeature *feature in features) {
            contents = feature.messageString;
            break;
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"二维码" message:contents delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
