//
//  CanvasObjectRectangle.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/17.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObjectRectangle.h"

@implementation CanvasObjectRectangle
//矩形オブジェクト

//プロパティアクセッサメソッド
@synthesize ObjectType = _ObjectType;

//メソッド
- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        _ObjectType = Rectangle;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //再描画時に呼ばれる。
    CGContextRef mainContext;
    CGRect rect;
    
    mainContext = [[NSGraphicsContext currentContext] graphicsPort];
    
    rect = self.bodyRectBounds;
    
    CGContextSaveGState(mainContext);
    {
        CGContextSetFillColorWithColor(mainContext, self.FillColor.CGColor);
        CGContextFillRect(mainContext, rect);
        CGContextSetStrokeColorWithColor(mainContext, self.StrokeColor.CGColor);
        CGContextStrokeRectWithWidth(mainContext, rect, self.StrokeWidth);
    }
    CGContextRestoreGState(mainContext);
    
    [self drawFocusRect];
}
@end
