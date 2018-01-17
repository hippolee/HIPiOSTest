//
//  YYIMChatDelegate,h
//  YonyouIM
//
//  Created by litfb on 14/12/26.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYIMLoginDelegate.h"
#import "YYIMMessageDelegate.h"
#import "YYIMRosterDelegate.h"
#import "YYIMChatGroupDelegate.h"
#import "YYIMUserDelegate.h"
#import "YYIMPubAccountDelegate.h"
#import "YYIMNotificationDelegate.h"
#import "YYIMTeleconferenceDelegate.h"
#import "YYIMNetMeetingDelegate.h"
#import "YYIMExtDelegate.h"

@protocol YYIMChatDelegate<YYIMLoginDelegate, YYIMMessageDelegate, YYIMRosterDelegate, YYIMChatGroupDelegate, YYIMUserDelegate, YYIMPubAccountDelegate, YYIMNotificationDelegate, YYIMTeleconferenceDelegate, YYIMNetMeetingDelegate, YYIMExtDelegate>

@end
