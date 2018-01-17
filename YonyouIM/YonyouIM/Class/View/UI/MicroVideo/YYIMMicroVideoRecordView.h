//
//  YYIMMicroVideoRecordView.h
//  YonyouIM
//
//  Created by yanghaoc on 16/6/3.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YYIMMicroVideoRecordViewDelegate;

@interface YYIMMicroVideoRecordView : UIView

@property (weak, nonatomic) id<YYIMMicroVideoRecordViewDelegate> delegate;

//上方站位button
@property (weak, nonatomic) IBOutlet UIButton *emptyButton;

//按钮组的view
@property (weak, nonatomic) IBOutlet UIView *functionView;
//关闭按钮
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
//摄像头切换按钮
@property (weak, nonatomic) IBOutlet UIButton *switchButton;

//摄像头画面显示界面
@property (weak, nonatomic) IBOutlet UIView *scanPreviewView;
//操作界面
@property (weak, nonatomic) IBOutlet UIView *operatorView;
//提示进度
@property (weak, nonatomic) IBOutlet UIView *middleProgressView;
//提示进度的约束，原来约束也是可以用xib和类属性绑定的呀
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleProgressViewWidthConstraint;
//拍摄的按钮
@property (weak, nonatomic) IBOutlet UIButton *captureBtn;
//拍摄操作提示文本
@property (weak, nonatomic) IBOutlet UILabel *recordOperatorTip;
//双击放大提示文本
@property (weak, nonatomic) IBOutlet UILabel *zoomTip;

#pragma mark -
#pragma mark public method

+ (YYIMMicroVideoRecordView *)initMicroVideoRecordView;

/**
 *  当view完全显示后的ui调整
 */
- (void)prepareToShow;

/**
 *  当view完全显示后的ui调整
 */
- (void)prepareToHide;


@end

@protocol YYIMMicroVideoRecordViewDelegate <NSObject>

@required

- (void)didMicroVideoRecordViewNeedClose;

- (void)didMicroVideoRecordViewNeedShowMessage:(NSString *)message;

- (void)didMicroVideoRecordViewWillSaveFile;

- (void)didMicroVideoRecordViewfinishSaveFile:(NSString *)filePath thumbPath:(NSString *)thumbPath;

- (void)didMicroVideoRecordViewSaveFileFailed;

@end
