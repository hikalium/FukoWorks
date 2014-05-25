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

//
// For object rotation
//

@synthesize rotationAngle = _rotationAngle;
- (void)setRotationAngle:(CGFloat)rotationAngle
{
    _rotationAngle = fmod(rotationAngle, 2 * pi);
    if(_rotationAngle < 0){
        _rotationAngle += 2 * pi;
    }
    [self setBodyRectFromCurrentFrame];
    [self setNeedsDisplay:YES];
}

- (void)setBodyRect:(NSRect)bodyRect
{
    bodyRect.origin.x -= (self.StrokeWidth / 2);
    bodyRect.origin.y -= (self.StrokeWidth / 2);
    bodyRect.size.width += self.StrokeWidth;
    bodyRect.size.height += self.StrokeWidth;
    
    [self setFrame:bodyRect];
}

- (NSRect)bodyRectBounds
{
    // このview上でのbodyRectの範囲を示す矩形を返す
    NSRect b;
    b = _bodyRect;
    b.origin.x -= self.frame.origin.x;
    b.origin.y -= self.frame.origin.y;
    return b;
}

- (void)setFrameOrigin:(NSPoint)newOrigin
{
    if([self.canvasUndoManager isUndoing] || [self.canvasUndoManager isRedoing]){
        [[self.canvasUndoManager prepareWithInvocationTarget:self] setFrameOrigin:self.frame.origin];
    }
    [self setFrameOriginRaw:newOrigin];
    
    // bodyRectを更新
    [self setBodyRectFromCurrentFrame];
}

- (void)setFrameSize:(NSSize)newSize
{
    if([self.canvasUndoManager isUndoing] || [self.canvasUndoManager isRedoing]){
        [[self.canvasUndoManager prepareWithInvocationTarget:self] setFrameSize:self.frame.size];
    }
    //
    [self setFrameSizeInternal:newSize];
}

- (void)setBodyRectFromCurrentFrame
{
    if(self.rotationAngle == 0){
        _bodyRect.origin.x = self.frame.origin.x + (self.StrokeWidth / 2);
        _bodyRect.origin.y = self.frame.origin.y + (self.StrokeWidth / 2);
        _bodyRect.size.width = self.frame.size.width - self.StrokeWidth;
        _bodyRect.size.height = self.frame.size.height - self.StrokeWidth;
    } else{
        CGFloat fw, fh;
        CGFloat bw, bh;
        CGFloat theta;
        CGFloat thetaMax;
        NSPoint c;
        fw = self.frame.size.width - self.StrokeWidth;
        fh = self.frame.size.height - self.StrokeWidth;
        theta =  self.rotationAngle;
        theta = fmod(theta, pi);
        thetaMax = atanf(fh / fw);
        if(theta < thetaMax){
            bw = (fw * cosf(theta) - fh * sinf(theta)) / cosf(2 * theta);
            bh = (fh * cosf(theta) - fw * sinf(theta)) / cosf(2 * theta);
        } else{
            theta = theta - thetaMax + (pi / 2);
            bh = (fw * cosf(theta) - fh * sinf(theta)) / cosf(2 * theta);
            bw = (fh * cosf(theta) - fw * sinf(theta)) / cosf(2 * theta);
        }
        c = NSMakePoint(self.frame.origin.x + fw / 2, self.frame.origin.y + fh / 2);
        _bodyRect.origin = NSMakePoint(c.x - bw / 2, c.y - bh / 2);
        _bodyRect.size = NSMakeSize(bw, bh);
    }
}

- (void)setFrameSizeInternal:(NSSize)newSize
{
    if(newSize.width > FWK_MAX_SIZE_PIXEL){
        newSize.width = FWK_MAX_SIZE_PIXEL;
    }
    if(newSize.height > FWK_MAX_SIZE_PIXEL){
        newSize.height = FWK_MAX_SIZE_PIXEL;
    }
    if(newSize.width < FWK_MIN_SIZE_PIXEL + self.StrokeWidth){
        newSize.width = FWK_MIN_SIZE_PIXEL + self.StrokeWidth;
    }
    if(newSize.height < FWK_MIN_SIZE_PIXEL + self.StrokeWidth){
        newSize.height = FWK_MIN_SIZE_PIXEL + self.StrokeWidth;
    }
    
    [self setFrameSizeRaw:newSize];
    // bodyRectを更新
    [self setBodyRectFromCurrentFrame];
}

- (id)init
{
    self = [super init];
    if(self){
        rotationHandleVector = NSZeroPoint;
    }
    
    return self;
}

//
// initial drawing
//

- (CanvasObject *)drawMouseDown:(NSPoint)currentPointInCanvas
{
    [[self.canvasUndoManager prepareWithInvocationTarget:self] setFrame:self.frame];
    
    drawingStartPoint = currentPointInCanvas;
    
    return self;
}

- (CanvasObject *)drawMouseDragged:(NSPoint)currentPointInCanvas
{
    [self setFrame:[CanvasObject makeNSRectFromMouseMovingWithModifierKey:drawingStartPoint :currentPointInCanvas]];
    [self setNeedsDisplay:YES];
    
    return self;
}

- (CanvasObject *)drawMouseUp:(NSPoint)currentPointInCanvas
{
    [self setFrame:[CanvasObject makeNSRectFromMouseMovingWithModifierKey:drawingStartPoint :currentPointInCanvas]];
    [self setNeedsDisplay:YES];
    return nil;
}

//
// EditHandle
//
- (NSUInteger)numberOfEditHandlesForCanvasObject
{
    return (4 + 1);
}

- (NSPoint)editHandlePointForHandleID:(NSUInteger)hid
{
    //hid:0-3(4)
    //2----3
    //|    |
    //0----1
    NSRect realRect = self.bodyRect;
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
        case 4:
            p.x += realRect.size.width / 2 + rotationHandleVector.x;
            p.y += realRect.size.height / 2 + rotationHandleVector.y;
            break;
    }
    return p;
}

- (void)editHandleDown:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid;
{
    [[self.canvasUndoManager prepareWithInvocationTarget:self] setFrame:self.frame];
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
        case 4:
            // rotationHandle
            drawingStartPoint = currentHandlePointInCanvas;
            break;
    }
}

- (void)editHandleDragged:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid;
{
    NSPoint p;
    CGFloat l;
    
    if(hid <= 3){
        p = [((CanvasObjectHandle *)[self.editHandleList objectAtIndex:(3 - hid)]) makeNSPointWithHandlePoint];
        [self setBodyRect:[CanvasObject makeNSRectFromMouseMovingWithModifierKey:p :currentHandlePointInCanvas]];
    } else if(hid == 4){
        rotationHandleVector = NSMakePoint(currentHandlePointInCanvas.x - drawingStartPoint.x, currentHandlePointInCanvas.y - drawingStartPoint.y);
        l = sqrtf(rotationHandleVector.x * rotationHandleVector.x + rotationHandleVector.y * rotationHandleVector.y);
        l = acos(rotationHandleVector.x / l);
        if(rotationHandleVector.y < 0){
            l = (2 * pi) - l;
        }
        self.rotationAngle = l;
    }
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
        case 4:
            // rotationHandle
            rotationHandleVector = NSZeroPoint;
            break;
    }
    [self setNeedsDisplay:YES];
    [((MainCanvasView *)self.ownerMainCanvasView) resetCanvasObjectHandleForCanvasObject:self];
}


@end
