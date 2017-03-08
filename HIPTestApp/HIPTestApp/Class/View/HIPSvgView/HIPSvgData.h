//
//  HIPSvgData.h
//  litfb_test
//
//  Created by litfb on 16/7/2.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define HIP_SVG_EMPTY @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<svg width=\"980\" height=\"800\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\"><g><title>Layer 1</title></g></svg>"

@interface HIPSvgData : NSObject

@property (nonatomic,readonly) CGSize size;

@end
