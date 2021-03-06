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

- (id)init
{
    self = [super init];
    if(self){
        Canvases = [NSMutableArray array];
        toolboxController = [ToolboxController sharedToolboxController];
        objectListController = [CanvasObjectListWindowController sharedCanvasObjectListWindowController];
        //ColorWellで透明色を指定できるようにする。
        [NSColor setIgnoresAlpha:NO];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // 起動処理の最後の最後に呼ばれる。
}


- (void)awakeFromNib
{
    NSString *s;
    
    [[NSColorPanel sharedColorPanel] close];
    [[NSFontPanel sharedFontPanel] close];
    
    [splashWindow center];
    [splashWindow setLevel:NSFloatingWindowLevel];
    s = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    splashBuildLabel.stringValue = [[NSString alloc] initWithFormat:@"%@%@", splashBuildLabel.stringValue, s];
    s = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    splashVersionLabel.stringValue = [[NSString alloc] initWithFormat:@"%@%@", splashVersionLabel.stringValue, s];
}
/*

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
    //ファイルを開く処理
}
*/
- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    CanvasWindowController *aCanvasWindow;
    [self createNewDrawCanvas:sender];
    aCanvasWindow = [Canvases objectAtIndex:[Canvases count] - 1];
    [aCanvasWindow.mainCanvasView loadCanvasFromURL:[NSURL fileURLWithPath:filename]];
    return YES;
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
}

- (IBAction)showCanvasObjectListWindow:(id)sender
{
    [[CanvasObjectListWindowController sharedCanvasObjectListWindowController] showWindow:sender];
}

- (IBAction)createNewDrawCanvas:(id)sender
{
    CanvasWindowController *aCanvasWindowController;
    
    aCanvasWindowController = [[CanvasWindowController alloc] initWithToolbox:toolboxController];
    [Canvases addObject:aCanvasWindowController];
    [aCanvasWindowController showWindow:sender];
    [self showToolBox:self];
    [splashWindow close];
    [aCanvasWindowController.window makeKeyAndOrderFront:self];
}


@end
