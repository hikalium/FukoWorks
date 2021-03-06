//
//  CanvasWindowController.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/23.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainCanvasView.h"
#import "ToolboxController.h"
#import "CanvasObjectListWindowController.h"

@interface CanvasWindowController : NSWindowController <NSWindowDelegate>

@property (nonatomic) MainCanvasView *mainCanvasView;

- (id)init;
- (id)initWithToolbox:(ToolboxController *)aToolbox;
- (BOOL)windowShouldClose:(id)sender;
- (void)windowShouldClose_SheetClosed:(id)sheet returnCode:(int)returnCode contextInfo:(id)contextInfo;
- (void)windowDidLoad;
- (void)windowDidBecomeKey:(NSNotification *)notification;
- (IBAction)comboBoxCanvasScaleChanged:(id)sender;
- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;

- (IBAction)saveCanvasImageForFile:(id)sender;
- (IBAction)saveEncodedCanvasStructureForFileNamed:(id)sender;
- (IBAction)saveEncodedCanvasStructureForFile:(id)sender;
- (IBAction)loadEncodedCanvasStructureFromFile:(id)sender;
- (IBAction)printCanvas:(id)sender;
@end
