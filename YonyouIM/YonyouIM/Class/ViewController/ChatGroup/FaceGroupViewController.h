//
//  FaceGroupViewController.h
//  YonyouIM
//
//  Created by litfb on 16/7/5.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMBaseViewController.h"

@interface FaceGroupViewController : YYIMBaseViewController

@end

@interface FaceGroupKeyboardCell : UICollectionViewCell

@property (nonatomic) NSString *text;

@property (weak, nonatomic) UILabel *label;

@end

@interface FaceGroupMemberCell : UICollectionViewCell

@property (nonatomic) NSString *userId;

@property (nonatomic) BOOL opacity;

@property (weak, nonatomic) UIImageView *imageView;

@end