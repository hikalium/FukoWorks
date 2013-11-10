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
}

- (CanvasObject *)drawMouseDown:(NSPoint)currentPointInCanvas;
- (CanvasObject *)drawMouseDragged:(NSPoint)currentPointInCanvas;
- (CanvasObject *)drawMouseUp:(NSPoint)currentPointInCanvas;

@end
