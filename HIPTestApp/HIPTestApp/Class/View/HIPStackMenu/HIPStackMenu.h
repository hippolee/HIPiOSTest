//
//  HIPStackMenu.h
//  litfb_test
//
//  Created by litfb on 16/5/19.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HIPStackMenuItem.h"

typedef enum {
    HIPStackMenuDirectionUp = 0,
    HIPStackMenuDirectionDown
} HIPStackMenuDirection;

typedef enum {
    HIPStackMenuAnimationTypeLinear = 0,
    HIPStackMenuAnimationTypeProgressive,
    HIPStackMenuAnimationTypeProgressiveInverse
} HIPStackMenuAnimationType;

@protocol HIPStackMenuDelegate;

@interface HIPStackMenu : UIView {
    
@protected
    NSMutableArray<HIPStackMenuItem *>* _items;
    
}

// Vertical spacing between items. default 6.0f
@property (nonatomic) CGFloat itemsSpacing;
// bounce when animaton. default YES
@property (nonatomic) BOOL bounce;
// Opening duration(seconds). default 0.4f
@property (nonatomic) NSTimeInterval openAnimationDuration;
// Closing duration(seconds). default 0.4f
@property (nonatomic) NSTimeInterval closeAnimationDuration;
// Offset between items start open(seconds). default 0.0f
@property (nonatomic) NSTimeInterval openAnimationOffset;
// Offset between items start close(seconds). default 0.0f
@property (nonatomic) NSTimeInterval closeAnimationOffset;
// Menu direction. default up
@property (nonatomic) HIPStackMenuDirection direction;
// Menu animation type. default progress
@property (nonatomic) HIPStackMenuAnimationType  animationType;

// MenuItems
@property (readonly, nonatomic) NSArray *menuItems;
// Whether menu opening
@property (readonly, nonatomic) BOOL isOpen;
// Delegate
@property (weak, nonatomic) id<HIPStackMenuDelegate> delegate;

/**
 *  初始化
 *
 *  @param frame CGRect
 *  @param items 选项
 *
 *  @return instance
 */
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray<HIPStackMenuItem *> *)items;

/**
 *  添加菜单项
 *
 *  @param item 菜单项
 */
- (void)addItem:(HIPStackMenuItem *)item;

/**
 *  批量添加菜单项
 *
 *  @param items 菜单项
 */
- (void)addItems:(NSArray<HIPStackMenuItem *> *)items;

/**
 *  移除菜单项
 *
 *  @param item 菜单项
 */
- (void)removeItem:(HIPStackMenuItem *)item;

/**
 *  移除菜单项
 *
 *  @param index 菜单下标
 */
- (void)removeItemAtIndex:(NSUInteger)index;

/**
 *  移除所有菜单项
 */
- (void)removeAllItems;

/**
 *  展开菜单
 */
- (void)openMenu;

/**
 *  收起菜单
 */
- (void)closeMenu;

/**
 *  切换菜单状态
 */
- (void)toggleMenu;

@end

@protocol HIPStackMenuDelegate <NSObject>

@optional

- (void)stackMenuWillOpen:(HIPStackMenu *)menu;

- (void)stackMenuDidOpen:(HIPStackMenu *)menu;

- (void)stackMenuWillClose:(HIPStackMenu *)menu;

- (void)stackMenuDidClose:(HIPStackMenu *)menu;

- (BOOL)stackMenu:(HIPStackMenu *)menu willSelectItem:(HIPStackMenuItem *)item atIndex:(NSUInteger)index;

- (void)stackMenu:(HIPStackMenu *)menu didSelectItem:(HIPStackMenuItem *)item atIndex:(NSUInteger)index;

@end
