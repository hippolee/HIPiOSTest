//
//  ChatMixedTableViewCell.h
//  YonyouIM
//
//  Created by litfb on 15/6/24.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMChatHeader.h"

extern const CGFloat kChatMixedTitleFontSize;
extern const CGFloat kChatMixedSubTitleFontSize;
extern const CGFloat kChatMixedDetailFontSize;

@interface ChatMixedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *mixedView;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (retain, nonatomic) YYMessage *message;

+ (CGFloat)heightForCellWithData:(YYMessage *)message;

- (void)setActiveMessage:(YYMessage *)message;

+ (CGFloat)baseHeight;

+ (CGFloat)baseWidth;

+ (CGFloat)titleHeight:(YYPubAccountContent *)paContent;

+ (CGFloat)subTitleHeight:(YYPubAccountContent *)paContent;

+ (CGFloat)detailHeight:(YYPubAccountContent *)paContent;

@end
