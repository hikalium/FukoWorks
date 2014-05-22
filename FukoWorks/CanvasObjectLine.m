//
//  CanvasObjectLine.m
//  FukoWorks
//
//  Created by 西田　耀 on 2014/03/28.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObjectLine.h"
#import "CanvasObjectHandle.h"
#import "MainCanvasView.h"
#import "NSColor+StringConversion.h"

@implementation CanvasObjectLine
{
    NSPoint p0, p1; //キャンバス座標
    NSPoint lp0, lp1;   //このビューにおける座標
}
//プロパティアクセッサメソッド
@synthesize ObjectType = _ObjectType;
@synthesize p0 = p0;
- (void)setP0:(NSPoint)_p0
{
    if([self.canvasUndoManager isUndoing] || [self.canvasUndoManager isRedoing]){
        [[self.canvasUndoManager prepareWithInvocationTarget:self] setP0:p0];
    }
    //
    p0 = _p0;
    [self setBodyRect:[CanvasObject makeNSRectFromMouseMoving:p0 :p1]];
    [self bindLinePointToLocal];
    [self setNeedsDisplay:YES];
}
@synthesize p1 = p1;
- (void)setP1:(NSPoint)_p1
{
    if([self.canvasUndoManager isUndoing] || [self.canvasUndoManager isRedoing]){
        [[self.canvasUndoManager prepareWithInvocationTarget:self] setP1:p1];
    }
    //
    p1 = _p1;
    [self setBodyRect:[CanvasObject makeNSRectFromMouseMoving:p0 :p1]];
    [self bindLinePointToLocal];
    [self setNeedsDisplay:YES];
}

// メソッド
- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        _ObjectType = Line;
        p0 = NSZeroPoint;
        p1 = NSZeroPoint;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //再描画時に呼ばれる。
    CGContextRef mainContext;
    
    mainContext = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextSaveGState(mainContext);
    {
        CGContextBeginPath(mainContext);
        CGContextMoveToPoint(mainContext, lp0.x, lp0.y);
        CGContextAddLineToPoint(mainContext, lp1.x, lp1.y);
        CGContextClosePath(mainContext);
        CGContextSetStrokeColorWithColor(mainContext, self.StrokeColor.CGColor);
        CGContextSetLineWidth(mainContext, self.StrokeWidth);
        CGContextStrokePath(mainContext);
    }
    CGContextRestoreGState(mainContext);
}

// data encoding
- (id)initWithEncodedString:(NSString *)sourceString
{
    NSArray *dataValues;
    
    dataValues = [sourceString componentsSeparatedByString:@"|"];
    
    self = [self initWithFrame:NSZeroRect];
    
    if(self){
        // p0|p1|StrokeColor|StrokeWidth
        p0 = NSPointFromString([dataValues objectAtIndex:0]);
        p1 = NSPointFromString([dataValues objectAtIndex:1]);
        [self setBodyRect:[CanvasObject makeNSRectFromMouseMoving:p0 :p1]];
        [self bindLinePointToLocal];
        self.StrokeColor = [NSColor colorFromString:[dataValues objectAtIndex:2] forColorSpace:[NSColorSpace deviceRGBColorSpace]];
        self.StrokeWidth = ((NSString *) [dataValues objectAtIndex:3]).floatValue;
        
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
    [encodedString appendFormat:@"%@|", [self.StrokeColor stringRepresentation]];
    [encodedString appendFormat:@"%f|", self.StrokeWidth];
    
    return [NSString stringWithString:encodedString];
}

- (CanvasObject *)drawMouseDown:(NSPoint)currentPointInCanvas
{
    // 初期描画中は変形を記録しないようにする
    [[self.canvasUndoManager prepareWithInvocationTarget:self] setFrame:self.frame];

    p0 = currentPointInCanvas;
    
    return self;
}

- (CanvasObject *)drawMouseDragged:(NSPoint)currentPointInCanvas
{
    p1 = currentPointInCanvas;
    [self setBodyRect:[CanvasObject makeNSRectFromMouseMoving:p0 :p1]];
    [self bindLinePointToLocal];
    [self setNeedsDisplay:YES];
    
    return self;
}

- (CanvasObject *)drawMouseUp:(NSPoint)currentPointInCanvas
{
    p1 = currentPointInCanvas;
    [self setBodyRect:[CanvasObject makeNSRectFromMouseMoving:p0 :p1]];
    [self bindLinePointToLocal];
    [self setNeedsDisplay:YES];
    
    return nil;
}

- (void)moved
{
    [[self.canvasUndoManager prepareWithInvocationTarget:self] setP0:p0];
    [[self.canvasUndoManager prepareWithInvocationTarget:self] setP1:p1];
    [self bindLinePointFromLocal];
}

//
// EditHandle
//
- (NSUInteger)numberOfEditHandlesForCanvasObject
{
    return 2;
}

- (NSPoint)editHandlePointForHandleID:(NSUInteger)hid
{
    // hid:
    //  0:p0
    //  1:p1
    NSPoint p;
    switch (hid) {
        case 0:
            p = p0;
            break;
        case 1:
            p = p1;
            break;
    }
    return p;
}

- (void)editHandleDown:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid;
{
    if(hid == 0){
        [[self.canvasUndoManager prepareWithInvocationTarget:self] setP0:p0];
    } else{
        [[self.canvasUndoManager prepareWithInvocationTarget:self] setP1:p1];
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
    }
}


- (void)bindLinePointToLocal
{
    lp0.x = p0.x - self.frame.origin.x;
    lp0.y = p0.y - self.frame.origin.y;
    lp1.x = p1.x - self.frame.origin.x;
    lp1.y = p1.y - self.frame.origin.y;
}

- (void)bindLinePointFromLocal
{
    p0.x = lp0.x + self.frame.origin.x;
    p0.y = lp0.y + self.frame.origin.y;
    p1.x = lp1.x + self.frame.origin.x;
    p1.y = lp1.y + self.frame.origin.y;
}

@end
