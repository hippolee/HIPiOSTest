//
//  UrlAnalysisTester.m
//  litfb_test_cmdtool
//
//  Created by 李腾飞 on 2017/2/10.
//  Copyright © 2017年 yonyou. All rights reserved.
//

#import "UrlAnalysisTester.h"
#import "UrlAnalysisUtility.h"

@implementation UrlAnalysisTester

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)testUrlRegex {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:@"http://www.baidu.com"];
    [array addObject:@"http://mp.weixin.qq.com/s/ojT3L1CbNM-wWivDBdB29Q"];
    [array addObject:@"https://www.baidu.com/s?wd=%E7%BF%BB%E8%AF%91&rsv_spt=1&rsv_iqid=0xfc60a0b20006d563&issp=1&f=3&rsv_bp=1&rsv_idx=2&ie=utf-8&rqlang=cn&tn=monline_3_dg&rsv_enter=1&inputT=2459&rsv_t=3effJNrrKqwBGKyOeSwuxpDdzB58SlkD2eOh0DnOz32QY69CTYAJ%2FxnbkmgJBzkyp%2Bg%2B&rsv_sug3=30&rsv_sug1=22&rsv_sug7=100&oq=url%25E6%25AD%25A3%25E5%2588%2599&rsv_pq=caae0be100002292&rsv_sug2=0&prefixsug=fanyi&rsp=0&rsv_sug4=3825"];
    [array addObject:@"http://upesn.com/space/home/index/VISITID/74269"];
    
    for (NSString *url in array) {
        NSLog(@"%@", url);
        NSLog(@"%@", [[UrlAnalysisUtility sharedInstance] isValidUrl:url] ? @"Y":@"N");
    }
}

@end
