//
//  YYIMEmojiTabViewCell.h
//  YonyouIM
//
//  Created by litfb on 15/4/20.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYIMEmojiTabViewCell : UICollectionViewCell

@property (retain, nonatomic) UIImage *image;

@property (retain, nonatomic) UIImage *highlightedImage;

@property (retain, nonatomic) IBOutlet UIImageView *iconImage;

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

- (void) setTitle:(NSString *)title;

@end
