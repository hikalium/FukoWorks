//
//  CanvasObjectRectFrameBase.h
//  FukoWorks
//
//  Created by 西田　耀 on 2013/10/27.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObject.h"

@interface CanvasObjectRectFrameBase : CanvasObject
{
    NSPoint drawingStartPoint;
    NSPoint rotationHandleVector;
}

//
// For object rotation
//
@property (nonatomic) CGFloat rotationAngle;    // [0, 2 * pi]
- (void)setRotationAngle:(CGFloat)rotationAngle;
- (void)setBodyRect:(NSRect)bodyRect;
- (NSRect)bodyRectBounds;
- (void)setFrameOrigin:(NSPoint)newOrigin;
- (void)setFrameFromCurrentBodyRect;

//
//
//
- (id)init;

//
// initial drawing
//
- (CanvasObject *)drawMouseDown:(NSPoint)currentPointInCanvas;
- (CanvasObject *)drawMouseDragged:(NSPoint)currentPointInCanvas;
- (CanvasObject *)drawMouseUp:(NSPoint)currentPointInCanvas;

//
// EditHandle
//
- (NSUInteger)numberOfEditHandlesForCanvasObject;
- (NSPoint)editHandlePointForHandleID:(NSUInteger)hid;
- (void)editHandleDown:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid;
- (void)editHandleDragged:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid;
- (void)editHandleUp:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid;

//
// Drawing
//
- (void)drawRect:(NSRect)dirtyRect;
- (void)drawInBodyRect: (CGContextRef)mainContext;
- (void)drawFocusRect;


@end
