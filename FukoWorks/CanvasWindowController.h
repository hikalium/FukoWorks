//
//  CanvasWindowController.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/23.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainCanvasView.h"

@interface CanvasWindowController : NSWindowController <NSWindowDelegate>
{
    IBOutlet NSWindow *mainWindow;
    IBOutlet NSScrollView *scrollView;
    IBOutlet NSTextField *label_indicator;
    IBOutlet NSComboBox *comboBoxCanvasScale;
}

@property (nonatomic) MainCanvasView *mainCanvasView;

- (id)init;
- (BOOL)windowShouldClose:(id)sender;
- (void)windowShouldClose_SheetClosed:(id)sheet returnCode:(int)returnCode contextInfo:(id)contextInfo;
- (void)windowDidLoad;
- (IBAction)comboBoxCanvasScaleChanged:(id)sender;
- (IBAction)saveCanvasImageForFile:(id)sender;
- (IBAction)saveEncodedCanvasStructureForFile:(id)sender;
@end
