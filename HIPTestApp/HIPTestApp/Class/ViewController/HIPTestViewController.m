//
//  HIPTestViewController.m
//  litfb_test
//
//  Created by litfb on 16/1/14.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPTestViewController.h"
#import "HIPScanBoxView.h"
#import "ZXingObjC.h"

#define kScrollPadding 10

@interface HIPTestViewController ()<UIActionSheetDelegate>
// <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) UICollectionView *collectionView;

@end

@implementation HIPTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"TEST"];
    
    [self initView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initView {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 200, 60)];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"TestActionSheet" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:btn];
//    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
//    [layout setMinimumLineSpacing:10.0f];
//    [layout setMinimumInteritemSpacing:0.0f];
//    [layout setItemSize:CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
//    @property (nonatomic) CGSize headerReferenceSize;
//    @property (nonatomic) CGSize footerReferenceSize;
//    @property (nonatomic) UIEdgeInsets sectionInset;
//    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
//    [collectionView registerClass:<#(nullable Class)#> forCellWithReuseIdentifier:<#(nonnull NSString *)#>]
//    [self.view addSubview:collectionView];
//    self.collectionView = collectionView;
}

- (void)btnAction:(id)sender {
//    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"other1"];
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor yellowColor], NSForegroundColorAttributeName, nil];
//    [attrString setAttributes:dic range:NSMakeRange(0, attrString.length)];
    NSString *str1 = @"other1";
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"title" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:@"destructive" otherButtonTitles:str1, @"other2", @"other3", nil];
    [sheet showInView:self.view];
}

#pragma mark UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)actionSheetCancel:(UIActionSheet *)actionSheet {

}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (UIView *subView in actionSheet.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subView;
            label.font = [UIFont systemFontOfSize:16];
            label.textColor = [UIColor greenColor];
            label.frame = CGRectMake(CGRectGetMinX(label.frame), CGRectGetMinY(label.frame), CGRectGetWidth(label.frame), CGRectGetHeight(label.frame)+20);
        }
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)subView;
//            if ([button.titleLabel.text isEqualToString:@"确定"]) {
//                [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//            } else {
//                
//            }
            [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:18];
        }
    }
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {
    for (UIView *subView in actionSheet.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subView;
            label.font = [UIFont systemFontOfSize:16];
            label.textColor = [UIColor greenColor];
            label.frame = CGRectMake(CGRectGetMinX(label.frame), CGRectGetMinY(label.frame), CGRectGetWidth(label.frame), CGRectGetHeight(label.frame)+20);
        }
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)subView;
            //            if ([button.titleLabel.text isEqualToString:@"确定"]) {
            //                [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            //            } else {
            //
            //            }
            [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:18];
        }
    }
}


#pragma mark UICollectionViewDelegate, UICollectionViewDataSource



@end
