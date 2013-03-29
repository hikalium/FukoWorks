//
//  CanvasObjectEllipse.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/28.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObjectEllipse.h"

@implementation CanvasObjectEllipse

@synthesize ObjectType = _ObjectType;

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        // Initialization code here.
        _ObjectType = Ellipse;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //再描画時に呼ばれる。
    CGContextRef mainContext;
    CGRect ellipseRect;
    
    mainContext = [[NSGraphicsContext currentContext] graphicsPort];
    
    ellipseRect = [self makeNSRectWithRealSizeViewFrameInLocal];
    
    CGContextSaveGState(mainContext);
    {
        CGContextAddEllipseInRect(mainContext, ellipseRect);
        CGContextSetFillColorWithColor(mainContext, self.FillColor);
        CGContextFillPath(mainContext);
        
        CGContextAddEllipseInRect(mainContext, ellipseRect);
        CGContextSetStrokeColorWithColor(mainContext, self.StrokeColor);
        CGContextSetLineWidth(mainContext, self.StrokeWidth);
        CGContextStrokePath(mainContext);
    }
    CGContextRestoreGState(mainContext);

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
    [self setNeedsDisplay:YES];
    
    return nil;
}

@end
