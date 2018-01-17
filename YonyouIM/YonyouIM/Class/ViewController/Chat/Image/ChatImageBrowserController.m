//
//  ChatImageBrowserController.m
//  YonyouIM
//
//  Created by litfb on 16/3/17.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "ChatImageBrowserController.h"
#import "YYImageBrowserView.h"
#import "YMRoundProgressView.h"
#import "YYIMChatHeader.h"
#import "UIColor+YYIMTheme.h"
#import "YYMessage+YYIMCatagory.h"
#import "YYIMUtility.h"
#import "UIViewController+HUDCategory.h"
#import "ChatImageView.h"
#import "ZXingObjC.h"
#import "YYIMQRCodeUtility.h"

@interface ChatImageBrowserController ()<YYImageBrowserDelegate, YYImageBrowserDateSource, UIActionSheetDelegate>

@property (nonatomic, weak) YYImageBrowserView *browserView;



@property NSString *imagePathForSave;

@property NSString *imageQrCode;

@end

@implementation ChatImageBrowserController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSubView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)initSubView {
    [self.view setBackgroundColor:[UIColor blueColor]];
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    YYImageBrowserView *browserView = [[YYImageBrowserView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [browserView setBackgroundColor:[UIColor themeColor]];
    [browserView setImageBrowserDateSource:self];
    [browserView setImageBrowserDelegate:self];
    [self.view addSubview:browserView];
    self.browserView = browserView;
    
    if (self.imageIndex) {
        [self.browserView setCurrentImageIndex:self.imageIndex];
    }
}

- (void)setImageSourceArray:(NSArray *)imageSourceArray {
    _imageSourceArray = imageSourceArray;
    [self reloadData];
}

- (void)setImageIndex:(NSInteger)imageIndex {
    _imageIndex = imageIndex;
    [self.browserView setCurrentImageIndex:imageIndex];
}

- (void)reloadData {
    [self.browserView reloadData];
}

#pragma mark YYImageBrowserDelegate

- (NSUInteger)numberOfImagesInImageBrowser:(YYImageBrowserView *)imageBrowser {
    return [self.imageSourceArray count];
}

- (void)imageBrowser:(YYImageBrowserView *)imageBrowser imageAtIndex:(NSUInteger)index complete:(void (^)(UIImage *))complete {
    YYMessage *message = [self.imageSourceArray objectAtIndex:index];
    complete([message getMessageOriginalImage]);
}

- (void)imageBrowser:(YYImageBrowserView *)imageBrowser willDisplayImageAtIndex:(NSUInteger)index inView:(YYImageView *)imageView {
    YYMessage *message = [self.imageSourceArray objectAtIndex:index];
    [(ChatImageView *)imageView setMessage:message];
}

- (BOOL)imageBrowser:(YYImageBrowserView *)imageBrowser acceptSingleTapForIndex:(NSUInteger)index {
    return YES;
}

- (void)imageBrowser:(YYImageBrowserView *)imageBrowser didSingleTapForIndex:(NSUInteger)index {
    [self.navigationController popViewControllerAnimated:NO];
}

- (BOOL)imageBrowser:(YYImageBrowserView *)imageBrowser acceptLongPressForIndex:(NSUInteger)index {
    return YES;
}

- (void)imageBrowser:(YYImageBrowserView *)imageBrowser didLongPressForIndex:(NSUInteger)index {
    YYMessage *message = [self.imageSourceArray objectAtIndex:index];
    self.imagePathForSave = [self getMessageImagePath:message];
    if (!self.imagePathForSave) {
        return;
    }
    
    // scan image
    ZXResult *result = [YYIMQRCodeUtility attemptScanQRCodeImage:[message getMessageImage]];
    if (result && kBarcodeFormatQRCode == result.barcodeFormat) {
        self.imageQrCode = result.text;
    }
    
    UIActionSheet *actionSheet;
    if (self.imageQrCode) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存图片", @"识别图中二维码", nil];
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存图片", nil];
    }
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [actionSheet showInView:self.browserView];
}

- (Class)imageBrowserImageViewClass {
    return [ChatImageView class];
}

- (void)willImageShow:(id)imageSource {
    YYMessage *message = (YYMessage *) imageSource;
    [message getMessageImage];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self showHint:@"图片已保存"];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            ALAssetsLibrary * assetsLibrary = [[ALAssetsLibrary alloc] init];
            NSData *data = [NSData dataWithContentsOfFile:self.imagePathForSave];
            [assetsLibrary writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error) {
                    [self showHint:@"图片保存失败"];
                } else {
                    [self showHint:@"图片已保存"];
                }
            }];
            break;
        }
        case 1: {
            if (self.imageQrCode) {
                [YYIMQRCodeUtility dealQrCodeWithText:self.imageQrCode atVC:self closeVC:NO];
            }
            break;
        }
        default:
            break;
    }
    self.imagePathForSave = nil;
    self.imageQrCode = nil;
}

- (NSString *)getMessageImagePath:(YYMessage *)message {
    if ([message getResOriginalLocal]) {
        return [message getResOriginalLocal];
    }
    
    if ([message getResLocal]) {
        return [message getResLocal];
    }
    
    if ([message getResThumbLocal]) {
        return [message getResThumbLocal];
    }
    return nil;
}

#pragma mark visible

- (BOOL)isVisible {
    return (self.isViewLoaded && self.view.window);
}

@end
