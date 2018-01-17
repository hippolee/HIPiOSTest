//
//  YYIMHeadPhonesManager.h
//  YonyouIM
//
//  Created by yanghaoc on 16/3/30.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYIMHeadPhonesManager : NSObject

+ (instancetype)sharedInstance;

- (BOOL)HeadPhoneEnable;

@end
