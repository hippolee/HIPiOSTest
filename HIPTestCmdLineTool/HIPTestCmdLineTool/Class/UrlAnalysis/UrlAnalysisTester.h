//
//  UrlAnalysisTester.h
//  litfb_test_cmdtool
//
//  Created by 李腾飞 on 2017/2/10.
//  Copyright © 2017年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UrlAnalysisTester : NSObject

+ (instancetype)sharedInstance;

- (void)testUrlRegex;

@end
