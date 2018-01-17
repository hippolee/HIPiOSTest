//
//  YMRoundProgressView.m
//  YonyouIM
//
//  Created by litfb on 15/8/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YMRoundProgressView.h"
#import "YMRoundProgressLayer.h"

@implementation YMRoundProgressView

+ (Class)layerClass {
    return [YMRoundProgressLayer class];
}

@end
