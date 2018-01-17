//
//  SingleLineSelCell.h
//  YonyouIM
//
//  Created by litfb on 15/1/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingleLineCell.h"

@interface SingleLineSelCell : SingleLineCell

@property (retain, nonatomic) IBOutlet UIImageView *checkboxImage;

- (void)setSelectEnable:(BOOL)enable;

- (void)setSelectEnable:(BOOL)enable withDisableImage:(UIImage *)image;

@end
