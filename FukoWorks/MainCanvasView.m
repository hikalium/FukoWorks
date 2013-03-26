//
//  MainCanvasView.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/16.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "MainCanvasView.h"

@implementation MainCanvasView

@synthesize label_indicator = _label_indicator;

@synthesize toolboxController = _toolboxController;
@synthesize canvasScale = _canvasScale;
- (void)setCanvasScale:(CGFloat)canvasScale
{
    [self scaleUnitSquareToSize:NSMakeSize(1/_canvasScale, 1/_canvasScale)];
    _canvasScale = canvasScale;
    [self scaleUnitSquareToSize:NSMakeSize(canvasScale, canvasScale)];
    [self setFrameSize:NSMakeSize(baseFrame.size.width * canvasScale, baseFrame.size.height * canvasScale)];
    [self.superview setNeedsDisplay:YES];
    [self setNeedsDisplay:YES];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        baseFrame = NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
        drawingStartPoint.x = 0;
        drawingStartPoint.y = 0;
        
        backgroundColor = CGColorCreateGenericRGB(1, 1, 1, 1);
        guideRectFillColor = CGColorCreateGenericRGB(0, 0, 1, 0.75);
        guideRectStrokeColor = CGColorCreateGenericRGB(1, 1, 1, 0.75);
        guideRectStrokeWidth = 2;
        _canvasScale = 1;
        
        dragging = false;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef mainContext;
    CGRect rect, guideRect;
    
    mainContext = [[NSGraphicsContext currentContext] graphicsPort];
    
    rect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    guideRect = NSRectToCGRect([self makeNSRectFromMouseMoving:drawingStartPoint :drawingDragPoint]);
    
    CGContextSaveGState(mainContext);
    {
        CGContextSetFillColorWithColor(mainContext, backgroundColor);
        CGContextFillRect(mainContext, rect);
        if(dragging){
            CGContextSetFillColorWithColor(mainContext, guideRectFillColor);
            CGContextFillRect(mainContext, guideRect);
            CGContextSetStrokeColorWithColor(mainContext, guideRectStrokeColor);
            CGContextStrokeRectWithWidth(mainContext, guideRect, guideRectStrokeWidth);
        }
    }
    CGContextRestoreGState(mainContext);
}

- (void)mouseDown:(NSEvent*)event
{
    NSPoint currentPoint;
    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mDw:%@", NSStringFromPoint(currentPoint)]];

    drawingStartPoint = currentPoint;
    dragging = true;
}

- (void)mouseUp:(NSEvent*)event
{
    NSPoint currentPoint;
    CanvasObjectRectangle *rect;
    NSRect baseRect;
    
    dragging = false;
    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mUp:%@", NSStringFromPoint(currentPoint)]];
 
    baseRect = [self makeNSRectFromMouseMoving:drawingStartPoint :currentPoint];
    rect = [[CanvasObjectRectangle alloc] initWithFrame:baseRect];
    if(rect != nil){
        rect.objectContext.FillColor = self.toolboxController.drawingFillColor;
        rect.objectContext.StrokeColor = self.toolboxController.drawingStrokeColor;
        rect.objectContext.StrokeWidth = self.toolboxController.drawingStrokeWidth;
        [self addSubview:rect];
    }
}

- (void)mouseDragged:(NSEvent*)event
{
    NSPoint currentPoint;

    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mDr:%@", NSStringFromPoint(currentPoint)]];
    drawingDragPoint = currentPoint;
    [self setNeedsDisplay:YES];
}

- (NSRect)makeNSRectFromMouseMoving:(NSPoint)startPoint :(NSPoint)endPoint
{
    NSPoint p;
    NSSize q;
    
    if(endPoint.x < startPoint.x){
        p.x = endPoint.x;
        q.width = startPoint.x - endPoint.x + 1;
    } else{
        p.x = startPoint.x;
        q.width = endPoint.x - startPoint.x + 1;
    }
    
    if(endPoint.y < startPoint.y){
        p.y = endPoint.y;
        q.height = startPoint.y - endPoint.y + 1;
    } else{
        p.y = startPoint.y;
        q.height = endPoint.y - startPoint.y + 1;
    }
    
    return NSMakeRect(p.x, p.y, q.width, q.height);
}

- (NSPoint)getPointerLocationRelativeToSelfView:(NSEvent*)event
{
    //このViewに相対的な座標でマウスポインタの座標を返す。
    NSPoint currentPoint;
    
    currentPoint = [event locationInWindow];
    return [self convertPoint:currentPoint fromView:nil];
}

@end
