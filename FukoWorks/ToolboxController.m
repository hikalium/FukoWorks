//
//  ToolboxController.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/31.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "ToolboxController.h"
#import "CanvasObjectListWindowController.h"
#import "FukoWorks.h"

@implementation ToolButton
@synthesize isDoubleClicked = _isDoubleClicked;

- (id)init
{
    self = [super init];
    if(self){
        self.isDoubleClicked = NO;
    }
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if([theEvent clickCount] > 1){
        // double-click
        self.isDoubleClicked = YES;
    } else{
        // single-click
        self.isDoubleClicked = NO;
    }
    [super mouseDown:theEvent];
}
@end

@implementation ToolboxController

@synthesize drawingStrokeColor = _drawingStrokeColor;
@synthesize drawingStrokeWidth = _drawingStrokeWidth;
@synthesize drawingFillColor = _drawingFillColor;
@synthesize drawingObjectType = _drawingObjectType;
@synthesize editingObject = _editingObject;
- (void)setEditingObject:(CanvasObject *)editingObject
{
    _editingObject = editingObject;
    //ペイントメニューの切り替え
    if([_editingObject isKindOfClass:[CanvasObjectPaintFrame class]]){
        [toolPaintRect setEnabled:YES];
        [toolPaintEllipse setEnabled:YES];
        [toolPaintPen setEnabled:YES];
        [toolPaintLine setEnabled:YES];
        [toolPaintFill setEnabled:YES];
    } else{
        [toolPaintRect setEnabled:NO];
        [toolPaintEllipse setEnabled:NO];
        [toolPaintPen setEnabled:NO];
        [toolPaintLine setEnabled:NO];
        [toolPaintFill setEnabled:NO];
        if(_drawingObjectType > PaintToolsBase){
            //ペイントツールを選択していたので、カーソルにモードを戻す。
            [self drawingObjectTypeChanged:toolCursor];
        }
    }
    if([_editingObject isKindOfClass:[CanvasObject class]] && editingObject.ObjectType != TextBox){
        if(editingObject.FillColor){
            [cWellFillColor setColor:editingObject.FillColor];
            _drawingFillColor = editingObject.FillColor;
        }
        if(editingObject.StrokeColor){
            [cWellStrokeColor setColor:editingObject.StrokeColor];
            _drawingStrokeColor = editingObject.StrokeColor;
        }
        sliderStrokeWidth.doubleValue = editingObject.StrokeWidth;
        textFieldStrokeWidth.doubleValue = editingObject.StrokeWidth;
        _drawingStrokeWidth = editingObject.StrokeWidth;
    }
    [[CanvasObjectListWindowController sharedCanvasObjectListWindowController] selectCanvasObject:editingObject byExtendingSelection:NO];
}

- (id)init
{
    self = [super initWithWindowNibName:[self className]];
    
    if(self){
        _drawingObjectType = Undefined;
        selectedDrawingObjectTypeButton = nil;
        beforeSelectedDrawingObjectTypeButton = nil;
        _editingObject = nil;
    }
    
    return self;
}

ToolboxController *_sharedToolboxController = nil;
+ (ToolboxController *)sharedToolboxController
{
    if(_sharedToolboxController == nil) {
        _sharedToolboxController = [[ToolboxController alloc] init];
    }
    return _sharedToolboxController;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    sliderStrokeWidth.maxValue = 10;
    sliderStrokeWidth.minValue = 0;
    [sliderStrokeWidth setIntegerValue:1];
    [textFieldStrokeWidth setIntegerValue:[sliderStrokeWidth integerValue]];
    [self sliderStrokeWidthChanged:self];
    
    cWellFillColor.color = [NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:0.5];;
    [self fillColorChanged:self];
    
    cWellStrokeColor.color = [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:1];
    [self strokeColorChanged:self];
    
    [toolbox setReleasedWhenClosed:NO];
    
    [self drawingObjectTypeChanged:toolCursor];
    beforeSelectedDrawingObjectTypeButton = toolCursor;
}

- (void)strokeColorChanged:(id)sender
{
    NSColor *color;
    
    color = cWellStrokeColor.color;
    _drawingStrokeColor = color;

    _editingObject.StrokeColor = color;
}

- (void)fillColorChanged:(id)sender
{
    NSColor *color;
    
    color = cWellFillColor.color;
    _drawingFillColor = color;

    _editingObject.FillColor = color;
}

- (void)sliderStrokeWidthChanged:(id)sender
{
    _drawingStrokeWidth = sliderStrokeWidth.doubleValue;
    textFieldStrokeWidth.doubleValue = _drawingStrokeWidth;
    
    _editingObject.StrokeWidth = _drawingStrokeWidth;
}

- (void)textFieldStrokeWidthChanged:(id)sender
{
    double width;
    
    width = textFieldStrokeWidth.doubleValue;
    if(width > sliderStrokeWidth.maxValue){
        width = sliderStrokeWidth.maxValue;
    }
    if(width < sliderStrokeWidth.minValue){
        width = sliderStrokeWidth.minValue;
    }
    
    if(width != textFieldStrokeWidth.doubleValue){
        textFieldStrokeWidth.doubleValue = width;
    }
    sliderStrokeWidth.doubleValue = width;
    _drawingStrokeWidth = width;
    
    _editingObject.StrokeWidth = _drawingStrokeWidth;
}

- (void)drawingObjectTypeChanged:(id)sender
{
    ToolButton *nextButton;
    
    if([sender isKindOfClass:[ToolButton class]]){
        nextButton = (ToolButton *)sender;
        if([nextButton isDoubleClicked]){
            if(nextButton.tag < PaintToolsBase){
                // ペイントツール以外が永続選択できる。
                beforeSelectedDrawingObjectTypeButton = nextButton;
                nextButton.isDoubleClicked = NO;
            }
        } else{
            if(nextButton == toolCursor){
                beforeSelectedDrawingObjectTypeButton = toolCursor;
            }
            [selectedDrawingObjectTypeButton setState:NSOffState];
            selectedDrawingObjectTypeButton = nextButton;
            [selectedDrawingObjectTypeButton setState:NSOnState];
            _drawingObjectType = selectedDrawingObjectTypeButton.tag;
        }
    }
}

- (void)endObjectCreation
{
    // キャンバスで描画が終わる度に呼び出される
    // 以前選択していた（最後にダブルクリックした）ツールに、ツール選択を戻す
    if(selectedDrawingObjectTypeButton != beforeSelectedDrawingObjectTypeButton){
        [self drawingObjectTypeChanged:beforeSelectedDrawingObjectTypeButton];
    }
}

@end
