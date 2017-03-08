//
//  HIPSvgTool.m
//  litfb_test
//
//  Created by litfb on 16/7/1.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPSvgToolInfo.h"

@implementation HIPSvgToolInfo

- (instancetype)initWithToolId:(NSInteger)toolId toolName:(NSString *)toolName toolIdentity:(NSString *)toolIdentity isEnable:(BOOL)isEnable {
    if (self = [super init]) {
        self.toolId = toolId;
        self.toolName = toolName;
        self.toolIdentity = toolIdentity;
        self.isEnable = isEnable;
    }
    return self;
}

- (NSString *)toolIcon {
    return [NSString stringWithFormat:@"icon_wbt_%@", self.toolIdentity];
}

- (NSString *)menuIcon {
    return [NSString stringWithFormat:@"icon_wb_%@", self.toolIdentity];
}

- (NSString *)menuHilightIcon {
    return [NSString stringWithFormat:@"icon_wb_%@_hl", self.toolIdentity];
}

@end
