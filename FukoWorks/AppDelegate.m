//
//  AppDelegate.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/16.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize scrollView = _scrollView;
@synthesize label_indicator = _label_indicator;
@synthesize toolBox = _toolbox;
@synthesize cWellStrokeColor = _cWellStrokeColor;
@synthesize cWellFillColor = _cWellFillColor;
@synthesize cWellTextColor = _cWellTextColor;
@synthesize sliderStrokeWidth = _sliderStrokeWidth;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //初期化
}

- (void)awakeFromNib
{
    //表示部分の初期化
    [_label_indicator setStringValue:@"初期化完了"];
    [_window addChildWindow:_toolbox ordered:NSWindowAbove];
    [_window setHidesOnDeactivate:NO];
    [_toolbox setHidesOnDeactivate:NO];
    
    _sliderStrokeWidth.maxValue = 10;
    _sliderStrokeWidth.minValue = 0;
    [_sliderStrokeWidth setIntegerValue:0];
    
    mainCanvasView = [[MainCanvasView alloc] initWithFrame:NSMakeRect(0, 0, 1024, 768)];
    mainCanvasView.label_indicator = _label_indicator;
    _scrollView.documentView = mainCanvasView;
    
    [NSColor setIgnoresAlpha:NO];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    //最後のwindowが閉じたときに終了するか否か
    return YES;
}

-(IBAction)ToolBox_StrokeColorChanged:(id)sender
{
    NSColor *color;
    
    color = self.cWellStrokeColor.color;
    mainCanvasView.drawingStrokeColor = CGColorCreateGenericRGB(color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent);
}

-(IBAction)ToolBox_FillColorChanged:(id)sender
{
    NSColor *color;
    
    color = self.cWellFillColor.color;
    mainCanvasView.drawingFillColor = CGColorCreateGenericRGB(color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent);
}

-(IBAction)ToolBox_TextColorChanged:(id)sender
{
    NSColor *color;
    
    color = self.cWellTextColor.color;
    mainCanvasView.drawingTextColor = CGColorCreateGenericRGB(color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent);
}

-(IBAction)ToolBox_sliderStrokeWidthChanged:(id)sender
{
    mainCanvasView.drawingStrokeWidth = self.sliderStrokeWidth.doubleValue;
    self.textFieldStrokeWidth.doubleValue = mainCanvasView.drawingStrokeWidth;
}

-(IBAction)ToolBox_textFieldStrokeWidthChanged:(id)sender
{
    double width;
    
    width = self.textFieldStrokeWidth.doubleValue;
    if(width > self.sliderStrokeWidth.maxValue){
        width = self.sliderStrokeWidth.maxValue;
    }
    if(width < self.sliderStrokeWidth.minValue){
        width = self.sliderStrokeWidth.minValue;
    }
    
    if(width != self.textFieldStrokeWidth.doubleValue){
        self.textFieldStrokeWidth.doubleValue = width;
    }
    self.sliderStrokeWidth.doubleValue = width;
    mainCanvasView.drawingStrokeWidth = width;
}

-(IBAction)comboBoxCanvasScaleChanged:(id)sender
{
    double scalePerCent, scale;
    
    scalePerCent = self.comboBoxCanvasScale.doubleValue;
    if(scalePerCent < 0){
        scalePerCent = 100;
    }
    scale = scalePerCent / 100;
    
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"scaleSet:%f", scale]];
    [mainCanvasView setCanvasScale:scale];
    
}

-(IBAction)ButtonPushed:(id)sender
{
    [mainCanvasView setNeedsDisplay:YES];
}

@end
