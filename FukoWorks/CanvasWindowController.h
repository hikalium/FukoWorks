//
//  CanvasWindowController.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/23.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainCanvasView.h"

@interface CanvasWindowController : NSObject
{
    IBOutlet NSWindow *mainWindow;
    IBOutlet NSScrollView *scrollView;
    IBOutlet NSTextField *label_indicator;
    IBOutlet NSComboBox *comboBoxCanvasScale;
}

@property (nonatomic) MainCanvasView *currentCanvasView;

-(IBAction)comboBoxCanvasScaleChanged:(id)sender;

@end
