//
//  YYIMEmojiHelper.m
//  YonyouIM
//
//  Created by litfb on 15/1/29.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMEmojiHelper.h"
#import "YYIMEmojiItem.h"
#import "YYIMChatHeader.h"
#import "YYIMEmojiLabel.h"

@interface YYIMEmojiHelper ()<YYIMEmojiLabelDelegate>

@property (strong, nonatomic) YYIMEmojiLabel *emojiLabel;

@property (retain, nonatomic) NSArray *emojiArray;

@property (retain, nonatomic) NSDictionary *emojiDic;

@property (retain, nonatomic) NSMutableArray *emojiHistoryArray;

@property (retain, nonatomic) NSMutableArray *emojiHisArray;

@property (retain, nonatomic) NSString *historyPath;

@end

@implementation YYIMEmojiHelper

+ (YYIMEmojiHelper *)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (instancetype)init {
    if (self = [super init]) {
        [self loadEmojiFromPlist];
    }
    return self;
}

- (NSString *)historyPath {
    if (!_historyPath) {
        NSString *documentdir = [YYIMResourceUtility resourceRootDirectory];
        _historyPath = [documentdir stringByAppendingPathComponent:@"EmojiHistory.plist"];
    }
    return _historyPath;
}

- (void)loadEmojiFromPlist {
    // emoji plist
    NSArray *emojiDicArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Emoji" ofType:@"plist"]];
    // emoji history plist
    NSArray *emojiHisArray = [NSArray arrayWithContentsOfFile:self.historyPath];
    self.emojiHisArray = [NSMutableArray arrayWithArray:emojiHisArray];
    
    // emoji array
    NSMutableArray *emojiArray = [NSMutableArray arrayWithCapacity:[emojiDicArray count]];
    // emoji dictionary
    NSMutableDictionary *emojiDic = [NSMutableDictionary dictionaryWithCapacity:[emojiDicArray count]];
    for (NSDictionary *dic in emojiDicArray) {
        // 表情
        NSString *emojiText = [dic objectForKey:@"text"];
        // 图片
        NSString *imageName = [NSString stringWithFormat:@"%@.png", [dic objectForKey:@"image"]];
        // emojiItem
        YYIMEmojiItem *emojiItem = [YYIMEmojiItem emojiItemWithText:emojiText imageName:imageName];
        // add to emoji array
        [emojiArray addObject:emojiItem];
        // set into dic
        [emojiDic setObject:emojiItem forKey:emojiText];
    }
    // emoji history array
    NSMutableArray *emojiHistroyArray = [NSMutableArray array];
    for (NSString *emojiText in self.emojiHisArray) {
        NSObject *obj = [emojiDic objectForKey:emojiText];
        if (!obj) {
            [self.emojiHisArray removeAllObjects];
            [self.emojiHisArray writeToFile:self.historyPath atomically:YES];
            break;
        }
        // used in week
        [emojiHistroyArray addObject:obj];
    }
    self.emojiArray = emojiArray;
    self.emojiDic = emojiDic;
    self.emojiHistoryArray = emojiHistroyArray;
}

- (NSArray *)arrayOfEmoji {
    return self.emojiArray;
}

- (NSArray *)arrayOfEmojiHistory {
    return self.emojiHistoryArray;
}

- (NSString *)imageNameWithEmojiText:(NSString *)emojiText {
    return [[self.emojiDic objectForKey:emojiText] emojiImageName];
}

- (void)didEmojiUsed:(YYIMEmojiItem *)emojiItem {
    [self.emojiHistoryArray removeObject:emojiItem];
    [self.emojiHistoryArray insertObject:emojiItem atIndex:0];
    
    [self.emojiHisArray removeObject:[emojiItem emojiText]];
    [self.emojiHisArray insertObject:[emojiItem emojiText] atIndex:0];
    
    if ([self.emojiHistoryArray count] >= 30) {
        [self.emojiHistoryArray removeLastObject];
        [self.emojiHisArray removeLastObject];
    }
    [self.emojiHisArray writeToFile:self.historyPath atomically:YES];
}

- (NSMutableAttributedString *)attributeStringWithEmojiText:(NSString*)emojiText {
    return [self.emojiLabel mutableAttributeStringWithEmojiText:[[NSAttributedString alloc] initWithString:emojiText]];
}

- (CGSize)preferredSizeWithAttributedString:(NSAttributedString *)attrString maxWidth:(CGFloat)maxWidth fontSize:(CGFloat)fontSize {
    [self.emojiLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [self.emojiLabel setText:attrString];
    return [self.emojiLabel preferredSizeWithMaxWidth:maxWidth];
}

- (YYIMEmojiLabel *)emojiLabel {
    if (!_emojiLabel) {
        _emojiLabel = [[YYIMEmojiLabel alloc] initWithFrame:CGRectZero];
        [_emojiLabel setEmojiDelegate:self];
    }
    return _emojiLabel;
}

#pragma mark YYIMEmojiLabelDelegate

- (NSString *)emojiLabel:(YYIMEmojiLabel *)emojiLabel imageNameOfEmojiText:(NSString *)emojiText {
    return [self imageNameWithEmojiText:emojiText];
}

@end
