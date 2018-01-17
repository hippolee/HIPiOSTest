//
//  YYIMError.h
//  YonyouIM
//
//  Created by litfb on 14/12/25.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#define YMERROR_CODE_UNKNOWN_ERROR                  100
#define YMERROR_CODE_NOT_AUTHORIZED                 101
#define YMERROR_CODE_GET_TOKEN_FAILD                102
#define YMERROR_CODE_CONNECT_FIELD                  103
#define YMERROR_CODE_RESPONSE_NOT_RECEIVED          104

#define YMERROR_CODE_ILLEGAL_ARGUMENT               201
#define YMERROR_CODE_UNEXPECT_STATE                 202

#define YMERROR_CODE_USER_NOT_FOUND                 301
#define YMERROR_CODE_USER_MOBILE_NOT_FOUND          302
#define YMERROR_CODE_PARTICIPANTS_MOBILE_NOT_FOUND  303

#define YMERROR_CODE_FILE_NOT_FOUND                 401

#define YMERROR_CODE_NO_AUTHORITY                   40301
#define YMERROR_CODE_NETMEETING_HAS_LOCK            40302
#define YMERROR_CODE_NETMEETING_INVITER_MISMATCH    40303
#define YMERROR_CODE_NETMEETING_SELF_MISMATCH       40304
#define YMERROR_CODE_NETMEETING_HAS_END             40305
#define YMERROR_CODE_NETMEETING_OVER_LIMIT_COUNT    40308

#define YMERROR_CODE_MEMBER_COUNT_FAULT             40001

#define YMERROR_CODE_MISS_PARAMETER                 80001

#define YMERROR_CODE_CHATGROUP_UNEXIST              400
#define YMERROR_CODE_CHATGROUP_EXPIRED              403

#define YMERROR_CODE_MESSAGE_REVOKE_TIMEOUT         40335

@interface YYIMError : NSObject

@property (nonatomic) NSInteger errorCode;

@property (nonatomic) NSString *errorMsg;

@property (nonatomic) NSError *srcError;

+ (YYIMError *)errorWithCode:(NSInteger)errCode errorMessage:(NSString *)errorMsg;

+ (YYIMError *)errorWithNSError:(NSError *)error;

@end
