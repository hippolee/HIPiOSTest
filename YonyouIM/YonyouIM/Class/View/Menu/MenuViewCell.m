//
//  MenuViewCell.m
//  YonyouIM
//
//  Created by litfb on 15/1/20.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "MenuViewCell.h"
#import "UIColor+YYIMTheme.h"
#import "YYIMUIDefs.h"

@interface MenuViewCell ()

@property (retain, nonatomic) IBOutlet UIImageView *menuIcon;
@property (retain, nonatomic) IBOutlet UILabel *menuLabel;
@property (weak, nonatomic) IBOutlet UIView *separator;

@end

@implementation MenuViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = [UIColor darkGrayColor];
}

- (void)reuse {
    self.menuIcon.image = nil;
    self.menuLabel.text = nil;
    [self.separator setHidden:NO];
    self.backgroundColor = [UIColor clearColor];
}

- (void)setMenuIconImage:(NSString *)imageName {
    self.menuIcon.image = [UIImage imageNamed:imageName];
}

- (void)setMenuLabelName:(NSString *)menuName {
    self.menuLabel.text = menuName;
}

- (void)setSeparatorHidden:(BOOL)isHidden {
    [self.separator setHidden:isHidden];
}

@end
