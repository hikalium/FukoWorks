//
//  InspectorWindowController.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/06/09.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CanvasObject.h"

@interface InspectorWindowController : NSWindowController
{
    CanvasObject *editingCanvasObject;
    NSView *editingView;
    IBOutlet NSTextField *editTypeLabel;
    
    IBOutlet NSTextField *tboxSizeX;
    IBOutlet NSTextField *tboxSizeY;
    IBOutlet NSTextField *tboxLocationX;
    IBOutlet NSTextField *tboxLocationY;
}

- (id)initWithEditView:(NSView *)editView;
- (IBAction)changeTextFieldValue:(id)sender;


@end
