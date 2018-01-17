//
//  ChatImageView.m
//  YonyouIM
//
//  Created by litfb on 15/8/7.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ChatImageView.h"
#import "YMRoundProgressView.h"
#import "YYIMColorHelper.h"
#import "UIColor+YYIMTheme.h"
#import "YYIMUtility.h"

static const CGFloat kProgressWidth = 80.0f;
static const CGFloat kDownloadButtonWidth = 100.0f;
static const CGFloat kDownloadButtonHeight = 36.0f;

@interface ChatImageView ()<YYIMAttachProgressDelegate>

@property (nonatomic, weak) YMRoundProgressView *progressView;
@property (nonatomic, weak) UIButton *downloadbButton;

@end

@implementation ChatImageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[YYIMChat sharedInstance].chatManager addAttachProgressDelegate:self];
        [self initSubView];
    }
    return self;
}

- (void)initSubView {
    YMRoundProgressView *progressView = [[YMRoundProgressView alloc] initWithFrame:CGRectMake(0, 0, kProgressWidth, kProgressWidth)];
    progressView.progressBackColor = [UIColor clearColor];
    progressView.progressTintColor = [UIColor themeBlueColor];
    [self addSubview:progressView];
    self.progressView = progressView;
    
    //
    UIButton *downloadbButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kDownloadButtonWidth, kDownloadButtonHeight)];
    [downloadbButton setBackgroundColor:UIColorFromRGB(0x69b553)];
    [downloadbButton setTitle:@"下载原图" forState:UIControlStateNormal];
    [downloadbButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [downloadbButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [downloadbButton addTarget:self action:@selector(downloadOriginalImage:) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer *buttonLayer = [downloadbButton layer];
    [buttonLayer setMasksToBounds:YES];
    [buttonLayer setCornerRadius:4];
    
    [self addSubview:downloadbButton];
    self.downloadbButton = downloadbButton;
}

- (void)layoutSubviews {
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    self.progressView.frame = CGRectMake((width - kProgressWidth) / 2, (height - kProgressWidth) / 2, kProgressWidth, kProgressWidth);
    self.downloadbButton.frame = CGRectMake((width - kDownloadButtonWidth) / 2, height - 20 - kDownloadButtonHeight, kDownloadButtonWidth, kDownloadButtonHeight);
}

- (void)prepareForReuse {
    self.message = nil;
    [self.progressView setHidden:YES];
    [self.downloadbButton setHidden:YES];
}

- (void)setMessage:(YYMessage *)message {
    _message = message;
    if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE && [[message getMessageContent] isOriginal] && [YYIMUtility isEmptyString:[self.message getResOriginalLocal]]) {
        [self.downloadbButton setHidden:NO];
    }
    
    if (message) {
        if ([YYIMUtility isEmptyString:[message getResLocal]]) {
            [[YYIMChat sharedInstance].chatManager downloadImageMessageRes:[message pid] imageType:kYYIMImageTypeNormal progress:nil complete:nil];
        }
    }
}

- (void)downloadOriginalImage:(id)sender {
    if ([self.message direction] == YM_MESSAGE_DIRECTION_RECEIVE && [[self.message getMessageContent] isOriginal] && [YYIMUtility isEmptyString:[self.message getResOriginalLocal]]) {
        [[YYIMChat sharedInstance].chatManager downloadImageMessageRes:[self.message pid] imageType:kYYIMImageTypeOriginal progress:nil complete:nil];
    }
    [self.downloadbButton setHidden:YES];
}

#pragma mark YYIMAttachProgressDelegate

- (void)attachDownloadProgress:(float)progress totalSize:(long long)totalSize readedSize:(long long)readedSize withAttachKey:(NSString *)attachKey {
    NSString *messageAttachId = [[self.message getMessageContent] fileAttachId];
    NSString *attachKeyOriginal = [YYIMResourceUtility getAttachKey:messageAttachId imageType:kYYIMImageTypeOriginal];
    if ([attachKey isEqualToString:attachKeyOriginal]) {
        [self.progressView setHidden:NO];
        if (totalSize < 0) {
            totalSize = [[self.message getMessageContent] fileSize];
            progress = (float)readedSize/totalSize;
        }
        [self.progressView setProgress:progress];
    }
}

- (void)attachDownloadComplete:(BOOL)result withAttachKey:(NSString *)attachKey error:(YYIMError *)error {
    NSString *messageAttachId = [[self.message getMessageContent] fileAttachId];
    NSString *attachKeyOriginal = [YYIMResourceUtility getAttachKey:messageAttachId imageType:kYYIMImageTypeOriginal];
    if ([attachKey isEqualToString:attachKeyOriginal]) {
        [self.progressView setHidden:YES];
    }
}

@end
