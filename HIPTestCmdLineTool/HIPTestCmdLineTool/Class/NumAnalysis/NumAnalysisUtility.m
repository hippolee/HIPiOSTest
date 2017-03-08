//
//  NumberAnalysisUtility.m
//  litfb_test_cmdtool
//
//  Created by 李腾飞 on 2017/3/7.
//  Copyright © 2017年 yonyou. All rights reserved.
//

#import "NumAnalysisUtility.h"

#define NUM_PATTERN @"(?<=\\D{1}|^)(\\d{1,3}-\\d{1,4}-\\d{3,8}-\\d{3,8}|\\d{2,3}-\\d{5,6}-\\d{3,8}|\\d{2,3}-\\d{3,4}-\\d{3,16}|\\d{2,3}-\\d{1,2}-\\d{6,16}|\\d{1}-\\d{5,12}-\\d{3,8}|\\d{1}-\\d{1,4}-\\d{6,16}|\\d{8}-\\d{3,8}|\\d{4,7}-\\d{3,16}|\\d{1,3}-\\d{6,20}|\\d{7,23})(?=\\D+|$)"

@implementation NumAnalysisUtility

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)test1 {
    NSRegularExpression *regex = [self regularExpression];
    
    for (int i = 1; i < 30; i++) {
        NSString *s1 = [self genPartString:i preString:@""];
       
        NSLog(@"%@", s1);
        [regex enumerateMatchesInString:s1 options:0 range:NSMakeRange(0, s1.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {

            NSLog(@"------%@", [s1 substringWithRange:[result range]]);
        }];
        
        s1 = [NSString stringWithFormat:@"AAA%@BBB", s1];
        NSLog(@"%@", s1);
        [regex enumerateMatchesInString:s1 options:0 range:NSMakeRange(0, s1.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            
            NSLog(@"------%@", [s1 substringWithRange:[result range]]);
        }];
    }
}

- (void)test2 {

}

- (void)test3 {
    
}

- (void)test4 {

}

- (NSRegularExpression *)regularExpression {
    return [[NSRegularExpression alloc] initWithPattern:NUM_PATTERN options:NSRegularExpressionCaseInsensitive error:nil];
}

- (NSString *)genPartString:(int)length preString:(NSString *)preString  {
    NSMutableString *string = [NSMutableString stringWithString:preString];
    for (int i = 0; i < length; i++) {
        [string appendString:[NSString stringWithFormat:@"%u", arc4random() % 10]];
    }
    return string;
}

@end
