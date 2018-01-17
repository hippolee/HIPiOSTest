//
//  YYIMEmojiKeyboard.m
//  YonyouIM
//
//  Created by litfb on 15/1/15.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMEmojiKeyboard.h"
#import "YYIMEmojiKeyboardKeyGroupView.h"
#import "YYIMEmojiHelper.h"
#import "UIColor+YYIMTheme.h"
#import "YYIMEmojiDefs.h"

@interface YYIMEmojiKeyboard ()

@property (nonatomic, weak, readwrite) UITextView *textInput;

//@property (nonatomic, weak) YYIMEmojiKeyboardToolsView *toolsView;

@property (nonatomic, strong) NSArray *keyItemGroupViews;

@property (nonatomic, readonly) CGRect keyItemGroupViewFrame;

@end

@implementation YYIMEmojiKeyboard

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

- (void)initView {
    if (CGRectIsEmpty(self.bounds)) {
        self.bounds = (CGRect){CGPointZero,CGSizeMake(CGRectGetWidth([[UIScreen mainScreen] bounds]), kYYIMEmojiKeyboardDefaultHeight)};
    }
    
    // 分割线
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 1)];
    [view setBackgroundColor:[UIColor edGrayColor]];
    [self addSubview:view];
}

// 退格
- (void)backspace {
    if (self.textInput.selectedTextRange.empty) {
        //Find the last thing we may input and delete it. And RETURN
        NSString *text = [self.textInput textInRange:[self.textInput textRangeFromPosition:self.textInput.beginningOfDocument toPosition:self.textInput.selectedTextRange.start]];
        for (YYIMEmojiKeyboardKeyGroup *group in self.keyItemGroups) {
            for (YYIMEmojiItem *item in group.keyItems) {
                if ([text hasSuffix:item.emojiText]) {
                    __block NSUInteger composedCharacterLength = 0;
                    [item.emojiText enumerateSubstringsInRange:NSMakeRange(0, item.emojiText.length)
                                                       options:NSStringEnumerationByComposedCharacterSequences
                                                    usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
                                                        composedCharacterLength++;
                                                    }];
                    UITextRange *rangeToDelete = [self.textInput textRangeFromPosition:[self.textInput positionFromPosition:self.textInput.selectedTextRange.start offset:-composedCharacterLength] toPosition:self.textInput.selectedTextRange.start];
                    if (rangeToDelete) {
                        [self replaceTextInRange:rangeToDelete withText:@""];
                        return;
                    }
                }
            }
        }
        
        //If we cannot find the text. Do a delete backward.
        UITextRange *rangeToDelete = [self.textInput textRangeFromPosition:self.textInput.selectedTextRange.start toPosition:[self.textInput positionFromPosition:self.textInput.selectedTextRange.start offset:-1]];
        [self replaceTextInRange:rangeToDelete withText:@""];
    } else {
        [self replaceTextInRange:self.textInput.selectedTextRange withText:@""];
    }
}

// 切换表情组
- (void)switchToKeyItemGroup:(YYIMEmojiKeyboardKeyGroup *)keyItemGroup {
    [self.keyItemGroupViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self.keyItemGroupViews enumerateObjectsUsingBlock:^(YYIMEmojiKeyboardKeyGroupView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.keyItemGroup isEqual:keyItemGroup]) {
            obj.frame = self.keyItemGroupViewFrame;
            obj.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self addSubview:obj];
            *stop = YES;
        }
    }];
}

+ (instancetype)keyboard {
    YYIMEmojiKeyboard *keyboard = [[YYIMEmojiKeyboard alloc] init];
    return keyboard;
}

- (void)attachToTextInput:(UITextView *)textInput {
    self.textInput = textInput;
}

#pragma mark - Text Input

- (BOOL)textInputShouldReplaceTextInRange:(UITextRange *)range replacementText:(NSString *)replacementText {
    
    BOOL shouldChange = YES;
    
    NSInteger startOffset = [self.textInput offsetFromPosition:self.textInput.beginningOfDocument toPosition:range.start];
    NSInteger endOffset = [self.textInput offsetFromPosition:self.textInput.beginningOfDocument toPosition:range.end];
    NSRange replacementRange = NSMakeRange(startOffset, endOffset - startOffset);
    
    if ([self.textInput.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]){
        shouldChange = [self.textInput.delegate textView:self.textInput shouldChangeTextInRange:replacementRange replacementText:replacementText];
    }
    return shouldChange;
}

- (void)replaceTextInRange:(UITextRange *)range withText:(NSString *)text {
    if (range && [self textInputShouldReplaceTextInRange:range replacementText:text]) {
        [self.textInput replaceRange:range withText:text];
    }
}

- (void)inputText:(NSString *)text {
    [self replaceTextInRange:self.textInput.selectedTextRange withText:text];
}

- (void)setKeyItemGroups:(NSArray *)keyItemGroups {
    _keyItemGroups = [keyItemGroups copy];
    [self reloadKeyItemGroupViews];
//    self.toolsView.keyItemGroups = keyItemGroups;
    [self switchToKeyItemGroup:[keyItemGroups objectAtIndex:0]];
}

- (void)reloadKeyItemGroupViews {
    [self.keyItemGroupViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    YYIMEmojiKeyboard *__weak weakSelf = self;
    self.keyItemGroupViews = nil;
    NSMutableArray *keyItemGroupViews = [NSMutableArray array];
    [self.keyItemGroups enumerateObjectsUsingBlock:^(YYIMEmojiKeyboardKeyGroup *obj, NSUInteger idx, BOOL *stop) {
        YYIMEmojiKeyboardKeyGroupView *keyItemGroupView = [[YYIMEmojiKeyboardKeyGroupView alloc] initWithFrame:weakSelf.keyItemGroupViewFrame];
        keyItemGroupView.keyItemGroup = obj;
        [keyItemGroupView setKeyItemTappedBlock:^(YYIMEmojiItem *keyItem) {
            [weakSelf keyItemTapped:keyItem];
        }];
        [keyItemGroupView setBackspaceButtonTappedBlock:^{
            [weakSelf backspace];
        }];
        
        [keyItemGroupView setPressedKeyItemCellChangedBlock:^(YYIMEmojiKeyboardCell *fromCell, YYIMEmojiKeyboardCell *toCell) {
            if (weakSelf.keyItemGroupPressedKeyCellChangedBlock) {
                weakSelf.keyItemGroupPressedKeyCellChangedBlock(obj,fromCell,toCell);
            }
        }];
        [keyItemGroupView setKeyboardWillReturnBlock:^{
            [weakSelf keyboardWillReturn];
        }];
        [keyItemGroupViews addObject:keyItemGroupView];
    }];
    self.keyItemGroupViews = [keyItemGroupViews copy];
}

- (void)keyItemTapped:(YYIMEmojiItem *)keyItem {
    [self inputText:keyItem.emojiText];
    [[YYIMEmojiHelper sharedInstance] didEmojiUsed:keyItem];
    [self reloadKeyItemGroupData];
}

- (void)reloadKeyItemGroupData {
    [self.keyItemGroupViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj reloadEmojiData];
    }];
}

- (void)keyboardWillReturn {
    if ([self.textInput.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]){
        [self.textInput.delegate textView:self.textInput shouldChangeTextInRange:NSMakeRange(self.textInput.text.length, 0) replacementText:@"\n"];
    }
}

#pragma mark - KeyItems

- (CGRect)keyItemGroupViewFrame {
    return CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
}

@end