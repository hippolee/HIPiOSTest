//
//  YYIMMicroVideoRecordView.m
//  YonyouIM
//
//  Created by yanghaoc on 16/6/3.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYIMMicroVideoRecordView.h"
#import "YYIMResourceUtility.h"
#import "YYIMColorHelper.h"
#import "SCRecorder.h"
#import "YYIMLogger.h"

//上移取消的颜色
#define YYIM_SHORT_VIDEO_VIEW_NORMAL_TIPCOLOR     UIColorFromRGB(0x0093FF)
//松开取消的颜色
#define YYIM_SHORT_VIDEO_VIEW_WARNING_TIPCOLOR    UIColorFromRGB(0xd80028)

//录制的最大时间
#define YYIM_SHORT_VIDEO_VIEW_VIDEO_MAX_TIME       6.0
//录制的最小时间
#define YYIM_SHORT_VIDEO_VIEW_VIDEO_VALID_MINTIME  0.8

//触点在按钮内时的提示
#define YYIM_SHORT_VIDEO_VIEW_OPERATE_RECORD_TIP  @"↑上滑取消"
//触点在按钮外时的提示
#define YYIM_SHORT_VIDEO_VIEW_OPERATE_CANCEL_TIP  @"松手取消"
//触点在按钮外时的提示
#define YYIM_SHORT_VIDEO_VIEW_OPERATE_INVALID_TIP  @"手指不要放开"

@interface YYIMMicroVideoRecordView() <SCRecorderDelegate, SCAssetExportSessionDelegate>

//响应各种焦距和缩放的事件的view
@property (strong, nonatomic) SCRecorderToolsView *focusView;

@property (strong, nonatomic) SCRecorder *recorder;

@property (assign, nonatomic) BOOL captureValidFlag;

@property (assign, nonatomic) BOOL isRecording;

@property (strong, nonatomic) NSTimer *longPressTimer;

@property (assign, nonatomic) BOOL isFinish;
//当前手指是否在按钮外
@property (assign, nonatomic) BOOL isTouchOutSide;

@property (strong, nonatomic) UITapGestureRecognizer *doubleTapToZoomGesture;

@end

@implementation YYIMMicroVideoRecordView

+ (YYIMMicroVideoRecordView *)initMicroVideoRecordView {
    NSArray* nibView = [[NSBundle mainBundle] loadNibNamed:@"YYIMMicroVideoRecordView" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.recordOperatorTip setHidden:YES];
    [self.middleProgressView setHidden:YES];
    
    CALayer *layer = [self.closeButton layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:21];
    
    layer = [self.switchButton layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:21];
    
    self.doubleTapToZoomGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeZoom)];
    self.doubleTapToZoomGesture.numberOfTapsRequired = 2;
    [self.functionView addGestureRecognizer:self.doubleTapToZoomGesture];
}

#pragma mark -
#pragma mark Action

/**
 *  关闭按钮点击
 *
 *  @param sender
 */
- (IBAction)closeAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didMicroVideoRecordViewNeedClose)]) {
        [self.delegate didMicroVideoRecordViewNeedClose];
    }
}

- (IBAction)switchCamera:(UIButton *)sender {
    [self.recorder switchCaptureDevices];
}

#pragma mark - Center Record Btn ActionEvent

/**
 *  当一次触摸从拍摄按钮内部拖动到外部时
 *
 *  @param captureBtn
 */
- (IBAction)captureStartDragExit:(UIButton *)captureBtn {
    self.isTouchOutSide = YES;
    [self setReleaseOperatorTipStyle];
}

/**
 *  当一次触摸从拍摄按钮之外拖动到内部时。
 *
 *  @param captureBtn
 */
- (IBAction)captureStartDrayEnter:(UIButton *)captureBtn {
    self.isTouchOutSide = NO;
    [self setNormalOperatorTipStyle];
}

/**
 *  拍摄按钮内部抬起事件
 *
 *  @param captureBtn
 */
- (IBAction)captureStartTouchUpInside:(UIButton *)captureBtn {
    if (self.captureValidFlag) {
        //阅览
        [self finishCapture];
    } else {
        //重新初始化session
        [self cancelCapture];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didMicroVideoRecordViewNeedShowMessage:)]) {
            [self.delegate didMicroVideoRecordViewNeedShowMessage:YYIM_SHORT_VIDEO_VIEW_OPERATE_INVALID_TIP];
        }
    }
}

/**
 *  当拍摄按钮外抬起
 *
 *  @param captureBtn
 */
- (IBAction)captureStartTouchUpOutside:(UIButton *)captureBtn {
    //结束拍摄并不保存文件
    [self cancelCapture];
}

/**
 *  当拍摄按钮被按下
 *
 *  @param captureBtn
 */
- (IBAction)captureStartTouchDownAction:(UIButton *)captureBtn {
    //captureValidFlag用来校验拍摄是否没有达到指定的最小时间，先设置成没有超过，当超过了会通过定时器设置成yes
    self.captureValidFlag = NO;
    self.isRecording = YES;
    self.isTouchOutSide = NO;
    
    [self hideZoomTip];
    [self canShowButtonView:NO];
    
    //重新初始化长按开始计时器
    if (self.longPressTimer) {
        [self.longPressTimer invalidate];
        self.longPressTimer = nil;
    }
    
    //小于0.8秒不认为用户要启用拍摄
    self.longPressTimer = [NSTimer scheduledTimerWithTimeInterval:YYIM_SHORT_VIDEO_VIEW_VIDEO_VALID_MINTIME target:self selector:@selector(captureSuccess) userInfo:nil repeats:NO];
    
    //开始录制
    [self.recorder record];
    //显示提示
    [self showOperationTipView];
}

#pragma mark - SCRecorderDelegate
/**
 *  录制进度的回调
 *
 *  @param recorder
 *  @param recordSession
 */
- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    //update progressBar
    [self refreshProgressViewLengthByTime:recordSession.duration];
}

/**
 *  录制完成的回调
 *
 *  @param recorder
 *  @param session
 */
- (void)recorder:(SCRecorder *__nonnull)recorder didCompleteSession:(SCRecordSession *__nonnull)session {
    //隐藏进度条
    [self hideOperationTipView];
    
    if (self.isTouchOutSide) {
        //如果手指在外面只是取消拍摄，不提示其他的信息
        [self cancelCapture];
    } else if (self.captureValidFlag) {
        [self finishCapture];
    } else {
        //如果不合法，重新初始化session,显示拍摄按钮文字
        [self cancelCapture];
        [self showInValidOperatorTipStyle];
    }
}

#pragma mark - SCAssetExportSessionDelegate
/**
 *
 *  根据assetExportSessionDidProgress回调提供的信息进度更新中间转圈的保存文件进度
 *  @param assetExportSession
 */
- (void)assetExportSessionDidProgress:(SCAssetExportSession *)assetExportSession {
    dispatch_async(dispatch_get_main_queue(), ^{
        //        float progress = assetExportSession.progress;
    });
}


#pragma mark -
#pragma mark public method

/**
 *  当view完全显示后的ui调整
 */
- (void)prepareToShow {
    //进度条隐藏
    [self clearProgressView];
    //当view完全显示后将空白的view设置成蒙版效果
    [self.emptyButton setBackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
    
    //显示双击放大并2秒后自动消失
    [self.zoomTip setHidden:NO];
    [self performSelector:@selector(hideZoomTip) withObject:nil afterDelay:2.0f];
    
    //操作提示隐藏
    [self.recordOperatorTip setTextColor:YYIM_SHORT_VIDEO_VIEW_NORMAL_TIPCOLOR];
    [self.recordOperatorTip setHidden:YES];
    
    self.captureValidFlag = NO;
    
    [self initRecorder];
    
    [self.recorder startRunning];
}

/**
 *  当view完全显示后的ui调整
 */
- (void)prepareToHide {
    //当view完全隐藏前将空白的view的蒙版效果清除
    [self.emptyButton setBackgroundColor:[UIColor clearColor]];
    
    [self.recorder stopRunning];
    self.focusView = nil;
    self.scanPreviewView = nil;
    
}


#pragma mark -
#pragma mark private method

/**
 *  初始化recorder
 */
- (void)initRecorder {
    //初始化SCRecorder
    self.recorder = [SCRecorder recorder];
    self.recorder.captureSessionPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
    self.recorder.maxRecordDuration = CMTimeMake(30 * YYIM_SHORT_VIDEO_VIEW_VIDEO_MAX_TIME, 30);
    self.recorder.delegate = self;
    self.recorder.autoSetVideoOrientation = YES;
    self.recorder.previewView = self.scanPreviewView;
    
    //SCRecorderToolsView用来接收所有事件并处理的view
    self.focusView = [[SCRecorderToolsView alloc] initWithFrame:self.scanPreviewView.bounds];
    self.focusView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.focusView.recorder = _recorder;
    [self.scanPreviewView addSubview:self.focusView];
    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"icon_microvideo_scan_focus"];
    
    //禁用懒初始化
    _recorder.initializeSessionLazily = NO;
    
    NSError *error;
    if (![_recorder prepare:&error]) {
        YYIMLogError(@"Prepare error: %@", error.localizedDescription);
    }
    
    [self prepareSession];
}

/**
 *  初始化一个session
 */
- (void)prepareSession {
    if (self.recorder.session == nil) {
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeMPEG4;
        
        self.recorder.session = session;
    }
}

- (void)changeZoom {
    [self.focusView ChangeZoom];
}

/**
 *  隐藏缩放提示
 */
- (void)hideZoomTip {
    if (!self.zoomTip.isHidden) {
        [self.zoomTip setHidden:YES];
    }
}

/**
 *  初始化进度条的约束
 */
- (void)clearProgressView {
    self.middleProgressViewWidthConstraint.constant = 0;
}

/**
 *  初始化进度条的约束
 */
- (void)initialProgressView {
    self.middleProgressViewWidthConstraint.constant = 0;
}

/**
 *  根据进度更新进度条的约束
 *
 *  @param duration
 */
- (void)refreshProgressViewLengthByTime:(CMTime)duration {
    CGFloat durationTime = CMTimeGetSeconds(duration);
    CGFloat progressWidthConstant = (1 - (YYIM_SHORT_VIDEO_VIEW_VIDEO_MAX_TIME - durationTime) / YYIM_SHORT_VIDEO_VIEW_VIDEO_MAX_TIME) * self.frame.size.width;
    self.middleProgressViewWidthConstraint.constant = progressWidthConstant <= self.frame.size.width ? progressWidthConstant : self.frame.size.width;
}

/**
 *  显示拍摄提示
 */
- (void)showOperationTipView {
    [self setNormalOperatorTipStyle];
    [self initialProgressView];
    [UIView animateWithDuration:0.2 animations:^{
        [self.recordOperatorTip setHidden:NO];
        [self.middleProgressView setHidden:NO];
    } completion:^(BOOL finished) {
        
    }];
}

//隐藏拍摄提示
- (void)hideOperationTipView {
    [UIView animateWithDuration:0.2 animations:^{
        [self.recordOperatorTip setHidden:YES];
        [self.middleProgressView setHidden:YES];
        [self clearProgressView];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)canShowButtonView:(BOOL)show {
    if (show) {
        [self.closeButton setHidden:NO];
        [self.switchButton setHidden:NO];
    } else {
        [self.closeButton setHidden:YES];
        [self.switchButton setHidden:YES];
    }
}

/**
 *  时间太短的ui
 */
- (void)showInValidOperatorTipStyle {
    self.recordOperatorTip.textColor = [UIColor whiteColor];
    self.recordOperatorTip.backgroundColor = YYIM_SHORT_VIDEO_VIEW_WARNING_TIPCOLOR;
    self.recordOperatorTip.text = YYIM_SHORT_VIDEO_VIEW_OPERATE_INVALID_TIP;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.recordOperatorTip setHidden:NO];
    } completion:^(BOOL finished) {
        
    }];
}

/**
 *  隐藏时间太短的ui
 */
- (void)hideInValidOperatorTipStyle {
    if (!self.isRecording) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.recordOperatorTip setHidden:NO];
        } completion:^(BOOL finished) {
            
        }];
    }
}

/**
 *  长按拍摄的ui
 */
- (void)setNormalOperatorTipStyle {
    self.recordOperatorTip.textColor = [UIColor whiteColor];
    self.recordOperatorTip.text = YYIM_SHORT_VIDEO_VIEW_OPERATE_RECORD_TIP;
    self.recordOperatorTip.backgroundColor = [UIColor clearColor];
    self.middleProgressView.backgroundColor = YYIM_SHORT_VIDEO_VIEW_NORMAL_TIPCOLOR;
}

/**
 *  上滑松手的ui
 */
- (void)setReleaseOperatorTipStyle {
    self.recordOperatorTip.textColor = [UIColor whiteColor];
    self.recordOperatorTip.backgroundColor = YYIM_SHORT_VIDEO_VIEW_WARNING_TIPCOLOR;
    self.recordOperatorTip.text = YYIM_SHORT_VIDEO_VIEW_OPERATE_CANCEL_TIP;
    self.middleProgressView.backgroundColor = YYIM_SHORT_VIDEO_VIEW_WARNING_TIPCOLOR;
}

/**
 *  设置当前的录制有效，超过了最小时间
 */
- (void)captureSuccess {
    self.captureValidFlag = YES;
}

/**
 *  完成了录制
 */
- (void)finishCapture {
    self.isRecording = NO;
    [self hideOperationTipView];
    
    [_recorder pause:^{
        //录制结束，保存文件。
        [self saveCapture];
    }];
}

/**
 *  取消录制，需要重新初始化session
 */
- (void)cancelCapture {
    self.isRecording = NO;
    [self canShowButtonView:YES];
    
    [self hideOperationTipView];
    
    [_recorder pause:^{
        //如果强制取消，重新初始化一个session
        if (self.recorder.session != nil) {
            [self.recorder.session cancelSession:nil];
            self.recorder.session = nil;
        }
        
        [self prepareSession];
    }];
}

/**
 *  保存视频
 */
- (void)saveCapture {
    if (self.isFinish) {
        return;
    }
    
    self.isFinish = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didMicroVideoRecordViewWillSaveFile)]) {
        [self.delegate didMicroVideoRecordViewWillSaveFile];
    }
    
    // 资源相对路径
    NSString *resRelaPath = [YYIMResourceUtility resourceRelaPathWithResType:YYIM_RESOURCE_TYPE_MICROVIDEO ext:@"mp4"];
    NSString *resThumbRelaPath = [YYIMResourceUtility resourceRelaPathWithResType:YYIM_RESOURCE_TYPE_MICROVIDEO ext:@"jpg"];
    // full path
    NSString *resFullPath = [YYIMResourceUtility fullPathWithResourceRelaPath:resRelaPath];
    NSString *resThumbFullPath = [YYIMResourceUtility fullPathWithResourceRelaPath:resThumbRelaPath];
    
    NSURL *fileUrl = [NSURL fileURLWithPath:resFullPath];
    
    SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:_recorder.session.assetRepresentingSegments];
    exportSession.videoConfiguration.preset = SCPresetCustomQuality;
    exportSession.audioConfiguration.preset = SCPresetCustomQuality;
    exportSession.videoConfiguration.maxFrameRate = 30;
    exportSession.outputUrl = fileUrl;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.delegate = self;
    
    CFTimeInterval time = CACurrentMediaTime();
    [exportSession exportAsynchronouslyWithCompletionHandler:^(BOOL result, NSError * _Nonnull exportError) {
        YYIMLogDebug(@"Completed compression in %fs", CACurrentMediaTime() - time);
        
        if (result) {
            if (self.recorder.session != nil) {
                [self.recorder.session cancelSession:nil];
                self.recorder.session = nil;
            }
            
            //生成视频的缩略图
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileUrl options:nil];
            
            if (!asset) {
                YYIMLogError(@"生成小视频失败,asset不存在");
                [self saveRecordFailed];
                return;
            }
            
            AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            generate.appliesPreferredTrackTransform = YES;
            generate.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
            NSError *err = NULL;
            CMTime time = CMTimeMake(1, 30);
            CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
            
            if (err) {
                YYIMLogError(@"生成小视频微略图失败:%@",err.localizedDescription);
                [self saveRecordFailed];
                return;
            }
            
            UIImage *thumbNailImage = [[UIImage alloc] initWithCGImage:imgRef];
            
            // image data
            NSData *imageData = UIImageJPEGRepresentation(thumbNailImage, 0.75);
            // save
            [imageData writeToFile:resThumbFullPath atomically:NO];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(didMicroVideoRecordViewfinishSaveFile:thumbPath:)]) {
                [self.delegate didMicroVideoRecordViewfinishSaveFile:resRelaPath thumbPath:resThumbRelaPath];
            }
        } else {
            if (self.recorder.session != nil) {
                [self.recorder.session cancelSession:nil];
                self.recorder.session = nil;
            }
            
            YYIMLogError(@"生成小视频失败:%@",exportError.localizedDescription);
            [self saveRecordFailed];
        }
    }];
}

- (void)saveRecordFailed {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didMicroVideoRecordViewSaveFileFailed)]) {
        [self.delegate didMicroVideoRecordViewSaveFileFailed];
    }
    
    [self closeAction:nil];
}


@end
