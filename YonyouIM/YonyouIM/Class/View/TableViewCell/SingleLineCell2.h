//
//  SingleLineCell2.h
//  YonyouIM
//
//  Created by litfb on 15/3/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleLineCell2 : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *detailLabel;
@property (retain, nonatomic) IBOutlet UISwitch *switchControl;
@property (retain, nonatomic) IBOutlet UIImageView *detailImage;

@property (retain, nonatomic) IBOutlet UIView *timerView;
@property (retain, nonatomic) IBOutlet UILabel *timerLabel;
@property (retain, nonatomic) IBOutlet UIImageView *timerImage;


- (void)reuse;

- (void)setNameLabelWidth:(CGFloat)nameWidth;

- (void)setName:(NSString *)name;

- (void)setAttributeName:(NSMutableAttributedString *)name;

- (void)setDetail:(NSString *)detail;

- (void)setImageWithName:(NSString *)name;

- (void)setImageWithUrl:(NSString *)url;

- (void)setImageWithUrl:(NSString *)url placeholderName:(NSString *)name;

- (void)setImageRadius:(CGFloat)radius;

- (void)setSwitchState:(BOOL)switchState;

- (void)setSwitchState:(BOOL)switchState enable:(BOOL)enable;

- (void)setTimer:(NSString *)timer enbleEidt:(BOOL)enbleEidt;

@end
