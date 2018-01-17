//
//  ImageCollectionViewCell.h
//  YonyouIM
//
//  Created by litfb on 15/2/4.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *foregroundView;
@property (weak, nonatomic) IBOutlet UIButton *checkboxButton;

@end
