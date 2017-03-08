//
//  HIPStackMenuViewController.m
//  litfb_test
//
//  Created by litfb on 16/5/19.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPStackMenuViewController.h"
#import "HIPStackMenu.h"
#import "HIPColorStackMenu.h"
#import "HIPColorStackMenuItem.h"
#import "HIPColorPowerSlider.h"

@interface HIPStackMenuViewController ()<HIPStackMenuDelegate, HIPColorPowerDelegate>

@property (weak, nonatomic) HIPStackMenu *menu;

@property (weak, nonatomic) HIPColorStackMenu *colorMenu;

@property (weak, nonatomic) HIPColorPowerSlider *colorSilder;

@property (nonatomic) NSUInteger currPower;

@property (nonatomic) UIColor *currColor;

@property (strong, nonatomic) NSArray *colorArray;

@end

@implementation HIPStackMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"菜单测试"];
    
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initData {
    self.colorArray = [NSArray arrayWithObjects:[UIColor redColor], [UIColor orangeColor], [UIColor yellowColor], [UIColor greenColor], [UIColor blueColor], [UIColor purpleColor], [UIColor brownColor], [UIColor blackColor], nil];
    self.currPower = 3;
    self.currColor = [self.colorArray objectAtIndex:0];
}

- (void)initView {
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 1; i <= 3; i++) {
        HIPStackMenuItem *item = [[HIPStackMenuItem alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon%02d", i]] highlightedImage:[UIImage imageNamed:[NSString stringWithFormat:@"hicon%02d", i]]];
        [items addObject:item];
    }
    HIPStackMenu *menu = [[HIPStackMenu alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 70, CGRectGetHeight(self.view.frame) - 120, 50, 50) items:items];
    [menu setDelegate:self];
    [menu setCloseAnimationDuration:0];
    [menu setBounce:NO];
    [self.view addSubview:menu];
    self.menu = menu;
    
    NSMutableArray *colorItems = [NSMutableArray array];
    for (UIColor *color in self.colorArray) {
        HIPColorStackMenuItem *item = [[HIPColorStackMenuItem alloc] initWithColor:color power:self.currPower];
        [colorItems addObject:item];
    }
    HIPColorStackMenu *colorMenu = [[HIPColorStackMenu alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.view.frame) - 120, 50, 50) items:colorItems];
    [colorMenu setDelegate:self];
    [colorMenu setAnimationType:HIPStackMenuAnimationTypeProgressive];
    [self.view addSubview:colorMenu];
    self.colorMenu = colorMenu;
    
    HIPColorPowerSlider *colorSlider = [[HIPColorPowerSlider alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - 200) / 2, CGRectGetHeight(self.view.frame) - 115, 200, 40) color:_currColor];
    [colorSlider setMinimumValue:1];
    [colorSlider setMaximumValue:20];
    [colorSlider setValue:self.currPower];
    [colorSlider setDelegate:self];
    [colorSlider setHidden:YES];
    
    [self.view addSubview:colorSlider];
    self.colorSilder = colorSlider;
}

#pragma mark HIPStackMenuDelegate

- (void)stackMenuWillOpen:(HIPStackMenu *)menu {
    if (menu == _menu) {
        NSLog(@"stackMenuWillOpen:menu");
    } else if (menu == _colorMenu) {
        NSLog(@"stackMenuWillOpen:colorMenu");
        [self.colorSilder setHidden:NO];
    }
}

- (void)stackMenuDidOpen:(HIPStackMenu *)menu {
    if (menu == _menu) {
        NSLog(@"stackMenuDidOpen:menu");
    } else if (menu == _colorMenu) {
        NSLog(@"stackMenuDidOpen:colorMenu");
    }
}

- (void)stackMenuWillClose:(HIPStackMenu *)menu {
    if (menu == _menu) {
        NSLog(@"stackMenuWillClose:menu");
    } else if (menu == _colorMenu) {
        NSLog(@"stackMenuWillClose:colorMenu");
        [self.colorSilder setHidden:YES];
    }
}

- (void)stackMenuDidClose:(HIPStackMenu *)menu {
    if (menu == _menu) {
        NSLog(@"stackMenuDidClose:menu");
    } else if (menu == _colorMenu) {
        NSLog(@"stackMenuDidClose:colorMenu");
    }
}

- (void)stackMenu:(HIPStackMenu *)menu didSelectItem:(HIPStackMenuItem *)item atIndex:(NSUInteger)index {
    if (menu == _menu) {
        NSLog(@"menu:didSelectItem:%lu", (unsigned long)index);
    } else if (menu == _colorMenu) {
        NSLog(@"colorMenu:didSelectItem:%lu", (unsigned long)index);
        self.currColor = [self.colorArray objectAtIndex:index];
        [self.colorSilder setColor:self.currColor];
    }
}

#pragma mark HIPColorPowerDelegate

- (void)colorPowerSlider:(HIPColorPowerSlider *)slider powerDidChange:(NSUInteger)power {
    NSUInteger sliderValue = [self.colorSilder value];
    NSLog(@"powerDidChange:%lu", (unsigned long)power);
    self.currPower = power;
    [self.colorMenu setPower:sliderValue];
}

@end
