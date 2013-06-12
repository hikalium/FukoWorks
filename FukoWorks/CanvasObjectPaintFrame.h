//
//  CanvasObjectPaintFrame.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/06/09.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObject.h"

@interface CanvasObjectPaintFrame : CanvasObject
{
    void *bmpBuffer;
    NSPoint drawingStartPoint;
}

@property CGContextRef paintContext;

- (id)initWithFrame:(NSRect)frame;
- (void)resetPaintContext;
- (void)drawRect:(NSRect)dirtyRect;
- (CanvasObject *)drawMouseDown:(NSPoint)currentPointInCanvas;
- (CanvasObject *)drawMouseDragged:(NSPoint)currentPointInCanvas;
- (CanvasObject *)drawMouseUp:(NSPoint)currentPointInCanvas;
@end
