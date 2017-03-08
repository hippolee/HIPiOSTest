//
//  HIPStackMenu.m
//  litfb_test
//
//  Created by litfb on 16/5/19.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPStackMenu.h"

const static CGFloat                   kStackMenuDefaultItemsSpacing           = 6.0f;
const static HIPStackMenuDirection     kStackMenuDefaultDirection              = HIPStackMenuDirectionUp;
const static HIPStackMenuAnimationType kStackMenuDefaultAnimationType          = HIPStackMenuAnimationTypeLinear;
const static BOOL                      kStackMenuDefaultBounce                 = YES;
const static NSTimeInterval            kStackMenuDefaultOpenAnimationDuration  = 0.4;
const static NSTimeInterval            kStackMenuDefaultCloseAnimationDuration = 0.4;
const static NSTimeInterval            kStackMenuDefaultOpenAnimationOffset    = 0.0;
const static NSTimeInterval            kStackMenuDefaultCloseAnimationOffset   = 0.0;

@interface HIPStackMenu ()

@property (nonatomic) CGPoint centerPoint;

@property (nonatomic) CGFloat baseWidth;

@property (nonatomic) CGFloat baseHeight;

@property (nonatomic) NSUInteger currentIndex;

@property (nonatomic) NSUInteger animatedItemTag;

@property (nonatomic) BOOL isAnimating;

@property (readwrite, nonatomic) BOOL isOpen;

@end

@implementation HIPStackMenu

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray<HIPStackMenuItem *> *)items {
    if (self = [super initWithFrame:frame]) {
        _baseWidth = CGRectGetWidth(frame);
        _baseHeight = CGRectGetHeight(frame);
        _centerPoint = CGPointMake(frame.origin.x + _baseWidth / 2, frame.origin.y + _baseHeight / 2);
        _currentIndex = 0;
        
        _itemsSpacing = kStackMenuDefaultItemsSpacing;
        _direction = kStackMenuDefaultDirection;
        _animationType = kStackMenuDefaultAnimationType;
        _bounce = kStackMenuDefaultBounce;
        _openAnimationDuration = kStackMenuDefaultOpenAnimationDuration;
        _closeAnimationDuration = kStackMenuDefaultCloseAnimationDuration;
        _openAnimationOffset = kStackMenuDefaultOpenAnimationOffset;
        _closeAnimationOffset  = kStackMenuDefaultCloseAnimationOffset;
        
        _items = [NSMutableArray new];
        if (items) {
            [self addItems:items];
        }
    }
    return self;
}

- (void)addItem:(HIPStackMenuItem *)item {
    [item addTarget:self action:@selector(itemSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    NSUInteger idx = [_items count];
    if (idx == _currentIndex) {
        [item setHidden:NO];
        [item setSelected:YES];
    } else {
        [item setHidden:YES];
        [item setSelected:NO];
    }
    [_items addObject:item];
    [item setFrame:CGRectMake(0, 0, _baseWidth, _baseHeight)];
    [self addSubview:item];
}

- (void)addItems:(NSArray<HIPStackMenuItem *> *)items {
    [items enumerateObjectsUsingBlock:^(HIPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
        [self addItem:item];
    }];
}

- (void)removeItem:(HIPStackMenuItem *)item {
    if(![_items containsObject:item]) {
        return;
    }
    
    [_items removeObject:item];
    [item removeFromSuperview];
}

- (void)removeItemAtIndex:(NSUInteger)index {
    if (index >= [_items count]) {
        return;
    }
    
    HIPStackMenuItem *item = [_items objectAtIndex:index];
    [self removeItem:item];
}

- (void)removeAllItems {
    [_items enumerateObjectsUsingBlock:^(HIPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
        [self removeItem:item];
    }];
}

- (NSArray *)menuItems {
    return [NSArray arrayWithArray:_items];
}

- (void)openMenu {
    if (_isAnimating || _isOpen) {
        return;
    }
    
    if ([_items count] <= 0) {
        return;
    }
    
    _isAnimating = YES;
    _animatedItemTag = 0;
    
    if (_delegate && [_delegate respondsToSelector:@selector(stackMenuWillOpen:)]) {
        [_delegate stackMenuWillOpen:self];
    }
    
    NSUInteger itemsCount = [_items count];
    CGFloat totalHeight = _baseHeight * itemsCount + _itemsSpacing * (itemsCount - 1);
    CGRect openFrame;
    CGPoint referPoint;
    switch (_direction) {
        case HIPStackMenuDirectionDown:
            openFrame = CGRectMake(_centerPoint.x - _baseWidth / 2, _centerPoint.y - _baseHeight / 2, _baseWidth, totalHeight);
            referPoint = CGPointMake(_baseWidth/ 2, _baseHeight / 2);
            break;
        default:
            openFrame = CGRectMake(_centerPoint.x - _baseWidth / 2, _centerPoint.y - totalHeight + _baseHeight / 2, _baseWidth, totalHeight);
            referPoint = CGPointMake(_baseWidth / 2, totalHeight - _baseHeight / 2);
            break;
    }
    [self setFrame:openFrame];
    
    [_items enumerateObjectsUsingBlock:^(HIPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
        [item setFrame:CGRectMake(referPoint.x - _baseWidth / 2, referPoint.y - _baseHeight / 2, _baseWidth, _baseHeight)];
        
        NSUInteger realIndex = idx;
        if (idx == _currentIndex) {
            realIndex = 0;
        } else if (idx < _currentIndex) {
            realIndex = realIndex + 1;
        }
        
        NSTimeInterval duration;
        switch (_animationType) {
            case HIPStackMenuAnimationTypeProgressive:
                duration = (realIndex * _openAnimationDuration) / itemsCount;
                break;
            case HIPStackMenuAnimationTypeProgressiveInverse:
                duration = ((itemsCount - realIndex) * _openAnimationDuration) / itemsCount;
                break;
            default:
                duration = _openAnimationDuration;
                break;
        }
        
        CGPoint targetCenter;
        switch (_direction) {
            case HIPStackMenuDirectionDown:
                targetCenter = CGPointMake(referPoint.x, referPoint.y + realIndex * (_baseHeight + _itemsSpacing));
                break;
            default:
                targetCenter = CGPointMake(referPoint.x, referPoint.y - realIndex * (_baseHeight + _itemsSpacing));
                break;
        }
        
        [self moveItem:item toCenter:targetCenter withDuration:duration delay:(realIndex * _openAnimationOffset) isOpening:YES];
    }];
    
    _isOpen = YES;
}

- (void)closeMenu {
    if (_isAnimating || !_isOpen) {
        return;
    }
    
    if ([_items count] <= 0) {
        return;
    }
    
    _isAnimating = YES;
    _animatedItemTag = 0;
    
    if (_delegate && [_delegate respondsToSelector:@selector(stackMenuWillClose:)]) {
        [_delegate stackMenuWillClose:self];
    }
    
    NSUInteger itemsCount = [_items count];
    CGFloat totalHeight = _baseHeight * itemsCount + _itemsSpacing * (itemsCount - 1);
    CGPoint referPoint;
    switch (_direction) {
        case HIPStackMenuDirectionDown:
            referPoint = CGPointMake(_baseWidth / 2, _baseHeight / 2);
            break;
        default:
            referPoint = CGPointMake(_baseWidth / 2, totalHeight - _baseHeight / 2);
            break;
    }
    
    [_items enumerateObjectsUsingBlock:^(HIPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
        NSUInteger realIndex = idx;
        if (idx == _currentIndex) {
            realIndex = 0;
        } else if (idx < _currentIndex) {
            realIndex = realIndex + 1;
        }
        
        NSTimeInterval duration;
        switch (_animationType) {
            case HIPStackMenuAnimationTypeProgressive:
                duration = (realIndex * _closeAnimationDuration) / itemsCount;
                break;
            case HIPStackMenuAnimationTypeProgressiveInverse:
                duration = ((itemsCount - realIndex) * _closeAnimationDuration) / itemsCount;
                break;
            default:
                duration = _closeAnimationDuration;
                break;
        }
        
        [self moveItem:item toCenter:referPoint withDuration:duration delay:(realIndex * _closeAnimationOffset) isOpening:NO];
    }];
    
    _isOpen = NO;
}

- (void)toggleMenu {
    if (_isOpen) {
        [self closeMenu];
    } else {
        [self openMenu];
    }
}

- (void)moveItem:(HIPStackMenuItem *)item toCenter:(CGPoint)center withDuration:(NSTimeInterval)duration delay:(CGFloat)delay isOpening:(BOOL)isOpening {
    [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        NSUInteger idx = [_items indexOfObject:item];
        
        if (isOpening) {
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.2 animations:^{
                [item setHidden:NO];
            }];
        }
        
        if (_bounce) {
            CGFloat bounceOffset;
            switch (_direction) {
                case HIPStackMenuDirectionDown:
                    bounceOffset = _itemsSpacing;
                    break;
                default:
                    bounceOffset = _itemsSpacing * -1;
                    break;
            }
            
            if (idx != _currentIndex) {
                if (isOpening) {
                    CGPoint farCenter = CGPointMake(center.x, center.y + bounceOffset);
                    CGPoint nearCenter = CGPointMake(center.x, center.y - (bounceOffset / 2));
                    
                    [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.8 animations:^{
                        item.center = farCenter;
                    }];
                    
                    [UIView addKeyframeWithRelativeStartTime:0.8 relativeDuration:0.1 animations:^{
                        item.center = nearCenter;
                    }];
                    
                    [UIView addKeyframeWithRelativeStartTime:0.9 relativeDuration:0.1 animations:^{
                        item.center = center;
                    }];
                } else {
                    CGPoint farCenter = CGPointMake(item.center.x, item.center.y + bounceOffset);
                    
                    [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.1 animations:^{
                        item.center = farCenter;
                    }];
                    
                    [UIView addKeyframeWithRelativeStartTime:0.1 relativeDuration:0.9 animations:^{
                        item.center = center;
                    }];
                }
            }
        }
        
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
            item.center = center;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:duration * 0.8 relativeDuration:0.2 animations:^{
            if (!isOpening) {
                if (idx != _currentIndex) {
                    [item setHidden:YES];
                    [item setSelected:NO];
                } else {
                    [item setSelected:YES];
                }
            }
        }];
    } completion:^(BOOL finished) {
        _animatedItemTag++;
        if (_animatedItemTag < [_items count]) {
            return;
        }
        
        if (_isOpen) {
            if (_delegate && [_delegate respondsToSelector:@selector(stackMenuDidOpen:)]) {
                [_delegate stackMenuDidOpen:self];
            }
        } else {
            [self setFrame:CGRectMake(_centerPoint.x - _baseWidth / 2, _centerPoint.y - _baseHeight / 2, _baseWidth, _baseHeight)];
            
            [_items enumerateObjectsUsingBlock:^(HIPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
                [item setFrame:CGRectMake(0, 0, _baseWidth, _baseHeight)];
            }];
            
            if (_delegate && [_delegate respondsToSelector:@selector(stackMenuDidClose:)]) {
                [_delegate stackMenuDidClose:self];
            }
        }
        _isAnimating = NO;
    }];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
}

#pragma mark - Actions

- (void)itemSelectAction:(id)sender {
    NSInteger idx = [_items indexOfObject:sender];
    if (idx == NSNotFound) {
        return;
    }
    
    if (_isOpen) {
        _currentIndex = idx;
        if (_delegate && [_delegate respondsToSelector:@selector(stackMenu:didSelectItem:atIndex:)]) {
            [_delegate stackMenu:self didSelectItem:sender atIndex:idx];
        }
        [self closeMenu];
    } else {
        [self openMenu];
    }    
}

@end
