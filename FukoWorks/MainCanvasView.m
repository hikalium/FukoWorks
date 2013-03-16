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
    // Drawing code here.
}

- (void)mouseDown:(NSEvent*)event
{
    NSPoint currentPoint;
    CGContextRef maincontext;
    
    maincontext = [[NSGraphicsContext currentContext] graphicsPort];
    
    currentPoint = [event locationInWindow];
    CGContextSetRGBFillColor(maincontext, 0, 0, 0, 1);
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mDw:%@", NSStringFromPoint(currentPoint)]];

    drawingStartPoint = currentPoint;
}

- (void)mouseUp:(NSEvent*)event
{
    NSPoint currentPoint;
    CGContextRef maincontext;
    
    maincontext = [[NSGraphicsContext currentContext] graphicsPort];
    
    currentPoint = [event locationInWindow];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mUp:%@", NSStringFromPoint(currentPoint)]];

    CGContextFillRect(maincontext, CGRectMake(drawingStartPoint.x, drawingStartPoint.y, currentPoint.x - drawingStartPoint.x, currentPoint.y - drawingStartPoint.y));
    
}

- (void)mouseDragged:(NSEvent*)event
{
    NSPoint currentPoint;
    CGContextRef maincontext;
    
    maincontext = [[NSGraphicsContext currentContext] graphicsPort];
    
    currentPoint = [event locationInWindow];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mDr:%@", NSStringFromPoint(currentPoint)]];

}

@end
