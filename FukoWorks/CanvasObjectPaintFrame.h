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
    void *bmpBuffer;
    CGContextRef paintContext;
    CGContextRef editingContext;
    CGRect contextRect;
}

- (id)initWithFrame:(NSRect)frame;

- (id)initWithEncodedString:(NSString *)sourceString;
- (NSString *)encodedStringForCanvasObject;

- (void)resetPaintContext;
- (void)drawRect:(NSRect)dirtyRect;

- (CanvasObject *)drawMouseDown:(NSPoint)currentPointInCanvas;
- (CanvasObject *)drawMouseDragged:(NSPoint)currentPointInCanvas;
- (CanvasObject *)drawMouseUp:(NSPoint)currentPointInCanvas;

- (void)editHandleDown:(NSPoint)currentHandlePointInCanvas :(NSInteger)tag;
- (void)editHandleDragged:(NSPoint)currentHandlePointInCanvas :(NSInteger)tag;
- (void)editHandleUp:(NSPoint)currentHandlePointInCanvas :(NSInteger) tag;

- (void)drawPaintFrameMouseDown:(NSPoint)currentPointInCanvas mode:(CanvasObjectType)mode;
- (void)drawPaintFrameMouseDragged:(NSPoint)currentPointInCanvas mode:(CanvasObjectType)mode;
- (void)drawPaintFrameMouseUp:(NSPoint)currentPointInCanvas mode:(CanvasObjectType)mode;

- (NSPoint)getNSPointIntegral: (NSPoint)basePoint;

//
// ViewComputing
//
- (NSRect)makeNSRectFromMouseMoving:(NSPoint)startPoint :(NSPoint)endPoint;
- (NSRect)makeNSRectWithRealSizeViewFrame;
- (NSRect)makeNSRectWithRealSizeViewFrameInLocal;
- (NSRect)makeNSRectWithFullSizeViewFrameFromRealSizeViewFrame:(NSRect)RealSizeViewFrame;

@end
