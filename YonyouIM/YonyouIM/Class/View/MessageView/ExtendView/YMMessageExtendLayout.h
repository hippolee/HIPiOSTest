//
//  YMMessageExtendLayout.h
//  YonyouIM
//
//  Created by litfb on 15/6/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

#define YYIM_MESSAGE_EXTEND_ITEMS_PER_ROW 4
#define YYIM_MESSAGE_EXTEND_ROWS_PER_PAGE 2
#define YYIM_MESSAGE_EXTEND_ITEMS_PER_PAGE (YYIM_MESSAGE_EXTEND_ITEMS_PER_ROW * YYIM_MESSAGE_EXTEND_ROWS_PER_PAGE)

@interface YMMessageExtendLayout : UICollectionViewLayout

@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat lineSpacing;
@property (nonatomic) CGFloat itemSpacing;
@property (nonatomic) UIEdgeInsets pageContentInsets;

@end
