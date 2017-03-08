//
//  HIPSvgContainer.h
//  litfb_test
//
//  Created by litfb on 16/7/2.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HIPSvgData.h"

@interface HIPSvgContainer : UIScrollView

@property (retain, nonatomic) HIPSvgData *svgData;

@property (assign, nonatomic) NSUInteger index;

- (void)prepareForReuse;

@end
