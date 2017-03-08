//
//  HIPSvgEditor.h
//  litfb_test
//
//  Created by litfb on 16/6/21.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPSvgEditor.h"
#import "HIPDBHelper.h"
#import "HIPSvgToolInfo.h"

@interface HIPSvgEditor ()

@property (nonatomic, readwrite) BOOL isEditing;

@end

@implementation HIPSvgEditor

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initEditor];
    }
    return self;
}

- (void)initEditor {
    [self setBackgroundColor:[UIColor darkGrayColor]];
    
    
}

#pragma funcs

- (void)startEdit {
    if (self.delegate && [self.delegate respondsToSelector:@selector(svgEditorWillStartEdit:)]) {
        [self.delegate svgEditorWillStartEdit:self];
    }
    
    _isEditing = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(svgEditorDidStartEdit:)]) {
        [self.delegate svgEditorDidStartEdit:self];
    }
}

- (void)endEdit {
    _isEditing = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(svgEditorDidEndEdit:)]) {
        [self.delegate svgEditorDidEndEdit:self];
    }
}

- (BOOL)canUndo {
    return NO;
}

- (void)undo {
    
}

- (BOOL)canRedo {
    return NO;
}

- (void)redo {
    
}

@end
