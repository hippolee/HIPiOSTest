//
//  YYImageCropperViewController.h
//  YonyouIM
//
//  Created by litfb on 15/4/23.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYImageCropperViewController;

@protocol YYImageCropperDelegate <NSObject>

- (void)imageCropper:(YYImageCropperViewController *)cropperViewController didFinished:(UIImage *)croppedImage;

- (void)imageCropperDidCancel:(YYImageCropperViewController *)cropperViewController;

@end

@interface YYImageCropperViewController : UIViewController

@property (nonatomic, assign) id<YYImageCropperDelegate> delegate;
@property (nonatomic, assign) CGRect cropFrame;

- (instancetype)initWithImage:(UIImage *)originalImage;

- (instancetype)initWithImage:(UIImage *)originalImage limitScaleRatio:(NSInteger)limitRatio;

- (instancetype)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio;

@end
