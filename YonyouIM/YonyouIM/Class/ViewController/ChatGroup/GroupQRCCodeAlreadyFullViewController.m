//
//  GroupQRCCodeAlreadyFullViewController.m
//  YonyouIM
//
//  Created by yanghaoc on 16/6/15.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "GroupQRCCodeAlreadyFullViewController.h"
#import "UIImageView+YYIMCatagory.h"

@interface GroupQRCCodeAlreadyFullViewController ()

@end

@implementation GroupQRCCodeAlreadyFullViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"加入群组";
    
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initUI {
    [self.groupIcon ym_setImageWithGroupInfo:self.groupInfo placeholderImage:[UIImage imageNamed:@"icon_chatgroup"]];
    [self.groupNameLabel setText:self.groupInfo.group.groupName];
    [self.groupMemberCountLabel setText:[NSString stringWithFormat:@"共%ld人", (long)self.groupInfo.group.memberCount]];
}

@end
