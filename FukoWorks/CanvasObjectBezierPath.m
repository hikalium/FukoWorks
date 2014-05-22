//
//  CanvasObjectBezierPath.m
//  FukoWorks
//
//  Created by 西田　耀 on 2014/04/02.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObjectBezierPath.h"

#import "CanvasObjectHandle.h"
#import "MainCanvasView.h"
#import "NSColor+StringConversion.h"

@implementation CanvasObjectBezierPath
{
    NSPoint p0, p1, cp0, cp1; //キャンバス座標
    NSPoint lp0, lp1, lcp0, lcp1;   //このビューにおける座標
    NSBezierPath *bp;
}
//プロパティアクセッサメソッド
@synthesize ObjectType = _ObjectType;
@synthesize p0 = p0;
- (void)setP0:(NSPoint)_p0
{
    if([self.canvasUndoManager isUndoing] || [self.canvasUndoManager isRedoing]){
        [[self.canvasUndoManager prepareWithInvocationTarget:self] setP0:p0];
        lp0 = [self bindLinePointToLocalSub:_p0];
    }
    p0 = _p0;
    [self sizeToFit];
}
@synthesize p1 = p1;
- (void)setP1:(NSPoint)_p1
{
    if([self.canvasUndoManager isUndoing] || [self.canvasUndoManager isRedoing]){
        [[self.canvasUndoManager prepareWithInvocationTarget:self] setP1:p1];
        lp1 = [self bindLinePointToLocalSub:_p1];
    }
    p1 = _p1;
    [self sizeToFit];
}

@synthesize cp0 = cp0;
- (void)setCp0:(NSPoint)_cp0
{
    if([self.canvasUndoManager isUndoing] || [self.canvasUndoManager isRedoing]){
        [[self.canvasUndoManager prepareWithInvocationTarget:self] setCp0:cp0];
        lcp0 = [self bindLinePointToLocalSub:_cp0];
    }
    cp0 = _cp0;
    [self sizeToFit];
}
@synthesize cp1 = cp1;
- (void)setCp1:(NSPoint)_cp1
{
    if([self.canvasUndoManager isUndoing] || [self.canvasUndoManager isRedoing]){
        [[self.canvasUndoManager prepareWithInvocationTarget:self] setCp1:cp1];
        lcp1 = [self bindLinePointToLocalSub:_cp1];
    }
    cp1 = _cp1;
    [self sizeToFit];
}

// メソッド
- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        _ObjectType = BezierPath;
        p0 = NSZeroPoint;
        p1 = NSZeroPoint;
        bp = [NSBezierPath bezierPath];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //再描画時に呼ばれる。
    [bp setLineWidth:self.StrokeWidth];
    
    [bp moveToPoint:lp0];
    [bp curveToPoint:lp1 controlPoint1:lcp0 controlPoint2:lcp1];
    
    [self.StrokeColor set];
    [bp stroke];
    
    [self.FillColor set];
    [bp fill];
    
    [bp removeAllPoints];
    
    if(self.isSelected){
        [[NSColor selectedControlColor] set];
        [bp moveToPoint:lp0];
        [bp lineToPoint:lcp0];
        [bp moveToPoint:lp1];
        [bp lineToPoint:lcp1];
        [bp stroke];
        [bp removeAllPoints];
    }
    
}

// data encoding
- (id)initWithEncodedString:(NSString *)sourceString
{
    NSArray *dataValues;
    
    dataValues = [sourceString componentsSeparatedByString:@"|"];
    
    self = [self initWithFrame:NSZeroRect];
    
    if(self){
        // p0|p1|StrokeColor|StrokeWidth
        self.p0 = NSPointFromString([dataValues objectAtIndex:0]);
        self.p1 = NSPointFromString([dataValues objectAtIndex:1]);
        self.cp0 = NSPointFromString([dataValues objectAtIndex:2]);
        self.cp1 = NSPointFromString([dataValues objectAtIndex:3]);
        self.StrokeColor = [NSColor colorFromString:[dataValues objectAtIndex:4] forColorSpace:[NSColorSpace deviceRGBColorSpace]];
        self.FillColor = [NSColor colorFromString:[dataValues objectAtIndex:5] forColorSpace:[NSColorSpace deviceRGBColorSpace]];
        self.StrokeWidth = ((NSString *) [dataValues objectAtIndex:6]).floatValue;
        
        [self setNeedsDisplay:YES];
    }
    return self;
}

- (NSString *)encodedStringForCanvasObject
{
    NSMutableString *encodedString;
    
    encodedString = [[NSMutableString alloc] init];
    
    // p0|p1|StrokeColor|StrokeWidth
    [encodedString appendFormat:@"%@|", NSStringFromPoint(p0)];
    [encodedString appendFormat:@"%@|", NSStringFromPoint(p1)];
    [encodedString appendFormat:@"%@|", NSStringFromPoint(cp0)];
    [encodedString appendFormat:@"%@|", NSStringFromPoint(cp1)];
    [encodedString appendFormat:@"%@|", [self.StrokeColor stringRepresentation]];
    [encodedString appendFormat:@"%@|", [self.FillColor stringRepresentation]];
    [encodedString appendFormat:@"%f|", self.StrokeWidth];
    
    
    return [NSString stringWithString:encodedString];
}

- (CanvasObject *)drawMouseDown:(NSPoint)currentPointInCanvas
{
    p0 = currentPointInCanvas;
    currentPointInCanvas.x += 20;
    currentPointInCanvas.y += 20;
    cp0 = currentPointInCanvas;
    
    return self;
}

- (CanvasObject *)drawMouseDragged:(NSPoint)currentPointInCanvas
{
    p1 = currentPointInCanvas;
    currentPointInCanvas.x -= 20;
    currentPointInCanvas.y -= 20;
    cp1 = currentPointInCanvas;
    
    [self sizeToFit];
    
    return self;
}

- (CanvasObject *)drawMouseUp:(NSPoint)currentPointInCanvas
{
    p1 = currentPointInCanvas;
    currentPointInCanvas.x -= 20;
    currentPointInCanvas.y -= 20;
    cp1 = currentPointInCanvas;
    
    [self sizeToFit];
    
    return nil;
}

- (void)moved
{
    [[self.canvasUndoManager prepareWithInvocationTarget:self] setP0:p0];
    [[self.canvasUndoManager prepareWithInvocationTarget:self] setP1:p1];
    [[self.canvasUndoManager prepareWithInvocationTarget:self] setCp0:cp0];
    [[self.canvasUndoManager prepareWithInvocationTarget:self] setCp1:cp1];
    [self bindLinePointFromLocal];
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
    // hid:
    //  0:p0
    //  1:p1
    //  2:cp0
    //  3:cp1
    NSPoint p;
    switch (hid) {
        case 0:
            p = p0;
            break;
        case 1:
            p = p1;
            break;
        case 2:
            p = cp0;
            break;
        case 3:
            p = cp1;
            break;
    }
    return p;
}

- (void)editHandleDown:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid;
{
    // Undo登録
    [[self.canvasUndoManager prepareWithInvocationTarget:self] sizeToFit];
    switch (hid) {
        case 0:
            [[self.canvasUndoManager prepareWithInvocationTarget:self] setP0:p0];
            break;
        case 1:
            [[self.canvasUndoManager prepareWithInvocationTarget:self] setP1:p1];
            break;
        case 2:
            [[self.canvasUndoManager prepareWithInvocationTarget:self] setCp0:cp0];
            break;
        case 3:
            [[self.canvasUndoManager prepareWithInvocationTarget:self] setCp1:cp1];
            break;
    }
}

- (void)editHandleDragged:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid;
{
    switch (hid) {
        case 0:
            self.p0 = currentHandlePointInCanvas;
            break;
        case 1:
            self.p1 = currentHandlePointInCanvas;
            break;
        case 2:
            self.cp0 = currentHandlePointInCanvas;
            break;
        case 3:
            self.cp1 = currentHandlePointInCanvas;
            break;
    }
    
    [((MainCanvasView *)self.ownerMainCanvasView) resetCanvasObjectHandleForCanvasObject:self];
}

- (void)editHandleUp:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid;
{
    switch (hid) {
        case 0:
            self.p0 = currentHandlePointInCanvas;
            break;
        case 1:
            self.p1 = currentHandlePointInCanvas;
            break;
        case 2:
            self.cp0 = currentHandlePointInCanvas;
            break;
        case 3:
            self.cp1 = currentHandlePointInCanvas;
            break;
    }
}


- (void)bindLinePointToLocal
{
    lp0 = [self bindLinePointToLocalSub:p0];
    lp1 = [self bindLinePointToLocalSub:p1];
    lcp0 = [self bindLinePointToLocalSub:cp0];
    lcp1 = [self bindLinePointToLocalSub:cp1];
}

- (NSPoint)bindLinePointToLocalSub:(NSPoint)p
{
    return NSMakePoint(p.x - self.frame.origin.x, p.y - self.frame.origin.y);
}

- (void)bindLinePointFromLocal
{
    p0 = [self bindLinePointFromLocalSub:lp0];
    p1 = [self bindLinePointFromLocalSub:lp1];
    cp0 = [self bindLinePointFromLocalSub:lcp0];
    cp1 = [self bindLinePointFromLocalSub:lcp1];
}

- (NSPoint)bindLinePointFromLocalSub:(NSPoint)p
{
    return NSMakePoint(p.x + self.frame.origin.x, p.y + self.frame.origin.y);
}

- (void)sizeToFit
{
    NSRect r;
    /*
    [bp moveToPoint:lp0];
    [bp curveToPoint:lp1 controlPoint1:lcp0 controlPoint2:lcp1];
    
    r = [self convertRect:[bp controlPointBounds] toView:self.superview];
    [self setBodyRect:r];
    [self bindLinePointToLocal];
    [bp removeAllPoints];
     */
    // キャンバス座標ベース
    [bp moveToPoint:p0];
    [bp curveToPoint:p1 controlPoint1:cp0 controlPoint2:cp1];
    
    r = [bp controlPointBounds];
    [self setBodyRect:r];
    [self bindLinePointToLocal];
    [bp removeAllPoints];
    [self setNeedsDisplay:YES];
}

@end
