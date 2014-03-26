//
//  OverlayCanvasView.m
//  FukoWorks
//
//  Created by 西田　耀 on 2013/11/24.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "OverlayCanvasView.h"
#import "CanvasObject.h"
#import "MainCanvasView.h"

@implementation OverlayCanvasView
{
    CGColorRef highlightColor;
    MainCanvasView *ownerCanvasView;
    CGRect oldRect;
}

@synthesize ownerCanvasView = ownerCanvasView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        highlightColor = CGColorCreateGenericRGB(0.5, 0.5, 1, 0.5);
        oldRect = CGRectMake(0, 0, 0, 0);
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
 /*
    CanvasObject *co;
    CGContextRef mainContext;
    NSArray *sol = ownerCanvasView.selectedObjectList;
    NSRect r;
    
    [super drawRect:dirtyRect];
    
    mainContext = [[NSGraphicsContext currentContext] graphicsPort];
    
    [[NSColor colorWithDeviceWhite:0.0 alpha:0.0] set];
    NSRectFillUsingOperation(oldRect, NSCompositeSourceOver);
    
    oldRect = [ownerCanvasView getVisibleRectOnObjectLayer];
    
    CGContextSetStrokeColorWithColor(mainContext, highlightColor);
    CGContextSetFillColorWithColor(mainContext, highlightColor);
    for(NSInteger i = 0; i < sol.count; i++){
        co = sol[i];
        r = NSIntersectionRect(co.frame, oldRect);
        CGContextStrokeRectWithWidth(mainContext, r, 4);
        //CGContextFillRect(mainContext, r);
    }
  */
}

@end
