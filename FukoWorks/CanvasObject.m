//
//  CanvasObject.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/28.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObject.h"
#import "NSColor+StringConversion.h"
#import "NSString+UUIDGeneration.h"

@implementation CanvasObject
//
// Property
//

@synthesize FillColor = _FillColor;
- (void)setFillColor:(NSColor *)FillColor
{
    [[_undoManager prepareWithInvocationTarget:self] setFillColor:_FillColor];
    //
    _FillColor = FillColor;
    [self setNeedsDisplay:YES];
}

@synthesize StrokeColor = _StrokeColor;
- (void)setStrokeColor:(NSColor *)StrokeColor
{
    [[_undoManager prepareWithInvocationTarget:self] setStrokeColor:_StrokeColor];
    //
    _StrokeColor = StrokeColor;
    [self setNeedsDisplay:YES];
}

@synthesize StrokeWidth = _StrokeWidth;
- (void)setStrokeWidth:(CGFloat)StrokeWidth
{
    NSRect realRect;
    //
    [[_undoManager prepareWithInvocationTarget:self] setStrokeWidth:_StrokeWidth];
    //
    realRect = [self makeNSRectWithRealSizeViewFrame];
    _StrokeWidth = StrokeWidth;
    [self setFrame:[self makeNSRectWithFullSizeViewFrameFromRealSizeViewFrame:realRect]];
    [self setNeedsDisplay:YES];
}

@synthesize ObjectType = _ObjectType;

NSString *objectTypeNameList[] = {
    @"キャンバス",
    @"矩形",
    @"楕円",
    @"ペイント枠"};

- (NSString *)ObjectTypeName
{
    NSInteger t = self.ObjectType;
    if(0 <= t && t < (sizeof(objectTypeNameList) / sizeof(objectTypeNameList[0]))){
        return objectTypeNameList[t];
    }
    return nil;
}

@synthesize objectName = _objectName;
@synthesize undoManager = _undoManager;
@synthesize uuid = _uuid;
@synthesize editHandleList = _editHandleList;
@synthesize ownerMainCanvasView = _ownerMainCanvasView;

//
// Function
//
- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        _ObjectType = Undefined;
        
        _FillColor = nil;
        _StrokeColor = nil;
        _StrokeWidth = 0;
        
        _objectName = @"NoName";
        _uuid = [NSString UUID];
    }

    return self;
}

- (id)initWithEncodedString:(NSString *)sourceString
{
    NSArray *dataValues;
    
    dataValues = [sourceString componentsSeparatedByString:@"|"];
    
    self = [self initWithFrame:NSRectFromString([dataValues objectAtIndex:0])];
    
    if(self){
        self.FillColor = [NSColor colorFromString:[dataValues objectAtIndex:1] forColorSpace:[NSColorSpace deviceRGBColorSpace]];
        self.StrokeColor = [NSColor colorFromString:[dataValues objectAtIndex:2] forColorSpace:[NSColorSpace deviceRGBColorSpace]];
        self.StrokeWidth = ((NSString *) [dataValues objectAtIndex:3]).floatValue;
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
    
}

- (void)setFrame:(NSRect)frameRect
{
    [[_undoManager prepareWithInvocationTarget:self] setFrame:self.frame];
    //
    if(frameRect.size.width > FWK_MAX_SIZE_PIXEL){
        frameRect.size.width = FWK_MAX_SIZE_PIXEL;
        NSLog(@"Too large frame width!");
    }
    if(frameRect.size.height > FWK_MAX_SIZE_PIXEL){
        frameRect.size.height = FWK_MAX_SIZE_PIXEL;
        NSLog(@"Too large frame height!");
    }
    [super setFrame:frameRect];
}

//Frame|FillColor|StrokeColor|StrokeWidth
- (NSString *)encodedStringForCanvasObject
{
    NSMutableString *encodedString;

    
    encodedString = [[NSMutableString alloc] init];
    
    [encodedString appendFormat:@"%@|", NSStringFromRect(self.frame)];
    [encodedString appendFormat:@"%@|", [self.FillColor stringRepresentation]];
    [encodedString appendFormat:@"%@|", [self.StrokeColor stringRepresentation]];
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

- (void)doubleClicked
{

}

- (void)selected
{
    
}

- (void)deselected
{
    
}

//
// EditHandle
//
- (NSUInteger)numberOfEditHandlesForCanvasObject
{
    return 0;
}

//
// ViewComputing
//
- (NSRect)makeNSRectFromMouseMoving:(NSPoint)startPoint :(NSPoint)endPoint
{
    //全体を含むframeRectを返す。
    NSPoint p;
    NSSize q;
    
    if(endPoint.x < startPoint.x){
        p.x = endPoint.x;
        q.width = startPoint.x - endPoint.x;
    } else{
        p.x = startPoint.x;
        q.width = endPoint.x - startPoint.x;
    }
    
    if(endPoint.y < startPoint.y){
        p.y = endPoint.y;
        q.height = startPoint.y - endPoint.y;
    } else{
        p.y = startPoint.y;
        q.height = endPoint.y - startPoint.y;
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

