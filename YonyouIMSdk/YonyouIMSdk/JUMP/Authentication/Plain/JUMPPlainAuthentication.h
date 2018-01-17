//
//  JUMPPlainAuthentication.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JUMPSASLAuthentication.h"
#import "JUMPStream.h"

@interface JUMPPlainAuthentication : NSObject<JUMPSASLAuthentication>

@end

#pragma mark -

@interface JUMPStream (JUMPPlainAuthentication)

- (BOOL)supportsPlainAuthentication;

@end