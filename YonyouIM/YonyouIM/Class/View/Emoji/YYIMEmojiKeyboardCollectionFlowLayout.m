//
//  YYIMEmojiKeyboardCollectionFlowLayout.m
//  YonyouIM
//
//  Created by litfb on 15/1/15.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMEmojiKeyboardCollectionFlowLayout.h"
#import "YYIMEmojiKeyboardKeyGroup.h"
#import "YYIMEmojiDefs.h"

@interface YYIMEmojiKeyboardCollectionFlowLayout ()

@property (nonatomic, readwrite) CGSize itemSize;
@property (nonatomic, readwrite) CGFloat lineSpacing;
@property (nonatomic, readwrite) CGFloat itemSpacing;
@property (nonatomic, readwrite) UIEdgeInsets pageContentInsets;

@property (nonatomic, readonly) NSInteger numberOfItems;
@property (nonatomic, readonly) CGSize pageSize;

@property (nonatomic, readonly) NSInteger numberOfItemsPerPage;
@property (nonatomic, readonly) NSInteger numberOfRowsPerPage;
@property (nonatomic, readonly) NSInteger numberOfItemsPerRow;
@property (nonatomic, readonly) CGSize avaliableSizePerPage;

@end

@implementation YYIMEmojiKeyboardCollectionFlowLayout

- (instancetype)init {
    if (self = [super init]) {
        CGFloat edgeX = kYYIMEmojiKeyboardDefaultWidth - kYYIMEmojiKeyboardItemSide * kYYIMEmojiKeyboardColNumber - kYYIMEmojiKeyboardItemSpacing * (kYYIMEmojiKeyboardColNumber - 1);
        CGFloat edgeY = kYYIMEmojiKeyboardKeyItemGroupHeight - kYYIMEmojiKeyboardItemSide * kYYIMEmojiKeyboardRowNumber - kYYIMEmojiKeyboardLineSpacing * (kYYIMEmojiKeyboardRowNumber - 1);
        self.pageContentInsets = UIEdgeInsetsMake(edgeY, edgeX / 2, 0, edgeX / 2);
    }
    return self;
}

- (CGSize)itemSize {
    return CGSizeMake(kYYIMEmojiKeyboardItemSide, kYYIMEmojiKeyboardItemSide);
}

- (CGFloat)lineSpacing {
    return kYYIMEmojiKeyboardLineSpacing;
}

- (CGFloat)itemSpacing {
    return kYYIMEmojiKeyboardItemSpacing;
}

- (NSInteger)numberOfItems {
    NSInteger section = 0;
    NSInteger numberOfItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:section];
    return numberOfItems;
}

- (CGSize)pageSize {
    return self.collectionView.bounds.size;
}

- (CGSize)avaliableSizePerPage {
    return (CGSize){
        self.pageSize.width - self.pageContentInsets.left - self.pageContentInsets.right,
        self.pageSize.height - self.pageContentInsets.top - self.pageContentInsets.bottom
    };
}

- (NSInteger)numberOfItemsPerRow {
    return kYYIMEmojiKeyboardColNumber;
}

- (NSInteger)numberOfRowsPerPage {
    return kYYIMEmojiKeyboardRowNumber;
}

- (NSInteger)numberOfItemsPerPage {
    return kYYIMEmojiKeyboardItemsPerPage - 1;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (CGSizeEqualToSize(self.collectionView.bounds.size, newBounds.size)) {
        return NO;
    } else {
        return YES;
    }
}

- (void)prepareLayout {
    //We do nothing...
}

- (CGSize)collectionViewContentSize {
    CGFloat width = ceil((float)self.numberOfItems/self.numberOfItemsPerPage) * self.pageSize.width;
    CGFloat height = self.pageSize.height;
    return CGSizeMake(width, height);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    NSInteger page = floor((float)index/self.numberOfItemsPerPage);
    NSInteger row  = floor((float)(index % self.numberOfItemsPerPage)/self.numberOfItemsPerRow);
    NSInteger n    = (index % self.numberOfItemsPerPage) % self.numberOfItemsPerRow;
    CGRect frame;
    if (row == self.numberOfRowsPerPage - 1 && n == self.numberOfItemsPerRow - 2) {
        frame = (CGRect){
            {page * self.pageSize.width + self.pageContentInsets.left + n*(self.itemSize.width + self.itemSpacing),
                self.pageContentInsets.top + row*(self.itemSize.height + self.lineSpacing)},
            CGSizeMake(kYYIMEmojiKeyboardItemSide * 2 + kYYIMEmojiKeyboardItemSpacing, kYYIMEmojiKeyboardItemSide)
        };
    } else {
        frame = (CGRect){
            {page * self.pageSize.width + self.pageContentInsets.left + n*(self.itemSize.width + self.itemSpacing),
                self.pageContentInsets.top + row*(self.itemSize.height + self.lineSpacing)},
            self.itemSize
        };
    }
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = frame;
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < self.numberOfItems; i++){
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [array addObject:attributes];
        }
    }
    return [array copy];
}

@end
