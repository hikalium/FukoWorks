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
- (void)resetPaintContext;
- (void)drawRect:(NSRect)dirtyRect;
- (void)drawPaintFrameMouseDown:(NSPoint)currentPointInCanvas mode:(CanvasObjectType)mode;
- (void)drawPaintFrameMouseDragged:(NSPoint)currentPointInCanvas mode:(CanvasObjectType)mode;
- (void)drawPaintFrameMouseUp:(NSPoint)currentPointInCanvas mode:(CanvasObjectType)mode;
@end
