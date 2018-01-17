//
//  PanTableViewCell.h
//  YonyouIM
//
//  Created by litfb on 15/7/7.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JZSwipeCell.h"
#import "YYIMChatHeader.h"

@interface PanTableViewCell : JZSwipeCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImage;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (weak, nonatomic) IBOutlet UILabel *propLabel;

@property (assign, nonatomic) BOOL enableSwipe;

- (void)setActiveFile:(YYFile *)file;

- (YYFile *)activeFile;

- (void)setIconImageName:(NSString *)imageName;

- (void)setName:(NSString *)name;

- (void)setDetail:(NSString *)detail;

- (void)setProp:(NSString *)prop;

@end
