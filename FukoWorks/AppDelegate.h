//
//  AppDelegate.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/16.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainCanvasView.h"
#import "ToolBoxController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet ToolBoxController *toolboxController;
    
    IBOutlet NSPanel *panelToolBox;
    IBOutlet NSSlider *sliderStrokeWidth;
    IBOutlet NSWindow *window;
    IBOutlet NSScrollView *scrollView;
    IBOutlet NSTextField *label_indicator;
    IBOutlet NSComboBox *comboBoxCanvasScale;
    
    MainCanvasView *mainCanvasView;
    
}

-(IBAction)comboBoxCanvasScaleChanged:(id)sender;
-(IBAction)ButtonPushed:(id)sender;

@end
