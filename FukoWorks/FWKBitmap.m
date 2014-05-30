//
//  FWKBitmap.m
//  FukoWorks
//
//  Created by 西田　耀 on 2014/05/21.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "FWKBitmap.h"

@implementation FWKBitmap
{
    unsigned int *bmpBuffer;
    NSUInteger bmpBufferByteSize;

    unsigned char *bmpSelectionMap;
    NSUInteger bmpSelectionMapByteSize;

    CGContextRef paintContext;
    CGContextRef overlayContext;

    CGRect contextRect;

    int xsize;
    int ysize;
    unsigned int searchColor;
}

@synthesize undoManager = _undoManager;
@synthesize ownerView = _ownerView;

- (id)init
{
    self = [super init];
    
    if(self){
        bmpBuffer = NULL;
        bmpSelectionMap = NULL;
        bmpBufferByteSize = 0;
        paintContext = NULL;
        overlayContext = NULL;
        contextRect = CGRectNull;
    }
    
    return self;
}

- (void)drawRectWithContext: (CGContextRef)destinationContext inRect:(NSRect)rect
{
    CGImageRef paintImage, editingImage;
    
    if(paintContext && overlayContext){
        CGContextSetShouldAntialias(destinationContext, false);
        paintImage = CGBitmapContextCreateImage(paintContext);
        editingImage = CGBitmapContextCreateImage(overlayContext);
        
        CGContextDrawImage(destinationContext, rect, paintImage);
        CGContextDrawImage(destinationContext, rect, editingImage);
        CGImageRelease(paintImage);
        CGImageRelease(editingImage);
    }
}

- (void)copyBufferFromNSData: (NSData *)data
{
    [[self.undoManager prepareWithInvocationTarget:self] copyBufferFromNSData:[self bufferData]];
    
    NSUInteger len;
    len = [data length];
    if(len > bmpBufferByteSize){
        len = bmpBufferByteSize;
    }
    memcpy(bmpBuffer, [data bytes], len);
    [_ownerView setNeedsDisplay:YES];
}

- (NSData *)bufferData
{
    return [NSData dataWithBytes:bmpBuffer length:bmpBufferByteSize];
}

- (void)resetBitmapContextToSize:(NSSize)size
{
    CGColorSpaceRef aColorSpace;
    //
    CGContextRef oldPaintContext = nil;
    unsigned int *oldBMPBuffer = NULL;
    NSData *oldBMPData = [self bufferData];
    CGRect oldContextRect;
    CGImageRef paintImage;
    
    if(paintContext != nil){
        // editingContextをpaintContextに反映
        //[self drawRect:contextRect];
        // 古いpaintContextを保存
        oldPaintContext = paintContext;
        oldBMPBuffer = bmpBuffer;
        // editingContextは解放
        CGContextRelease(overlayContext);
        // 古いcontextRectを保存
        oldContextRect = contextRect;
    }
    // 新しいcontextRectを生成
    contextRect = CGRectMake(0, 0, ceil(size.width), ceil(size.height));
    xsize = contextRect.size.width;
    ysize = contextRect.size.height;
    aColorSpace = CGColorSpaceCreateDeviceRGB();
    bmpBufferByteSize = 4 * xsize * ysize;
    bmpBuffer = malloc(bmpBufferByteSize);
    
    if(bmpSelectionMap){
        free(bmpSelectionMap);
    }
    bmpSelectionMapByteSize = xsize * ysize;
    bmpSelectionMap = malloc(bmpSelectionMapByteSize);
    
    if(bmpBuffer != NULL){
        paintContext = CGBitmapContextCreate(bmpBuffer, xsize, ysize, 8, xsize * 4, aColorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
        if(paintContext == NULL){
            free(bmpBuffer);
            NSRunAlertPanel(@"FukoWorks:Bitmap", @"paintコンテキスト生成に失敗しました。", @"OK", nil, nil);
        }
        overlayContext = CGBitmapContextCreate(nil, xsize, ysize, 8, xsize * 4, aColorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
        if(overlayContext == NULL){
            NSRunAlertPanel(@"FukoWorks:Bitmap", @"editingコンテキスト生成に失敗しました。", @"OK", nil, nil);
        }
    } else{
        NSRunAlertPanel(@"FukoWorks:Bitmap", @"メモリ確保に失敗しました。", @"OK", nil, nil);
    }
    
    CGColorSpaceRelease(aColorSpace);
    
    if(paintContext == NULL){
        return;
    }
    CGContextSetShouldAntialias(paintContext, false);
    CGContextSetShouldAntialias(overlayContext, false);
    CGContextSetRGBFillColor(paintContext, 1, 1, 1, 1);
    CGContextFillRect(paintContext, contextRect);
    CGContextSetRGBFillColor(overlayContext, 0, 0, 0, 0);
    CGContextFillRect(overlayContext, contextRect);
    
    // 以前のペイント枠の内容をコピー
    
    if(oldPaintContext){
        [[self.undoManager prepareWithInvocationTarget:self] copyBufferFromNSData:oldBMPData];
        paintImage = CGBitmapContextCreateImage(oldPaintContext);
        
        CGContextDrawImage(paintContext, oldContextRect, paintImage);
        CGImageRelease(paintImage);
        
        CGContextRelease(oldPaintContext);
        if(bmpBuffer != NULL){
            free(oldBMPBuffer);
        }
        [[self.undoManager prepareWithInvocationTarget:self] resetBitmapContextToSize:oldContextRect.size];
    }
}

- (void)clearOverlayContext
{
    CGContextClearRect(overlayContext, contextRect);
}

- (void)applyOverlayContext
{
    CGImageRef editingImage;
    
    [[self.undoManager prepareWithInvocationTarget:self] copyBufferFromNSData:[self bufferData]];
    
    editingImage = CGBitmapContextCreateImage(overlayContext);
    
    CGContextSetShouldAntialias(paintContext, false);
    CGContextDrawImage(paintContext, contextRect, editingImage);
    CGContextClearRect(overlayContext, contextRect);
    
    CGImageRelease(editingImage);
}

- (void)strokePoint:(NSPoint)p withColor:(NSColor *)c size:(CGFloat)s
{
    CGContextBeginPath(overlayContext);
    CGContextMoveToPoint(overlayContext, p.x - (s / 2), p.y);
    CGContextAddLineToPoint(overlayContext, p.x + (s / 2), p.y);
    CGContextClosePath(overlayContext);
    CGContextSetStrokeColorWithColor(overlayContext, c.CGColor);
    CGContextSetLineWidth(overlayContext, s);
    CGContextStrokePath(overlayContext);
}

- (void)paintRectangle:(NSRect)r withFillColor:(NSColor *)fc strokeColor:(NSColor *)sc strokeWidth:(CGFloat)s
{
    CGContextSetFillColorWithColor(overlayContext, fc.CGColor);
    CGContextFillRect(overlayContext, r);
    //
    CGContextSetStrokeColorWithColor(overlayContext, sc.CGColor);
    CGContextStrokeRectWithWidth(overlayContext, r, s);
}

- (void)paintEllipse:(NSRect)r withFillColor:(NSColor *)fc strokeColor:(NSColor *)sc strokeWidth:(CGFloat)s
{
    CGContextAddEllipseInRect(overlayContext, r);
    CGContextSetFillColorWithColor(overlayContext, fc.CGColor);
    CGContextFillPath(overlayContext);
    //
    CGContextAddEllipseInRect(overlayContext, r);
    CGContextSetStrokeColorWithColor(overlayContext, sc.CGColor);
    CGContextSetLineWidth(overlayContext, s);
    CGContextStrokePath(overlayContext);

}

- (void)paintLineFrom:(NSPoint)p to:(NSPoint)q withStrokeColor:(NSColor *)sc strokeWidth:(CGFloat)s
{
    CGContextBeginPath(overlayContext);
    CGContextMoveToPoint(overlayContext, p.x, p.y);
    CGContextAddLineToPoint(overlayContext, q.x, q.y);
    CGContextClosePath(overlayContext);
    CGContextSetStrokeColorWithColor(overlayContext, sc.CGColor);
    CGContextSetLineWidth(overlayContext, s);
    CGContextStrokePath(overlayContext);
}

- (void)clearSelectionMap
{
    int i;
    for(i = 0; i < bmpSelectionMapByteSize; i++){
        bmpSelectionMap[i] = 0;
    }
}

- (void)fillBySelectionMapWithColor:(NSColor *)c
{
    int lx;
    int x, y;
    int flg;
    
    [[self.undoManager prepareWithInvocationTarget:self] copyBufferFromNSData:[self bufferData]];
    
    for(y = 0; y < ysize; y++){
        flg = 0;
        for(x = 0; x < xsize; x++){
            if(flg == 0){
                if(bmpSelectionMap[y * xsize + x] == 1){
                    lx = x;
                    flg = 1;
                }
            } else{
                if(bmpSelectionMap[y * xsize + x] != 1){
                    [self fillBySelectionMapWithColorSub:c y:y lx:lx rx:x - 1];
                    flg = 0;
                }
            }
        }
        if(flg){
            [self fillBySelectionMapWithColorSub:c y:y lx:lx rx:x - 1];
        }
    }
}

- (void)fillBySelectionMapWithColorSub:(NSColor *)c y:(int)y lx:(int)lx rx:(int)rx
{
    CGContextBeginPath(paintContext);
    CGContextMoveToPoint(paintContext, lx, ysize - y - 1);
    CGContextAddLineToPoint(paintContext, rx, ysize - y - 1);
    CGContextClosePath(paintContext);
    CGContextSetStrokeColorWithColor(paintContext, c.CGColor);
    CGContextSetLineWidth(paintContext, 1);
    CGContextStrokePath(paintContext);
}

- (void)selectBitmapAreaByPoint: (NSPoint)p
{
    int bx, by;
    [self clearSelectionMap];

    bx = p.x;
    by = contextRect.size.height - p.y - 1;
    
    if(!bmpBuffer){
        return;
    }
    if(bx < 0 || by < 0 || contextRect.size.width <= bx || contextRect.size.height <= by){
        return;
    }
    
    searchColor = bmpBuffer[by * xsize + bx];
    [self selectBitmapAreaByPointSubBx:bx by:by];
}

- (void)selectBitmapAreaByPointSubBx:(int)bx by:(int)by
{
    int lx, rx, flg;
    // 与えられた座標はbitmap内かつ、ぬりつぶし領域上にあることを想定
    // 左端の捜索
    for(;;){
        if(bx <= 0){
            break;
        }
        if(bmpBuffer[by * xsize + bx - 1] != searchColor){
            break;
        }
        bx--;
    }
    // lxは塗りつぶすラインの左端のx座標になっている
    lx = bx;
    
    // 右端の捜索
    for(;;){
        if(bx >= xsize){
            break;
        }
        if(bmpBuffer[by * xsize + bx] != searchColor){
            break;
        }
        bx++;
    }
    // rxは塗りつぶすラインの右端のx座標になる
    rx = bx - 1;
    
    // マップを塗る
    for(bx = lx; bx <= rx; bx++){
        bmpSelectionMap[by * xsize + bx] = 1;
    }
    
    // 上方向の検索
    bx = lx;
    if(by > 0){
        flg = 0;
        for(;;){
            if(bx > rx){
                // 右端に到達したら終了する
                break;
            }
            if(bmpBuffer[(by - 1) * xsize + bx] == searchColor && bmpSelectionMap[(by - 1) * xsize + bx] == 0){
                // さらに上側を調査
                if(flg == 0){
                    [self selectBitmapAreaByPointSubBx:bx by:by - 1];
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
                // 右端に到達したら終了する
                break;
            }
            if(bmpBuffer[(by + 1) * xsize + bx] == searchColor && bmpSelectionMap[(by + 1) * xsize + bx] == 0){
                // さらに下側を調査
                if(flg == 0){
                    [self selectBitmapAreaByPointSubBx:bx by:by + 1];
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

@end
