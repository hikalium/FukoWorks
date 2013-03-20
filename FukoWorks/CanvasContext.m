//
//  CanvasContext.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/20.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasContext.h"

@implementation CanvasContext

@synthesize ControlView = _ControlView;

@synthesize FillColor = _FillColor;
- (void)setFillColor:(CGColorRef)FillColor
{
    _FillColor = FillColor;
    [self.ControlView setNeedsDisplay:YES];
}

@synthesize StrokeColor = _StrokeColor;
- (void)setStrokeColor:(CGColorRef)StrokeColor
{
    _StrokeColor = StrokeColor;
    [self.ControlView setNeedsDisplay:YES];
}

@synthesize StrokeWidth = _StrokeWidth;
- (void)setStrokeWidth:(CGFloat)StrokeWidth
{
    _StrokeWidth = StrokeWidth;
    [self.ControlView setNeedsDisplay:YES];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _ControlView = nil;
        _FillColor = nil;
        _FillColor = nil;
        _StrokeWidth = 0;
    }
    
    return self;
}

@end
