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
#import "FukoWorks.h"

@implementation CanvasObjectPaintFrame
{
    FWKBitmap *bitmap;
}

@synthesize ObjectType = _ObjectType;
- (void)setCanvasUndoManager:(NSUndoManager *)canvasUndoManager
{
    [super setCanvasUndoManager:canvasUndoManager];
    bitmap.undoManager = canvasUndoManager;
}

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

@synthesize PaintFillColor = _PaintFillColor;
@synthesize PaintStrokeColor = _PaintStrokeColor;
@synthesize PaintStrokeWidth = _PaintStrokeWidth;

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
        bitmap.ownerView = self;
    }
    
    return self;
}

- (void)drawInBodyRect:(CGContextRef)mainContext
{
    [bitmap drawRectWithContext:mainContext inRect:self.bodyRectBounds];
    
    CGContextSetStrokeColorWithColor(mainContext, self.StrokeColor.CGColor);
    CGContextStrokeRectWithWidth(mainContext, self.bodyRectBounds, self.StrokeWidth);
}

// data encoding
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
        // BMPData
        s = [dataValues objectAtIndex:0];
        [self setBodyRect:NSRectFromString([dataValues objectAtIndex:0])];
        [self resetPaintContext];
        s = [dataValues objectAtIndex:1];
        self.rotationAngle = s.floatValue;
        s = [dataValues objectAtIndex:2];
        self.FillColor = [NSColor colorFromString:s forColorSpace:[NSColorSpace deviceRGBColorSpace]];
        s = [dataValues objectAtIndex:3];
        self.StrokeColor = [NSColor colorFromString:s forColorSpace:[NSColorSpace deviceRGBColorSpace]];
        s = [dataValues objectAtIndex:4];
        self.StrokeWidth = s.floatValue;
        s = [dataValues objectAtIndex:5];
        [bitmap copyBufferFromNSData:[[NSData alloc] initWithHexadecimalString:s]];
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
    
    // BodyRect
    // RotationAngle
    // FillColor
    // StrokeColor
    // StrokeWidth
    // BMPData
    [encodedString appendFormat:@"%@|", NSStringFromRect(self.bodyRect)];
    [encodedString appendFormat:@"%f|", self.rotationAngle];
    [encodedString appendFormat:@"%@|", [self.FillColor stringRepresentation]];
    [encodedString appendFormat:@"%@|", [self.StrokeColor stringRepresentation]];
    [encodedString appendFormat:@"%f|", self.StrokeWidth];
    [encodedString appendFormat:@"%@|", [contextData hexadecimalString]];
    
    return [NSString stringWithString:encodedString];
}

// paintContext
- (void)resetPaintContext
{
    // 小さすぎるとコンテキスト生成に失敗するので、ある程度の大きさを確保する
    if(self.bodyRect.size.width < FWK_MIN_SIZE_PIXEL_PAINTFRAME){
        [self setFrameSize:NSMakeSize(FWK_MIN_SIZE_PIXEL_PAINTFRAME, self.bodyRect.size.height)];
    }
    if(self.bodyRect.size.height < FWK_MIN_SIZE_PIXEL_PAINTFRAME){
        [self setFrameSize:NSMakeSize(self.bodyRect.size.width, FWK_MIN_SIZE_PIXEL_PAINTFRAME)];
    }
    [bitmap resetBitmapContextToSize:self.bodyRectBounds.size];
}

// Preview drawing
-(CanvasObject *)drawMouseDown:(NSPoint)currentPointInCanvas
{
    [self.canvasUndoManager beginUndoGrouping];
    return [super drawMouseDown:currentPointInCanvas];
}

- (CanvasObject *)drawMouseUp:(NSPoint)currentPointInCanvas
{
    [super drawMouseUp:currentPointInCanvas];
    [self resetPaintContext];
    [self.canvasUndoManager endUndoGrouping];
    [self setNeedsDisplay:YES];
    
    return nil;
}

// EditHandle <CanvasObjectHandling>

-(void)editHandleDown:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid
{
    [self.canvasUndoManager beginUndoGrouping];
    [super editHandleDown:currentHandlePointInCanvas forHandleID:hid];
}

- (void)editHandleUp:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid
{
    [super editHandleUp:currentHandlePointInCanvas forHandleID:hid];
    [self resetPaintContext];
    [self.canvasUndoManager endUndoGrouping];
    [self setNeedsDisplay:YES];
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
            [bitmap paintRectangle:rect withFillColor:self.PaintFillColor strokeColor:self.PaintStrokeColor strokeWidth:self.PaintStrokeWidth];
            break;
        case PaintEllipse:
            [bitmap paintEllipse:rect withFillColor:self.PaintFillColor strokeColor:self.PaintStrokeColor strokeWidth:self.PaintStrokeWidth];
            break;
        case PaintPen:
            [bitmap paintLineFrom:drawingStartPoint to:localPoint withStrokeColor:self.PaintStrokeColor strokeWidth:self.PaintStrokeWidth];
            drawingStartPoint = localPoint;
            break;
        case PaintLine:
            [bitmap paintLineFrom:drawingStartPoint to:localPoint withStrokeColor:self.PaintStrokeColor strokeWidth:self.PaintStrokeWidth];
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
        [bitmap fillBySelectionMapWithColor:self.PaintFillColor];
    }
}
@end
