//
//  CanvasObjectPaintFrame.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/06/09.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObjectPaintFrame.h"
#import "NSData+HexadecimalConversion.h"

@implementation CanvasObjectPaintFrame

@synthesize ObjectType = _ObjectType;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _ObjectType = PaintFrame;
        paintContext = NULL;
        editingContext = NULL;
        bmpBuffer = NULL;
        contextRect = CGRectNull;
        
        [self resetPaintContext];
    }
    
    return self;
}

- (id)initWithEncodedString:(NSString *)sourceString
{
    NSArray *dataValues;
    NSBitmapImageRep *bitmap;
    
    dataValues = [sourceString componentsSeparatedByString:@"|"];
    
    self = [self initWithFrame:NSRectFromString([dataValues objectAtIndex:0])];
    
    if(self){
        bitmap = [NSBitmapImageRep imageRepWithData:[[NSData alloc] initWithHexadecimalString:[dataValues objectAtIndex:1]]];
        //NSLog(@"%@", bitmap);
        CGContextDrawImage(paintContext, CGRectMake(0, 0, bitmap.size.width, bitmap.size.height), [bitmap CGImage]);
        [self setNeedsDisplay:YES];
    }
    
    return self;
}

//Frame|Data
- (NSString *)encodedStringForCanvasObject
{
    NSMutableString *encodedString;
    NSImage *contextImage;
    NSData *contextData;
    CGImageRef imageRef;
    
    encodedString = [[NSMutableString alloc] init];
    
    //PNGデータを生成
    imageRef = CGBitmapContextCreateImage(paintContext);
    contextImage = [[NSImage alloc] initWithCGImage:imageRef size:self.frame.size];
    CFRelease(imageRef);
    
    contextData = [contextImage TIFFRepresentation];
    
    [encodedString appendFormat:@"%@|", NSStringFromRect(self.frame)];
    [encodedString appendFormat:@"%@|", [contextData hexadecimalString]];
    
    return [NSString stringWithString:encodedString];
}

- (void)resetPaintContext
{
    int px, py;
    CGColorSpaceRef aColorSpace;
    
    if(paintContext != NULL){
        CGContextRelease(paintContext);
        CGContextRelease(editingContext);
    }
    
    if(bmpBuffer != NULL){
        free(bmpBuffer);
    }
    
    px = ceilf(self.frame.size.width);
    py = ceilf(self.frame.size.height);
    contextRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    aColorSpace = CGColorSpaceCreateDeviceRGB();
    
    bmpBuffer = malloc(4 * px * py);
    if(bmpBuffer != NULL){
        paintContext = CGBitmapContextCreate(bmpBuffer, px, py, 8, px * 4, aColorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
        if(paintContext == NULL){
            free(bmpBuffer);
            NSRunAlertPanel(@"FukoWorks:PaintFrame", @"paintコンテキスト生成に失敗しました。", @"OK", nil, nil);
        }
        editingContext = CGBitmapContextCreate(nil, px, py, 8, px * 4, aColorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
        if(editingContext == NULL){
            NSRunAlertPanel(@"FukoWorks:PaintFrame", @"editingコンテキスト生成に失敗しました。", @"OK", nil, nil);
        }
    } else{
        NSRunAlertPanel(@"FukoWorks:PaintFrame", @"メモリ確保に失敗しました。", @"OK", nil, nil);
    }
    
    CGColorSpaceRelease(aColorSpace);
    
    if(paintContext == NULL){
        return;
    }
    CGContextSetShouldAntialias(paintContext, false);
    CGContextSetShouldAntialias(editingContext, false);
    CGContextSetRGBFillColor(paintContext, 1, 1, 1, 1);
    CGContextFillRect(paintContext, contextRect);
    CGContextSetRGBFillColor(editingContext, 0, 0, 0, 0);
    CGContextFillRect(editingContext, self.bounds);
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef mainContext;
    CGImageRef paintImage, editingImage;
    
    mainContext = [[NSGraphicsContext currentContext] graphicsPort];
    if(paintContext && editingContext){
        CGContextSetShouldAntialias(mainContext, false);
        paintImage = CGBitmapContextCreateImage(paintContext);
        editingImage = CGBitmapContextCreateImage(editingContext);
        CGContextDrawImage(mainContext, contextRect, paintImage);
        CGContextDrawImage(mainContext, contextRect, editingImage);
        CGImageRelease(paintImage);
        CGImageRelease(editingImage);
    }
    
    [self drawFocusRect];
}

- (CanvasObject *)drawMouseDown:(NSPoint)currentPointInCanvas
{
    currentPointInCanvas = [self getNSPointIntegral:currentPointInCanvas];
    //
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
    return [super drawMouseDragged:[self getNSPointIntegral:currentPointInCanvas]];
}

- (CanvasObject *)drawMouseUp:(NSPoint)currentPointInCanvas
{
    currentPointInCanvas = [self getNSPointIntegral:currentPointInCanvas];
    //
    [self setFrame:[self makeNSRectFromMouseMoving:drawingStartPoint :currentPointInCanvas]];
    [self setNeedsDisplay:YES];
    //
    [self.undoManager enableUndoRegistration];
    //
    [self resetPaintContext];
    return nil;
}

//
//
//

- (void)editHandleDown:(NSPoint)currentHandlePointInCanvas :(NSInteger)tag
{
    [super editHandleDown:[self getNSPointIntegral:currentHandlePointInCanvas] forHandleID:tag];
}

- (void)editHandleDragged:(NSPoint)currentHandlePointInCanvas :(NSInteger)tag
{
    [super editHandleDragged:[self getNSPointIntegral:currentHandlePointInCanvas] forHandleID:tag];
}

- (void)editHandleUp:(NSPoint)currentHandlePointInCanvas :(NSInteger) tag
{
    currentHandlePointInCanvas = [self getNSPointIntegral:currentHandlePointInCanvas];

    [super editHandleUp:currentHandlePointInCanvas forHandleID:tag];
    [self resetPaintContext];
}

//
// drawing to paintframe context
//

- (void)drawPaintFrameMouseDown:(NSPoint)currentPointInCanvas mode:(CanvasObjectType)mode
{
    NSPoint localPoint = [self getNSPointIntegral:[self convertPoint:currentPointInCanvas fromView:self.superview]];
    
    drawingStartPoint = localPoint;
    
    if(mode == PaintPen){
        //ペンはクリックした時点で点を打つ
        CGContextBeginPath(editingContext);
        CGContextMoveToPoint(editingContext, drawingStartPoint.x - (self.StrokeWidth / 2), drawingStartPoint.y);
        CGContextAddLineToPoint(editingContext, drawingStartPoint.x + (self.StrokeWidth / 2), drawingStartPoint.y);
        CGContextClosePath(editingContext);
        CGContextSetStrokeColorWithColor(editingContext, self.StrokeColor.CGColor);
        CGContextSetLineWidth(editingContext, floor(self.StrokeWidth + 0.5));
        CGContextStrokePath(editingContext);
        //NSLog(@"drawPoint!%f",self.StrokeWidth);
        [self setNeedsDisplay:YES];
    }
}
- (void)drawPaintFrameMouseDragged:(NSPoint)currentPointInCanvas mode:(CanvasObjectType)mode
{
    NSPoint localPoint = [self getNSPointIntegral:[self convertPoint:currentPointInCanvas fromView:self.superview]];
    CGRect rect;
    
    if(mode > PaintToolsBase && mode != PaintPen){
        //描画中なので、編集中コンテキストをクリア
        //NSLog(@"%@", NSStringFromPoint(localPoint));
        CGContextClearRect(editingContext, contextRect);
    }
    
    rect = NSRectToCGRect([self makeNSRectFromMouseMoving:drawingStartPoint :localPoint]);
    
    CGContextSaveGState(editingContext);
    {
        switch(mode){
            case PaintRectangle:
                CGContextSetFillColorWithColor(editingContext, self.FillColor.CGColor);
                CGContextFillRect(editingContext, rect);
                //
                CGContextSetStrokeColorWithColor(editingContext, self.StrokeColor.CGColor);
                CGContextStrokeRectWithWidth(editingContext, rect, floor(self.StrokeWidth + 0.5));
                break;
            case PaintEllipse:
                CGContextAddEllipseInRect(editingContext, rect);
                CGContextSetFillColorWithColor(editingContext, self.FillColor.CGColor);
                CGContextFillPath(editingContext);
                //
                CGContextAddEllipseInRect(editingContext, rect);
                CGContextSetStrokeColorWithColor(editingContext, self.StrokeColor.CGColor);
                CGContextSetLineWidth(editingContext, floor(self.StrokeWidth + 0.5));
                CGContextStrokePath(editingContext);
                break;
            case PaintPen:
                CGContextMoveToPoint(editingContext, drawingStartPoint.x, drawingStartPoint.y);
                CGContextAddLineToPoint(editingContext, localPoint.x, localPoint.y);
                CGContextSetStrokeColorWithColor(editingContext, self.StrokeColor.CGColor);
                CGContextSetLineWidth(editingContext, floor(self.StrokeWidth + 0.5));
                CGContextStrokePath(editingContext);
                drawingStartPoint = localPoint;
                break;
            default:
                break;
        }
    }
    CGContextRestoreGState(editingContext);
    
    [self setNeedsDisplay:YES];
}
- (void)drawPaintFrameMouseUp:(NSPoint)currentPointInCanvas mode:(CanvasObjectType)mode
{
    //NSPoint localPoint = [self getNSPointIntegral:[self convertPoint:currentPointInCanvas fromView:self.superview]];
    
    CGImageRef editingImage;
    
    //編集結果を適用
    if(mode > PaintToolsBase){
        editingImage = CGBitmapContextCreateImage(editingContext);
        
        CGContextSetShouldAntialias(paintContext, false);
        CGContextDrawImage(paintContext, contextRect, editingImage);
        CGContextClearRect(editingContext, contextRect);
        
        CGImageRelease(editingImage);
    }
}

- (NSPoint)getNSPointIntegral: (NSPoint)basePoint
{
    basePoint.x += 0.5;
    basePoint.y += 0.5;
    basePoint.x = floor(basePoint.x) + 0.5;
    basePoint.y = floor(basePoint.y) + 0.5;
    return basePoint;
}

//
// ViewComputing
//
// Without StrokeWidth version
- (NSRect)makeNSRectFromMouseMoving:(NSPoint)startPoint :(NSPoint)endPoint
{
    //全体を含むframeRectを返す。
    NSPoint p;
    NSSize q;
    
    if(endPoint.x < startPoint.x){
        p.x = endPoint.x;
        q.width = startPoint.x - endPoint.x;
    } else{
        p.x = startPoint.x;
        q.width = endPoint.x - startPoint.x;
    }
    
    if(endPoint.y < startPoint.y){
        p.y = endPoint.y;
        q.height = startPoint.y - endPoint.y;
    } else{
        p.y = startPoint.y;
        q.height = endPoint.y - startPoint.y;
    }
    
    return NSMakeRect(p.x, p.y, q.width, q.height);
}

- (NSRect)makeNSRectWithRealSizeViewFrame
{
    //親FrameにおけるRealSizeRect(Fill部分のみのRect)を返す。
    return self.frame;
}

- (NSRect)makeNSRectWithRealSizeViewFrameInLocal
{
    //このViewに対する、ローカル座標のRealSizeRect(Fill部分のみのRect)を返す。
    return self.frame;
}

- (NSRect)makeNSRectWithFullSizeViewFrameFromRealSizeViewFrame:(NSRect)RealSizeViewFrame
{
    return self.frame;
}



@end
