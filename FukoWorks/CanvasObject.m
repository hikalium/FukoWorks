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
    NSRect realRect;
    
    realRect = [self makeNSRectWithRealSizeViewFrame];
    _StrokeWidth = StrokeWidth;
    [self setFrame:[self makeNSRectWithFullSizeViewFrameFromRealSizeViewFrame:realRect]];
    [self resetHandle];
    [self setNeedsDisplay:YES];
}

@synthesize ObjectType = _ObjectType;

@synthesize Focused = _Focused;
- (void)setFocused:(BOOL)Focused
{
    NSRect realSizeFrame;
    CanvasObjectHandle *aHandle;
    NSPoint aPoint;
    
    realSizeFrame = [self makeNSRectWithRealSizeViewFrame];
    
    if(Focused != _Focused){
        if(Focused){
            //LD
            aPoint = realSizeFrame.origin;
            aHandle = [[CanvasObjectHandle alloc] initWithHandlePoint:aPoint];
            aHandle.ownerCanvasObject = self;
            aHandle.tag = 0;
            editHandle[aHandle.tag] = aHandle;
            //LU
            aPoint = NSMakePoint(realSizeFrame.origin.x, realSizeFrame.origin.y + realSizeFrame.size.height - 1);
            aHandle = [[CanvasObjectHandle alloc] initWithHandlePoint:aPoint];
            aHandle.ownerCanvasObject = self;
            aHandle.tag = 1;
            editHandle[aHandle.tag] = aHandle;
            //RD
            aPoint = NSMakePoint(realSizeFrame.origin.x + realSizeFrame.size.width - 1, realSizeFrame.origin.y);
            aHandle = [[CanvasObjectHandle alloc] initWithHandlePoint:aPoint];
            aHandle.ownerCanvasObject = self;
            aHandle.tag = 2;
            editHandle[aHandle.tag] = aHandle;
            //RU
            aPoint = NSMakePoint(realSizeFrame.origin.x + realSizeFrame.size.width - 1, realSizeFrame.origin.y + realSizeFrame.size.height - 1);
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
    }
    _Focused = Focused;
}

- (void)resetHandle
{
    NSRect realSizeFrame;
    NSPoint aPoint;
    
    realSizeFrame = [self makeNSRectWithRealSizeViewFrame];
    
    //LD
    aPoint = realSizeFrame.origin;
    [((CanvasObjectHandle *)editHandle[0]) setHandlePoint:aPoint];
    //LU
    aPoint = NSMakePoint(realSizeFrame.origin.x, realSizeFrame.origin.y + realSizeFrame.size.height - 1);
    [((CanvasObjectHandle *)editHandle[1]) setHandlePoint:aPoint];
    //RD
    aPoint = NSMakePoint(realSizeFrame.origin.x + realSizeFrame.size.width - 1, realSizeFrame.origin.y);
    [((CanvasObjectHandle *)editHandle[2]) setHandlePoint:aPoint];
    //RU
    aPoint = NSMakePoint(realSizeFrame.origin.x + realSizeFrame.size.width - 1, realSizeFrame.origin.y + realSizeFrame.size.height - 1);
    [((CanvasObjectHandle *)editHandle[3]) setHandlePoint:aPoint];
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

- (id)initWithEncodedString:(NSString *)sourceString
{
    NSArray *dataValues;
    
    dataValues = [sourceString componentsSeparatedByString:@"|"];
    
    self = [self initWithFrame:NSRectFromString([dataValues objectAtIndex:0])];
    
    if(self){
        self.FillColor = [CanvasObject decodedCGColorRefFromString:[dataValues objectAtIndex:1]];
        self.StrokeColor = [CanvasObject decodedCGColorRefFromString:[dataValues objectAtIndex:2]];
        self.StrokeWidth = ((NSString *) [dataValues objectAtIndex:3]).floatValue;
    }
        
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

//Frame|FillColor|StrokeColor|StrokeWidth
- (NSString *)encodedStringForCanvasObject
{
    NSMutableString *encodedString;

    
    encodedString = [[NSMutableString alloc] init];
    
    [encodedString appendFormat:@"%@|", NSStringFromRect(self.frame)];
    [encodedString appendFormat:@"%@|", [CanvasObject encodedStringForCGColorRef:self.FillColor]];
    [encodedString appendFormat:@"%@|", [CanvasObject encodedStringForCGColorRef:self.StrokeColor]];
    [encodedString appendFormat:@"%f|", self.StrokeWidth];
    
    return [NSString stringWithString:encodedString];
}

+ (NSString *)encodedStringForCGColorRef:(CGColorRef)cref
{
    NSMutableString *encodedString;
    NSInteger i, i_max;
    const CGFloat *colorComponents;
    
    encodedString = [[NSMutableString alloc] init];
    
    colorComponents = CGColorGetComponents(cref);
    i_max = CGColorGetNumberOfComponents(cref);
    
    for(i = 0; i < i_max; i++){
        [encodedString appendFormat:@"%f,", colorComponents[i]];
    }
    
    return [NSString stringWithString:encodedString];
}

+ (CGColorRef)decodedCGColorRefFromString:(NSString *)sourceString
{
    NSArray *dataValues;
    CGColorRef cRef;
    CGFloat colorComponents[4];
    NSUInteger i;
    
    dataValues = [sourceString componentsSeparatedByString:@","];

    for(i = 0; i < sizeof(colorComponents) / sizeof(CGFloat); i++){
        colorComponents[i] = ((NSString *)[dataValues objectAtIndex:i]).floatValue;
    }
       
    cRef = CGColorCreateGenericRGB(colorComponents[0], colorComponents[1], colorComponents[2], colorComponents[3]);
    
    return cRef;
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

- (void)editHandleDown:(NSPoint)currentHandlePointInCanvas :(NSInteger) tag
{
    editingHandleID = tag;
    
    switch (tag) {
        case 0:
            //LD
        case 3:
            //RU
            [((CanvasObjectHandle *)editHandle[1]) setHidden:YES];
            [((CanvasObjectHandle *)editHandle[2]) setHidden:YES];
            break;
        case 1:
            //LU
        case 2:
            //RD
            [((CanvasObjectHandle *)editHandle[0]) setHidden:YES];
            [((CanvasObjectHandle *)editHandle[3]) setHidden:YES];
            break;
    }
}

- (void)editHandleDragged:(NSPoint)currentHandlePointInCanvas :(NSInteger) tag
{
    switch (tag) {
        case 0:
            //LD
            [self setFrame:[self makeNSRectFromMouseMoving:[((CanvasObjectHandle *)editHandle[3]) makeNSPointWithHandlePoint] :currentHandlePointInCanvas]];
            break;
        case 1:
            //LU
            [self setFrame:[self makeNSRectFromMouseMoving:[((CanvasObjectHandle *)editHandle[2]) makeNSPointWithHandlePoint] :currentHandlePointInCanvas]];
            break;
        case 2:
            //RD
            [self setFrame:[self makeNSRectFromMouseMoving:[((CanvasObjectHandle *)editHandle[1]) makeNSPointWithHandlePoint] :currentHandlePointInCanvas]];
            break;
        case 3:
            //RU
            [self setFrame:[self makeNSRectFromMouseMoving:[((CanvasObjectHandle *)editHandle[0]) makeNSPointWithHandlePoint] :currentHandlePointInCanvas]];
            break;
    }
    [self setNeedsDisplay:YES];
}

- (void)editHandleUp:(NSPoint)currentHandlePointInCanvas :(NSInteger) tag
{
    switch (tag) {
        case 0:
            //LD
        case 3:
            //RU
            [((CanvasObjectHandle *)editHandle[1]) setHidden:NO];
            [((CanvasObjectHandle *)editHandle[2]) setHidden:NO];
            break;
        case 1:
            //LU
        case 2:
            //RD
            [((CanvasObjectHandle *)editHandle[0]) setHidden:NO];
            [((CanvasObjectHandle *)editHandle[3]) setHidden:NO];
            break;

    }
    
    [self resetHandle];
}

- (NSRect)makeNSRectFromMouseMoving:(NSPoint)startPoint :(NSPoint)endPoint
{
    //全体を含むframeRectを返す。
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

- (NSRect)makeNSRectWithRealSizeViewFrame
{
    //親FrameにおけるRealSizeRect(Fill部分のみのRect)を返す。
    NSRect realRect;
    
    realRect = self.frame;
    
    realRect.origin.x += (self.StrokeWidth / 2);
    realRect.origin.y += (self.StrokeWidth / 2);
    realRect.size.height -= self.StrokeWidth;
    realRect.size.width -= self.StrokeWidth;
    
    return realRect;
}

- (NSRect)makeNSRectWithRealSizeViewFrameInLocal
{
    //このViewに対する、ローカル座標のRealSizeRect(Fill部分のみのRect)を返す。
    NSRect realRect;
    
    realRect.origin.x = (self.StrokeWidth / 2);
    realRect.origin.y = (self.StrokeWidth / 2);
    realRect.size.height = self.frame.size.height - self.StrokeWidth;
    realRect.size.width = self.frame.size.width - self.StrokeWidth;
    
    return realRect;
}

- (NSRect)makeNSRectWithFullSizeViewFrameFromRealSizeViewFrame:(NSRect)RealSizeViewFrame
{
    RealSizeViewFrame.origin.x -= (self.StrokeWidth / 2);
    RealSizeViewFrame.origin.y -= (self.StrokeWidth / 2);
    RealSizeViewFrame.size.height += self.StrokeWidth;
    RealSizeViewFrame.size.width += self.StrokeWidth;
    
    return RealSizeViewFrame;
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

