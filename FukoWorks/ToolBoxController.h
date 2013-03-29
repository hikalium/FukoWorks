//
//  ToolBoxController.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/23.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CanvasObject.h"

@interface ToolBoxController : NSObject
{
    IBOutlet NSPanel *toolBox;
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

-(IBAction)ToolBox_StrokeColorChanged:(id)sender;
-(IBAction)ToolBox_FillColorChanged:(id)sender;
-(IBAction)ToolBox_sliderStrokeWidthChanged:(id)sender;
-(IBAction)ToolBox_textFieldStrokeWidthChanged:(id)sender;

-(IBAction)ToolBox_DrawingObjectTypeChanged:(id)sender;

@end
