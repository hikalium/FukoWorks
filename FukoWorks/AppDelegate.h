//
//  AppDelegate.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/16.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainCanvasView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    MainCanvasView *mainCanvasView;
}
@property (assign) IBOutlet NSWindow *window;
@property (strong, nonatomic) IBOutlet NSScrollView *scrollView;
@property (strong, nonatomic) IBOutlet NSTextField *label_indicator;
@property (strong, nonatomic) IBOutlet NSComboBox *comboBoxCanvasScale;
@property (strong, nonatomic) IBOutlet NSPanel *toolBox;
@property (strong, nonatomic) IBOutlet NSColorWell *cWellStrokeColor;
@property (strong, nonatomic) IBOutlet NSColorWell *cWellFillColor;
@property (strong, nonatomic) IBOutlet NSColorWell *cWellTextColor;
@property (strong, nonatomic) IBOutlet NSSlider *sliderStrokeWidth;
@property (strong, nonatomic) IBOutlet NSTextField *textFieldStrokeWidth;

-(IBAction)ToolBox_StrokeColorChanged:(id)sender;
-(IBAction)ToolBox_FillColorChanged:(id)sender;
-(IBAction)ToolBox_TextColorChanged:(id)sender;
-(IBAction)ToolBox_sliderStrokeWidthChanged:(id)sender;
-(IBAction)ToolBox_textFieldStrokeWidthChanged:(id)sender;
-(IBAction)comboBoxCanvasScaleChanged:(id)sender;
-(IBAction)ButtonPushed:(id)sender;

@end
