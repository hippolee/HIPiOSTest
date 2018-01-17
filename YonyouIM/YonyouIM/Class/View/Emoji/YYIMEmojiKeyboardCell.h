//
//  YYIMEmojiKeyboardCell.h
//  YonyouIM
//
//  Created by litfb on 15/6/17.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMEmojiItem.h"

@interface YYIMEmojiKeyboardCell : UICollectionViewCell

@property (nonatomic, retain) IBOutlet UIImageView *emojiImage;

@property (nonatomic, retain) IBOutlet UILabel *emojiLabel;

@property (nonatomic, retain) YYIMEmojiItem *keyItem;

@property (nonatomic) BOOL isBack;

@property (nonatomic) BOOL isSend;

@end
