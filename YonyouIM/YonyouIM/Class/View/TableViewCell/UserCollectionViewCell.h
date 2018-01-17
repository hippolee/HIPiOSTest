//
//  UserCollectionViewCell.h
//  YonyouIM
//
//  Created by litfb on 15/3/24.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCollectionViewCell : UICollectionViewCell

@property (retain, nonatomic) IBOutlet UIImageView *iconImage;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;

@property (retain, nonatomic) IBOutlet UIView *delView;

@property (nonatomic) CGFloat roundCorner;

- (void)reuse;

- (void)setHeadImageWithUrl:(NSString *)headUrl;

- (void)setHeadImageWithUrl:(NSString *)headUrl placeholderName:(NSString *)name;

- (void)setHeadIcon:(NSString *)iconName;

- (void)setName:(NSString *)name;

@end
