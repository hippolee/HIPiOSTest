//
//  YYIMEmojiKeyboardKeyGroupView.m
//  YonyouIM
//
//  Created by litfb on 15/1/15.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMEmojiKeyboardKeyGroupView.h"
#import "YYIMEmojiKeyboardCell.h"
#import "UIColor+YYIMTheme.h"
#import "YYIMEmojiDefs.h"
#import "YYIMEmojiKeyboardCollectionFlowLayout.h"

@interface YYIMEmojiKeyboardKeyGroupView () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,weak) UICollectionView *collectionView;
@property (nonatomic,weak) UIPageControl *pageControl;
@property (nonatomic,weak) YYIMEmojiKeyboardCell *lastPressedCell;
@property (nonatomic,weak) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@implementation YYIMEmojiKeyboardKeyGroupView

- (void)setKeyItemGroup:(YYIMEmojiKeyboardKeyGroup *)keyItemGroup {
    _keyItemGroup = keyItemGroup;
    
    if (self.keyItemGroup.keyItemCellClass == [YYIMEmojiKeyboardCell class]) {
        UINib *collnib=[UINib nibWithNibName:@"YYIMEmojiKeyboardCell" bundle:nil];
        [self.collectionView registerNib:collnib forCellWithReuseIdentifier:@"YYIMEmojiKeyboardCell"];
    } else {
        [self.collectionView registerClass:self.keyItemGroup.keyItemCellClass forCellWithReuseIdentifier:NSStringFromClass(self.keyItemGroup.keyItemCellClass)];
    }
    [self.collectionView reloadData];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // pageControl
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - kYYIMEmojiKeyboardKeyItemGroupViewPageControlHeight, CGRectGetWidth(self.bounds), kYYIMEmojiKeyboardKeyItemGroupViewPageControlHeight)];
        pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        pageControl.userInteractionEnabled = NO;
        pageControl.hidesForSinglePage = YES;
        [pageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
        [pageControl setCurrentPageIndicatorTintColor:[UIColor themeBlueColor]];
        [self addSubview:pageControl];
        self.pageControl = pageControl;
        
        // collectionView
        YYIMEmojiKeyboardCollectionFlowLayout *layout = [[YYIMEmojiKeyboardCollectionFlowLayout alloc] init];
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kYYIMEmojiKeyboardKeyItemGroupViewPageControlHeight) collectionViewLayout:layout];
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.pagingEnabled = YES;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewLongPress:)];
        longPressGestureRecognizer.minimumPressDuration = 0.08;
        [self.collectionView addGestureRecognizer:longPressGestureRecognizer];
        self.longPressGestureRecognizer = longPressGestureRecognizer;
    }
    return self;
}

- (void)reloadEmojiData {
    [self.collectionView reloadData];
}

#pragma mark - Long Press

- (void)collectionViewLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint touchedLocation = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *__block touchedIndexPath = [NSIndexPath indexPathForItem:NSNotFound inSection:NSNotFound];
    [self.collectionView.indexPathsForVisibleItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = obj;
        if (CGRectContainsPoint([[self.collectionView layoutAttributesForItemAtIndexPath:indexPath] frame], touchedLocation)) {
            touchedIndexPath = indexPath;
            *stop = YES;
        }
    }];
    
    if (touchedIndexPath.item == NSNotFound || gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.pressedKeyItemCellChangedBlock) {
            self.pressedKeyItemCellChangedBlock(self.lastPressedCell,nil);
        }
        [self.lastPressedCell setSelected:NO];
        self.lastPressedCell = nil;
        
        if (touchedIndexPath.item != NSNotFound) {
            YYIMEmojiKeyboardCell *pressedCell = (YYIMEmojiKeyboardCell *)[self.collectionView cellForItemAtIndexPath:touchedIndexPath];
            if ([pressedCell isBack]) {
                if (self.backspaceButtonTappedBlock) {
                    self.backspaceButtonTappedBlock();
                }
            } else if ([pressedCell isSend]) {
                if (self.keyboardWillReturnBlock) {
                    self.keyboardWillReturnBlock();
                }
            } else {
                NSInteger index = [self getRealIndex:touchedIndexPath];
                YYIMEmojiItem *tappedKeyItem = self.keyItemGroup.keyItems[index];
                if (self.keyItemTappedBlock) {
                    self.keyItemTappedBlock(tappedKeyItem);
                }
            }
        }
    } else {
        [self.lastPressedCell setSelected:NO];
        YYIMEmojiKeyboardCell *pressedCell = (YYIMEmojiKeyboardCell *)[self.collectionView cellForItemAtIndexPath:touchedIndexPath];
        [pressedCell setSelected:YES];
        
        if (self.pressedKeyItemCellChangedBlock) {
            self.pressedKeyItemCellChangedBlock(self.lastPressedCell, pressedCell);
        }
        self.lastPressedCell = pressedCell;
    }
}


#pragma mark - CollectionView Delegate & DataSource

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
    CGFloat count = self.keyItemGroup.keyItems.count;
    
    return ceil(count / (kYYIMEmojiKeyboardItemsPerPage - 2)) * (kYYIMEmojiKeyboardItemsPerPage - 1);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YYIMEmojiKeyboardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(self.keyItemGroup.keyItemCellClass) forIndexPath:indexPath];
    if ([self isBackIndexPath:indexPath]) {
        cell.keyItem = nil;
        cell.isBack = YES;
    } else if ([self isSendIndexPath:indexPath]) {
        cell.keyItem = nil;
        cell.isSend = YES;
    } else if ([self isEmptyIndexPath:indexPath]) {
        cell.keyItem = nil;
        cell.isBack = NO;
    } else {
        NSInteger index = [self getRealIndex:indexPath];
        cell.keyItem = self.keyItemGroup.keyItems[index];
        cell.isBack = NO;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if ([self isBackIndexPath:indexPath]) {
        if (self.backspaceButtonTappedBlock) {
            self.backspaceButtonTappedBlock();
        }
    } else if ([self isSendIndexPath:indexPath]) {
        if (self.keyboardWillReturnBlock) {
            self.keyboardWillReturnBlock();
        }
    } else if ([self isEmptyIndexPath:indexPath]) {
        return;
    } else {
        NSInteger index = [self getRealIndex:indexPath];
        YYIMEmojiItem *tappedKeyItem = self.keyItemGroup.keyItems[index];
        if (self.keyItemTappedBlock) {
            self.keyItemTappedBlock(tappedKeyItem);
        }
    }
}

#pragma mark -

- (BOOL)isBackIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % (kYYIMEmojiKeyboardItemsPerPage - 1) == kYYIMEmojiKeyboardColNumber * (kYYIMEmojiKeyboardRowNumber - 1) - 1) {
        return YES;
    }
    return NO;
}

- (BOOL)isEmptyIndexPath:(NSIndexPath *)indexPath {
    if ([self isBackIndexPath:indexPath]) {
        return NO;
    }
    
    if ([self isSendIndexPath:indexPath]) {
        return NO;
    }
    
    NSInteger count = self.keyItemGroup.keyItems.count;
    NSInteger realIndex = [self getRealIndex:indexPath];
    if (realIndex >= count) {
        return YES;
    }
    return NO;
}

- (BOOL)isSendIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % (kYYIMEmojiKeyboardItemsPerPage - 1) == kYYIMEmojiKeyboardItemsPerPage - 2) {
        return YES;
    }
    return NO;
}

- (NSInteger)getRealIndex:(NSIndexPath *)indexPath {
    NSInteger numberPerPage = kYYIMEmojiKeyboardItemsPerPage - 3;
    NSInteger baseIndex = floorf(indexPath.row / (kYYIMEmojiKeyboardItemsPerPage - 1)) * numberPerPage;
    NSInteger offset = indexPath.row % (kYYIMEmojiKeyboardItemsPerPage - 1);
    NSInteger backIndex = kYYIMEmojiKeyboardColNumber * (kYYIMEmojiKeyboardRowNumber - 1) - 1;
    NSInteger realIndex = baseIndex + (offset > backIndex ? (offset - 1) : offset);
    return realIndex;
}

@end
