//
//  YYIMNetMeetingInviteConfirmViewController.h
//  YonyouIM
//
//  Created by yanghaoc on 16/2/19.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMDefs.h"
#import "YYIMBaseViewController.h"
#import "NetMeetingDispatch.h"

@interface YYIMNetMeetingInviteConfirmViewController : YYIMBaseViewController <NetMeetingDispatchDelegate>

@property (strong, nonatomic) NSString *channelId;

@end
