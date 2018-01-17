//
//  YMNormalProgressView.m
//  YonyouIM
//
//  Created by litfb on 15/8/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YMNormalProgressView.h"
#import "YMNormalProgressLayer.h"

@implementation YMNormalProgressView

+ (Class)layerClass {
    return [YMNormalProgressLayer class];
}

@end
