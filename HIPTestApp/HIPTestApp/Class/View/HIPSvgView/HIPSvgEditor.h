//
//  HIPSvgEditor.h
//  litfb_test
//
//  Created by litfb on 16/6/21.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HIPSvgElement.h"
#import "HIPSvgData.h"

@protocol HIPSvgDelegate;

@interface HIPSvgEditor : UIView

@property (strong, nonatomic) HIPSvgData *svgData;

@property (nonatomic, readonly) BOOL isEditing;

@property (nonatomic) NSUInteger linePower;

@property (nonatomic) UIColor *lineColor;

@property (weak, nonatomic) id<HIPSvgDelegate> delegate;

- (void)startEdit;

- (void)endEdit;

- (BOOL)canUndo;

- (void)undo;

- (BOOL)canRedo;

- (void)redo;

@end

@protocol HIPSvgDelegate <NSObject>

- (void)svgEditorDidLoadData:(HIPSvgEditor *)svgEditor;

- (void)svgEditorWillStartEdit:(HIPSvgEditor *)svgEditor;

- (void)svgEditorDidStartEdit:(HIPSvgEditor *)svgEditor;

- (void)svgEditorDidEndEdit:(HIPSvgEditor *)svgEditor;

- (void)svgEditor:(HIPSvgEditor *)svgEditor didUndoWithElement:(HIPSvgElement *)element;

- (void)svgEditorDidRedo:(HIPSvgEditor *)svgEditor;

- (void)svgEditor:(HIPSvgEditor *)svgEditor didAddElement:(HIPSvgElement *)element;

@end