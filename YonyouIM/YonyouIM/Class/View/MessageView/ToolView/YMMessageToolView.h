//
//  YMMessageToolView.h
//  YonyouIM
//
//  Created by litfb on 15/5/29.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const kYMMessageToolViewDefaultHeight;

@protocol YMMessageToolViewDelegate;

@interface YMMessageToolView : UIView<UITextViewDelegate>

// delegate
@property (nonatomic, weak) id<YMMessageToolViewDelegate> delegate;

// 文本输入框
@property (nonatomic, retain) UITextView *messageInputView;

// 文本语音切换按钮
@property (nonatomic, retain, readonly) UIButton *leftButton;

// 表情按钮
@property (nonatomic, retain, readonly) UIButton *emojiButton;

// 扩展面板按钮
@property (nonatomic, retain, readonly) UIButton *extendButton;

// 语音按钮
@property (nonatomic, retain, readonly) UIButton *audioButton;

- (void)shrinkBottomViews;

- (NSString *)getMessageInputText;

- (void)inputAtText:(NSString *)text withUserId:(NSString *)userId;

- (void)inputText:(NSString *)text;

- (NSArray *)atUserArray;

- (void)clearAtUser;

@end

@protocol YMMessageToolViewDelegate <NSObject>

@optional

/**
 * 输入框将要开始编辑
 */
- (void)messageInputViewWillBeginEditing:(UITextView *)messageInputView;

/**
 * 输入框开始编辑
 */
- (void)messageInputViewDidBeginEditing:(UITextView *)messageInputView;

/**
 * 输入框输入
 */
- (void)messageInputViewDidChange:(UITextView *)messageInputView;

/**
 * 输入框结束编辑
 */
- (BOOL)messageInputDidEndEditing:(UITextView *)messageInputView;

/**
 * 点击语音按钮
 */
- (void)didSwitchToAudioState:(BOOL)isAudioState;

/**
 * 点击表情按钮
 */
- (void)didSwitchToEmojiState:(BOOL)isEmojiState;

/**
 * 点击扩展按钮
 */
- (void)didSwitchToExtendState:(BOOL)isExtedState;

/**
 * 工具栏高度变更
 */
- (void)didToolViewHeightChange:(BOOL)isEmojiState;

/**
 * 输入At
 */
- (void)didInputAt;

/**
 * 收起
 */
- (void)didShrink;

/**
 * 按下录音按钮开始录音
 */
- (void)didStartRecording;

/**
 * 手指向上滑动取消录音
 */
- (void)didCancelRecording;

/**
 * 松开手指完成录音
 */
- (void)didEndRecording;

/**
 * 将要取消录音（手指移出录音按钮）
 */
- (void)willCancelRecording;

/**
 * 将要继续录音（手指移回录音按钮）
 */
- (void)didResumeRecording;

@end
