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
#import "NSColor+StringConversion.h"

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
// data encoding
//
- (id)initWithEncodedString:(NSString *)sourceString
{
    NSArray *dataValues;
    NSString *s;
    
    dataValues = [sourceString componentsSeparatedByString:@"|"];
    
    self = [self initWithFrame:NSZeroRect];
    
    if(self){
        // BodyRect
        // RotationAngle
        // FillColor
        // StrokeColor
        // StrokeWidth
        s = [dataValues objectAtIndex:0];
        [self setBodyRect:NSRectFromString(s)];
        s = [dataValues objectAtIndex:1];
        self.rotationAngle = s.floatValue;
        s = [dataValues objectAtIndex:2];
        self.FillColor = [NSColor colorFromString:s forColorSpace:[NSColorSpace deviceRGBColorSpace]];
        s = [dataValues objectAtIndex:3];
        self.StrokeColor = [NSColor colorFromString:s forColorSpace:[NSColorSpace deviceRGBColorSpace]];
        s = [dataValues objectAtIndex:4];
        self.StrokeWidth = s.floatValue;
    }
    return self;
}

- (NSString *)encodedStringForCanvasObject
{
    NSMutableString *encodedString;
    
    encodedString = [[NSMutableString alloc] init];
    // BodyRect
    // RotationAngle
    // FillColor
    // StrokeColor
    // StrokeWidth
    [encodedString appendFormat:@"%@|", NSStringFromRect(self.bodyRect)];
    [encodedString appendFormat:@"%f|", self.rotationAngle];
    [encodedString appendFormat:@"%@|", [self.FillColor stringRepresentation]];
    [encodedString appendFormat:@"%@|", [self.StrokeColor stringRepresentation]];
    [encodedString appendFormat:@"%f|", self.StrokeWidth];
    
    return [NSString stringWithString:encodedString];
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

- (void)drawRect:(NSRect)dirtyRect
{
    //再描画時に呼ばれる。
    CGContextRef mainContext;
    // CGRect rect;
    
    mainContext = [[NSGraphicsContext currentContext] graphicsPort];
    
    // rect = self.bodyRectBounds;
    
    CGContextSaveGState(mainContext);
    {
        CGContextTranslateCTM(mainContext, self.frame.size.width / 2, self.frame.size.height / 2);
        CGContextRotateCTM(mainContext, self.rotationAngle);
        CGContextTranslateCTM(mainContext, -self.frame.size.width / 2, -self.frame.size.height / 2);
        //
        [self drawInBodyRect:mainContext];
        //
        [self drawFocusRect];
    }
    CGContextRestoreGState(mainContext);
}

- (void)drawInBodyRect: (CGContextRef)mainContext
{
    // 子クラスはこの関数をオーバーライドして描画を実装する（回転は自動的に適用される）
    // 描画位置の指定にはbodyRectBoundsを利用する。
}

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
        
        CGContextSetStrokeColorWithColor(mainContext, [c CGColor]);
        CGContextStrokeRectWithWidth(mainContext, rect, 8);
    }
}



@end
