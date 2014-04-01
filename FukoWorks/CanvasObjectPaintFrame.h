//
//  CanvasObjectPaintFrame.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/06/09.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObjectRectFrameBase.h"

@interface CanvasObjectPaintFrame : CanvasObjectRectFrameBase
{
    unsigned int *bmpBuffer;
    NSUInteger bmpBufferByteSize;
    CGContextRef paintContext;
    CGContextRef editingContext;
    CGRect contextRect;
}

//
// Function
//

// NSView override
- (id)initWithFrame:(NSRect)frame;
- (void)drawRect:(NSRect)dirtyRect;

// data encoding
- (id)initWithEncodedString:(NSString *)sourceString;
- (NSString *)encodedStringForCanvasObject;

// paintContext
- (void)resetPaintContext;

// Preview drawing
- (CanvasObject *)drawMouseDown:(NSPoint)currentPointInCanvas;
- (CanvasObject *)drawMouseDragged:(NSPoint)currentPointInCanvas;
- (CanvasObject *)drawMouseUp:(NSPoint)currentPointInCanvas;

// EditHandle <CanvasObjectHandling>
- (void)editHandleUp:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid;

// User interaction
- (void)drawPaintFrameMouseDown:(NSPoint)currentPointInCanvas mode:(CanvasObjectType)mode;
- (void)drawPaintFrameMouseDragged:(NSPoint)currentPointInCanvas mode:(CanvasObjectType)mode;
- (void)drawPaintFrameMouseUp:(NSPoint)currentPointInCanvas mode:(CanvasObjectType)mode;

@end
