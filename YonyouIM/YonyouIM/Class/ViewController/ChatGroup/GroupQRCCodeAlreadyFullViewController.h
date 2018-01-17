//
//  GroupQRCCodeAlreadyFullViewController.h
//  YonyouIM
//
//  Created by yanghaoc on 16/6/15.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYChatGroupInfo.h"

@interface GroupQRCCodeAlreadyFullViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *groupIcon;

@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *groupMemberCountLabel;

@property (strong, nonatomic) YYChatGroupInfo *groupInfo;

@end
