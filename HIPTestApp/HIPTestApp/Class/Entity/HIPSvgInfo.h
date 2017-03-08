//
//  HIPSvgInfo.h
//  litfb_test
//
//  Created by litfb on 16/3/21.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HIPSvgData.h"

@interface HIPSvgInfo : NSObject

@property (nonatomic) NSString *svgId;

@property (nonatomic) NSString *svgName;

@property (nonatomic) NSString *svgDataXml;

@property (nonatomic, readonly) HIPSvgData *svgData;

@property (nonatomic) NSTimeInterval dateline;

@end
