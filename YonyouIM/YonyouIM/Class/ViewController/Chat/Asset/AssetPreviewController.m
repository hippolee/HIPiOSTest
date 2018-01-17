//
//  AssetPreviewController.m
//  YonyouIM
//
//  Created by litfb on 15/4/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetPreviewController.h"
#import "YYImageBrowserView.h"
#import "YYIMColorHelper.h"
#import "YYIMUtility.h"
#import "UIColor+YYIMTheme.h"
#import "UIViewController+HUDCategory.h"

@interface AssetPreviewController ()<YYImageBrowserDelegate, YYImageBrowserDateSource>

@property (weak, nonatomic) YYImageBrowserView *imageBrowser;

@property (weak, nonatomic) UIView *topView;
@property (weak, nonatomic) UIView *bottomView;

@property (weak, nonatomic) UIButton *originalButton;
@property (weak, nonatomic) UILabel *originalLabel;
@property (weak, nonatomic) UILabel *numberLabel;
@property (weak, nonatomic) UIButton *sendButton;

@property (weak, nonatomic) UIButton *checkboxButton;

@property BOOL isOriginal;

@end

@implementation AssetPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initBrowserView];
    [self initTopView];
    [self initBottomView];
    
    [self resetCheckboxState:self.imageIndex];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self refreshButtonState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initTopView {
    CGFloat width = CGRectGetWidth(self.view.frame);
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 64)];
    [topView setBackgroundColor:UIColorFromRGBA(0x000000, 0.6)];
    
    UIButton *checkboxButton = [[UIButton alloc] initWithFrame:CGRectMake(width - 64, 0, 64, 64)];
    [checkboxButton setImage:[UIImage imageNamed:@"icon_checkbox"] forState:UIControlStateNormal];
    [checkboxButton setImage:[UIImage imageNamed:@"icon_checkbox_hl"] forState:UIControlStateSelected];
    [checkboxButton addTarget:self action:@selector(imageCheckChange:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:checkboxButton];
    self.checkboxButton = checkboxButton;
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
    [backButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    
    [self.view addSubview:topView];
    self.topView = topView;
}

- (void)initBottomView {
    CGFloat width = CGRectGetWidth(self.view.frame);
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 44, width, 44)];
    [bottomView setBackgroundColor:UIColorFromRGBA(0x000000, 0.6)];
    // 原图按钮
    UIButton *originalButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 7, 30, 30)];
    [originalButton setImage:[UIImage imageNamed:@"icon_checkbox"] forState:UIControlStateNormal];
    [originalButton setImage:[UIImage imageNamed:@"icon_checkbox_hl"] forState:UIControlStateSelected];
    [originalButton addTarget:self action:@selector(originalAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:originalButton];
    self.originalButton = originalButton;
    
    UILabel *originalLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, 10, 100, 24)];
    [originalLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [originalLabel setTextColor:[UIColor whiteColor]];
    [originalLabel setText:@"原图"];
    
    [bottomView addSubview:originalLabel];
    self.originalLabel = originalLabel;
    
    // 发送按钮
    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(width - 52, 7, 36, 30)];
    [sendButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [sendButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor themeBlueColor] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:sendButton];
    self.sendButton = sendButton;
    
    // 数字
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(width - 76, 12, 20, 20)];
    [numberLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [numberLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [numberLabel setTextColor:[UIColor whiteColor]];
    [numberLabel setTextAlignment:NSTextAlignmentCenter];
    [numberLabel setBackgroundColor:[UIColor themeBlueColor]];
    
    [bottomView addSubview:numberLabel];
    self.numberLabel = numberLabel;
    
    CALayer *numberLayer = [self.numberLabel layer];
    [numberLayer setMasksToBounds:YES];
    [numberLayer setCornerRadius:10];
    
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
}

- (void)initBrowserView {
    YYImageBrowserView *browserView = [[YYImageBrowserView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    [browserView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [self.view addSubview:browserView];
    self.imageBrowser = browserView;
    // 设置数据
    [self.imageBrowser setBackgroundColor:[UIColor themeColor]];
    [self.imageBrowser setImageBrowserDelegate:self];
    [self.imageBrowser setImageBrowserDateSource:self];
    [self.imageBrowser reloadData];
    [self.imageBrowser setCurrentImageIndex:self.imageIndex];
}

- (void)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendAction:(id)sender {
    [self.delegate didSelectAssets:self.selectedArray isOriginal:self.isOriginal];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)originalAction:(id)sender {
    if (self.isOriginal) {
        self.isOriginal = NO;
        [self.originalButton setSelected:NO];
    } else {
        self.isOriginal = YES;
        [self.originalButton setSelected:YES];
    }
    
    NSInteger index = [self.imageBrowser currentImageIndex];
    [self resetOriginalLabelForIndex:index];
    ALAsset *asset = [self.imageSourceArray objectAtIndex:index];
    if (![self.selectedArray containsObject:asset] && [[self selectedArray] count] < 9) {
        [[self selectedArray] addObject:asset];
        [self.checkboxButton setSelected:YES];
    }
    [self refreshButtonState];
}

- (void)resetOriginalLabelForIndex:(NSUInteger)index {
    if (self.isOriginal) {
        ALAsset *asset = [self.imageSourceArray objectAtIndex:index];
        [self.originalLabel setText:[NSString stringWithFormat:@"原图(%@)", [YYIMUtility fileSize:[[asset defaultRepresentation] size]]]];
    } else {
        [self.originalLabel setText:@"原图"];
    }
}

- (void)resetCheckboxState:(NSUInteger)index {
    ALAsset *asset = [self.imageSourceArray objectAtIndex:index];
    if ([self.selectedArray containsObject:asset]) {
        [self.checkboxButton setSelected:YES];
    } else {
        [self.checkboxButton setSelected:NO];
    }
}

#pragma mark YYImageBrowserDelegate, YYImageBrowserDateSource

- (NSUInteger)numberOfImagesInImageBrowser:(YYImageBrowserView *)imageBrowser {
    return self.imageSourceArray.count;
}

- (UIImage *)imageBrowser:(YYImageBrowserView *)imageBrowser imageAtIndex:(NSUInteger)index {
    ALAsset *asset = [self.imageSourceArray objectAtIndex:index];
    return [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
}

- (BOOL)imageBrowser:(YYImageBrowserView *)imageBrowser acceptSingleTapForIndex:(NSUInteger)index {
    return YES;
}

- (void)imageBrowser:(YYImageBrowserView *)imageBrowser didSingleTapForIndex:(NSUInteger)index {
    if ([self.topView isHidden]) {
        [self showBar];
    } else {
        [self hiddenBar];
    }
}

- (void)imageBrowser:(YYImageBrowserView *)imageBrowser didDisplayImageAtIndex:(NSUInteger)index inView:(YYImageView *)imageView {
    [self resetOriginalLabelForIndex:index];
    [self resetCheckboxState:index];
}

#pragma mark private func

- (void)imageCheckChange:(id)sender {
    NSInteger index = [self.imageBrowser currentImageIndex];
    
    UIButton *checkboxBtn = (UIButton *)sender;
    if (![checkboxBtn isSelected] && [[self selectedArray] count] >= 9) {
        [self showHint:@"您最多只能选择9张照片"];
        return;
    }
    
    ALAsset *asset = [self.imageSourceArray objectAtIndex:index];
    if ([self.selectedArray containsObject:asset]) {
        [self.selectedArray removeObject:asset];
        [self.checkboxButton setSelected:NO];
    } else {
        [[self selectedArray] addObject:asset];
        [self.checkboxButton setSelected:YES];
    }
    [self refreshButtonState];
}

- (void)hiddenBar {
    [self.topView setHidden:YES];
    [self.bottomView setHidden:YES];
}

- (void)showBar {
    [self.topView setHidden:NO];
    [self.bottomView setHidden:NO];
}

- (void)refreshButtonState {
    NSInteger count = [[self selectedArray] count];
    [self.numberLabel setText:[NSString stringWithFormat:@"%ld", (long)count]];
    if (count <= 0) {
        [self.numberLabel setHidden:YES];
        [self.sendButton setEnabled:NO];
    } else {
        [self.numberLabel setHidden:NO];
        [self.sendButton setEnabled:YES];
    }
}

- (CGFloat)baseViewHeight {
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    CGFloat navigationHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    CGFloat statusHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    return screenHeight - navigationHeight - statusHeight;
}

@end
