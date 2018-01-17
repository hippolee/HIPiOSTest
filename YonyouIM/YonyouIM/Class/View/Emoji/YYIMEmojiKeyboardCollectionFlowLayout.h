//
//  YYIMEmojiKeyboardCollectionFlowLayout.h
//  YonyouIM
//
//  Created by litfb on 15/1/15.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYIMEmojiKeyboardCollectionFlowLayout : UICollectionViewLayout

@property (nonatomic, readonly) CGSize itemSize;
@property (nonatomic, readonly) CGFloat lineSpacing;
@property (nonatomic, readonly) CGFloat itemSpacing;
@property (nonatomic, readonly) UIEdgeInsets pageContentInsets;

@end
