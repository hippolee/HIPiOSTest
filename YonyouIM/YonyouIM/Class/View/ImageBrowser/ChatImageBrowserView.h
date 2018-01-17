//
//  ChatImageBrowserView.h
//  YonyouIM
//
//  Created by litfb on 15/8/4.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatImageBrowserView : UIView

@property BOOL isShown;

- (void)setImageSourceArray:(NSArray *)imageSourceArray;

- (void)setImageIndex:(NSInteger)currentIndex;

- (void)reloadData;

- (void)show;

@end
