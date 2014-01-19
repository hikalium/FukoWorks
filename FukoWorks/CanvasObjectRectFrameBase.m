//
//  CanvasObjectRectFrameBase.m
//  FukoWorks
//
//  Created by 西田　耀 on 2013/10/27.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObjectRectFrameBase.h"

@implementation CanvasObjectRectFrameBase

- (CanvasObject *)drawMouseDown:(NSPoint)currentPointInCanvas
{
    [[self.undoManager prepareWithInvocationTarget:self] setFrame:self.frame];
    //https://github.com/Pixen/Pixen/issues/228
    [self.undoManager endUndoGrouping];
    [self.undoManager disableUndoRegistration];
    //
    drawingStartPoint = currentPointInCanvas;
    
    return self;
}

- (CanvasObject *)drawMouseDragged:(NSPoint)currentPointInCanvas
{
    [self setFrame:[self makeNSRectFromMouseMoving:drawingStartPoint :currentPointInCanvas]];
    [self setNeedsDisplay:YES];
    
    return self;
}

- (CanvasObject *)drawMouseUp:(NSPoint)currentPointInCanvas
{
    [self setFrame:[self makeNSRectFromMouseMoving:drawingStartPoint :currentPointInCanvas]];
    [self setNeedsDisplay:YES];
    //
    [self.undoManager enableUndoRegistration];
    //
    return nil;
}

//
// EditHandle
//
- (NSUInteger)numberOfEditHandlesForCanvasObject
{
    return 4;
}

- (NSPoint)editHandlePointForHandleID:(NSUInteger)hid
{
    //hid:0-3(4)
    //2----3
    //|    |
    //0----1
    NSRect realRect = [self makeNSRectWithRealSizeViewFrame];
    NSPoint p = realRect.origin;
    switch (hid) {
        case 1:
            p.x += realRect.size.width;
            break;
        case 2:
            p.y += realRect.size.height;
            break;
        case 3:
            p.x += realRect.size.width;
            p.y += realRect.size.height;
            break;
    }
    return p;
}

@end
