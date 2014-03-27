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

// baseColor
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

// objectShape
@synthesize StrokeWidth = _StrokeWidth;
- (void)setStrokeWidth:(CGFloat)StrokeWidth
{
    [[_undoManager prepareWithInvocationTarget:self] setStrokeWidth:_StrokeWidth];
    //
    _StrokeWidth = StrokeWidth;
    // 間接的にself.frameを更新
    [self setBodyRect:self.bodyRect];
}

@synthesize bodyRect = _bodyRect;
- (void)setBodyRect:(NSRect)bodyRect
{
    bodyRect.origin.x -= (self.StrokeWidth / 2);
    bodyRect.origin.y -= (self.StrokeWidth / 2);
    bodyRect.size.width += self.StrokeWidth;
    bodyRect.size.height += self.StrokeWidth;
    
    [self setFrame:bodyRect];
}

- (NSRect)bodyRectBounds
{
    // このview上でのbodyRectの範囲を示す矩形を返す
    NSRect b;
    b = _bodyRect;
    b.origin.x = (self.StrokeWidth / 2);
    b.origin.y = (self.StrokeWidth / 2);
    return b;
}

// objectInfo
NSString * objectTypeNameList[5] = {
    @"未定義",
    @"矩形",
    @"楕円",
    @"ペイント枠",
    @"テキスト",
};
@synthesize ObjectType = _ObjectType;
- (NSString *)ObjectTypeName
{
    NSInteger t = self.ObjectType;
    if(0 <= t && t < (sizeof(objectTypeNameList) / sizeof(objectTypeNameList[0]))){
        return objectTypeNameList[t];
    }
    return nil;
}
@synthesize objectName = _objectName;
@synthesize uuid = _uuid;
@synthesize isSelected = _isSelected;

// MainCanvasView property
@synthesize undoManager = _undoManager;
@synthesize editHandleList = _editHandleList;
@synthesize ownerMainCanvasView = _ownerMainCanvasView;

//
// Function
//

// NSView override
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
        _isSelected = false;
    }

    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    
}

- (void)setFrame:(NSRect)frameRect
{
    // setFrameOriginとsetFrameSizeが内部的に呼び出される。
    [super setFrame:frameRect];
}

- (void)setFrameOrigin:(NSPoint)newOrigin
{
    [[_undoManager prepareWithInvocationTarget:self] setFrameOrigin:self.frame.origin];
    //
    [super setFrameOrigin:newOrigin];
    // bodyRectを更新
    _bodyRect.origin.x = newOrigin.x + (self.StrokeWidth / 2);
    _bodyRect.origin.y = newOrigin.y + (self.StrokeWidth / 2);
}

- (void)setFrameSize:(NSSize)newSize
{
    [[_undoManager prepareWithInvocationTarget:self] setFrameSize:self.frame.size];
    //
    if(newSize.width > FWK_MAX_SIZE_PIXEL){
        newSize.width = FWK_MAX_SIZE_PIXEL;
        NSLog(@"Too large frame width!");
    }
    if(newSize.height > FWK_MAX_SIZE_PIXEL){
        newSize.height = FWK_MAX_SIZE_PIXEL;
        NSLog(@"Too large frame height!");
    }
    if(newSize.width < FWK_MIN_SIZE_PIXEL + self.StrokeWidth){
        newSize.width = FWK_MIN_SIZE_PIXEL + self.StrokeWidth;
        NSLog(@"Too small frame width!");
    }
    if(newSize.height < FWK_MIN_SIZE_PIXEL + self.StrokeWidth){
        newSize.height = FWK_MIN_SIZE_PIXEL + self.StrokeWidth;
        NSLog(@"Too small frame height!");
    }
    
    [super setFrameSize:newSize];
    // bodyRectを更新
    _bodyRect.size.width = newSize.width - self.StrokeWidth;
    _bodyRect.size.height = newSize.height - self.StrokeWidth;
}

//
- (void)drawFocusRect
{
    CGContextRef mainContext;
    CGRect rect;
    NSColor *c;
    
    if(_isSelected){
        mainContext = [[NSGraphicsContext currentContext] graphicsPort];
        
        rect = self.bodyRectBounds;
        c = [[NSColor selectedControlColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
        c = [NSColor colorWithCalibratedRed:c.redComponent green:c.greenComponent blue:c.blueComponent alpha:0.75];
        
        CGContextSaveGState(mainContext);
        {
            CGContextSetStrokeColorWithColor(mainContext, [c CGColor]);
            CGContextStrokeRectWithWidth(mainContext, rect, 8);
        }
        CGContextRestoreGState(mainContext);
    }
}

// data encoding
// Frame|FillColor|StrokeColor|StrokeWidth
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

// Preview drawing
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

// User interaction
- (void)doubleClicked
{

}

- (void)selected
{
    _isSelected = true;
}

- (void)deselected
{
    _isSelected = false;
}

// EditHandle <CanvasObjectHandling>
- (NSUInteger)numberOfEditHandlesForCanvasObject
{
    return 0;
}

// ViewComputing
+ (NSRect)makeNSRectFromMouseMoving:(NSPoint)startPoint :(NSPoint)endPoint
{
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
    return NSMakeRect(p.x, p.y, q.width, q.height);
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

