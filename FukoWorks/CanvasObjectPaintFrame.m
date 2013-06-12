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
        _paintContext = NULL;
        bmpBuffer = NULL;
        
        [self resetPaintContext];
    }
    
    return self;
}

- (void)resetPaintContext
{
    int px, py;
    CGColorSpaceRef aColorSpace;
    
    if(_paintContext != NULL){
        CGContextRelease(_paintContext);
    }
    
    if(bmpBuffer != NULL){
        free(bmpBuffer);
    }
    
    px = ceilf(self.frame.size.width);
    py = ceilf(self.frame.size.height);
    aColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    
    bmpBuffer = malloc(4 * px * py);
    if(bmpBuffer != NULL){
        _paintContext = CGBitmapContextCreate(bmpBuffer, px, py, 8, px * 4, aColorSpace, kCGImageAlphaPremultipliedLast);
        if(_paintContext == NULL){
            free(bmpBuffer);
            NSRunAlertPanel(@"FukoWorks:PaintFrame", @"コンテキスト生成に失敗しました。", @"OK", nil, nil);
        }
    } else{
        NSRunAlertPanel(@"FukoWorks:PaintFrame", @"メモリ確保に失敗しました。", @"OK", nil, nil);
    }
    
    CGColorSpaceRelease(aColorSpace);
    
    if(_paintContext == NULL){
        return;
    }
    CGContextSetRGBFillColor(_paintContext, 1, 1, 1, 1);
    CGContextFillRect(_paintContext, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef mainContext;
    CGImageRef anImage;
    
    mainContext = [[NSGraphicsContext currentContext] graphicsPort];
    if(_paintContext != NULL){
        anImage = CGBitmapContextCreateImage(_paintContext);
        
        CGContextSaveGState(mainContext);
        {
            CGContextDrawImage(mainContext, self.bounds, anImage);
        }
        CGContextRestoreGState(mainContext);
        
        CGImageRelease(anImage);
    }
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

@end
