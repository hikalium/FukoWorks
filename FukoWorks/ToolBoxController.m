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

- (id)init
{
    self = [super initWithWindowNibName:[self className]];
    
    if(self){
        _drawingObjectType = Undefined;
        selectedDrawingObjectTypeButton = nil;
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
    [sliderStrokeWidth setIntegerValue:0];
    [textFieldStrokeWidth setIntegerValue:0];

}


- (void)strokeColorChanged:(id)sender
{
    NSColor *color;
    
    color = cWellStrokeColor.color;
    _drawingStrokeColor = CGColorCreateGenericRGB(color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent);
}

- (void)fillColorChanged:(id)sender
{
    NSColor *color;
    
    color = cWellFillColor.color;
    _drawingFillColor = CGColorCreateGenericRGB(color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent);
}

- (void)sliderStrokeWidthChanged:(id)sender
{
    _drawingStrokeWidth = sliderStrokeWidth.doubleValue;
    textFieldStrokeWidth.doubleValue = _drawingStrokeWidth;
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
