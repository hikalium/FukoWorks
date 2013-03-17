//
//  MainCanvasView.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/16.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "MainCanvasView.h"

@implementation MainCanvasView

@synthesize parentwindow = _parentwindow;
@synthesize label_indicator = _label_indicator;

@synthesize  drawingForeColor = _drawingForeColor;
@synthesize drawingFillColor = _drawingFillColor;
@synthesize  drawingTextColor = _drawingTextColor;

NSPoint drawingStartPoint;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    drawingStartPoint.x = 0;
    drawingStartPoint.y = 0;
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //[super drawRect:dirtyRect];
}

- (void)mouseDown:(NSEvent*)event
{
    NSPoint currentPoint;
    
    currentPoint = [event locationInWindow];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mDw:%@", NSStringFromPoint(currentPoint)]];

    drawingStartPoint = currentPoint;
}

- (void)mouseUp:(NSEvent*)event
{
    NSPoint currentPoint;
    CanvasObjectRectangle *rect;
    NSRect baseRect;
    
    currentPoint = [event locationInWindow];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mUp:%@", NSStringFromPoint(currentPoint)]];
 
    baseRect = [self makeNSRectFromMouseMoving:drawingStartPoint :currentPoint];
    rect = [[CanvasObjectRectangle alloc] initWithFrame:baseRect];
    if(rect != nil){
        [self addSubview:rect];
        rect.FillColor = self.drawingFillColor;
    }
}

- (void)mouseDragged:(NSEvent*)event
{
    NSPoint currentPoint;

    currentPoint = [event locationInWindow];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mDr:%@", NSStringFromPoint(currentPoint)]];

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

@end
