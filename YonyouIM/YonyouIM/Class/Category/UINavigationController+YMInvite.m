//
//  UINavigationController+YMInvite.m
//  YonyouIM
//
//  Created by litfb on 15/5/7.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "UINavigationController+YMInvite.h"
#import "UIColor+YYIMTheme.h"
#import "InviteUserCollectionViewCell.h"
#import "YYRoster.h"
#import "YYUser.h"
#import "YYChatGroupMember.h"
#import <objc/runtime.h>

static const void *objInviteDelegateKey = &objInviteDelegateKey;
static const void *objSelectedUserArrayKey = &objSelectedUserArrayKey;
static const void *objSelectedUserDicKey = &objSelectedUserDicKey;
static const void *objDisabledUserArrayKey = &objDisabledUserArrayKey;
static const void *objCollectionViewKey = &objCollectionViewKey;
static const void *objDataSourceKey = &objDataSourceKey;

@implementation UINavigationController (YMInvite)

- (void)setInviteDelegate:(id<YMInviteDelegate>)delegate {
    objc_setAssociatedObject(self, objInviteDelegateKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<YMInviteDelegate>)inviteDelegate {
    return objc_getAssociatedObject(self, objInviteDelegateKey);
}

- (NSMutableArray *)selectedUserArray {
    NSMutableArray *array = objc_getAssociatedObject(self, objSelectedUserArrayKey);
    if (!array) {
        array = [NSMutableArray array];
        objc_setAssociatedObject(self, objSelectedUserArrayKey, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return array;
}

- (NSMutableDictionary *)selectedUserDic {
    NSMutableDictionary *dic = objc_getAssociatedObject(self, objSelectedUserDicKey);
    if (!dic) {
        dic = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, objSelectedUserDicKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dic;
}

- (NSMutableArray *)disabledUserArray {
    NSMutableArray *array = objc_getAssociatedObject(self, objDisabledUserArrayKey);
    if (!array) {
        array = [NSMutableArray array];
        objc_setAssociatedObject(self, objDisabledUserArrayKey, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return array;
}

- (void)setUserSelectState:(NSString *)userId info:(id)userObject isSelect:(BOOL)isSelect {
    if (!userObject) {
        userObject = userId;
    }
    NSMutableArray *array = [self selectedUserArray];
    NSMutableDictionary *dic = [self selectedUserDic];
    if (isSelect) {
        if ([self isUserSelected:userId]) {
            [array removeObject:[dic objectForKey:userId]];
            [dic removeObjectForKey:userId];
        }
        [array addObject:userObject];
        [dic setObject:userObject forKey:userId];
    } else {
        [array removeObject:[dic objectForKey:userId]];
        [dic removeObjectForKey:userId];
    }
    [self generateToolbar];
    [[self inviteDelegate] didSelectChangeWithCount:array.count];
}

- (void)generateToolbar {
    NSMutableArray *array = [self selectedUserArray];
    [[self toolbarCollectionView] reloadData];
    if (array.count > 0) {
        [[self toolbarCollectionView] scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self selectedUserArray].count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        [self setToolbarHidden:NO animated:YES];
    } else {
        [self setToolbarHidden:YES animated:YES];
    }
}

- (BOOL)isUserSelected:(NSString *)userId {
    return [[[self selectedUserDic] allKeys] containsObject:userId];
}

- (void)setDisableUserIdArray:(NSArray *)userIdArray {
    [[self disabledUserArray] removeAllObjects];
    [[self disabledUserArray] addObjectsFromArray:userIdArray];
}

- (BOOL)isUserDisabled:(NSString *)userId {
    return [[self disabledUserArray] containsObject:userId];
}

- (void)clearData {
    [[self selectedUserArray] removeAllObjects];
    [[self selectedUserDic] removeAllObjects];
    [[self disabledUserArray] removeAllObjects];
    [self generateToolbar];
}

- (UICollectionView *)toolbarCollectionView {
    UICollectionView *collectionView = objc_getAssociatedObject(self, objCollectionViewKey);
    if (!collectionView) {
        // collectionView
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setItemSize:CGSizeMake(36.0f, 36.0f)];
        [flowLayout setMinimumLineSpacing:4.0f];
        [flowLayout setMinimumInteritemSpacing:0.0f];
        [flowLayout setSectionInset:UIEdgeInsetsMake(4.0f, 8.0f, 4.0f, 8.0f)];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.toolbar.frame), CGRectGetHeight(self.toolbar.frame)) collectionViewLayout:flowLayout];
        [collectionView setBackgroundColor:[UIColor edGrayColor]];
        [collectionView setDataSource:[self dataSource]];
        [collectionView setDelegate:[self dataSource]];
        [collectionView registerNib:[UINib nibWithNibName:@"InviteUserCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"InviteUserCollectionViewCell"];
        [collectionView setShowsHorizontalScrollIndicator:YES];
        [collectionView setShowsVerticalScrollIndicator:NO];
        
        [self.toolbar addSubview:collectionView];
        objc_setAssociatedObject(self, objCollectionViewKey, collectionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return collectionView;
}

- (YMInviteCollectionViewDataSource *)dataSource {
    YMInviteCollectionViewDataSource *dataSource = objc_getAssociatedObject(self, objDataSourceKey);
    if (!dataSource) {
        dataSource = [[YMInviteCollectionViewDataSource alloc] initWithNavController:self];
        objc_setAssociatedObject(self, objDataSourceKey, dataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dataSource;
}

@end

@implementation YMInviteCollectionViewDataSource

- (instancetype)initWithNavController:(UINavigationController *)navController {
    if (self = [super init]) {
        self.navController = navController;
    }
    return self;
}

#pragma mark collection delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.navController selectedUserArray].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id userObj = [[self.navController selectedUserArray] objectAtIndex:indexPath.row];
    
    NSString *headImageUrl;
    id<YMInviteDelegate> delegate = [self.navController inviteDelegate];
    if (delegate && [delegate respondsToSelector:@selector(headImageUrlWithUserObj:)]) {
        headImageUrl = [delegate headImageUrlWithUserObj:userObj];
    } else {
        headImageUrl = [self defaultHeadImageWithUserObj:userObj];
    }
    
    NSString *name;
    if (delegate && [delegate respondsToSelector:@selector(userNameWithUserObj:)]) {
        name = [delegate userNameWithUserObj:userObj];
    } else {
        name = [self defaultUserNameWithUserObj:userObj];
    }
    
    InviteUserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"InviteUserCollectionViewCell" forIndexPath:indexPath];
    [cell setHeadImageWithUrl:headImageUrl placeholderName:name];
    [cell setRoundCorner:17.0f];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id userObj = [[self.navController selectedUserArray] objectAtIndex:indexPath.row];
    NSArray *userIdArray = [[self.navController selectedUserDic] allKeysForObject:userObj];
    if (userIdArray && userIdArray.count > 0) {
        NSString *userId = [userIdArray objectAtIndex:0];
        [self.navController setUserSelectState:userId info:userObj isSelect:NO];
        id<YMInviteDelegate> delegate = [self.navController inviteDelegate];
        if (delegate && [delegate respondsToSelector:@selector(didUserUnSelect:withObject:)]) {
            [delegate didUserUnSelect:userId withObject:userObj];
        }
    }
}

- (NSString *)defaultHeadImageWithUserObj:(id)userObj {
    NSString *imageUrl;
    if ([userObj isKindOfClass:[YYRoster class]]) {
        imageUrl = [(YYRoster *)userObj getRosterPhoto];
    } else if ([userObj isKindOfClass:[YYUser class]]) {
        imageUrl = [(YYUser *)userObj getUserPhoto];
    } else if ([userObj isKindOfClass:[YYChatGroupMember class]]) {
        imageUrl = [(YYChatGroupMember *)userObj getMemberPhoto];
    }
    
    return imageUrl;
}

- (NSString *)defaultUserNameWithUserObj:(id)userObj {
    NSString *name;
    if ([userObj isKindOfClass:[YYRoster class]]) {
        name = [(YYRoster *)userObj rosterAlias];
    } else if ([userObj isKindOfClass:[YYUser class]]) {
        name = [(YYUser *)userObj userName];
    } else if ([userObj isKindOfClass:[YYChatGroupMember class]]) {
        name = [(YYChatGroupMember *)userObj memberName];
    }
    
    return name;
}
@end

@implementation UIToolbar (YMInvite)

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize result = [super sizeThatFits:size];
    result.height = 46;
    return result;
}

@end
