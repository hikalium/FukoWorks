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
@synthesize mainCanvasView = _mainCanvasView;
@synthesize label_indicator = _label_indicator;
@synthesize toolBox = _toolbox;
@synthesize cWellStrokeColor = _cWellStrokeColor;
@synthesize cWellFillColor = _cWellFillColor;
@synthesize cWellTextColor = _cWellTextColor;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //初期化
}

- (void)awakeFromNib
{
    //表示部分の初期化
    [self.label_indicator setStringValue:@"初期化完了"];
    [_window addChildWindow:_toolbox ordered:NSWindowAbove];
    [_window setHidesOnDeactivate:NO];
    [_toolbox setHidesOnDeactivate:NO];
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
    self.mainCanvasView.drawingStrokeColor = CGColorCreateGenericRGB(color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent);
}

-(IBAction)ToolBox_FillColorChanged:(id)sender
{
    NSColor *color;
    
    color = self.cWellFillColor.color;
    self.mainCanvasView.drawingFillColor = CGColorCreateGenericRGB(color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent);
}

-(IBAction)ToolBox_TextColorChanged:(id)sender
{
    NSColor *color;
    
    color = self.cWellTextColor.color;
    self.mainCanvasView.drawingTextColor = CGColorCreateGenericRGB(color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent);
}

-(IBAction)ButtonPushed:(id)sender
{
    [self.mainCanvasView setNeedsDisplay:YES];
}

@end
