//
//  SingleLineCell3.h
//  YonyouIM
//
//  Created by yanghaoc on 16/1/12.
//  Copyright (c) 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleLineCell3 : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *moreLabel;

- (void)setName:(NSString *)name;

@end
