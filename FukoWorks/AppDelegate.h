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
#import "CanvasObjectListWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    //IBOutlet NSWindow *menuWindow;
    NSMutableArray *Canvases;
    ToolboxController *toolboxController;
    CanvasObjectListWindowController *objectListController;
    
    //For splashWindow
    IBOutlet NSWindow *splashWindow;
    IBOutlet NSTextField *splashVersionLabel;
    IBOutlet NSTextField *splashBuildLabel;
}

- (IBAction)showPreferenceWindow:(id)sender;
- (IBAction)showToolBox:(id)sender;
- (IBAction)showCanvasObjectListWindow:(id)sender;
- (IBAction)createNewDrawCanvas:(id)sender;
- (IBAction)openFile:(id)sender;

@end
