//
//  HIPSvgTool.h
//  litfb_test
//
//  Created by litfb on 16/7/1.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HIPSvgToolInfo : NSObject

@property (nonatomic) NSInteger toolId;

@property (nonatomic) NSString *toolName;

@property (nonatomic) NSString *toolIdentity;

@property (nonatomic) BOOL isEnable;

- (instancetype)initWithToolId:(NSInteger)toolId toolName:(NSString *)toolName toolIdentity:(NSString *)toolIdentity isEnable:(BOOL)isEnable;

- (NSString *)toolIcon;

- (NSString *)menuIcon;

- (NSString *)menuHilightIcon;

@end
