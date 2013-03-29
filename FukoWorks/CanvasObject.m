//
//  CanvasObject.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/28.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObject.h"

@implementation CanvasObject

@synthesize FillColor = _FillColor;
- (void)setFillColor:(CGColorRef)FillColor
{
    _FillColor = FillColor;
    [self setNeedsDisplay:YES];
}

@synthesize StrokeColor = _StrokeColor;
- (void)setStrokeColor:(CGColorRef)StrokeColor
{
    _StrokeColor = StrokeColor;
    [self setNeedsDisplay:YES];
}

@synthesize StrokeWidth = _StrokeWidth;
- (void)setStrokeWidth:(CGFloat)StrokeWidth
{
    _StrokeWidth = StrokeWidth;
    [self setNeedsDisplay:YES];
}

@synthesize ObjectType = _ObjectType;

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        // Initialization code here.
        _ObjectType = Undefined;
        
        _FillColor = nil;
        _FillColor = nil;
        _StrokeWidth = 0;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

-(CanvasObject *)drawMouseDown:(NSPoint)currentPointInCanvas
{
    return nil;
}

- (CanvasObject *)drawMouseDragged:(NSPoint)currentPointInCanvas
{
    return nil;
}

- (CanvasObject *)drawMouseUp:(NSPoint)currentPointInCanvas
{
    return nil;
}

- (NSRect)makeNSRectFromMouseMoving:(NSPoint)startPoint :(NSPoint)endPoint
{
    //StrokeWidthによる補正も入っているので注意
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
    
    return NSMakeRect(p.x - (self.StrokeWidth / 2), p.y - (self.StrokeWidth / 2), q.width + self.StrokeWidth, q.height + self.StrokeWidth);
}

- (NSRect)makeNSRectWithRealSizeViewFrameInLocal
{
    //StrokeWidthによる補正も入っているので注意
    NSRect realRect;
    
    realRect.origin.x = (self.StrokeWidth / 2);
    realRect.origin.y = (self.StrokeWidth / 2);
    realRect.size.height = self.frame.size.height - self.StrokeWidth;
    realRect.size.width = self.frame.size.width - self.StrokeWidth;
    
    return realRect;
}


- (NSPoint)getPointerLocationRelativeToSelfView:(NSEvent*)event
{
    //このViewに相対的な座標でマウスポインタの座標を返す。
    //ViewのScaleに合わせて座標も調節される。
    NSPoint currentPoint;
    
    currentPoint = [event locationInWindow];
    return [self convertPoint:currentPoint fromView:nil];
}


@end
