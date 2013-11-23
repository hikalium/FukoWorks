//
//  ToolboxController.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/31.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "ToolboxController.h"

@implementation ToolboxController

@synthesize drawingStrokeColor = _drawingStrokeColor;
@synthesize drawingStrokeWidth = _drawingStrokeWidth;
@synthesize drawingFillColor = _drawingFillColor;
@synthesize drawingObjectType = _drawingObjectType;
@synthesize editingObject = _editingObject;
- (void)setEditingObject:(CanvasObject *)editingObject
{
    _editingObject = editingObject;
    if([_editingObject isKindOfClass:[CanvasObjectPaintFrame class]]){
        [toolPaintRect setEnabled:YES];
        [toolPaintEllipse setEnabled:YES];
        [toolPaintPen setEnabled:YES];
    } else{
        [toolPaintRect setEnabled:NO];
        [toolPaintEllipse setEnabled:NO];
        [toolPaintPen setEnabled:YES];
    }
    if([_editingObject isKindOfClass:[CanvasObject class]]){
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
}

- (id)init
{
    self = [super initWithWindowNibName:[self className]];
    
    if(self){
        _drawingObjectType = Undefined;
        selectedDrawingObjectTypeButton = nil;
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
    NSButton *nextButton;
    
    if([sender isKindOfClass:[NSButton class]]){
        nextButton = (NSButton *)sender;
        [selectedDrawingObjectTypeButton setState:NSOffState];
        selectedDrawingObjectTypeButton = nextButton;
        [selectedDrawingObjectTypeButton setState:NSOnState];
        _drawingObjectType = selectedDrawingObjectTypeButton.tag;
    }
}


@end
