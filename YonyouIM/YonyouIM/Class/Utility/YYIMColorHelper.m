//
//  YYIMColorHelper.m
//  YonyouIM
//
//  Created by litfb on 15/6/17.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMColorHelper.h"

@interface YYIMColorHelper ()

@property (retain, nonatomic) NSDictionary *colorDic;

@end

@implementation YYIMColorHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (instancetype)init {
    if ((self = [super init])) {
        NSMutableDictionary *colorDictionary = [NSMutableDictionary dictionary];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xF95450] forKey:@"a"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0x3AAFEC] forKey:@"b"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0x7DB82A] forKey:@"c"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0x4AAA44] forKey:@"d"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0x3A6DEC] forKey:@"e"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xC6B91F] forKey:@"f"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xF66C26] forKey:@"g"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0x29AE9B] forKey:@"h"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0x4C6DE0] forKey:@"i"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xE04F4A] forKey:@"j"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xA16FE8] forKey:@"k"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xF66C26] forKey:@"l"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xECAC19] forKey:@"m"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xF05C38] forKey:@"n"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0x2BC6B0] forKey:@"o"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0x817BFF] forKey:@"p"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xEA4B7C] forKey:@"q"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xAB64E8] forKey:@"r"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0x43C678] forKey:@"s"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0x9064F7] forKey:@"t"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xDE56C4] forKey:@"u"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0x4CA8D9] forKey:@"v"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xDC7E39] forKey:@"w"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xD76155] forKey:@"x"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xD79944] forKey:@"y"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0x499CFA] forKey:@"z"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xF95450] forKey:@"1"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0x3AAFEC] forKey:@"2"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0x7DB82A] forKey:@"3"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0x4AAA44] forKey:@"4"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0x3A6DEC] forKey:@"5"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xC6B91F] forKey:@"6"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xF66C26] forKey:@"7"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0x29AE9B] forKey:@"8"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0x4C6DE0] forKey:@"9"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xE04F4A] forKey:@"0"];
        [colorDictionary setObject:[NSNumber numberWithInteger:0xA16FE8] forKey:@"#"];
        self.colorDic = colorDictionary;
    }
    return self;
}

- (UIColor *)colorForLetter:(NSString *)letterString {
    NSNumber *colorNumber = [self.colorDic objectForKey:letterString];
    if (!colorNumber) {
        colorNumber = [self.colorDic objectForKey:@"#"];
    }
    UIColor *color = UIColorFromRGB([colorNumber intValue]);
    return color;
}

@end
