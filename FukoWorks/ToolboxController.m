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
    
    cWellFillColor.color = [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0];
    [self fillColorChanged:self];
    
    [toolbox setReleasedWhenClosed:NO];
}

- (void)strokeColorChanged:(id)sender
{
    NSColor *color;
    
    color = cWellStrokeColor.color;
    _drawingStrokeColor = CGColorCreateGenericRGB(color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent);

    _editingObject.StrokeColor = _drawingStrokeColor;
}

- (void)fillColorChanged:(id)sender
{
    NSColor *color;
    
    color = cWellFillColor.color;
    _drawingFillColor = CGColorCreateGenericRGB(color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent);

    _editingObject.FillColor = _drawingFillColor;
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
