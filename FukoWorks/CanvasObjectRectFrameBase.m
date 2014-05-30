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
// bodyRectとrotationAngleで描画位置の矩形を一意に決定する

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
    [self setFrameFromCurrentBodyRect];
    [self setNeedsDisplay:YES];
}

- (void)setBodyRect:(NSRect)bodyRect
{
    _bodyRect = bodyRect;
    [self setFrameFromCurrentBodyRect];
}

- (NSRect)bodyRectBounds
{
    // このview上でのbodyRectの範囲を示す矩形を返す
    // 回転時は不正確な矩形になる。
    NSRect b;
    b = _bodyRect;
    b.origin.x -= self.frame.origin.x;
    b.origin.y -= self.frame.origin.y;
    return b;
}

- (void)setFrameOrigin:(NSPoint)newOrigin
{
    NSPoint diff;
    diff.x = newOrigin.x - self.frame.origin.x;
    diff.y = newOrigin.y - self.frame.origin.y;
    [self setFrameOriginRaw:newOrigin];
    _bodyRect.origin.x += diff.x;
    _bodyRect.origin.y += diff.y;
}

/*
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
*/
- (void)setFrameFromCurrentBodyRect
{
    NSRect fr;
    if(self.rotationAngle == 0){
        fr = self.bodyRect;
        fr.origin.x -= (self.StrokeWidth / 2);
        fr.origin.y -= (self.StrokeWidth / 2);
        fr.size.width += self.StrokeWidth;
        fr.size.height += self.StrokeWidth;
    } else{
        CGFloat fw, fh;
        CGFloat bw, bh;
        CGFloat theta, tcos, tsin;
        NSPoint c;
        bw = self.bodyRect.size.width;
        bh = self.bodyRect.size.height;
        theta =  self.rotationAngle;
        tcos = fabsf(cosf(theta));
        tsin = fabsf(sinf(theta));
        fw = bw * tcos + bh * tsin;
        fh = bh * tcos + bw * tsin;
        c = NSMakePoint(self.bodyRect.origin.x + bw / 2, self.bodyRect.origin.y + bh / 2);
        fr.origin = NSMakePoint(c.x - (fw + self.StrokeWidth) / 2, c.y - (fh + self.StrokeWidth) / 2);
        fr.size = NSMakeSize(fw + self.StrokeWidth, fh + self.StrokeWidth);
    }
    [self setFrameSizeRaw:fr.size];
    [self setFrameOriginRaw:fr.origin];
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
    //[[self.canvasUndoManager prepareWithInvocationTarget:self] setBodyRect:self.bodyRect];
    
    drawingStartPoint = currentPointInCanvas;
    
    return self;
}

- (CanvasObject *)drawMouseDragged:(NSPoint)currentPointInCanvas
{
    [self setBodyRect:[CanvasObject makeNSRectFromMouseMovingWithModifierKey:drawingStartPoint :currentPointInCanvas]];
    return self;
}

- (CanvasObject *)drawMouseUp:(NSPoint)currentPointInCanvas
{
    [self setBodyRect:[CanvasObject makeNSRectFromMouseMovingWithModifierKey:drawingStartPoint :currentPointInCanvas]];
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
    [[self.canvasUndoManager prepareWithInvocationTarget:self] setBodyRect:self.bodyRect];
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
    [((MainCanvasView *)self.ownerMainCanvasView) resetCanvasObjectHandleForCanvasObject:self];
}
/*
- (void)drawFocusRect
{
    CGContextRef mainContext;
    CGRect rect;
    NSColor *c;
    
    if(self.isSelected){
        mainContext = [[NSGraphicsContext currentContext] graphicsPort];
        
        
        
        rect = self.bodyRectBounds;
        c = [[NSColor selectedControlColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
        c = [NSColor colorWithCalibratedRed:c.redComponent green:c.greenComponent blue:c.blueComponent alpha:0.75];
        
        CGContextSaveGState(mainContext);
        {
            CGContextSetStrokeColorWithColor(mainContext, [c CGColor]);
            CGContextStrokeRectWithWidth(mainContext, rect, 8);
        }
        CGContextRestoreGState(mainContext);
    }
}
*/


@end
