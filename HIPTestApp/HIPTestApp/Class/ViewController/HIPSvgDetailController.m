//
//  HIPSvgDetailController.m
//  litfb_test
//
//  Created by litfb on 16/3/21.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPSvgDetailController.h"
#import "HIPSvgInfo.h"
#import "HIPDBHelper.h"
#import "HIPColorHelper.h"
#import "HIPSvgBrowser.h"
#import "HIPStackMenu.h"
#import "HIPColorStackMenu.h"
#import "HIPColorPowerSlider.h"
#import "HIPSvgEditor.h"
#import "HIPSvgToolInfo.h"

@interface HIPSvgDetailController ()<UIActionSheetDelegate, HIPStackMenuDelegate, HIPColorPowerDelegate, HIPSvgBrowserDataSource, HIPSvgBrowserDelegate, HIPSvgDelegate>

#pragma mark Views

@property (weak, nonatomic) HIPSvgBrowser *browser;

@property (weak, nonatomic) UIView *bottomView;

@property (weak, nonatomic) HIPStackMenu *toolMenu;

@property (weak, nonatomic) HIPColorStackMenu *colorMenu;

@property (weak, nonatomic) HIPColorPowerSlider *colorSilder;

@property (weak, nonatomic) UIButton *endBtn;

@property (weak, nonatomic) UIView *undoRedoView;

@property (weak, nonatomic) UIButton *undoBtn;

@property (weak, nonatomic) UIButton *redoBtn;

@property (weak, nonatomic) UITapGestureRecognizer *tapRecognizer;

#pragma datas

@property (strong, nonatomic) NSArray *toolArray;

@property (strong, nonatomic) NSArray *colorArray;

@property (nonatomic) NSUInteger linePower;

@property (nonatomic) UIColor *lineColor;

@end

@implementation HIPSvgDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化数据
    [self initData];
    // 初始化视图
    [self initView];
    
    [self setExtendedLayoutIncludesOpaqueBars:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initData {
    // 当前svg
    HIPSvgInfo *svgInfo = [self.svgArray objectAtIndex:self.index];
    [self.navigationItem setTitle:[svgInfo svgName]];
    
    self.toolArray = [[HIPDBHelper sharedInstance] getEnabledSvgTools];
    self.colorArray = [NSArray arrayWithObjects:[UIColor redColor], [UIColor orangeColor], [UIColor yellowColor], [UIColor greenColor], [UIColor blueColor], [UIColor purpleColor], [UIColor brownColor], [UIColor blackColor], nil];
    self.lineColor = [self.colorArray objectAtIndex:0];
    self.linePower = 3;
}

- (void)initView {
    [self initBackground];
    [self initNavigationBarButton];
    [self initBottomView];
    [self initSvgBrowser];
    [self initToolMenu];
    [self initColorMenu];
    [self initColorSlider];
    [self initEndBtn];
    [self initUndoRedoView];
}

#pragma mark background

- (void)initBackground {
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tapRecognizer];
    self.tapRecognizer = tapRecognizer;
}

- (void)setHiddenBar:(BOOL)hidden {
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:hidden];
    [self.bottomView setHidden:hidden];
}

- (void)tapAction:(id)sender {
    if ([self.bottomView isHidden]) {
        [self setHiddenBar:NO];
    } else {
        [self setHiddenBar:YES];
    }
}

#pragma mark navigationBarButton

- (void)initNavigationBarButton {
    // menu
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_wb_more"] style:UIBarButtonItemStylePlain target:self action:@selector(menuAction:)]];
    // close
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_wb_close"] style:UIBarButtonItemStylePlain target:self action:@selector(closeAction:)]];
}

- (void)menuAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:@"拷贝到", @"保存到相册", nil];
    [actionSheet showInView:self.view];
}

- (void)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    // TODO
}

#pragma mark bottomView

- (void)initBottomView {
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 44, CGRectGetWidth(self.view.frame), 44)];
    [bottomView setBackgroundColor:HIP_THEME_ORANGE];
    
    CGFloat unitWidth = CGRectGetWidth(self.view.frame) / 5;
    CGFloat offset = (unitWidth - 44) / 2;
    
    UIButton *annotateBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.5f * unitWidth + offset, 0, 44, 44)];
    [annotateBtn setBackgroundImage:[UIImage imageNamed:@"icon_wb_annotate"] forState:UIControlStateNormal];
    [annotateBtn addTarget:self action:@selector(annotateAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *commentsBtn = [[UIButton alloc] initWithFrame:CGRectMake(1.5f * unitWidth + offset, 0, 44, 44)];
    [commentsBtn setBackgroundImage:[UIImage imageNamed:@"icon_wb_comments"] forState:UIControlStateNormal];
    [commentsBtn addTarget:self action:@selector(commentsAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *recordBtn = [[UIButton alloc] initWithFrame:CGRectMake(2.5f * unitWidth + offset, 0, 44, 44)];
    [recordBtn setBackgroundImage:[UIImage imageNamed:@"icon_wb_record"] forState:UIControlStateNormal];
    [recordBtn addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *thumbBtn = [[UIButton alloc] initWithFrame:CGRectMake(3.5f * unitWidth + offset, 0, 44, 44)];
    [thumbBtn setBackgroundImage:[UIImage imageNamed:@"icon_wb_thumb"] forState:UIControlStateNormal];
    [thumbBtn addTarget:self action:@selector(thumbAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:annotateBtn];
    [bottomView addSubview:commentsBtn];
    [bottomView addSubview:recordBtn];
    [bottomView addSubview:thumbBtn];
    
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
}

- (void)annotateAction:(id)sender {
    
}

- (void)commentsAction:(id)sender {
    
}

- (void)recordAction:(id)sender {
    
}

- (void)thumbAction:(id)sender {
    
}

#pragma mark svgBrowser

- (void)initSvgBrowser {
    HIPSvgBrowser *browser = [[HIPSvgBrowser alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    [browser setDelegate:self];
    [browser setDataSource:self];
    [self.view addSubview:browser];
    self.browser = browser;
}

#pragma mark HIPSvgBrowserDataSource, HIPSvgBrowserDelegate

- (NSUInteger)numberOfSvgsInSvgBrowser:(HIPSvgBrowser *)svgBrowser {
    return [self.svgArray count];
}

- (HIPSvgData *)svgBrowser:(HIPSvgBrowser *)svgBrowser svgAtIndex:(NSUInteger)index {
    HIPSvgInfo *svgInfo = [self.svgArray objectAtIndex:index];
    return [svgInfo svgData];
}

//- (void)svgBrowser:(HIPSvgBrowser *)svgBrowser svgAtIndex:(NSUInteger)index complete:(void (^)(HIPSvgData *svgData))complete {
//
//}

- (void)svgBrowser:(HIPSvgBrowser *)svgBrowser willDisplaySvgAtIndex:(NSUInteger)index inView:(HIPSvgContainer *)svgContainer {
    NSLog(@"willDisplaySvgAtIndex:%lu",(unsigned long)index);
}

- (void)svgBrowser:(HIPSvgBrowser *)svgBrowser didDisplaySvgAtIndex:(NSUInteger)index inView:(HIPSvgContainer *)svgContainer {
    NSLog(@"didDisplaySvgAtIndex:%lu",(unsigned long)index);
}

#pragma mark toolMenu

- (void)initToolMenu {
    NSMutableArray *items = [NSMutableArray array];
    for (HIPSvgToolInfo *svgToolInfo in self.toolArray) {
        HIPStackMenuItem *item = [[HIPStackMenuItem alloc] initWithImage:[UIImage imageNamed:[svgToolInfo menuIcon]] highlightedImage:[UIImage imageNamed:[svgToolInfo menuHilightIcon]]];
        [items addObject:item];
    }
    HIPStackMenuItem *item = [[HIPStackMenuItem alloc] initWithImage:[UIImage imageNamed:@"icon_wb_setting"] highlightedImage:nil];
    [items addObject:item];
    
    HIPStackMenu *toolMenu = [[HIPStackMenu alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 62, CGRectGetHeight(self.view.frame) - 62, 50, 50) items:items];
    [toolMenu setDelegate:self];
    [toolMenu setCloseAnimationDuration:0];
    [toolMenu setBounce:NO];
    [toolMenu setHidden:YES];
    [self.view addSubview:toolMenu];
    self.toolMenu = toolMenu;
}

#pragma mark colorMenu

- (void)initColorMenu {
    NSMutableArray *colorItems = [NSMutableArray array];
    for (UIColor *color in self.colorArray) {
        HIPColorStackMenuItem *item = [[HIPColorStackMenuItem alloc] initWithColor:color power:self.linePower];
        [colorItems addObject:item];
    }
    HIPColorStackMenu *colorMenu = [[HIPColorStackMenu alloc] initWithFrame:CGRectMake(12, CGRectGetHeight(self.view.frame) - 62, 50, 50) items:colorItems];
    [colorMenu setDelegate:self];
    [colorMenu setAnimationType:HIPStackMenuAnimationTypeProgressive];
    [colorMenu setHidden:YES];
    [self.view addSubview:colorMenu];
    self.colorMenu = colorMenu;
}

#pragma mark HIPStackMenuDelegate

- (void)stackMenuWillOpen:(HIPStackMenu *)menu {
    if (menu == _toolMenu) {
        NSLog(@"stackMenuWillOpen:toolMenu");
        [self.endBtn setHidden:YES];
        [self.colorMenu setHidden:YES];
        [self.undoRedoView setHidden:YES];
    } else if (menu == _colorMenu) {
        NSLog(@"stackMenuWillOpen:colorMenu");
        [self.endBtn setHidden:YES];
        [self.toolMenu setHidden:YES];
        [self.undoRedoView setHidden:YES];
        [self.colorSilder setHidden:NO];
    }
}

- (void)stackMenuDidOpen:(HIPStackMenu *)menu {
    if (menu == _toolMenu) {
        NSLog(@"stackMenuDidOpen:toolMenu");
    } else if (menu == _colorMenu) {
        NSLog(@"stackMenuDidOpen:colorMenu");
    }
}

- (void)stackMenuWillClose:(HIPStackMenu *)menu {
    if (menu == _toolMenu) {
        NSLog(@"stackMenuWillClose:toolMenu");
    } else if (menu == _colorMenu) {
        NSLog(@"stackMenuWillClose:colorMenu");
        [self.colorSilder setHidden:YES];
    }
}

- (void)stackMenuDidClose:(HIPStackMenu *)menu {
    if (menu == _toolMenu) {
        NSLog(@"stackMenuDidClose:toolMenu");
    } else if (menu == _colorMenu) {
        NSLog(@"stackMenuDidClose:colorMenu");
    }
}

- (BOOL)stackMenu:(HIPStackMenu *)menu willSelectItem:(HIPStackMenuItem *)item atIndex:(NSUInteger)index {
    return YES;
}

- (void)stackMenu:(HIPStackMenu *)menu didSelectItem:(HIPStackMenuItem *)item atIndex:(NSUInteger)index {
    if (menu == _toolMenu) {
        NSLog(@"toolMenu:didSelectItem:%lu", (unsigned long)index);
        [self.endBtn setHidden:NO];
        [self.colorMenu setHidden:NO];
        [self.undoRedoView setHidden:NO];
    } else if (menu == _colorMenu) {
        NSLog(@"colorMenu:didSelectItem:%lu", (unsigned long)index);
        self.lineColor = [self.colorArray objectAtIndex:index];
        [self.colorSilder setColor:self.lineColor];
        [self.colorSilder setHidden:YES];
        [self.toolMenu setHidden:NO];
        [self.undoRedoView setHidden:NO];
    }
}

#pragma mark colorSlider

- (void)initColorSlider {
    HIPColorPowerSlider *colorSlider = [[HIPColorPowerSlider alloc] initWithFrame:CGRectMake(86, CGRectGetHeight(self.view.frame) - 60, CGRectGetWidth(self.view.frame) - 140, 44) color:self.lineColor];
    [colorSlider setMinimumValue:1];
    [colorSlider setMaximumValue:20];
    [colorSlider setValue:self.linePower];
    [colorSlider setDelegate:self];
    [colorSlider setHidden:YES];
    
    [self.view addSubview:colorSlider];
    self.colorSilder = colorSlider;
}

#pragma mark endBtn

- (void)initEndBtn {
    UIButton *endBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 70, 12, 54, 28)];
    [endBtn setTitle:@"完成" forState:UIControlStateNormal];
    [endBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [endBtn setBackgroundColor:[UIColor blackColor]];
    [endBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [endBtn addTarget:self action:@selector(endAction:) forControlEvents:UIControlEventTouchUpInside];
    [endBtn setHidden:YES];
    
    CALayer *layer = [endBtn layer];
    [layer setBorderColor:[UIColor whiteColor].CGColor];
    [layer setBorderWidth:2.0f];
    
    [self.view addSubview:endBtn];
    self.endBtn = endBtn;
}

- (void)endAction:(id)sender {
    
}

#pragma mark undoredo

- (void)initUndoRedoView {
    UIView *undoRedoView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - 115) / 2, CGRectGetHeight(self.view.frame) - 60, 115, 40)];
    [undoRedoView setBackgroundColor:[UIColor clearColor]];
    [undoRedoView setHidden:YES];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 115, 40)];
    [imageView setImage:[UIImage imageNamed:@"bg_wb_undoredo"]];
    [undoRedoView addSubview:imageView];
    
    UIButton *undoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 56, 40)];
    [undoBtn setImage:[UIImage imageNamed:@"icon_wb_undo"] forState:UIControlStateNormal];
    [undoBtn setImage:[UIImage imageNamed:@"icon_wb_undo_disable"] forState:UIControlStateDisabled];
    [undoBtn setEnabled:NO];
    [undoRedoView addSubview:undoBtn];
    
    UIButton *redoBtn = [[UIButton alloc] initWithFrame:CGRectMake(59, 0, 56, 40)];
    [redoBtn setImage:[UIImage imageNamed:@"icon_wb_redo"] forState:UIControlStateNormal];
    [redoBtn setImage:[UIImage imageNamed:@"icon_wb_redo_disable"] forState:UIControlStateDisabled];
    [redoBtn setEnabled:NO];
    [undoRedoView addSubview:redoBtn];
    
    [self.view addSubview:undoRedoView];
    self.undoRedoView = undoRedoView;
}

#pragma mark HIPColorPowerDelegate

- (void)colorPowerSlider:(HIPColorPowerSlider *)slider powerDidChange:(NSUInteger)power {
    self.linePower = power;
    [self.colorMenu setPower:power];
}

#pragma mark HIPSvgDelegate

- (void)svgEditorDidLoadData:(HIPSvgEditor *)svgEditor {
    
}

- (void)svgEditorWillStartEdit:(HIPSvgEditor *)svgEditor {
    [self.tapRecognizer setEnabled:NO];
    [self setHiddenBar:YES];
}

- (void)svgEditorDidStartEdit:(HIPSvgEditor *)svgEditor {
    
}

- (void)svgEditorDidEndEdit:(HIPSvgEditor *)svgEditor {
    [self.tapRecognizer setEnabled:YES];
    [self setHiddenBar:NO];
}

- (void)svgEditor:(HIPSvgEditor *)svgEditor didUndoWithElement:(HIPSvgElement *)element {
    
}

- (void)svgEditorDidRedo:(HIPSvgEditor *)svgEditor {
    
}

- (void)svgEditor:(HIPSvgEditor *)svgEditor didAddElement:(HIPSvgElement *)element {
    
}

@end
