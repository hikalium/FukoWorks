//
//  CanvasObjectRectFrameBase.m
//  FukoWorks
//
//  Created by 西田　耀 on 2013/10/27.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObjectRectFrameBase.h"
#import "CanvasObjectHandle.h"
#import "MainCanvasView.h"

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

- (void)editHandleDown:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid;
{
    [[self.undoManager prepareWithInvocationTarget:self] setFrame:self.frame];
    //https://github.com/Pixen/Pixen/issues/228
    [self.undoManager endUndoGrouping];
    [self.undoManager disableUndoRegistration];
    //
    switch (hid) {
        case 0:
            //LD
        case 3:
            //RU
            [[self.editHandleList objectAtIndex:1] setHidden:YES];
            [[self.editHandleList objectAtIndex:2] setHidden:YES];
            break;
        case 2:
            //LU
        case 1:
            //RD
            [[self.editHandleList objectAtIndex:0] setHidden:YES];
            [[self.editHandleList objectAtIndex:3] setHidden:YES];
            break;
    }
}

- (void)editHandleDragged:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid;
{
    NSPoint p;
    
    p = [((CanvasObjectHandle *)[self.editHandleList objectAtIndex:(3 - hid)])makeNSPointWithHandlePoint];
    [self setFrame:[self makeNSRectFromMouseMoving:p :currentHandlePointInCanvas]];

    [self setNeedsDisplay:YES];
    [((MainCanvasView *)self.ownerMainCanvasView) resetCanvasObjectHandleForCanvasObject:self];
}

- (void)editHandleUp:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid;
{
    switch (hid) {
        case 0:
            //LD
        case 3:
            //RU
            [[self.editHandleList objectAtIndex:1] setHidden:NO];
            [[self.editHandleList objectAtIndex:2] setHidden:NO];
            break;
        case 2:
            //LU
        case 1:
            //RD
            [[self.editHandleList objectAtIndex:0] setHidden:NO];
            [[self.editHandleList objectAtIndex:3] setHidden:NO];
            break;
    }
    //
    [self.undoManager enableUndoRegistration];
    //
}


@end
