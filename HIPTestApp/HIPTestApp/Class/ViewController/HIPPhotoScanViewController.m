//
//  HIPPhotoScanViewController.m
//  litfb_test
//
//  Created by litfb on 16/1/14.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPPhotoScanViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ZXingObjC.h"
#import "HIPUtility.h"
#import "HIPQRCodeUtility.h"
#import "HIPColorHelper.h"

@interface HIPPhotoScanViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation HIPPhotoScanViewController

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
        // scan image
        ZXResult *result = [HIPQRCodeUtility attemptScanQRCodeImage:originalImage];
        if (result) {
            // The coded result as a string. The raw data can be accessed with
            // result.rawBytes and result.length.
            NSString *contents = result.text;
            
            // The barcode format, such as a QR code or UPC-A
            ZXBarcodeFormat format = result.barcodeFormat;
            
            NSString *title;
            switch (format) {
                case kBarcodeFormatQRCode:
                    title = @"二维码";
                    break;
                default:
                    title = @"条形码";
                    break;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:contents delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            // Use error to determine why we didn't get a result, such as a barcode
            // not being found, an invalid checksum, or a format inconsistency.
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:[NSString stringWithFormat:@"未能识别该图片"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
