//
//  JUMPJIDTester.m
//  HIPTestCmdLineTool
//
//  Created by litfb on 2017/3/28.
//  Copyright © 2017年 李腾飞. All rights reserved.
//

#import "JUMPJIDTester.h"
#import "JUMPJID.h"

@implementation JUMPJIDTester

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)test {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:@"user@"];
    [array addObject:@"user@domain/resource"];
    [array addObject:@"user@domain/"];
    [array addObject:@"user"];
    [array addObject:@"user.a.b@domain/resource"];
    [array addObject:@"user.a.b@im.yyuap.com/resource"];
    [array addObject:@"user.a.b@im.yyuap.com/pc-2.1"];
    [array addObject:@"111.222@333.444/555.666"];
    for (NSString *str in array) {
        NSLog(@"%@", [JUMPJID jidWithString:str]);
    }
}

@end
