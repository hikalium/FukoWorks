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

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    CGContextRef context;
    
    context = [[NSGraphicsContext currentContext] graphicsPort];
    
    
}

- (void)mouseDown:(NSEvent*)event
{
    NSPoint currentPoint;
    
    currentPoint = [event locationInWindow];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mDw:%@", NSStringFromPoint(currentPoint)]];
}

- (void)mouseUp:(NSEvent*)event
{
    NSPoint currentPoint;
    
    currentPoint = [event locationInWindow];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mUp:%@", NSStringFromPoint(currentPoint)]];

}

- (void)mouseDragged:(NSEvent*)event
{
    NSPoint currentPoint;
    
    currentPoint = [event locationInWindow];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mDr:%@", NSStringFromPoint(currentPoint)]];

}

@end
