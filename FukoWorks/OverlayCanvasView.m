//
//  OverlayCanvasView.m
//  FukoWorks
//
//  Created by 西田　耀 on 2013/11/24.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "OverlayCanvasView.h"
#import "CanvasObject.h"

@implementation OverlayCanvasView

@synthesize canvasObjectList = _canvasObjectList;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        highlightColor = CGColorCreateGenericRGB(0.5, 0.5, 1, 0.5);
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CanvasObject *co;
    CGContextRef mainContext;
    
    [super drawRect:dirtyRect];
    
    mainContext = [[NSGraphicsContext currentContext] graphicsPort];
    
    for(NSInteger i = 0; i < _canvasObjectList.count; i++){
        co = _canvasObjectList[i];
        if(co.Focused){
            CGContextSetStrokeColorWithColor(mainContext, highlightColor);
            CGContextStrokeRectWithWidth(mainContext, co.frame, 4);
        }
    }
    // Drawing code here.
}

@end
