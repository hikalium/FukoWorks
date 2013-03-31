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
    //初期化
}

- (void)awakeFromNib
{
    //表示部分の初期化
    toolboxController = [ToolboxController sharedToolboxController];
    
    [window addChildWindow:toolboxController.window ordered:NSWindowAbove];
    [window setHidesOnDeactivate:NO];
    //[panelToolBox setHidesOnDeactivate:NO];
    
    
    [comboBoxCanvasScale setStringValue:@"100%"];
    mainCanvasView = [[MainCanvasView alloc] initWithFrame:NSMakeRect(0, 0, 1024, 768)];
    mainCanvasView.label_indicator = label_indicator;
    scrollView.documentView = mainCanvasView;
    mainCanvasView.toolboxController = toolboxController;
    canvasController.currentCanvasView = mainCanvasView;
    
    //ColorWellで透明色を指定できるようにする。
    [NSColor setIgnoresAlpha:NO];
    
    [label_indicator setStringValue:@"初期化完了"];
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

- (void)saveCanvasImageForFile:(id)sender
{
    NSSavePanel *savePanel;
    NSArray *allowedFileType;
    NSInteger pressedButton;
    NSURL *path;
    NSBitmapImageRep *bitmapImage;
    NSView *targetView;
    NSData *savedata;
    
    savePanel = [NSSavePanel savePanel];
    allowedFileType = [NSArray arrayWithObjects:@"png", nil];
    [savePanel setAllowedFileTypes:allowedFileType];
    
    pressedButton = [savePanel runModal];
    
    switch(pressedButton){
        case NSOKButton:
            path = [savePanel URL];
            targetView = (NSView *)[scrollView documentView];
            bitmapImage = [targetView bitmapImageRepForCachingDisplayInRect:targetView.frame];
            [targetView cacheDisplayInRect:targetView.bounds toBitmapImageRep:bitmapImage];
            savedata = [bitmapImage representationUsingType:NSPNGFileType properties:[NSDictionary dictionary]];
            [savedata writeToURL:path atomically:YES];
            
            break;
        case NSCancelButton:
            
            break;
    };
}

@end
