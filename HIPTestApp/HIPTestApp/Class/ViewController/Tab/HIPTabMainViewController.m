//
//  HIPTabMainViewController.m
//  HIPTestApp
//
//  Created by litfb on 2017/4/15.
//  Copyright © 2017年 李腾飞. All rights reserved.
//

#import "HIPTabMainViewController.h"
#import "HIPFirstViewController.h"
#import "HIPSecondViewController.h"
#import "HIPThirdViewController.h"

@interface HIPTabMainViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) HIPFirstViewController *firstVC;
@property (nonatomic, strong) HIPSecondViewController *secondVC;
@property (nonatomic, strong) HIPThirdViewController *thirdVC;

@property (nonatomic, strong) UIViewController *currentVC;

// 顶部滚动视图
@property (nonatomic, strong) UIScrollView *headScrollView;

@property (nonatomic, strong) NSArray *headArray;
@property (nonatomic, strong) NSArray *buttonArray;
@property (nonatomic, strong) NSArray *lineArray;
@property (nonatomic, strong) NSArray *vcArray;

@end

@implementation HIPTabMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // title
    self.navigationItem.title = @"TabDEMO";
    // 坑点
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 本页面视图尺寸供计算使用
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    // 页签高度
    CGFloat headHeight = 44;
    // 头部页签view
    self.headScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, headHeight)];
    [self.headScrollView setBackgroundColor:[UIColor whiteColor]];
    [self.headScrollView setContentSize:CGSizeMake(viewHeight - headHeight, 0)];
    [self.headScrollView setBounces:NO];
    [self.headScrollView setPagingEnabled:YES];
    [self.view addSubview:self.headScrollView];
    
    // 页签标题Array
    self.headArray = @[@"聊天",@"文件",@"动态"];
    
    // ButtonArray
    NSMutableArray *buttonArray = [NSMutableArray array];
    NSMutableArray *lineArray = [NSMutableArray array];
    
    // Button尺寸计算
    CGFloat buttonWidth = viewWidth / [self.headArray count];
    
    CGFloat lineWidth = buttonWidth - 70;
    for (int i = 0; i < [self.headArray count]; i++) {
        // 按钮
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setFrame:CGRectMake(i * buttonWidth, 0, buttonWidth, headHeight)];
        [button setTitle:[self.headArray objectAtIndex:i] forState:UIControlStateNormal];
        [button setTag:i + 100];
        [button addTarget:self action:@selector(didClickHeadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.headScrollView addSubview:button];
        [buttonArray addObject:button];
        // 线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(i * buttonWidth + 35, headHeight - 2, lineWidth, 2)];
        [lineView setBackgroundColor:[UIColor redColor]];
        [self.headScrollView addSubview:lineView];
        [lineArray addObject:lineView];
        
        if (i == 0) {
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [lineView setHidden:NO];
        } else {
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [lineView setHidden:YES];
        }
        
    }
    self.buttonArray = buttonArray;
    self.lineArray = lineArray;
    
    // 子页面尺寸计算
    CGFloat subViewHeight = viewHeight - headHeight;
    
    self.firstVC = [[HIPFirstViewController alloc] init];
    [self.firstVC.view setFrame:CGRectMake(0, headHeight, viewWidth, subViewHeight)];
    [self addChildViewController:_firstVC];
    
    self.secondVC = [[HIPSecondViewController alloc] init];
    [self.secondVC.view setFrame:CGRectMake(0, headHeight, viewWidth, subViewHeight)];
    
    self.thirdVC = [[HIPThirdViewController alloc] init];
    [self.thirdVC.view setFrame:CGRectMake(0, headHeight, viewWidth, subViewHeight)];
    
    [self.view addSubview:self.firstVC.view];
    self.currentVC = self.firstVC;
    self.vcArray = @[self.firstVC, self.secondVC, self.thirdVC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didClickHeadButtonAction:(UIButton *)button {
    NSInteger index = [button tag] - 100;
    UIViewController *newVC = [self.vcArray objectAtIndex:index];
    if (self.currentVC == newVC) {
        return;
    }
    for (int i = 0; i < [self.headArray count]; i++) {
        UIButton *button = [self.buttonArray objectAtIndex:i];
        UIView *lineView = [self.lineArray objectAtIndex:i];
        if (index == i) {
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [lineView setHidden:NO];
        } else {
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [lineView setHidden:YES];
        }
    }
    [self replaceController:self.currentVC newController:newVC];
}

- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)newController {
    [self addChildViewController:newController];
    [self transitionFromViewController:oldController toViewController:newController duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        
        if (finished) {
            [newController didMoveToParentViewController:self];
            [oldController willMoveToParentViewController:nil];
            [oldController removeFromParentViewController];
            self.currentVC = newController;
        } else {
            self.currentVC = oldController;
        }
    }];
}

@end
