//
//  ToolboxController.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/31.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CanvasObject.h"
#import "CanvasObjectPaintFrame.h"

@interface ToolButton : NSButton
{

}

@property BOOL isDoubleClicked;

@end

@interface ToolboxController : NSWindowController
{
    IBOutlet NSPanel *toolbox;
    IBOutlet NSColorWell *cWellStrokeColor;
    IBOutlet NSColorWell *cWellFillColor;
    IBOutlet NSSlider *sliderStrokeWidth;
    IBOutlet NSTextField *textFieldStrokeWidth;
    
    IBOutlet ToolButton *toolCursor;
    IBOutlet ToolButton *toolRect;
    IBOutlet ToolButton *toolEllipse;
    IBOutlet ToolButton *toolPaintFrame;
    //
    IBOutlet ToolButton *toolPaintRect;
    IBOutlet ToolButton *toolPaintEllipse;
    IBOutlet ToolButton *toolPaintPen;
    IBOutlet ToolButton *toolPaintLine;
    IBOutlet ToolButton *toolPaintFill;
    
    ToolButton *selectedDrawingObjectTypeButton;
    ToolButton *beforeSelectedDrawingObjectTypeButton;
}

@property (nonatomic) NSColor *drawingStrokeColor;
@property (nonatomic) CGFloat drawingStrokeWidth;
@property (nonatomic) NSColor *drawingFillColor;
@property (nonatomic) CanvasObjectType drawingObjectType;
//  0   カーソル
//  1   矩形
//  2   楕円
//  3   ペイント枠
//  4   文字列
//
//  101 ペイント矩形
//  102 ペイント楕円
//  103 ペイントペン
@property (nonatomic) CanvasObject *editingObject;

- (id)init;
+ (ToolboxController *)sharedToolboxController;
- (void)windowDidLoad;

- (IBAction)strokeColorChanged:(id)sender;
- (IBAction)fillColorChanged:(id)sender;
- (IBAction)sliderStrokeWidthChanged:(id)sender;
- (IBAction)textFieldStrokeWidthChanged:(id)sender;
- (IBAction)drawingObjectTypeChanged:(id)sender;
- (void)endObjectCreation;

@end
