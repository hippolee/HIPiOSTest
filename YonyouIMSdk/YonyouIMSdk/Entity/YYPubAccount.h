//
//  YYPubAccount.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/13.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#define YYIM_ACCOUNT_TYPE_SUBSCRIBE 1
#define YYIM_ACCOUNT_TYPE_BROADCAST 2

@interface YYPubAccount : NSObject

@property NSString *accountId;

@property NSString *accountName;

@property NSString *accountPhoto;

@property NSInteger accountType;

@property NSString *accountDesc;

//公共号的tag
@property (nonatomic, strong) NSArray *accountTag;

@end