//
//  YMMessageExtendView.m
//  YonyouIM
//
//  Created by litfb on 15/6/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YMMessageExtendView.h"
#import "YMMessageExtendViewCell.h"
#import "YMMessageExtendLayout.h"
#import "UIColor+YYIMTheme.h"

CGFloat const kYMMessageExtendViewDefaultHeight = 216.0f;

@interface YMMessageExtendView ()

@property (retain, nonatomic) UICollectionView *collectionView;

@property (retain, nonatomic) UIPageControl *pageControl;

@property (retain, nonatomic) NSArray *itemsArray;

@end

@implementation YMMessageExtendView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    [self setBackgroundColor:[UIColor f9GrayColor]];
    
    UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 1)];
    [sepView setBackgroundColor:[UIColor edGrayColor]];
    [sepView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
    [self addSubview:sepView];
    
    // collectionViewFlowLayout
    YMMessageExtendLayout *extendLayout = [[YMMessageExtendLayout alloc] init];
    [extendLayout setItemSize:CGSizeMake(CGRectGetWidth([[UIScreen mainScreen] bounds]) / 4, (CGRectGetHeight(self.frame) - 24) / 2)];
    
    // collectionView
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - 24.0f) collectionViewLayout:extendLayout];
    [collectionView setBackgroundColor:[UIColor clearColor]];
    [collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [collectionView registerNib:[UINib nibWithNibName:@"YMMessageExtendViewCell" bundle:nil] forCellWithReuseIdentifier:@"YMMessageExtendViewCell"];
    [collectionView setShowsHorizontalScrollIndicator:NO];
    [collectionView setShowsVerticalScrollIndicator:NO];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    
    // pageControl
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 24.0f, CGRectGetWidth(self.frame), 24.0f)];
    pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    pageControl.userInteractionEnabled = NO;
    pageControl.hidesForSinglePage = YES;
    [pageControl setPageIndicatorTintColor:[UIColor whiteColor]];
    [pageControl setCurrentPageIndicatorTintColor:[UIColor lightGrayColor]];
    [self addSubview:pageControl];
    self.pageControl = pageControl;
}

- (void)setExtendItems:(NSArray *)extendItems {
    self.itemsArray = extendItems;
    [self.collectionView reloadData];
}

#pragma mark collectionView delegate

- (void)refreshPageControl {
    self.pageControl.numberOfPages = ceil(self.collectionView.contentSize.width / CGRectGetWidth(self.collectionView.bounds));
    self.pageControl.currentPage = floor(self.collectionView.contentOffset.x / CGRectGetWidth(self.collectionView.bounds));
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self refreshPageControl];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshPageControl];
    });
    return self.itemsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YMMessageExtendViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YMMessageExtendViewCell" forIndexPath:indexPath];
    YMMessageExtendViewItem *item = [self.itemsArray objectAtIndex:indexPath.row];
    [cell setIconWithImageName:[item icon]];
    [cell setName:[item name]];
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    YMMessageExtendViewItem *item = [self.itemsArray objectAtIndex:indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectExtendItem:atIndex:)]) {
        [self.delegate didSelectExtendItem:item atIndex:indexPath.row];
    }
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

@end

@implementation YMMessageExtendViewItem

+ (instancetype)itemWithIdentifer:(NSString *)identifer icon:(NSString *)icon name:(NSString *)name {
    YMMessageExtendViewItem *item = [[YMMessageExtendViewItem alloc] init];
    [item setIdentifer:identifer];
    [item setIcon:icon];
    [item setName:name];
    return item;
}

@end
