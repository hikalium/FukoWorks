//
//  AppDelegate.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/16.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "AppDelegate.h"
#import "PreferenceWindowController.h"
#import "SaveFileFWK.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //初期化
}

- (void)awakeFromNib
{
    //表示部分の初期化
    toolboxController = [ToolboxController sharedToolboxController];
    
    //[window addChildWindow:toolboxController.window ordered:NSWindowAbove];
    [menuWindow setHidesOnDeactivate:NO];
    //[panelToolBox setHidesOnDeactivate:NO];
    
    //ColorWellで透明色を指定できるようにする。
    [NSColor setIgnoresAlpha:NO];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    //最後のwindowが閉じたときに終了するか否か
    return YES;
}

- (void)showPreferenceWindow:(id)sender
{
    [[PreferenceWindowController sharedPreferenceWindowController] showWindow:sender];
}

- (IBAction)ShowToolBox:(id)sender {
    [[ToolboxController sharedToolboxController] showWindow:sender];
    //[window addChildWindow:toolboxController.window ordered:NSWindowAbove];
}

- (IBAction)CreateNewDrawCanvas:(id)sender
{
    currentCanvasWindow = [[CanvasWindowController alloc] init];
    [currentCanvasWindow showWindow:sender];
    //[menuWindow close];
}

@end
