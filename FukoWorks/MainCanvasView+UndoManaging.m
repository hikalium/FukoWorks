//
//  MainCanvasView+UndoManaging.m
//  FukoWorks
//
//  Created by 西田　耀 on 2014/01/19.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "MainCanvasView.h"

@implementation MainCanvasView (UndoManaging)
//
// Undo / Redo
//

- (IBAction)undo:(id)sender
{
    [canvasUndoManager undo];
    [self resetAllCanvasObjectHandle];
}
- (IBAction)redo:(id)sender
{
    [canvasUndoManager redo];
    [self resetAllCanvasObjectHandle];
}
@end
