//
//  CanvasObjectPaintFrame.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/06/09.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObjectPaintFrame.h"
#import "NSData+HexadecimalConversion.h"
#import "NSColor+StringConversion.h"
#import "NSColor+HexValueConversion.h"
#import "FWKBitmap.h"

@implementation CanvasObjectPaintFrame
{
    FWKBitmap *bitmap;
}

@synthesize ObjectType = _ObjectType;

- (void)setStrokeWidth:(CGFloat)StrokeWidth
{
    [super setStrokeWidth:floor(StrokeWidth + 0.5)];
}

- (void)setFrameOrigin:(NSPoint)newOrigin
{
    NSPoint bodyOrigin;
    
    bodyOrigin = newOrigin;
    bodyOrigin.x += (self.StrokeWidth / 2);
    bodyOrigin.y += (self.StrokeWidth / 2);
    bodyOrigin.x = floor(bodyOrigin.x + 0.5);
    bodyOrigin.y = floor(bodyOrigin.y + 0.5);
    newOrigin = bodyOrigin;
    newOrigin.x -= (self.StrokeWidth / 2);
    newOrigin.y -= (self.StrokeWidth / 2);
    
    [super setFrameOrigin:newOrigin];
}

//
// Function
//

// NSView override
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _ObjectType = PaintFrame;
        bitmap = [[FWKBitmap alloc] init];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef mainContext;
    
    mainContext = [[NSGraphicsContext currentContext] graphicsPort];
    [bitmap drawRectWithContext:mainContext];
    CGContextSetStrokeColorWithColor(mainContext, self.StrokeColor.CGColor);
    CGContextStrokeRectWithWidth(mainContext, self.bodyRectBounds, self.StrokeWidth);
    
    [self drawFocusRect];
}

// data encoding
- (id)initWithEncodedString:(NSString *)sourceString
{
    NSArray *dataValues;
    
    dataValues = [sourceString componentsSeparatedByString:@"|"];
    
    self = [self initWithFrame:NSZeroRect];
    
    if(self){
        // BodyRect|FillColor|StrokeColor|StrokeWidth|BMPData
        [self setBodyRect:NSRectFromString([dataValues objectAtIndex:0])];
        
        [self resetPaintContext];
        self.FillColor = [NSColor colorFromString:[dataValues objectAtIndex:1] forColorSpace:[NSColorSpace deviceRGBColorSpace]];
        self.StrokeColor = [NSColor colorFromString:[dataValues objectAtIndex:2] forColorSpace:[NSColorSpace deviceRGBColorSpace]];
        self.StrokeWidth = ((NSString *) [dataValues objectAtIndex:3]).floatValue;
        [bitmap copyBufferFromNSData:[[NSData alloc] initWithHexadecimalString:[dataValues objectAtIndex:4]]];
        [self setNeedsDisplay:YES];
    }
    
    return self;
}

- (NSString *)encodedStringForCanvasObject
{
    NSMutableString *encodedString;
    NSData *contextData;
    
    encodedString = [[NSMutableString alloc] init];
    
    [self drawRect:self.bodyRectBounds];
    //データを生成
    contextData = [bitmap bufferData];
    
    // BodyRect|FillColor|StrokeColor|StrokeWidth|BMPData
    [encodedString appendFormat:@"%@|", NSStringFromRect(self.bodyRect)];
    [encodedString appendFormat:@"%@|", [self.FillColor stringRepresentation]];
    [encodedString appendFormat:@"%@|", [self.StrokeColor stringRepresentation]];
    [encodedString appendFormat:@"%f|", self.StrokeWidth];
    [encodedString appendFormat:@"%@|", [contextData hexadecimalString]];
    
    return [NSString stringWithString:encodedString];
}

// paintContext
- (void)resetPaintContext
{
    [bitmap resetBitmapContextToSize:self.bodyRectBounds.size];
}

// Preview drawing
- (CanvasObject *)drawMouseDown:(NSPoint)currentPointInCanvas
{
    // 初期描画中は変形を記録しないようにする
    [[self.canvasUndoManager prepareWithInvocationTarget:self] setFrame:self.frame];
    //https://github.com/Pixen/Pixen/issues/228
    [self.canvasUndoManager endUndoGrouping];
    [self.canvasUndoManager disableUndoRegistration];
    //
    drawingStartPoint = currentPointInCanvas;
    
    return self;
}

- (CanvasObject *)drawMouseDragged:(NSPoint)currentPointInCanvas
{
    [self setFrame:[CanvasObject makeNSRectFromMouseMovingWithModifierKey:drawingStartPoint :currentPointInCanvas]];
    [self setNeedsDisplay:YES];
    return [super drawMouseDragged:currentPointInCanvas];
}

- (CanvasObject *)drawMouseUp:(NSPoint)currentPointInCanvas
{
    [self setFrame:[CanvasObject makeNSRectFromMouseMovingWithModifierKey:drawingStartPoint :currentPointInCanvas]];
    [self setNeedsDisplay:YES];
    //
    [self.canvasUndoManager enableUndoRegistration];
    //
    [self resetPaintContext];
    return nil;
}

// EditHandle <CanvasObjectHandling>
- (void)editHandleUp:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid;
{
    [super editHandleUp:currentHandlePointInCanvas forHandleID:hid];
    [self resetPaintContext];
}

// User interaction
- (void)drawPaintFrameMouseDown:(NSPoint)currentPointInCanvas mode:(CanvasObjectType)mode
{
    NSPoint localPoint = [self convertPoint:currentPointInCanvas fromView:self.superview];
    localPoint.x -= self.StrokeWidth / 2;
    localPoint.y -= self.StrokeWidth / 2;
    localPoint.x = floor(localPoint.x);
    localPoint.y = floor(localPoint.y);
    
    drawingStartPoint = localPoint;
    
    if(mode == PaintPen){
        //ペンはクリックした時点で点を打つ
        [bitmap strokePoint:drawingStartPoint withColor:self.StrokeColor size:self.StrokeWidth];
        [self setNeedsDisplay:YES];
    }
}
- (void)drawPaintFrameMouseDragged:(NSPoint)currentPointInCanvas mode:(CanvasObjectType)mode
{
    NSPoint localPoint = [self convertPoint:currentPointInCanvas fromView:self.superview];
    localPoint.x -= self.StrokeWidth / 2;
    localPoint.y -= self.StrokeWidth / 2;
    localPoint.x = floor(localPoint.x);
    localPoint.y = floor(localPoint.y);
    
    CGRect rect;
    
    if(mode > PaintToolsBase && mode != PaintPen){
        //描画中なので、オーバーレイコンテキストをクリア
        [bitmap clearOverlayContext];
    }
    
    rect = NSRectToCGRect([CanvasObject makeNSRectFromMouseMovingWithModifierKey:drawingStartPoint :localPoint]);
    
    switch(mode){
        case PaintRectangle:
            [bitmap paintRectangle:rect withFillColor:self.FillColor strokeColor:self.StrokeColor strokeWidth:self.StrokeWidth];
            break;
        case PaintEllipse:
            [bitmap paintEllipse:rect withFillColor:self.FillColor strokeColor:self.StrokeColor strokeWidth:self.StrokeWidth];
            break;
        case PaintPen:
            [bitmap paintLineFrom:drawingStartPoint to:localPoint withStrokeColor:self.StrokeColor strokeWidth:self.StrokeWidth];
            drawingStartPoint = localPoint;
            break;
        case PaintLine:
            [bitmap paintLineFrom:drawingStartPoint to:localPoint withStrokeColor:self.StrokeColor strokeWidth:self.StrokeWidth];
            break;
        default:
            break;
    }
    [self setNeedsDisplay:YES];
}

- (void)drawPaintFrameMouseUp:(NSPoint)currentPointInCanvas mode:(CanvasObjectType)mode
{
    NSPoint localPoint = [self convertPoint:currentPointInCanvas fromView:self.superview];
    localPoint.x -= self.StrokeWidth / 2;
    localPoint.y -= self.StrokeWidth / 2;
    localPoint.x = floor(localPoint.x);
    localPoint.y = floor(localPoint.y);
    
    //編集結果を適用
    if(mode > PaintToolsBase){
        [bitmap applyOverlayContext];
    }
    if(mode == PaintFill){
        // 塗りつぶし
        [bitmap selectBitmapAreaByPoint:localPoint];
        [bitmap fillBySelectionMapWithColor:self.FillColor];
    }
}
@end
