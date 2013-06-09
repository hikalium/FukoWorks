//
//  AppDelegate.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/16.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainCanvasView.h"
#import "ToolboxController.h"
#import "CanvasWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSWindow *menuWindow;
    NSMutableArray *Canvases;
    ToolboxController *toolboxController;
}

- (IBAction)showPreferenceWindow:(id)sender;
- (IBAction)ShowToolBox:(id)sender;
- (IBAction)CreateNewDrawCanvas:(id)sender;

@end
