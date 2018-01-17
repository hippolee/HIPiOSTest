//
//  YMMessageToolView.m
//  YonyouIM
//
//  Created by litfb on 15/5/29.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YMMessageToolView.h"
#import "UIColor+YYIMTheme.h"
#import "UIButton+YYIMCatagory.h"
#import "YYIMEmojiHelper.h"
#import "YYIMUIDefs.h"

CGFloat const kYMMessageToolViewDefaultHeight = 50.0f;
CGFloat const kYMMessageToolViewButtonSize = 34.0f;
CGFloat const kYMMessageToolViewPadding = 8.0f;

@interface YMMessageToolView ()<UITextViewDelegate>

// 文本语音切换按钮
@property (nonatomic, retain, readwrite) UIButton *switchButton;

// 表情按钮
@property (nonatomic, retain, readwrite) UIButton *emojiButton;

// 扩展面板按钮
@property (nonatomic, retain, readwrite) UIButton *extendButton;

// 语音按钮
@property (nonatomic, retain, readwrite) UIButton *audioButton;

@property (nonatomic, assign) CGFloat previousTextViewContentHeight;
@property (nonatomic, assign) CGFloat defaultTextViewContentHeight;

@property (nonatomic, assign) BOOL maybeRecording;

// 待@的userIdArray
@property NSMutableDictionary *atUserDic;

@end

@implementation YMMessageToolView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.atUserDic = [NSMutableDictionary dictionary];
    // 配置自适应
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    self.backgroundColor = [UIColor f9GrayColor];
    
    UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 1)];
    [sepView setBackgroundColor:[UIColor edGrayColor]];
    [sepView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
    [self addSubview:sepView];
    
    // 语音切换按钮
    UIButton *switchButton = [[UIButton alloc] initWithFrame:CGRectMake(kYMMessageToolViewPadding, kYMMessageToolViewPadding, kYMMessageToolViewButtonSize, kYMMessageToolViewButtonSize)];
    [switchButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [switchButton setImage:[UIImage imageNamed:@"icon_audio"] forState:UIControlStateNormal];
    [switchButton setImage:[UIImage imageNamed:@"icon_audio_hl"] forState:UIControlStateSelected];
    [switchButton addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:switchButton];
    self.switchButton = switchButton;
    
    // 扩展面板按钮
    UIButton *extendButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - kYMMessageToolViewPadding - kYMMessageToolViewButtonSize, kYMMessageToolViewPadding, kYMMessageToolViewButtonSize, kYMMessageToolViewButtonSize)];
    [extendButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [extendButton setImage:[UIImage imageNamed:@"icon_extend"] forState:UIControlStateNormal];
    [extendButton setImage:[UIImage imageNamed:@"icon_extend_hl"] forState:UIControlStateSelected];
    [extendButton addTarget:self action:@selector(extendAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:extendButton];
    self.extendButton = extendButton;
    
    // 表情面板按钮
    UIButton *emojiButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 2 * kYMMessageToolViewPadding - 2 * kYMMessageToolViewButtonSize, kYMMessageToolViewPadding, kYMMessageToolViewButtonSize, kYMMessageToolViewButtonSize)];
    [emojiButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [emojiButton setImage:[UIImage imageNamed:@"icon_emoji"] forState:UIControlStateNormal];
    [emojiButton setImage:[UIImage imageNamed:@"icon_keyboard"] forState:UIControlStateSelected];
    [emojiButton addTarget:self action:@selector(emojiAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:emojiButton];
    self.emojiButton = emojiButton;
    
    // 录音按钮
    UIButton *audioButton = [[UIButton alloc] initWithFrame:CGRectMake(2 * kYMMessageToolViewPadding + kYMMessageToolViewButtonSize, kYMMessageToolViewPadding, CGRectGetWidth(self.frame) - 3 * kYMMessageToolViewButtonSize - 5 * kYMMessageToolViewPadding, kYMMessageToolViewButtonSize)];
    [audioButton setTitleColor:[UIColor _0bGrayColor] forState:UIControlStateNormal];
    [[audioButton titleLabel] setFont:[UIFont systemFontOfSize:15.0f]];
    [audioButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    [audioButton setTitle:@"松开 结束" forState:UIControlStateHighlighted];
    [audioButton setBackgroundColor:[UIColor edGrayColor] forState:UIControlStateHighlighted];
    [audioButton addTarget:self action:@selector(audioTouchDown) forControlEvents:UIControlEventTouchDown];
    [audioButton addTarget:self action:@selector(audioTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [audioButton addTarget:self action:@selector(audioTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [audioButton addTarget:self action:@selector(audioTouchUpDragExit) forControlEvents:UIControlEventTouchDragExit];
    [audioButton addTarget:self action:@selector(audioTouchUpDragEnter) forControlEvents:UIControlEventTouchDragEnter];
    [self addSubview:audioButton];
    self.audioButton = audioButton;
    
    // 录音按钮外观
    CALayer *audiolayer = [self.audioButton layer];
    [audiolayer setMasksToBounds:YES];
    [audiolayer setCornerRadius:5.0];
    [audiolayer setBorderWidth:1];
    [audiolayer setBorderColor:[[UIColor edGrayColor] CGColor]];
    
    // 初始化输入框
    UITextView *messageInputView = [[UITextView alloc] initWithFrame:CGRectMake(2 * kYMMessageToolViewPadding + kYMMessageToolViewButtonSize, kYMMessageToolViewPadding, CGRectGetWidth(self.frame) - 3 * kYMMessageToolViewButtonSize - 5 * kYMMessageToolViewPadding, kYMMessageToolViewButtonSize)];
    [messageInputView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [messageInputView setReturnKeyType:UIReturnKeySend];
    [messageInputView setEnablesReturnKeyAutomatically:YES];
    [messageInputView setDelegate:self];
    [messageInputView setFont:[UIFont systemFontOfSize:18.0f]];
    [self addSubview:messageInputView];
    self.messageInputView = messageInputView;
    
    CALayer *inputLayer = [messageInputView layer];
    [inputLayer setMasksToBounds:YES];
    [inputLayer setCornerRadius:5.0];
    [inputLayer setBorderWidth:1];
    [inputLayer setBorderColor:[[UIColor edGrayColor] CGColor]];
}

#pragma mark actions

// 录音切换按钮点击
- (void)leftAction:(UIButton *)sender {
    self.emojiButton.selected = NO;
    self.extendButton.selected = NO;
    sender.selected = !sender.selected;
    
    if (sender.selected){
        [self.messageInputView resignFirstResponder];
    } else {
        [self.messageInputView becomeFirstResponder];
    }
    
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.audioButton.hidden = !sender.selected;
        self.messageInputView.hidden = sender.selected;
        
        if (sender.selected) {
            // 还原输入框大小
            CGRect inputViewFrame = self.frame;
            self.frame = CGRectMake(0.0f, inputViewFrame.origin.y, CGRectGetWidth(inputViewFrame), kYMMessageToolViewDefaultHeight);
        } else {
            if (self.messageInputView.text.length > 0) {
                [self changeMessageInputViewHeight];
            }
        }
    } completion:^(BOOL finished) {
        if (sender.selected) {
            self.previousTextViewContentHeight = self.defaultTextViewContentHeight;
        }
    }];
    
    if ([self.delegate respondsToSelector:@selector(didSwitchToAudioState:)]) {
        [self.delegate didSwitchToAudioState:sender.selected];
    }
}

// 表情按钮点击
- (void)emojiAction:(UIButton *)sender {
    self.leftButton.selected = NO;
    self.extendButton.selected = NO;
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self.messageInputView resignFirstResponder];
    } else {
        [self.messageInputView becomeFirstResponder];
    }
    
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.audioButton.hidden = YES;
        self.messageInputView.hidden = NO;
    } completion:^(BOOL finished) {
        
    }];
    
    if ([self.delegate respondsToSelector:@selector(didSwitchToEmojiState:)]) {
        [self.delegate didSwitchToEmojiState:sender.selected];
    }
}

// 扩展按钮点击
- (void)extendAction:(UIButton *)sender {
    self.leftButton.selected = YES;
    self.emojiButton.selected = NO;
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self.messageInputView resignFirstResponder];
    } else {
        [self.messageInputView becomeFirstResponder];
    }
    
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.audioButton.hidden = YES;
        self.messageInputView.hidden = NO;
    } completion:^(BOOL finished) {
        
    }];
    
    if ([self.delegate respondsToSelector:@selector(didSwitchToExtendState:)]) {
        [self.delegate didSwitchToExtendState:sender.selected];
    }
}

- (void)audioTouchDown {
    self.maybeRecording = YES;
    if ([self.delegate respondsToSelector:@selector(didStartRecording)]) {
        [self.delegate didStartRecording];
    }
}

- (void)audioTouchUpOutside {
    if ([self.delegate respondsToSelector:@selector(didCancelRecording)]) {
        [self.delegate didCancelRecording];
    }
    self.maybeRecording = NO;
}

- (void)audioTouchUpInside {
    if ([self.delegate respondsToSelector:@selector(didEndRecording)]) {
        [self.delegate didEndRecording];
    }
    self.maybeRecording = NO;
}

- (void)audioTouchUpDragExit {
    if (!self.maybeRecording) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(willCancelRecording)]) {
        [self.delegate willCancelRecording];
    }
}

- (void)audioTouchUpDragEnter {
    if (!self.maybeRecording) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(didResumeRecording)]) {
        [self.delegate didResumeRecording];
    }
}

#pragma mark UITextViewDelegate delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(messageInputViewDidBeginEditing:)]) {
        [self.delegate messageInputViewDidBeginEditing:self.messageInputView];
    }
    self.emojiButton.selected = NO;
    self.extendButton.selected = NO;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(messageInputViewDidBeginEditing:)]) {
        [self.delegate messageInputViewDidBeginEditing:self.messageInputView];
    }
    if (!self.previousTextViewContentHeight) {
        self.previousTextViewContentHeight = self.messageInputView.contentSize.height;
    }
    if (!self.defaultTextViewContentHeight) {
        self.defaultTextViewContentHeight = self.messageInputView.contentSize.height;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(messageInputViewDidChange:)]) {
        [self.delegate messageInputViewDidChange:self.messageInputView];
    }
    [self changeMessageInputViewHeight];
}

- (void)changeMessageInputViewHeight {
    CGFloat maxHeight = [self.messageInputView.font lineHeight] * 3;
    CGSize size;
    if (YYIM_iOS9) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        
        NSDictionary *attributes = @{NSFontAttributeName:self.messageInputView.font, NSParagraphStyleAttributeName:paragraphStyle};
        
        CGRect rect = [self.messageInputView.text boundingRectWithSize:CGSizeMake(self.messageInputView.contentSize.width, maxHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        size = rect.size;
    } else {
        maxHeight += 12;
        size = [self.messageInputView sizeThatFits:CGSizeMake(self.messageInputView.contentSize.width, maxHeight)];
    }
    
    CGFloat textViewContentHeight = MAX(size.height, self.defaultTextViewContentHeight);
    // End of textView.contentSize replacement code
    BOOL isShrinking = textViewContentHeight < self.previousTextViewContentHeight;
    
    CGFloat changeInHeight = textViewContentHeight - self.previousTextViewContentHeight;
    
    if (!isShrinking && self.previousTextViewContentHeight == maxHeight) {
        changeInHeight = 0;
    } else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
    }
    
    if (changeInHeight != 0.0f) {
        [UIView animateWithDuration:0.25f animations:^{
            // from iOS 7, the content size will be accurate only if the scrolling is enabled.
            self.messageInputView.scrollEnabled = YES;
            
            CGRect inputViewFrame = self.frame;
            self.frame = CGRectMake(0.0f, inputViewFrame.origin.y - changeInHeight, CGRectGetWidth(inputViewFrame), CGRectGetHeight(inputViewFrame) + changeInHeight);
        } completion:^(BOOL finished) {
            
        }];
        
        self.previousTextViewContentHeight = MIN(textViewContentHeight, maxHeight);
        if ([self.delegate respondsToSelector:@selector(didToolViewHeightChange:)]) {
            [self.delegate didToolViewHeightChange:[self.emojiButton isSelected]];
        }
    }
    [self.messageInputView setContentOffset:CGPointMake(0, self.messageInputView.contentSize.height - CGRectGetHeight(self.messageInputView.frame))];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        BOOL sendResult = NO;
        if ([self.delegate respondsToSelector:@selector(messageInputDidEndEditing:)]) {
            sendResult = [self.delegate messageInputDidEndEditing:self.messageInputView];
        }
        if (sendResult) {
            [UIView animateWithDuration:0.25f animations:^{
                // 还原输入框大小
                CGRect inputViewFrame = self.frame;
                self.frame = CGRectMake(0.0f, inputViewFrame.origin.y + CGRectGetHeight(inputViewFrame) - kYMMessageToolViewDefaultHeight, CGRectGetWidth(inputViewFrame), kYMMessageToolViewDefaultHeight);
                if ([self.delegate respondsToSelector:@selector(didToolViewHeightChange:)]) {
                    [self.delegate didToolViewHeightChange:[self.emojiButton isSelected]];
                }
            } completion:^(BOOL finished) {
                self.previousTextViewContentHeight = self.defaultTextViewContentHeight;
            }];
        }
        return NO;
    } else if (range.length == 1 && [text isEqualToString:@""]) {
        UITextRange *range = [self emojiRange];
        if (range) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self replaceTextInRange:range withText:@""];
                return;
            });
            return NO;
        }
        
        range = [self atUserRange];
        if (range) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self replaceTextInRange:range withText:@""];
                return;
            });
            return NO;
        }
    } else if (range.length == 0 && [text isEqualToString:@"@"]) {
        BOOL isValidAt = NO;
        if (range.location == 0) {
            isValidAt = YES;
        } else {
            NSString *text = textView.text;
            NSString *lastStr = [text substringFromIndex:range.location - 1];
            
            NSString *regex = @"[A-Za-z0-9]{1}";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            isValidAt = ![predicate evaluateWithObject:lastStr];
        }
        
        if (isValidAt) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(didInputAt)]) {
                    [self.delegate didInputAt];
                }
            });
        }
    }
    //    else {
    //        [self judgeAtUserWithRange:range text:text];
    //    }
    if (!self.previousTextViewContentHeight) {
        self.previousTextViewContentHeight = self.messageInputView.contentSize.height;
    }
    if (!self.defaultTextViewContentHeight) {
        self.defaultTextViewContentHeight = self.messageInputView.contentSize.height;
    }
    return YES;
}

#pragma mark interface

- (NSString *)getMessageInputText {
    return self.messageInputView.text;
}

- (void)inputAtText:(NSString *)text withUserId:(NSString *)userId {
    [self inputText:text];
    [self.atUserDic setObject:[NSString stringWithFormat:@"@%@", text] forKey:userId];
}

- (void)inputText:(NSString *)text {
    [self replaceTextInRange:self.messageInputView.selectedTextRange withText:text];
}

- (NSArray *)atUserArray {
    return [NSArray arrayWithArray:[self.atUserDic allKeys]];
}

- (void)clearAtUser {
    return [self.atUserDic removeAllObjects];
}

- (void)replaceTextInRange:(UITextRange *)range withText:(NSString *)text {
    NSInteger startOffset = [self.messageInputView offsetFromPosition:self.messageInputView.beginningOfDocument toPosition:range.start];
    NSInteger endOffset = [self.messageInputView offsetFromPosition:self.messageInputView.beginningOfDocument toPosition:range.end];
    NSRange replacementRange = NSMakeRange(startOffset, endOffset - startOffset);
    if (range && [self textView:self.messageInputView shouldChangeTextInRange:replacementRange replacementText:text]) {
        [self.messageInputView replaceRange:range withText:text];
    }
}

- (UITextRange *)emojiRange {
    //Find the last thing we may input and delete it. And RETURN
    NSString *text = [self.messageInputView textInRange:[self.messageInputView textRangeFromPosition:self.messageInputView.beginningOfDocument toPosition:self.messageInputView.selectedTextRange.start]];
    NSArray *emojiArray = [[YYIMEmojiHelper sharedInstance] arrayOfEmoji];
    
    for (YYIMEmojiItem *item in emojiArray) {
        if ([text hasSuffix:item.emojiText]) {
            UITextRange *rangeToDelete = [self.messageInputView textRangeFromPosition:[self.messageInputView positionFromPosition:self.messageInputView.selectedTextRange.start offset:-item.emojiText.length] toPosition:self.messageInputView.selectedTextRange.start];
            return rangeToDelete;
        }
    }
    return nil;
}

- (UITextRange *)atUserRange {
    //Find the last thing we may input and delete it. And RETURN
    NSString *text = [self.messageInputView textInRange:[self.messageInputView textRangeFromPosition:self.messageInputView.beginningOfDocument toPosition:self.messageInputView.selectedTextRange.start]];
    for (NSString *userId in self.atUserDic) {
        NSString *atUserStr = [self.atUserDic objectForKey:userId];
        if ([text hasSuffix:atUserStr]) {
            UITextRange *rangeToDelete = [self.messageInputView textRangeFromPosition:[self.messageInputView positionFromPosition:self.messageInputView.selectedTextRange.start offset:-atUserStr.length] toPosition:self.messageInputView.selectedTextRange.start];
            
            [self.atUserDic removeObjectForKey:userId];
            return rangeToDelete;
        }
    }
    return nil;
}

- (void)judgeAtUserWithRange:(NSRange)range text:(NSString *)text {
    NSLog(@"range----------------:%@", NSStringFromRange(range));
    NSLog(@"text-----------------:%@", text);
    @synchronized(self)  {
        //        NSMutableArray *deleteArray = [NSMutableArray array];
        NSMutableDictionary *modifyDic = [NSMutableDictionary dictionaryWithDictionary:self.atUserDic];
        for (NSString *userId in self.atUserDic) {
            NSString *rangeString = [self.atUserDic objectForKey:userId];
            NSRange userRange = NSRangeFromString(rangeString);
            NSLog(@"range:%@", NSStringFromRange(range));
            NSLog(@"userRange:%@", NSStringFromRange(userRange));
            NSLog(@"text:%@", text);
            // range 在userRange后面
            if (range.location >= userRange.location + userRange.length) {
                NSLog(@"A");
            } else if (range.location + range.length <= userRange.location) {// range 在userRange前面
                NSLog(@"B");
                __block NSUInteger composedCharacterLength = 0;
                [text enumerateSubstringsInRange:NSMakeRange(0, text.length)
                                         options:NSStringEnumerationByComposedCharacterSequences
                                      usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
                                          composedCharacterLength++;
                                      }];
                NSInteger offset = composedCharacterLength - range.length;
                NSLog(@"offset:%ld", (long)offset);
                userRange.location = userRange.location + offset;
                [modifyDic setObject:NSStringFromRange(userRange) forKey:userId];
                NSLog(@"new range:%@", NSStringFromRange(userRange));
            } else {// 有交集
                NSLog(@"C");
                //                [deleteArray addObject:userId];
                [modifyDic removeObjectForKey:userId];
                NSLog(@"delete userId:%@", userId);
            }
        }
        //        if (deleteArray.count > 0) {
        //            [self.atUserDic removeObjectsForKeys:deleteArray];
        //        }
        //        if (modifyDic.count > 0) {
        NSLog(@"dic count:%lu", (unsigned long)self.atUserDic.count);
        [self.atUserDic setDictionary:modifyDic];
        NSLog(@"dic count:%lu", (unsigned long)self.atUserDic.count);
        //        }
    }
}

- (void)shrinkBottomViews {
    BOOL flag = NO;
    
    if (self.emojiButton.selected) {
        self.emojiButton.selected = NO;
        flag = YES;
    }
    
    if (self.extendButton.selected) {
        self.extendButton.selected = NO;
        flag = YES;
    }
    
    if ([self.messageInputView isFirstResponder]) {
        [self.messageInputView resignFirstResponder];
        flag = YES;
    }
    
    if (flag && [self.delegate respondsToSelector:@selector(didShrink)]) {
        [self.delegate didShrink];
    }
}

- (void)dealloc {
    _delegate = nil;
    _messageInputView = nil;
    _audioButton = nil;
    _leftButton = nil;
    _emojiButton = nil;
    _extendButton = nil;
}

@end
