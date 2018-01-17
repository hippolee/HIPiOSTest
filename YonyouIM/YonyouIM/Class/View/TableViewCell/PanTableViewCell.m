//
//  PanTableViewCell.m
//  YonyouIM
//
//  Created by litfb on 15/7/7.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "PanTableViewCell.h"
#import "YYIMColorHelper.h"
#import "YMNormalProgressView.h"
#import "UIColor+YYIMTheme.h"
#import "UIImage+YYIMCategory.h"

@interface PanTableViewCell ()<YYIMAttachProgressDelegate>

@property (retain, nonatomic) YYFile *file;

@property (weak, nonatomic) IBOutlet UIView *progressContainer;

@property (weak, nonatomic) YMNormalProgressView *progressView;

@end

@implementation PanTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIImage *iconImage = [self moreIconImage];
    self.imageSet = SwipeCellImageSetMake(nil, nil, nil, iconImage);
    UIColor *color = UIColorFromRGB(0x67c5f8);
    self.colorSet = SwipeCellColorSetMake(nil, nil, color, color);
    
    YMNormalProgressView *progressView = [[YMNormalProgressView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.progressContainer.frame), CGRectGetHeight(self.progressContainer.frame))];
    [progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    progressView.progressBackColor = [UIColor whiteColor];
    progressView.progressTintColor = [UIColor themeBlueColor];
    [progressView setHidden:YES];
    [self.progressContainer addSubview:progressView];
    self.progressView = progressView;
    
    [[YYIMChat sharedInstance].chatManager addAttachProgressDelegate:self];
    
    [self prepareForReuse];
}

- (UIImage *)moreIconImage {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [label setText:@"更多"];
    [label setFont:[UIFont systemFontOfSize:16.0f]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [view addSubview:label];

    UIImage *image = [UIImage convertViewToImage:view];
    return image;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        self.enableLeft = NO;
    } else {
        self.enableLeft = self.enableSwipe;
    }
}

- (void)prepareForReuse {
    self.iconImage.image = nil;
    self.nameLabel.text = nil;
    self.detailLabel.text = nil;
    self.propLabel.text = nil;
    self.file = nil;
    [self.progressView setHidden:YES];
    self.enableSwipe = YES;
}

- (void)setActiveFile:(YYFile *)file {
    self.file = file;
}

- (YYFile *)activeFile {
    return self.file;
}

- (void)setIconImageName:(NSString *)imageName {
    [self.iconImage setImage:[UIImage imageNamed:imageName]];
}

- (void)setName:(NSString *)name {
    self.nameLabel.text = name;
}

- (void)setDetail:(NSString *)detail {
    self.detailLabel.text = detail;
}

- (void)setProp:(NSString *)prop {
    self.propLabel.text = prop;
}

- (void)setEnableSwipe:(BOOL)enableSwipe {
    _enableSwipe = enableSwipe;
    [self setEnableLeft:enableSwipe];
}

#pragma mark YYIMAttachProgressDelegate

- (void)attachDownloadProgress:(float)progress totalSize:(long long)totalSize readedSize:(long long)readedSize withAttachKey:(NSString *)attachKey {
    if ([attachKey isEqualToString:[self.file fileId]]) {
        if (totalSize < 0) {
            totalSize = [self.file fileSize];
            progress = (float)readedSize/totalSize;
        }
        [self.progressView setHidden:NO];
        [self.progressView setProgress:progress];
    }
}

- (void)attachDownloadComplete:(BOOL)result withAttachKey:(NSString *)attachKey error:(YYIMError *)error {
    if ([attachKey isEqualToString:[self.file fileId]]) {
        [self.progressView setHidden:YES];
    }
}

@end
