//
//  ImageMessageTableViewCell.h
//  YonyouIM
//
//  Created by litfb on 15/11/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kYMPressedImageMessage @"kYMPressedImageMessage"

@interface ImageMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UIImageView *image3;
@property (weak, nonatomic) IBOutlet UIImageView *image4;

- (void)setImageMessages:(NSArray *)messages;

@end
