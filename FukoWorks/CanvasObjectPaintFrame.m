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

@implementation CanvasObjectPaintFrame

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
        paintContext = NULL;
        editingContext = NULL;
        bmpBuffer = NULL;
        contextRect = CGRectNull;
    }
    
    return self;
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
        
        CGContextDrawImage(mainContext, self.bodyRectBounds, paintImage);
        CGContextDrawImage(mainContext, self.bodyRectBounds, editingImage);
        CGImageRelease(paintImage);
        CGImageRelease(editingImage);
        //
        CGContextSetStrokeColorWithColor(mainContext, self.StrokeColor.CGColor);
        CGContextStrokeRectWithWidth(mainContext, self.bodyRectBounds, self.StrokeWidth);
    }
    
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
        memcpy(bmpBuffer, [[[NSData alloc] initWithHexadecimalString:[dataValues objectAtIndex:4]] bytes], bmpBufferByteSize);
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
    contextData = [NSData dataWithBytes:bmpBuffer length:bmpBufferByteSize];
    
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
    int px, py;
    CGColorSpaceRef aColorSpace;
    
    if(paintContext != NULL){
        CGContextRelease(paintContext);
        CGContextRelease(editingContext);
    }
    if(bmpBuffer != NULL){
        free(bmpBuffer);
    }
    contextRect = CGRectMake(0, 0, ceil(self.bodyRect.size.width), ceil(self.bodyRect.size.height));
    if(contextRect.size.width < 0 || contextRect.size.height < 0){
        return;
    }
    px = contextRect.size.width;
    py = contextRect.size.height;
    
    aColorSpace = CGColorSpaceCreateDeviceRGB();
    
    bmpBufferByteSize = 4 * px * py;
    bmpBuffer = malloc(bmpBufferByteSize);
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

// Preview drawing
- (CanvasObject *)drawMouseDown:(NSPoint)currentPointInCanvas
{
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
    return [super drawMouseDragged:currentPointInCanvas];
}

- (CanvasObject *)drawMouseUp:(NSPoint)currentPointInCanvas
{
    [self setFrame:[CanvasObject makeNSRectFromMouseMoving:drawingStartPoint :currentPointInCanvas]];
    [self setNeedsDisplay:YES];
    //
    [self.undoManager enableUndoRegistration];
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
        //NSLog(@"%@", NSStringFromPoint(drawingStartPoint));
        //ペンはクリックした時点で点を打つ
        CGContextBeginPath(editingContext);
        CGContextMoveToPoint(editingContext, drawingStartPoint.x - (self.StrokeWidth / 2), drawingStartPoint.y);
        CGContextAddLineToPoint(editingContext, drawingStartPoint.x + (self.StrokeWidth / 2), drawingStartPoint.y);
        CGContextClosePath(editingContext);
        CGContextSetStrokeColorWithColor(editingContext, self.StrokeColor.CGColor);
        CGContextSetLineWidth(editingContext, self.StrokeWidth);
        CGContextStrokePath(editingContext);
        //NSLog(@"drawPoint!%f",self.StrokeWidth);
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
        //描画中なので、編集中コンテキストをクリア
        //NSLog(@"%@", NSStringFromPoint(localPoint));
        CGContextClearRect(editingContext, contextRect);
    }
    
    rect = NSRectToCGRect([CanvasObject makeNSRectFromMouseMoving:drawingStartPoint :localPoint]);
    
    CGContextSaveGState(editingContext);
    {
        switch(mode){
            case PaintRectangle:
                CGContextSetFillColorWithColor(editingContext, self.FillColor.CGColor);
                CGContextFillRect(editingContext, rect);
                //
                CGContextSetStrokeColorWithColor(editingContext, self.StrokeColor.CGColor);
                CGContextStrokeRectWithWidth(editingContext, rect, self.StrokeWidth);
                break;
            case PaintEllipse:
                CGContextAddEllipseInRect(editingContext, rect);
                CGContextSetFillColorWithColor(editingContext, self.FillColor.CGColor);
                CGContextFillPath(editingContext);
                //
                CGContextAddEllipseInRect(editingContext, rect);
                CGContextSetStrokeColorWithColor(editingContext, self.StrokeColor.CGColor);
                CGContextSetLineWidth(editingContext, self.StrokeWidth);
                CGContextStrokePath(editingContext);
                break;
            case PaintPen:
                CGContextMoveToPoint(editingContext, drawingStartPoint.x, drawingStartPoint.y);
                CGContextAddLineToPoint(editingContext, localPoint.x, localPoint.y);
                CGContextSetStrokeColorWithColor(editingContext, self.StrokeColor.CGColor);
                CGContextSetLineWidth(editingContext, self.StrokeWidth);
                CGContextStrokePath(editingContext);
                drawingStartPoint = localPoint;
                break;
            case PaintLine:
                CGContextBeginPath(editingContext);
                CGContextMoveToPoint(editingContext, drawingStartPoint.x, drawingStartPoint.y);
                CGContextAddLineToPoint(editingContext, localPoint.x, localPoint.y);
                CGContextClosePath(editingContext);
                CGContextSetStrokeColorWithColor(editingContext, self.StrokeColor.CGColor);
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
    NSPoint localPoint = [self convertPoint:currentPointInCanvas fromView:self.superview];
    localPoint.x -= self.StrokeWidth / 2;
    localPoint.y -= self.StrokeWidth / 2;
    localPoint.x = floor(localPoint.x);
    localPoint.y = floor(localPoint.y);
    
    CGImageRef editingImage;
    
    //編集結果を適用
    if(mode > PaintToolsBase){
        editingImage = CGBitmapContextCreateImage(editingContext);
        
        CGContextSetShouldAntialias(paintContext, false);
        CGContextDrawImage(paintContext, contextRect, editingImage);
        CGContextClearRect(editingContext, contextRect);
        
        CGImageRelease(editingImage);
    }
    if(mode == PaintFill){
        // 塗りつぶし
        [self fillAreaAroundPoint:localPoint];
    }
}

- (void)fillAreaAroundPoint:(NSPoint)basePoint
{
    int bx, by;
    bx = basePoint.x;
    by = contextRect.size.height - basePoint.y - 1;
    
    if(!bmpBuffer){
        return;
    }
    if(bx < 0 || by < 0 || contextRect.size.width <= bx || contextRect.size.height <= by){
        return;
    }
    
    bmp = bmpBuffer;
    xsize = (unsigned int)contextRect.size.width;
    ysize = (unsigned int)contextRect.size.height;
    bc = bmpBuffer[by * xsize + bx];
    fc = self.FillColor.hexValue;
    
    if(bc == fc){
        return;
    }
    
    //fillAreaAroundPointSub(bx, by);
    [self fillAreaAroundPointSubBx:bx by:by];
    [self drawRect:contextRect];
}

unsigned int bc;    // baseColor
unsigned int fc;    // fillColor
unsigned int *bmp;
unsigned int xsize;
unsigned int ysize;

- (void) fillAreaAroundPointSubBx:(int)bx by:(int)by
{
    int lx, rx, flg;
    // 左端の捜索
    // 与えられた座標はbitmap内かつ、ぬりつぶし領域上にあることを想定
    for(;;){
        if(bx <= 0){
            break;
        }
        if(bmp[by * xsize + bx - 1] != bc){
            break;
        }
        bx--;
    }
    // lxは左端のx座標になっている
    lx = bx;
    
    // 現在のラインを塗る
    for(;;){
        if(bx >= xsize){
            break;
        }
        if(bmp[by * xsize + bx] == bc){
            //bmp[by * xsize + bx] = fc;
            
        } else{
            break;
        }
        bx++;
    }
    // rxは右端のx座標になっている
    rx = bx - 1;
    
    CGContextBeginPath(paintContext);
    CGContextMoveToPoint(paintContext, lx, ysize - by - 1);
    CGContextAddLineToPoint(paintContext, rx, ysize - by - 1);
    CGContextClosePath(paintContext);
    CGContextSetStrokeColorWithColor(paintContext, self.FillColor.CGColor);
    CGContextSetLineWidth(paintContext, 1);
    CGContextStrokePath(paintContext);
    
    // 上方向の検索
    bx = lx;
    if(by > 0){
        flg = 0;
        for(;;){
            if(bx > rx){
                // 右端に到達したら戻る
                break;
            }
            if(bmp[(by - 1) * xsize + bx] == bc){
                // さらに上側を調査
                if(flg == 0){
                    //fillAreaAroundPointSub(bx, by - 1);
                    [self fillAreaAroundPointSubBx:bx by:by - 1];
                    flg = 1;
                }
            } else{
                flg = 0;
            }
            bx++;
        }
    }
    
    // 下方向の検索
    bx = lx;
    if(by < ysize - 1){
        flg = 0;
        for(;;){
            if(bx >= rx){
                // 右端に到達したら戻る
                break;
            }
            if(bmp[(by + 1) * xsize + bx] == bc){
                // さらに上側を調査
                if(flg == 0){
                    //fillAreaAroundPointSub(bx, by + 1);
                     [self fillAreaAroundPointSubBx:bx by:by + 1];
                    flg = 1;
                }
            } else{
                flg = 0;
            }
            bx++;
        }
    }
    return;
}


/*
void fillAreaAroundPointSub(int bx, int by)
{
    int lx, rx, flg;
    // 左端の捜索
    // 与えられた座標はbitmap内かつ、ぬりつぶし領域上にあることを想定
    for(;;){
        if(bx <= 0){
            break;
        }
        if(bmp[by * xsize + bx - 1] != bc){
            break;
        }
        bx--;
    }
    // lxは左端のx座標になっている
    lx = bx;
    
    // 現在のラインを塗る
    for(;;){
        if(bx >= xsize){
            break;
        }
        if(bmp[by * xsize + bx] == bc){
            bmp[by * xsize + bx] = fc;
        } else{
            break;
        }
        bx++;
    }
    // rxは右端のx座標になっている
    rx = bx - 1;
    
    // 上方向の検索
    bx = lx;
    if(by > 0){
        flg = 0;
        for(;;){
            if(bx > rx){
                // 右端に到達したら戻る
                break;
            }
            if(bmp[(by - 1) * xsize + bx] == bc){
                // さらに上側を調査
                if(flg == 0){
                    fillAreaAroundPointSub(bx, by - 1);
                    flg = 1;
                }
            } else{
                flg = 0;
            }
            bx++;
        }
    }
    
    // 下方向の検索
    bx = lx;
    if(by < ysize - 1){
        flg = 0;
        for(;;){
            if(bx >= rx){
                // 右端に到達したら戻る
                break;
            }
            if(bmp[(by + 1) * xsize + bx] == bc){
                // さらに上側を調査
                if(flg == 0){
                    fillAreaAroundPointSub(bx, by + 1);
                    flg = 1;
                }
            } else{
                flg = 0;
            }
            bx++;
        }
    }
    return;
}
*/



@end
