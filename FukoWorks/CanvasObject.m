//
//  CanvasObject.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/28.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObject.h"
#import "CanvasObjectHandle.h"

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

@synthesize Focused = _Focused;
- (void)setFocused:(BOOL)Focused
{
    CanvasObjectHandle *aHandle;
    NSPoint aPoint;
    
    if(Focused){
        //LD
        aPoint = self.frame.origin;
        aHandle = [[CanvasObjectHandle alloc] initWithHandlePoint:aPoint];
        aHandle.ownerCanvasObject = self;
        aHandle.tag = 0;
        editHandle[aHandle.tag] = aHandle;
        //LU
        aPoint = NSMakePoint(self.frame.origin.x, self.frame.origin.y + self.frame.size.height - 1);
        aHandle = [[CanvasObjectHandle alloc] initWithHandlePoint:aPoint];
        aHandle.ownerCanvasObject = self;
        aHandle.tag = 1;
        editHandle[aHandle.tag] = aHandle;
        //RD
        aPoint = NSMakePoint(self.frame.origin.x + self.frame.size.width - 1, self.frame.origin.y);
        aHandle = [[CanvasObjectHandle alloc] initWithHandlePoint:aPoint];
        aHandle.ownerCanvasObject = self;
        aHandle.tag = 2;
        editHandle[aHandle.tag] = aHandle;
        //RU
        aPoint = NSMakePoint(self.frame.origin.x + self.frame.size.width - 1, self.frame.origin.y + self.frame.size.height - 1);
        aHandle = [[CanvasObjectHandle alloc] initWithHandlePoint:aPoint];
        aHandle.ownerCanvasObject = self;
        aHandle.tag = 3;
        editHandle[aHandle.tag] = aHandle;
        
        for(int i = 0; i < 4; i++){
            [self.superview addSubview:editHandle[i]];
        }
        
    } else{
        for(int i = 0; i < 4; i++){
            [editHandle[i] removeFromSuperview];
            editHandle[i] = nil;
        }
    }
    _Focused = Focused;
}

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        // Initialization code here.
        _ObjectType = Undefined;
        
        _FillColor = nil;
        _FillColor = nil;
        _StrokeWidth = 0;
        
        _Focused = NO;
        for(int i = 0; i < 4; i++){
            editHandle[i] = nil;
        }
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}
 
- (NSString *)encodedStringForObject
{
    NSMutableString *encodedString;

    
    encodedString = [[NSMutableString alloc] init];
    
    [encodedString appendFormat:@"%@:", NSStringFromRect(self.frame)];
    [encodedString appendFormat:@"%ld:", self.ObjectType];

    [encodedString appendFormat:@"%@:", [self encodedStringForCGColorRef:self.FillColor]];
    [encodedString appendFormat:@"%@:", [self encodedStringForCGColorRef:self.StrokeColor]];
    [encodedString appendFormat:@"%f:", self.StrokeWidth];
    
    return [NSString stringWithString:encodedString];
}

- (NSString *)encodedStringForCGColorRef:(CGColorRef)cref
{
    NSMutableString *encodedString;
    NSInteger i, i_max;
    const CGFloat *colorComponents;    
    encodedString = [[NSMutableString alloc] init];
    
    colorComponents = CGColorGetComponents(cref);
    i_max = CGColorGetNumberOfComponents(cref);
    
    [encodedString appendFormat:@"%ld,", i_max];
    for(i = 0; i < i_max; i++){
        [encodedString appendFormat:@"%f,", colorComponents[i]];
    }
    
    return [NSString stringWithString:encodedString];
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

- (void)editHandleDragged:(NSPoint)currentHandlePointInCanvas :(NSInteger) tag
{
    switch (tag) {
        case 0:
            //LD
            break;
        case 1:
            //LU
            break;
        case 2:
            //RD
            break;
        case 3:
            //RU
            break;
    }
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

