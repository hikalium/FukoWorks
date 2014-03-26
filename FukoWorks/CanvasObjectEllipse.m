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
        CGContextSetFillColorWithColor(mainContext, self.FillColor.CGColor);
        CGContextFillPath(mainContext);
        
        CGContextAddEllipseInRect(mainContext, ellipseRect);
        CGContextSetStrokeColorWithColor(mainContext, self.StrokeColor.CGColor);
        CGContextSetLineWidth(mainContext, self.StrokeWidth);
        CGContextStrokePath(mainContext);
    }
    CGContextRestoreGState(mainContext);

     [self drawFocusRect];
}
@end
