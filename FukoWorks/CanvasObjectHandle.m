//
//  CanvasObjectHandle.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/04/29.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObjectHandle.h"

@implementation CanvasObjectHandle

@synthesize ownerCanvasObject = _ownerCanvasObject;
@synthesize tag = _tag;

const CGFloat handleSize = 10;
const CGFloat handleStrokeWidth = 2;
CGColorRef handleFillColor;
CGColorRef handleStrokeColor;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _ownerCanvasObject = nil;
        handleFillColor = CGColorCreateGenericRGB(1, 1, 1, 0.5);
        handleStrokeColor = CGColorCreateGenericRGB(0.5, 0.5, 0.5, 0.5);
    }
    
    return self;
}

- (id)initWithHandlePoint:(NSPoint)handlePoint
{
    self = [self initWithFrame:NSMakeRect(handlePoint.x - ((handleSize + handleStrokeWidth) / 2), handlePoint.y - ((handleSize + handleStrokeWidth) / 2), handleSize + handleStrokeWidth, handleSize + handleStrokeWidth)];
    
    if(self){
    
    }
    
    return self;
}

- (void)setHandlePoint:(NSPoint)handlePoint
{
    handlePoint = [self.superview convertPoint:handlePoint fromView:_ownerCanvasObject.superview];
    [self setFrame:NSMakeRect(handlePoint.x - ((handleSize + handleStrokeWidth) / 2), handlePoint.y - ((handleSize + handleStrokeWidth) / 2), handleSize + handleStrokeWidth, handleSize + handleStrokeWidth)];
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef mainContext;
    CGRect ellipseRect;
    CGAffineTransform affine;
    CGFloat handleStrokeWidthTransformed;
    
    mainContext = [[NSGraphicsContext currentContext] graphicsPort];
    
    ellipseRect = self.frame;
    affine = CGContextGetCTM(mainContext);
    ellipseRect.size.width /= affine.a;
    ellipseRect.size.height /= affine.d;
    ellipseRect.origin.x = (self.frame.size.width - ellipseRect.size.width) / 2;
    ellipseRect.origin.y = (self.frame.size.height - ellipseRect.size.height) / 2;
    handleStrokeWidthTransformed = handleStrokeWidth / affine.a;
    ellipseRect.origin.x += (handleStrokeWidthTransformed / 2);
    ellipseRect.origin.y += (handleStrokeWidthTransformed / 2);
    ellipseRect.size.height -= handleStrokeWidthTransformed;
    ellipseRect.size.width -= handleStrokeWidthTransformed;
    
    CGContextSaveGState(mainContext);
    {
        CGContextAddEllipseInRect(mainContext, ellipseRect);
        CGContextSetFillColorWithColor(mainContext, handleFillColor);
        CGContextFillPath(mainContext);
        
        CGContextAddEllipseInRect(mainContext, ellipseRect);
        CGContextSetStrokeColorWithColor(mainContext, handleStrokeColor);
        CGContextSetLineWidth(mainContext, handleStrokeWidthTransformed);
        CGContextStrokePath(mainContext);
    }
    CGContextRestoreGState(mainContext);
}

- (NSRect)makeNSRectWithRealSizeViewFrameInLocal
{
    //StrokeWidthによる補正も入っているので注意
    NSRect realRect;
    
    realRect.origin.x = (handleStrokeWidth / 2);
    realRect.origin.y = (handleStrokeWidth / 2);
    realRect.size.height = self.frame.size.height - handleStrokeWidth;
    realRect.size.width = self.frame.size.width - handleStrokeWidth;
    
    return realRect;
}

- (NSPoint)makeNSPointWithHandlePoint
{
    //ハンドルが制御すべき一点の、superview内での座標を返す。
    return NSMakePoint(self.frame.origin.x + (self.frame.size.width / 2), self.frame.origin.y + (self.frame.size.height / 2));
}

- (void)mouseDown:(NSEvent *)theEvent
{
    moveHandleCursorOffset = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    [[self ownerCanvasObject] editHandleDown:[self makeNSPointWithHandlePoint] forHandleID:self.tag];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint objectOrigin;
    
    objectOrigin = [self.superview convertPoint:[theEvent locationInWindow] fromView:nil];
    
    objectOrigin.x -= moveHandleCursorOffset.x;
    objectOrigin.y -= moveHandleCursorOffset.y;
    
    [self setFrameOrigin:objectOrigin];
    
    [[self ownerCanvasObject] editHandleDragged:[self makeNSPointWithHandlePoint] forHandleID:self.tag];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [[self ownerCanvasObject] editHandleUp:[self makeNSPointWithHandlePoint] forHandleID:self.tag];
}

@end
