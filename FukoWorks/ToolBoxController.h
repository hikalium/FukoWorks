//
//  ToolboxController.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/31.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CanvasObject.h"

@interface ToolboxController : NSWindowController
{
    IBOutlet NSPanel *toolbox;
    IBOutlet NSColorWell *cWellStrokeColor;
    IBOutlet NSColorWell *cWellFillColor;
    IBOutlet NSSlider *sliderStrokeWidth;
    IBOutlet NSTextField *textFieldStrokeWidth;
    
    NSButton *selectedDrawingObjectTypeButton;
}

@property (nonatomic) CGColorRef drawingStrokeColor;
@property (nonatomic) CGFloat drawingStrokeWidth;
@property (nonatomic) CGColorRef drawingFillColor;
@property (nonatomic) CGColorRef drawingTextColor;
@property (nonatomic) CanvasObjectType drawingObjectType;

- (id)init;
+ (ToolboxController *)sharedToolboxController;
- (void)windowDidLoad;

- (IBAction)strokeColorChanged:(id)sender;
- (IBAction)fillColorChanged:(id)sender;
- (IBAction)sliderStrokeWidthChanged:(id)sender;
- (IBAction)textFieldStrokeWidthChanged:(id)sender;
- (IBAction)drawingObjectTypeChanged:(id)sender;

@end
