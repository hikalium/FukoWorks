//
//  ToolBoxController.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/23.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "ToolBoxController.h"

@implementation ToolBoxController

@synthesize drawingStrokeColor = _drawingStrokeColor;
@synthesize drawingStrokeWidth = _drawingStrokeWidth;
@synthesize drawingFillColor = _drawingFillColor;
@synthesize drawingTextColor = _drawingTextColor;

-(IBAction)ToolBox_StrokeColorChanged:(id)sender
{
    NSColor *color;
    
    color = cWellStrokeColor.color;
    _drawingStrokeColor = CGColorCreateGenericRGB(color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent);
}

-(IBAction)ToolBox_FillColorChanged:(id)sender
{
    NSColor *color;
    
    color = cWellFillColor.color;
    _drawingFillColor = CGColorCreateGenericRGB(color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent);
}

-(IBAction)ToolBox_TextColorChanged:(id)sender
{
    NSColor *color;
    
    color = cWellTextColor.color;
    _drawingTextColor = CGColorCreateGenericRGB(color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent);
}

-(IBAction)ToolBox_sliderStrokeWidthChanged:(id)sender
{
    _drawingStrokeWidth = sliderStrokeWidth.doubleValue;
    textFieldStrokeWidth.doubleValue = _drawingStrokeWidth;
}

-(IBAction)ToolBox_textFieldStrokeWidthChanged:(id)sender
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


@end
