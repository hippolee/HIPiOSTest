//
//  PanTableViewCell1.h
//  YonyouIM
//
//  Created by litfb on 15/7/7.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PanTableViewCell1 : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImage;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *propLabel;

- (void)setIconImageName:(NSString *)imageName;

- (void)setName:(NSString *)name;

- (void)setProp:(NSString *)prop;

@end
