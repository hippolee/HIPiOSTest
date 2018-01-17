//
//  YMMessageExtendView.h
//  YonyouIM
//
//  Created by litfb on 15/6/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const kYMMessageExtendViewDefaultHeight;

@protocol YMMessageExtendDelegate;

@interface YMMessageExtendView : UIView<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

// delegate
@property (nonatomic, weak) id<YMMessageExtendDelegate> delegate;

- (void)setExtendItems:(NSArray *)extendItems;

@end

@interface YMMessageExtendViewItem : NSObject

// 标识
@property NSString *identifer;
// 图标
@property NSString *icon;
// 名称
@property NSString *name;

+ (instancetype)itemWithIdentifer:(NSString *)identifer icon:(NSString *)icon name:(NSString *)name;

@end

@protocol YMMessageExtendDelegate <NSObject>

@optional

- (void)didSelectExtendItem:(YMMessageExtendViewItem *)item atIndex:(NSInteger)index;

@end