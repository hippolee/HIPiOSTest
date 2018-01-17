//
//  YMMessageExtendViewCell.h
//  YonyouIM
//
//  Created by litfb on 15/6/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMMessageExtendViewCell : UICollectionViewCell

@property (retain, nonatomic) IBOutlet UIImageView *iconImage;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;

- (void)setIconWithImageName:(NSString *)imageName;

- (void)setName:(NSString *)name;

@end
