//
//  FWKBitmap.h
//  FukoWorks
//
//  Created by 西田　耀 on 2014/05/21.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FWKBitmap : NSObject
- (id)init;
- (void)drawRectWithContext: (CGContextRef)destinationContext;
- (void)copyBufferFromNSData: (NSData *)data;
- (NSData *)bufferData;
- (void)resetBitmapContextToSize:(NSSize)size;
- (void)clearOverlayContext;
- (void)applyOverlayContext;
- (void)strokePoint:(NSPoint)p withColor:(NSColor *)c size:(CGFloat)s;
- (void)paintRectangle:(NSRect)r withFillColor:(NSColor *)fc strokeColor:(NSColor *)sc strokeWidth:(CGFloat)s;
- (void)paintEllipse:(NSRect)r withFillColor:(NSColor *)fc strokeColor:(NSColor *)sc strokeWidth:(CGFloat)s;
- (void)paintLineFrom:(NSPoint)p to:(NSPoint)q withStrokeColor:(NSColor *)sc strokeWidth:(CGFloat)s;
- (void)fillBySelectionMapWithColor:(NSColor *)c;
- (void)fillBySelectionMapWithColorSub:(NSColor *)c y:(int)y lx:(int)lx rx:(int)rx;
- (void)selectBitmapAreaByPoint: (NSPoint)p;

@end
