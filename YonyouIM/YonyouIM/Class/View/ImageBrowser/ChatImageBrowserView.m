//
//  ChatImageBrowserView.m
//  YonyouIM
//
//  Created by litfb on 15/8/4.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ChatImageBrowserView.h"
#import "YYImageBrowserView.h"
#import "YMRoundProgressView.h"
#import "YYIMChatHeader.h"
#import "UIColor+YYIMTheme.h"
#import "YYMessage+YYIMCatagory.h"
#import "YYIMUtility.h"
#import "MBProgressHUD+Add.h"
#import "ChatImageView.h"

@interface ChatImageBrowserView ()<YYImageBrowserDelegate, YYImageBrowserDateSource, UIActionSheetDelegate>

@property (nonatomic, weak) YYImageBrowserView *browserView;

@property (retain, nonatomic) NSArray *imageSourceArray;

@property NSString *imagePathForSave;

@end

@implementation ChatImageBrowserView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubView];
    }
    return self;
}

- (void)initSubView {
    [self setBackgroundColor:[UIColor blueColor]];
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    YYImageBrowserView *browserView = [[YYImageBrowserView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [browserView setBackgroundColor:[UIColor themeColor]];
    [browserView setImageBrowserDateSource:self];
    [browserView setImageBrowserDelegate:self];
    [self addSubview:browserView];
    self.browserView = browserView;
}

- (void)setImageSourceArray:(NSArray *)imageSourceArray {
    _imageSourceArray = imageSourceArray;
    [self reloadData];
}

- (void)setImageIndex:(NSInteger)currentIndex {
    [self.browserView setCurrentImageIndex:currentIndex];
}

- (void)reloadData {
    [self.browserView reloadData];
}

- (void)show {
    self.isShown = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
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
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self removeFromSuperview];
    self.isShown = NO;
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"保存图片" otherButtonTitles:nil];
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
    [MBProgressHUD showHint:@"图片已保存" toView:self];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            ALAssetsLibrary * assetsLibrary = [[ALAssetsLibrary alloc] init];
            NSData *data = [NSData dataWithContentsOfFile:self.imagePathForSave];
            [assetsLibrary writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error) {
                    [MBProgressHUD showHint:@"图片保存失败" toView:self];
                } else {
                    [MBProgressHUD showHint:@"图片已保存" toView:self];
                }
            }];
            break;
        }
        default:
            break;
    }
    self.imagePathForSave = nil;
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

@end
