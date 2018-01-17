//
//  NormalSelTabelViewCell.h
//  YonyouIM
//
//  Created by litfb on 15/1/20.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NormalTableViewCell.h"

@interface NormalSelTableViewCell : NormalTableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *checkboxImage;

- (void)setSelectEnable:(BOOL)enable;

- (void)setSelectEnable:(BOOL)enable withDisableImage:(UIImage *)image;

@end
