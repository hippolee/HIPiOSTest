//
//  FaceGroupViewController.m
//  YonyouIM
//
//  Created by litfb on 16/7/5.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "FaceGroupViewController.h"
#import "UIColor+YYIMTheme.h"
#import "YMHaloLabel.h"
#import "UIImageView+WebCache.h"
#import "UIImage+YYIMCategory.h"
#import "UIColor+YYIMTheme.h"
#import "YYIMUIDefs.h"
#import "UIViewController+HUDCategory.h"
#import "ChatViewController.h"
#import "YYIMUtility.h"
#import "UIButton+YYIMCatagory.h"
#import "YYIMColorHelper.h"

@interface FaceGroupViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate>

@property (weak, nonatomic) UILabel *promptLabel;

@property (weak, nonatomic) UIView *numberView;

@property (retain, nonatomic) NSMutableArray *numberLabelArray;

@property (weak, nonatomic) UILabel *warningLabel;

@property (weak, nonatomic) UICollectionView *keyboardView;

@property (weak, nonatomic) UILabel *promptLabel2;

@property (weak, nonatomic) UICollectionView *memberView;

@property (weak, nonatomic) UIButton *enterBtn;

@property (nonatomic) NSString *cipher;

@property (strong, nonatomic) NSMutableArray *memberArray;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) CLLocation *location;

@property (nonatomic) NSString *faceId;

@property (nonatomic) BOOL inputEnable;

@end

@implementation FaceGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"面对面建群"];
    
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initData {
    self.memberArray = [NSMutableArray array];
    self.inputEnable = YES;
    
    self.locationManager = [[CLLocationManager alloc] init];
    // 设置代理
    [self.locationManager setDelegate:self];
    // 设置定位精确度到米
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    // 设置过滤器为无
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    // 申请权限
    if (YYIM_iOS8) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    // 开始定位
    [self.locationManager startUpdatingLocation];
}

- (void)initView {
    [self.view setBackgroundColor:[UIColor themeColor]];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)]];
    
    [self initPromptLabel];
    [self initNumberView];
    [self initWarningLabel];
    [self initKeyboardView];
    [self initPromptLabel2];
    [self initMemberView];
    [self initEnterBtn];
}

- (void)backAction:(id)sender {
    if (self.cipher && self.faceId) {
        [[YYIMChat sharedInstance].chatManager quitFaceGroupWithCipher:self.cipher faceId:self.faceId];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initPromptLabel {
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(64.0f, 28.0f, CGRectGetWidth(self.view.frame) - 128.0f, 40.0f)];
    [promptLabel setNumberOfLines:0];
    [promptLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [promptLabel setTextColor:[UIColor grayColor]];
    [promptLabel setText:@"和身边的朋友输入同样的四个数字，进入同一个群聊"];
    [promptLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:promptLabel];
    self.promptLabel = promptLabel;
}

- (void)initNumberView {
    UIView *numberView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - 144.0f) / 2, 88.0f, 144.0f, 48.0f)];
    [numberView setBackgroundColor:[UIColor clearColor]];
    
    NSMutableArray *numberLabelArray = [NSMutableArray arrayWithCapacity:4];
    for (int i = 0; i < 4; i++) {
        YMHaloLabel *label = [[YMHaloLabel alloc] initWithFrame:CGRectMake(36.0f * i, 0, 36.0f, 48.0f)];
        [label setTextColor:[UIColor themeBlueColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont fontWithName:@"CourierNewPSMT" size:48.0f]];
        [label setHaloColor:[UIColor themeBlueColor]];
        [label setHaloAmount:4.0f];
        [numberView addSubview:label];
        [numberLabelArray addObject:label];
    }
    self.numberLabelArray = numberLabelArray;
    [self.view addSubview:numberView];
    self.numberView = numberView;
}

- (void)initWarningLabel {
    UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(32.0f, 144.0f, CGRectGetWidth(self.view.frame) - 64.0f, 20.0f)];
    [warningLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [warningLabel setTextColor:[UIColor redColor]];
    [warningLabel setText:@"数字过于简单，需重新约定"];
    [warningLabel setTextAlignment:NSTextAlignmentCenter];
    [warningLabel setHidden:YES];
    [self.view addSubview:warningLabel];
    self.warningLabel = warningLabel;
}

- (void)initKeyboardView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setItemSize:CGSizeMake((CGRectGetWidth(self.view.frame) - 3) / 3, 54.0f)];
    [layout setMinimumLineSpacing:0.5f];
    [layout setMinimumInteritemSpacing:0.1f];
    [layout setHeaderReferenceSize:CGSizeMake(CGRectGetWidth(self.view.frame), 0.5f)];
    [layout setFooterReferenceSize:CGSizeZero];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    UICollectionView *keyboardView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 218.0f - [self baseHeight], CGRectGetWidth(self.view.frame), 218.0f) collectionViewLayout:layout];
    [keyboardView setDataSource:self];
    [keyboardView setDelegate:self];
    [keyboardView registerClass:[FaceGroupKeyboardCell class] forCellWithReuseIdentifier:@"FaceGroupKeyboardCellIdentifier"];
    [keyboardView.layer setMasksToBounds:NO];
    
    [keyboardView setBackgroundColor:[UIColor darkGrayColor]];
    [self.view addSubview:keyboardView];
    self.keyboardView = keyboardView;
}

- (void)initPromptLabel2 {
    UILabel *promptLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(24.0f, 136.0f, CGRectGetWidth(self.view.frame) - 48.0f, 40.0f)];
    [promptLabel2 setFont:[UIFont systemFontOfSize:14.0f]];
    [promptLabel2 setTextColor:[UIColor grayColor]];
    [promptLabel2 setText:@"这些朋友也将进入群聊"];
    [promptLabel2 setTextAlignment:NSTextAlignmentCenter];
    [promptLabel2 setAlpha:0];
    [promptLabel2 setHidden:YES];
    
    CALayer *bBorder = [CALayer layer];
    bBorder.frame = CGRectMake(0.0f, 39.5f, CGRectGetWidth(promptLabel2.frame), 0.5f);
    bBorder.backgroundColor = [UIColor grayColor].CGColor;
    [promptLabel2.layer addSublayer:bBorder];
    
    [self.view addSubview:promptLabel2];
    self.promptLabel2 = promptLabel2;
}

- (void)initMemberView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWidth = (CGRectGetWidth(self.view.frame) - 88.0f - 36.0f) / 4;
    [layout setItemSize:CGSizeMake(itemWidth, itemWidth)];
    [layout setMinimumLineSpacing:12.0f];
    [layout setMinimumInteritemSpacing:12.0f];
    [layout setHeaderReferenceSize:CGSizeMake(CGRectGetWidth(self.view.frame), 8.0f)];
    [layout setFooterReferenceSize:CGSizeMake(CGRectGetWidth(self.view.frame), 8.0f)];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    UICollectionView *memberView = [[UICollectionView alloc] initWithFrame:CGRectMake(44.0f, 92.0f, CGRectGetWidth(self.view.frame) - 88.0f, CGRectGetHeight(self.view.frame) - 112.0f - 60.0f - [self baseHeight]) collectionViewLayout:layout];
    [memberView setDataSource:self];
    [memberView setDelegate:self];
    [memberView registerClass:[FaceGroupMemberCell class] forCellWithReuseIdentifier:@"FaceGroupMemberCellIdentifier"];
    [memberView.layer setMasksToBounds:NO];
    [memberView setBackgroundColor:[UIColor clearColor]];
    [memberView setAlpha:0];
    [memberView setHidden:YES];
    
    [self.view addSubview:memberView];
    self.memberView = memberView;
}

- (void)initEnterBtn {
    UIButton *enterBtn = [[UIButton alloc] initWithFrame:CGRectMake(24.0f, CGRectGetHeight(self.view.frame) - 60.0f - [self baseHeight], CGRectGetWidth(self.view.frame) - 48.0f, 44.0f)];
    [enterBtn setBackgroundColor:[UIColor themeBlueColor] forState:UIControlStateNormal];
    [enterBtn setBackgroundColor:UIColorFromRGB(0x0b6392) forState:UIControlStateSelected];
    [enterBtn setTitle:@"进入该群" forState:UIControlStateNormal];
    [enterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enterBtn setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateSelected];
    [enterBtn.titleLabel setFont:[UIFont systemFontOfSize:20.0f]];
    [enterBtn addTarget:self action:@selector(enterAction:) forControlEvents:UIControlEventTouchUpInside];
    [enterBtn setAlpha:0];
    [enterBtn setHidden:YES];
    
    CALayer *layer = [enterBtn layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:4.0f];
    
    [self.view addSubview:enterBtn];
    self.enterBtn = enterBtn;
}

- (void)enterAction:(id)sender {
    [[YYIMChat sharedInstance].chatManager joinFaceGroupWithCipher:self.cipher faceId:self.faceId];
}

#pragma mark UICollectionViewDelegate, UICollectionViewDataSource

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.keyboardView) {
        if (indexPath.row == 9) {
            return NO;
        }
        return YES;
    } else {
        return NO;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.keyboardView) {
        [self playSound];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.keyboardView) {
        if (indexPath.row == 9) {
            return NO;
        }
        return self.inputEnable;
    } else {
        return NO;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.keyboardView) {
        switch (indexPath.row) {
            case 9:
                break;
            case 10:
                [self keyboardInput:0];
                break;
            case 11:
                [self keyboardInput:-1];
                break;
            default:
                [self keyboardInput:indexPath.row + 1];
                break;
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.keyboardView) {
        return 12;
    } else {
        return [self.memberArray count] + 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.keyboardView) {
        FaceGroupKeyboardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FaceGroupKeyboardCellIdentifier" forIndexPath:indexPath];
        switch (indexPath.row) {
            case 9:
                [cell setText:@""];
                break;
            case 10:
                [cell setText:@"0"];
                break;
            case 11:
                [cell setText:@"<-"];
                break;
            default:
                [cell setText:[NSString stringWithFormat:@"%ld", (long)(indexPath.row + 1)]];
                break;
        }
        return cell;
    } else {
        FaceGroupMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FaceGroupMemberCellIdentifier" forIndexPath:indexPath];
        if (indexPath.row == [self.memberArray count]) {
            [cell setOpacity:YES];
        } else {
            [cell setUserId:[self.memberArray objectAtIndex:indexPath.row]];
        }
        return cell;
    }
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    // 记录location
    self.location = [locations firstObject];
    [self attamptParticipateInFaceGrop];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.warningLabel setText:@"定位失败，请稍后重试"];
    [self.warningLabel setHidden:NO];
    self.inputEnable = NO;
    self.cipher = @"";
    [self resetNumberLabel];
    [manager stopUpdatingLocation];
}

#pragma mark YYIMChatDelegate

- (void)didParticipateInFaceGrop:(NSString *)faceId cipher:(NSString *)cipher members:(NSArray *)memberIdArray {
    if ([cipher isEqualToString:self.cipher]) {
        // 界面变化
        [self showViewAnimation];
        // 记录faceId
        self.faceId = faceId;
        // 刷新成员
        [self.memberArray addObjectsFromArray:memberIdArray];
        [self.memberView reloadData];
    }
}

- (void)didNotParticipateInFaceGropWithCipher:(NSString *)cipher error:(YYIMError *)error {
    if ([cipher isEqualToString:self.cipher]) {
        [self.warningLabel setText:@"操作失败，请稍后重试"];
        [self.warningLabel setHidden:NO];
        self.inputEnable = NO;
    }
}

- (void)didJoinFaceGroupWithFaceId:(NSString *)faceId groupId:(NSString *)groupId {
    if ([faceId isEqualToString:self.faceId]) {
        ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
        [chatViewController setChatId:groupId];
        [chatViewController setChatType:YM_MESSAGE_TYPE_GROUPCHAT];
        [YYIMUtility pushFromController:self toController:chatViewController];
    }
}

- (void)didNotJoinFaceGroupWithFaceId:(NSString *)faceId error:(YYIMError *)error {
    if ([faceId isEqualToString:self.faceId]) {
        [self showHint:@"加入群失败"];
    }
}

- (void)didUserParticipateInFaceGroupWithFaceId:(NSString *)faceId cipher:(NSString *)cipher userId:(NSString *)userId members:(NSArray *)members {
    if ([faceId isEqualToString:self.faceId] && [cipher isEqualToString:self.cipher]) {
//        if (![self.memberArray containsObject:userId]) {
//            [self.memberArray addObject:userId];
//            [self.memberView reloadData];
//        }
        [self.memberArray removeAllObjects];
        [self.memberArray addObjectsFromArray:members];
        [self.memberView reloadData];
    }
}

- (void)didUserQuitFaceGroupWithFaceId:(NSString *)faceId cipher:(NSString *)cipher userId:(NSString *)userId members:(NSArray *)members {
    if ([faceId isEqualToString:self.faceId] && [cipher isEqualToString:self.cipher]) {
//        if ([self.memberArray containsObject:userId]) {
//            [self.memberArray removeObject:userId];
//            [self.memberView reloadData];
//        }
        [self.memberArray removeAllObjects];
        [self.memberArray addObjectsFromArray:members];
        [self.memberView reloadData];
    }
}

#pragma mark -

- (void)attamptParticipateInFaceGrop{
    if (!self.location) {
        return;
    }
    if ([self.cipher length] != 4) {
        return;
    }
    [self.locationManager stopUpdatingLocation];
    // 参与面对面建群
    CLLocationCoordinate2D coordinate = self.location.coordinate;
    [[YYIMChat sharedInstance].chatManager participateFaceGroupWithCipher:self.cipher longitude:coordinate.longitude latitude:coordinate.latitude];
}

- (void)keyboardInput:(NSInteger)number {
    if (number >= 0 && self.cipher.length <= 3) {
        self.cipher = [NSString stringWithFormat:@"%@%ld", (self.cipher ? self.cipher : @""), (long)number];
    } else if (number < 0 && self.cipher.length > 0) {
        self.cipher = [self.cipher substringToIndex:self.cipher.length - 1];
    }
    [self resetNumberLabel];
    
    if ([self.cipher isEqualToString:@"1111"] || [self.cipher isEqualToString:@"1234"]) {
        __block FaceGroupViewController *bself = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.warningLabel setHidden:NO];
            bself.cipher = @"";
            [bself resetNumberLabel];
        });
    } else {
        [self.warningLabel setHidden:YES];
        if ([self.cipher length] == 4) {
            [self attamptParticipateInFaceGrop];
        }
    }
}

- (void)showViewAnimation {
    [UIView animateKeyframesWithDuration:1.0f delay:0.2f options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [self.navigationItem setTitle:nil];
        [self.warningLabel setHidden:YES];
        [self.promptLabel2 setHidden:NO];
        [self.memberView setHidden:NO];
        [self.enterBtn setHidden:NO];
        
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.2 animations:^{
            [self.promptLabel setAlpha:0];
            [self.keyboardView setAlpha:0];
            [self.promptLabel2 setAlpha:1];
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.6 animations:^{
            CGRect numberViewFrame = self.numberView.frame;
            numberViewFrame.origin.y -= 88.0f;
            [self.numberView setFrame:numberViewFrame];
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.6 animations:^{
            CGRect warningLabelFrame = self.warningLabel.frame;
            warningLabelFrame.origin.y -= 88.0f;
            [self.warningLabel setFrame:warningLabelFrame];
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.6 animations:^{
            CGRect promptLabel2Frame = self.promptLabel2.frame;
            promptLabel2Frame.origin.y -= 88.0f;
            [self.promptLabel2 setFrame:promptLabel2Frame];
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.8 relativeDuration:0.2 animations:^{
            [self.memberView setAlpha:1];
            [self.enterBtn setAlpha:1];
        }];
    } completion:^(BOOL finished) {
        [self.promptLabel setHidden:YES];
        [self.keyboardView setHidden:YES];
    }];
}

- (void)resetNumberLabel {
    for (int i = 0; i < 4; i++) {
        YMHaloLabel *label = [self.numberLabelArray objectAtIndex:i];
        if (i < self.cipher.length) {
            [label setText:[self.cipher substringWithRange:NSMakeRange(i, 1)]];
        } else {
            [label setText:nil];
        }
    }
}

- (void)playSound {
    //    NSURL *url = [NSURL fileURLWithPath:@"/System/Library/Audio/UISounds/Tock.caf"];
    //    if (url) {
    //        SystemSoundID soundID;
    //        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    AudioServicesPlaySystemSound(1103);
    //    }
}

- (CGFloat)baseHeight {
    CGFloat navigationHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    CGFloat statusHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    return navigationHeight + statusHeight;
}

@end

@implementation FaceGroupKeyboardCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initCell];
    }
    return self;
}

- (void)prepareForReuse {
    [self.label setText:nil];
}

- (void)initCell {
    [self setBackgroundColor:[UIColor themeColor]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [label setTextColor:[UIColor darkGrayColor]];
    [label setFont:[UIFont systemFontOfSize:24.0f]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:label];
    self.label = label;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        [self.superview bringSubviewToFront:self];
        [self.layer setMasksToBounds:NO];
        [self.layer setContentsScale:[UIScreen mainScreen].scale];
        [self.layer setShadowColor:[UIColor themeBlueColor].CGColor];
        [self.layer setShadowOpacity:0.8f];
        [self.layer setShadowRadius:6.0f];
        [self.layer setShadowOffset:CGSizeZero];
        [self.layer setShadowPath:[UIBezierPath bezierPathWithRect:CGRectMake(-1, -1, CGRectGetWidth(self.frame) + 2, CGRectGetHeight(self.frame) + 2)].CGPath];
        [self.layer setShouldRasterize:YES];
        [self.layer setRasterizationScale:[UIScreen mainScreen].scale];
    } else {
        [self.layer setShadowColor:[UIColor clearColor].CGColor];
        [self.layer setShadowRadius:0.0f];
    }
}

- (void)setText:(NSString *)text {
    [self.label setText:text];
}

@end

@implementation FaceGroupMemberCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initCell];
    }
    return self;
}

- (void)initCell {
    [self setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [imageView setBackgroundColor:[UIColor clearColor]];
    
    CALayer *layer = [imageView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:(CGRectGetWidth(self.frame) - 1) / 2];
    
    [self addSubview:imageView];
    self.imageView = imageView;
}

- (void)prepareForReuse {
    [self.imageView setImage:nil];
    
    CALayer *layer = [self.imageView layer];
    [layer setBorderWidth:0];
    [layer removeAnimationForKey:@"opacity"];
    [layer removeAnimationForKey:@"movex"];
}

- (void)setUserId:(NSString *)userId {
    YYUser *user = [[YYIMChat sharedInstance].chatManager getUserWithId:userId];
    UIImage *image = [UIImage imageWithDispName:[user userName]];
    if (!image) {
        image = [UIImage imageNamed:@"icon_head"];
    }
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:[user getUserPhoto]] placeholderImage:image options:0];
}

- (void)setOpacity:(BOOL)twinkle {
    if (twinkle) {
        CALayer *layer = [self.imageView layer];
        [layer setBorderColor:[UIColor grayColor].CGColor];
        [layer setBorderWidth:1.0f];
        // 移动的动画。
        [layer addAnimation:[self moveX:2.0f from:[NSNumber numberWithFloat:-CGRectGetWidth(self.frame)]] forKey:@"movex"];
        // 闪烁效果
        [layer addAnimation:[self opacityAnimation:2.0f timeOffset:2.0f] forKey:@"opacity"];
    }
}

#pragma mark Animation

- (CABasicAnimation *)opacityAnimation:(float)time timeOffset:(float)timeOffset {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    animation.autoreverses = YES;
    animation.duration = time;
    animation.timeOffset = timeOffset;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return animation;
}

- (CABasicAnimation *)moveX:(float)time from:(NSNumber *)x {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.fromValue = x;
    animation.duration = time;
    animation.removedOnCompletion = NO;
    animation.repeatCount = 1;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    return animation;
}

@end