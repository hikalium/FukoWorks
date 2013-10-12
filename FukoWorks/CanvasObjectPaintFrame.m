//
//  CanvasObjectPaintFrame.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/06/09.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObjectPaintFrame.h"

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
        paintContext = CGBitmapContextCreate(bmpBuffer, px, py, 8, px * 4, aColorSpace, kCGImageAlphaPremultipliedLast);
        if(paintContext == NULL){
            free(bmpBuffer);
            NSRunAlertPanel(@"FukoWorks:PaintFrame", @"paintコンテキスト生成に失敗しました。", @"OK", nil, nil);
        }
        editingContext = CGBitmapContextCreate(nil, px, py, 8, px * 4, aColorSpace, kCGImageAlphaPremultipliedLast);
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
    CGContextSetRGBFillColor(paintContext, 0, 1, 0, 0.5);
    CGContextFillRect(paintContext, contextRect);
    //CGContextClearRect(paintContext, contextRect);
    //CGContextClearRect(editingContext, contextRect);
}

- (void)drawRect:(NSRect)dirtyRect
{
    
    CGContextRef mainContext;
    CGImageRef paintImage, editingImage;
    /*
    mainContext = [[NSGraphicsContext currentContext] graphicsPort];
    if(paintContext && editingContext){
        CGContextClearRect(mainContext, contextRect);
        
        paintImage = CGBitmapContextCreateImage(paintContext);
        editingImage = CGBitmapContextCreateImage(editingContext);
        
        CGContextDrawImage(mainContext, contextRect, paintImage);
        CGContextDrawImage(mainContext, contextRect, editingImage);
        
        CGImageRelease(paintImage);
        CGImageRelease(editingImage);
    }
     */
    mainContext = [[NSGraphicsContext currentContext] graphicsPort];
    paintImage = CGBitmapContextCreateImage(paintContext);
    CGContextDrawImage(mainContext, contextRect, paintImage);
    
    
}

- (CanvasObject *)drawMouseDown:(NSPoint)currentPointInCanvas
{
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
    [self resetPaintContext];
    [self setNeedsDisplay:YES];
    
    return nil;
}

- (void)editHandleUp:(NSPoint)currentHandlePointInCanvas :(NSInteger) tag
{
    [super editHandleUp:currentHandlePointInCanvas :tag];
    [self resetPaintContext];
}

//
// drawing to paintframe context
//

- (void)drawPaintFrameMouseDown:(NSPoint)currentPointInCanvas mode:(CanvasObjectType)mode
{
    NSPoint localPoint = [self convertPoint:currentPointInCanvas fromView:self.superview];
    
    drawingStartPoint = localPoint;
    
}
- (void)drawPaintFrameMouseDragged:(NSPoint)currentPointInCanvas mode:(CanvasObjectType)mode
{
    NSPoint localPoint = [self convertPoint:currentPointInCanvas fromView:self.superview];
    CGRect rect;
    
    if(mode > PaintToolsBase){
        //描画中なので、編集中コンテキストをクリア
        //NSLog(@"%@", NSStringFromPoint(localPoint));
        CGContextClearRect(editingContext, contextRect);
    }
    
    rect = NSRectToCGRect([self makeNSRectFromMouseMoving:drawingStartPoint :localPoint]);
    
    CGContextSaveGState(editingContext);
    {
        switch(mode){
            case PaintRectangle:
                CGContextSetFillColorWithColor(editingContext, self.FillColor);
                CGContextFillRect(editingContext, rect);
                CGContextSetStrokeColorWithColor(editingContext, self.StrokeColor);
                CGContextStrokeRectWithWidth(editingContext, rect, self.StrokeWidth);
                break;
            case PaintEllipse:
                CGContextAddEllipseInRect(editingContext, rect);
                CGContextSetFillColorWithColor(editingContext, self.FillColor);
                CGContextFillPath(editingContext);
                
                CGContextAddEllipseInRect(editingContext, rect);
                CGContextSetStrokeColorWithColor(editingContext, self.StrokeColor);
                CGContextSetLineWidth(editingContext, self.StrokeWidth);
                CGContextStrokePath(editingContext);
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
    //NSPoint localPoint = [self convertPoint:currentPointInCanvas fromView:self.superview];
    
    CGImageRef editingImage;
    
    //編集結果を適用
    if(mode > PaintToolsBase){
        editingImage = CGBitmapContextCreateImage(editingContext);
        
        CGContextDrawImage(paintContext, contextRect, editingImage);
        CGContextClearRect(editingContext, contextRect);
        
        CGImageRelease(editingImage);
    }
}

@end
