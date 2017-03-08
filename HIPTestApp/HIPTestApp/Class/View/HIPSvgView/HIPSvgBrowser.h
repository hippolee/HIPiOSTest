//
//  HIPSvgBrowser.h
//  litfb_test
//
//  Created by litfb on 16/7/2.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HIPSvgData.h"
#import "HIPSvgContainer.h"

@protocol HIPSvgBrowserDataSource;
@protocol HIPSvgBrowserDelegate;

@interface HIPSvgBrowser : UIView

@property (nonatomic) NSUInteger currentIndex;

@property (weak, nonatomic) id<HIPSvgBrowserDataSource> dataSource;

@property (weak, nonatomic) id<HIPSvgBrowserDelegate> delegate;

- (void)reloadData;

@end

@protocol HIPSvgBrowserDataSource <NSObject>

- (NSUInteger)numberOfSvgsInSvgBrowser:(HIPSvgBrowser *)svgBrowser;

@optional

- (HIPSvgData *)svgBrowser:(HIPSvgBrowser *)svgBrowser svgAtIndex:(NSUInteger)index;

- (void)svgBrowser:(HIPSvgBrowser *)svgBrowser svgAtIndex:(NSUInteger)index complete:(void (^)(HIPSvgData *svgData))complete;

@end

@protocol HIPSvgBrowserDelegate <NSObject>

@optional

- (void)svgBrowser:(HIPSvgBrowser *)svgBrowser willDisplaySvgAtIndex:(NSUInteger)index inView:(HIPSvgContainer *)svgContainer;
- (void)svgBrowser:(HIPSvgBrowser *)svgBrowser didDisplaySvgAtIndex:(NSUInteger)index inView:(HIPSvgContainer *)svgContainer;

@end