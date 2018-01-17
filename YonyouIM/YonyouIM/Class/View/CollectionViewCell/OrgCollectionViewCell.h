//
//  OrgCollectionViewCell.h
//  YonyouIM
//
//  Created by litfb on 15/6/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrgCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *arrowImage;

@property (nonatomic) BOOL isCurrentOrg;

@end
