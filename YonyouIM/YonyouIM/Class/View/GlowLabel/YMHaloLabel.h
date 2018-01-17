//
//  YMHaloLabel.h
//  YonyouIM
//
//  Created by yanghaoc on 16/6/24.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMHaloLabel : UILabel

@property (assign, nonatomic) CGSize haloOffset;
@property (assign, nonatomic) CGFloat haloAmount;
@property (retain, nonatomic) UIColor *haloColor;

@end
