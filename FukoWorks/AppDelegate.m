//
//  AppDelegate.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/16.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //初期化
}

- (void)awakeFromNib
{
    //表示部分の初期化
    [label_indicator setStringValue:@"初期化完了"];
    [window addChildWindow:panelToolBox ordered:NSWindowAbove];
    [window setHidesOnDeactivate:NO];
    [panelToolBox setHidesOnDeactivate:NO];
    
    sliderStrokeWidth.maxValue = 10;
    sliderStrokeWidth.minValue = 0;
    [sliderStrokeWidth setIntegerValue:0];
    
    mainCanvasView = [[MainCanvasView alloc] initWithFrame:NSMakeRect(0, 0, 1024, 768)];
    mainCanvasView.label_indicator = label_indicator;
    scrollView.documentView = mainCanvasView;
    mainCanvasView.toolboxController = toolboxController;
    
    [NSColor setIgnoresAlpha:NO];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    //最後のwindowが閉じたときに終了するか否か
    return YES;
}

-(IBAction)comboBoxCanvasScaleChanged:(id)sender
{
    double scalePerCent, scale;
    
    scalePerCent = comboBoxCanvasScale.doubleValue;
    if(scalePerCent < 0){
        scalePerCent = 100;
    }
    scale = scalePerCent / 100;
    
    [label_indicator setStringValue:[NSString stringWithFormat:@"scaleSet:%f", scale]];
    [mainCanvasView setCanvasScale:scale];
    
}

-(IBAction)ButtonPushed:(id)sender
{
    [mainCanvasView setNeedsDisplay:YES];
}

@end
