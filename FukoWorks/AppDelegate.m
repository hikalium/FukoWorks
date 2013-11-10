//
//  AppDelegate.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/16.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "AppDelegate.h"
#import "PreferenceWindowController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //表示部分の初期化
    Canvases = [NSMutableArray array];
    toolboxController = [ToolboxController sharedToolboxController];
    objectListController = [CanvasObjectListWindowController sharedCanvasObjectListWindowController];
    
    //[window addChildWindow:toolboxController.window ordered:NSWindowAbove];
    [menuWindow setHidesOnDeactivate:NO];
    
    //[panelToolBox setHidesOnDeactivate:NO];
    
    //ColorWellで透明色を指定できるようにする。
    [NSColor setIgnoresAlpha:NO];
}

- (void)awakeFromNib
{
    //中央に表示させる
    NSRect screen_frame = [[NSScreen mainScreen] visibleFrame];
    NSRect panel_frame = [menuWindow frame];
    NSPoint panel_origin;
    panel_origin.x = (screen_frame.size.width - panel_frame.size.width) / 2.0;
    panel_origin.y = (screen_frame.size.height - panel_frame.size.height) / 2.0;
    panel_origin.y += screen_frame.origin.y; // for Dock Height
    [menuWindow setFrameOrigin:panel_origin];
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

- (IBAction)showToolBox:(id)sender
{
    [[ToolboxController sharedToolboxController] showWindow:sender];
    //[window addChildWindow:toolboxController.window ordered:NSWindowAbove];
}

- (IBAction)showCanvasObjectListWindow:(id)sender
{
    [[CanvasObjectListWindowController sharedCanvasObjectListWindowController] showWindow:sender];
}

- (IBAction)createNewDrawCanvas:(id)sender
{
    CanvasWindowController *aCanvasWindowController;
    
    aCanvasWindowController = [[CanvasWindowController alloc] initWithToolbox:toolboxController];
    [aCanvasWindowController showWindow:sender];
    [Canvases addObject:aCanvasWindowController];
    [menuWindow close];
    [self showToolBox:self];
}
@end
