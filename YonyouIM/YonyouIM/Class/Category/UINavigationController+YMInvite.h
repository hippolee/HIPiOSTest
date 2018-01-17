//
//  UINavigationController+YMInvite.h
//  YonyouIM
//
//  Created by litfb on 15/5/7.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMInviteDelegate;

@interface UINavigationController (YMInvite)

- (void)setInviteDelegate:(id<YMInviteDelegate>)delegate;

- (void)setUserSelectState:(NSString *)userId info:(id)userObject isSelect:(BOOL)isSelect;

- (NSMutableArray *)selectedUserArray;

- (void)generateToolbar;

- (BOOL)isUserSelected:(NSString *)userId;

- (void)setDisableUserIdArray:(NSArray *)userIdArray;

- (BOOL)isUserDisabled:(NSString *)userId;

- (void)clearData;

@end

@protocol YMInviteDelegate <NSObject>

@optional

- (void)didSelectChangeWithCount:(NSInteger)count;

- (NSString *)headImageUrlWithUserObj:(id)userObj;

- (NSString *)userNameWithUserObj:(id)userObj;

- (void)didUserUnSelect:(NSString *)userId withObject:(id)userObj;

@end

@interface UIToolbar (YMInvite)

@end

@interface YMInviteCollectionViewDataSource : NSObject<UICollectionViewDataSource, UICollectionViewDelegate>

@property (retain, nonatomic) UINavigationController *navController;

- (instancetype)initWithNavController:(UINavigationController *)navController;

@end