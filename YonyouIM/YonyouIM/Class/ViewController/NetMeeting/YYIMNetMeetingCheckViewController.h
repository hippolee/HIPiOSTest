//
//  YYIMNetMeetingCheckViewController.h
//  YonyouIM
//
//  Created by yanghaoc on 16/4/15.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMChatHeader.h"
#import "YYIMNetMeetingDetailBasicViewController.h"

@interface YYIMNetMeetingCheckViewController : YYIMNetMeetingDetailBasicViewController

@property (strong, nonatomic) NSArray *memberIdArray;

@property (strong, nonatomic) NSString *currentTitle;

@property (assign, nonatomic) BOOL isReservation;

@end
