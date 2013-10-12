//
//  CanvasWindowController.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/23.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasWindowController.h"

@implementation CanvasWindowController

@synthesize mainCanvasView = _mainCanvasView;

- (id)init
{
    self = [super initWithWindowNibName:@"CanvasWindow"];
    
    if(self){
        
    }
    
    return self;
}

- (id)initWithToolbox:(ToolboxController *)aToolbox
{
    self = [self init];
    
    if(self){
        toolboxController = aToolbox;
    }
    
    return self;
}

- (BOOL)windowShouldClose:(id)sender
{
    NSBeginAlertSheet(@"FukoWorks", @"No", @"Yes", nil, mainWindow, self.self, @selector(windowShouldClose_SheetClosed:returnCode:contextInfo:), nil, nil, @"キャンバスを閉じてもよろしいですか？");
    
    return NO;
}

- (void)windowShouldClose_SheetClosed:(id)sheet returnCode:(int)returnCode contextInfo:(id)contextInfo
{
    switch (returnCode) {
        case NSAlertDefaultReturn:
            
            break;
            
        case NSAlertAlternateReturn:
            [mainWindow close];
            break;
    }
}

- (void)windowDidLoad
{
    [comboBoxCanvasScale setStringValue:@"100%"];
    self.mainCanvasView = [[MainCanvasView alloc] initWithFrame:NSMakeRect(0, 0, 1024, 768)];
    self.mainCanvasView.label_indicator = label_indicator;
    scrollView.documentView = self.mainCanvasView;
    [mainWindow makeFirstResponder:self.mainCanvasView];
    self.mainCanvasView.toolboxController = toolboxController;
    [label_indicator setStringValue:@"初期化完了"];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    [_mainCanvasView resetCursorRects];
}

-(IBAction)comboBoxCanvasScaleChanged:(id)sender
{
    double scalePerCent, scale, changeScale, beforeScale;
    NSPoint scrollPoint;
    
    //現在のスクロール位置を取得
    scrollPoint = scrollView.contentView.bounds.origin;
    scrollPoint.x -= _mainCanvasView.frame.origin.x;
    scrollPoint.y -= _mainCanvasView.frame.origin.y;
    
    //表示倍率をパーセントから実数へ変換
    scalePerCent = comboBoxCanvasScale.doubleValue;
    if(scalePerCent <= 0){
        scalePerCent = 100;
    }
    if(scalePerCent > (100 * 500)){
        scalePerCent = 100;
    }
    scale = scalePerCent / 100;
    //changeScale:倍率変更前の座標上の大きさを倍率変更後の大きさに直接変換する係数
    beforeScale = self.mainCanvasView.canvasScale;
    changeScale = scale / beforeScale;
    
    [self.mainCanvasView setCanvasScale:scale];
    
    //中央の表示位置を維持するようにスクロール
    scrollPoint.x += scrollView.contentSize.width / 2;
    scrollPoint.x *= changeScale;
    scrollPoint.x -= scrollView.contentSize.width / 2;
    scrollPoint.x /= scale;
    
    scrollPoint.y += scrollView.contentSize.height / 2;
    scrollPoint.y *= changeScale;
    scrollPoint.y -= scrollView.contentSize.height / 2;
    scrollPoint.y /= scale;
    
    [scrollView.documentView scrollPoint:scrollPoint];
    
    [label_indicator setStringValue:[NSString stringWithFormat:@"scaleSet:%f", scale]];
    NSLog(@"scaleSet:%@ %f", NSStringFromPoint(scrollPoint), changeScale);
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

- (void)saveEncodedCanvasStructureForFile:(id)sender
{
    NSSavePanel *savePanel;
    NSArray *allowedFileType;
    NSInteger pressedButton;
    NSURL *path;
    
    savePanel = [NSSavePanel savePanel];
    allowedFileType = [NSArray arrayWithObjects:@"fwk", nil];
    [savePanel setAllowedFileTypes:allowedFileType];
    
    pressedButton = [savePanel runModal];
    
    switch(pressedButton){
        case NSOKButton:
            path = [savePanel URL];
            
            [self.mainCanvasView writeCanvasToURL:path atomically:YES];
            
            break;
        case NSCancelButton:
            
            break;
    };
    
}

- (void)loadEncodedCanvasStructureFromFile:(id)sender
{
    NSOpenPanel *openPanel;
    NSArray *allowedFileType;
    
    allowedFileType = [NSArray arrayWithObjects:@"fwk", nil];
    
    openPanel = [NSOpenPanel openPanel];
    
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        NSURL *path;
        
        switch(result){
            case NSOKButton:
                path = [[openPanel URLs] objectAtIndex:0];
                [self.mainCanvasView loadCanvasFromURL:path];
                
                break;
            case NSCancelButton:
                
                break;
        };
    }];
    
}

- (void)printCanvas:(id)sender
{
    NSLog(@"print");
    /*
    NSPrintInfo *pinfo = [NSPrintInfo sharedPrintInfo];
    NSPrintOperation *op = [NSPrintOperation
                            printOperationWithView:scrollView.documentView
                            printInfo:pinfo];
    [op setShowsPrintPanel:YES];
    [op runOperation];
     */
    [scrollView.documentView print:self];
}

@end
