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

@property (assign) IBOutlet NSWindow *window;
@property (strong, nonatomic) IBOutlet MainCanvasView *mainCanvasView;
@property (strong, nonatomic) IBOutlet NSTextField *label_indicator;
@property (strong, nonatomic) IBOutlet NSPanel *toolBox;
@property (strong, nonatomic) IBOutlet NSColorWell *cWellForeColor;
@property (strong, nonatomic) IBOutlet NSColorWell *cWellFillColor;
@property (strong, nonatomic) IBOutlet NSColorWell *cWellTextColor;

-(IBAction)ToolBox_ForeColorChanged:(id)sender;
-(IBAction)ToolBox_FillColorChanged:(id)sender;
-(IBAction)ToolBox_TextColorChanged:(id)sender;
-(IBAction)ButtonPushed:(id)sender;

@end
