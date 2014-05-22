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
    [[_canvasUndoManager prepareWithInvocationTarget:self] setFillColor:_FillColor];
    //
    _FillColor = FillColor;
    [self setNeedsDisplay:YES];
}

@synthesize StrokeColor = _StrokeColor;
- (void)setStrokeColor:(NSColor *)StrokeColor
{
    [[_canvasUndoManager prepareWithInvocationTarget:self] setStrokeColor:_StrokeColor];
    //
    _StrokeColor = StrokeColor;
    [self setNeedsDisplay:YES];
}

// objectShape
@synthesize StrokeWidth = _StrokeWidth;
- (void)setStrokeWidth:(CGFloat)StrokeWidth
{
    [[_canvasUndoManager prepareWithInvocationTarget:self] setStrokeWidth:_StrokeWidth];
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
NSString * objectTypeNameList[7] = {
    @"未定義",
    @"矩形",
    @"楕円",
    @"ペイント枠",
    @"テキスト",
    @"直線",
    @"ベジェ曲線"
};
@synthesize ObjectType = _ObjectType;
- (NSString *)ObjectTypeName
{
    NSInteger t = self.ObjectType;
    if(0 <= t && t < (sizeof(objectTypeNameList) / sizeof(objectTypeNameList[0]))){
        return objectTypeNameList[t];
    }
    return objectTypeNameList[0];
}
@synthesize objectName = _objectName;
@synthesize uuid = _uuid;
@synthesize isSelected = _isSelected;

// MainCanvasView property
@synthesize canvasUndoManager = _canvasUndoManager;
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
    if([_canvasUndoManager isUndoing] || [_canvasUndoManager isRedoing]){
        [[_canvasUndoManager prepareWithInvocationTarget:self] setFrameOrigin:self.frame.origin];
    }
    [super setFrameOrigin:newOrigin];
    // bodyRectを更新
    _bodyRect.origin.x = newOrigin.x + (self.StrokeWidth / 2);
    _bodyRect.origin.y = newOrigin.y + (self.StrokeWidth / 2);
}

- (void)setFrameSize:(NSSize)newSize
{
    if([_canvasUndoManager isUndoing] || [_canvasUndoManager isRedoing]){
        [[_canvasUndoManager prepareWithInvocationTarget:self] setFrameSize:self.frame.size];
    }
    //
    [self setFrameSizeInternal:newSize];
}

- (void)setFrameSizeInternal:(NSSize)newSize
{
    if(newSize.width > FWK_MAX_SIZE_PIXEL){
        newSize.width = FWK_MAX_SIZE_PIXEL;
    }
    if(newSize.height > FWK_MAX_SIZE_PIXEL){
        newSize.height = FWK_MAX_SIZE_PIXEL;
    }
    if(newSize.width < FWK_MIN_SIZE_PIXEL + self.StrokeWidth){
        newSize.width = FWK_MIN_SIZE_PIXEL + self.StrokeWidth;
    }
    if(newSize.height < FWK_MIN_SIZE_PIXEL + self.StrokeWidth){
        newSize.height = FWK_MIN_SIZE_PIXEL + self.StrokeWidth;
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
- (id)initWithEncodedString:(NSString *)sourceString
{
    NSArray *dataValues;
    
    dataValues = [sourceString componentsSeparatedByString:@"|"];
    
    self = [self initWithFrame:NSZeroRect];
    
    if(self){
        // BodyRect|FillColor|StrokeColor|StrokeWidth
        [self setBodyRect:NSRectFromString([dataValues objectAtIndex:0])];
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
    // BodyRect|FillColor|StrokeColor|StrokeWidth
    [encodedString appendFormat:@"%@|", NSStringFromRect(self.bodyRect)];
    [encodedString appendFormat:@"%@|", [self.FillColor stringRepresentation]];
    [encodedString appendFormat:@"%@|", [self.StrokeColor stringRepresentation]];
    [encodedString appendFormat:@"%f|", self.StrokeWidth];
    
    return [NSString stringWithString:encodedString];
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

- (void)moved
{
    
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

+ (NSRect)makeNSRectFromMouseMovingWithModifierKey:(NSPoint)startPoint :(NSPoint)endPoint
{
    CGFloat xsize, ysize;
    
    NSUInteger modifierFlags = [[NSApp currentEvent] modifierFlags];
    if (modifierFlags & NSShiftKeyMask) {
        // fix 1:1
        xsize = fabs(startPoint.x - endPoint.x);
        ysize = fabs(startPoint.y - endPoint.y);
        if(xsize > ysize){
            // y based
            if(endPoint.x > startPoint.x){
                endPoint.x = startPoint.x + ysize;
            } else{
                endPoint.x = startPoint.x - ysize;
            }
        } else{
            // x based
            if(endPoint.y > startPoint.y){
                endPoint.y = startPoint.y + xsize;
            } else{
                endPoint.y = startPoint.y - xsize;
            }
        }
    }
    return [self makeNSRectFromMouseMoving:startPoint :endPoint];
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

