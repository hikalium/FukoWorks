//
//  MainCanvasView.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/16.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "MainCanvasView.h"

@implementation MainCanvasView

@synthesize label_indicator = _label_indicator;

@synthesize toolboxController = _toolboxController;
@synthesize canvasScale = _canvasScale;
- (void)setCanvasScale:(CGFloat)canvasScale
{
    [self scaleUnitSquareToSize:NSMakeSize(1/_canvasScale, 1/_canvasScale)];
    _canvasScale = canvasScale;
    [self scaleUnitSquareToSize:NSMakeSize(canvasScale, canvasScale)];
    [self setFrameSize:NSMakeSize(baseFrame.size.width * canvasScale, baseFrame.size.height * canvasScale)];
    [self.superview setNeedsDisplay:YES];
    [self setNeedsDisplay:YES];
}
@synthesize focusedObject = _focusedObject;
- (void)setFocusedObject:(CanvasObject *)focusedObject
{
    if(focusedObject != _focusedObject){
        [_focusedObject setFocused:NO];
        [focusedObject setFocused:YES];
    }
    _focusedObject = focusedObject;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        baseFrame = NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
        drawingStartPoint.x = 0;
        drawingStartPoint.y = 0;
        
        backgroundColor = CGColorCreateGenericRGB(1, 1, 1, 1);
        _canvasScale = 1;
        
        dragging = false;
        
        canvasCursor = [NSCursor crosshairCursor];
        
        editingObject = nil;
        _focusedObject = nil;
        movingObject = nil;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef mainContext;
    CGRect rect, guideRect;
    
    mainContext = [[NSGraphicsContext currentContext] graphicsPort];
    
    rect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    guideRect = NSRectToCGRect([self makeNSRectFromMouseMoving:drawingStartPoint :drawingDragPoint]);
    
    CGContextSaveGState(mainContext);
    {
        CGContextSetFillColorWithColor(mainContext, backgroundColor);
        CGContextFillRect(mainContext, rect);
    }
    CGContextRestoreGState(mainContext);
}

- (void)mouseDown:(NSEvent*)event
{
    NSPoint currentPoint;
    
    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mDw:%@", NSStringFromPoint(currentPoint)]];

    if(editingObject == nil){
        //図形の新規作成
        switch(self.toolboxController.drawingObjectType){
            case Undefined:
                movingObject = [self getCanvasObjectAtCursorLocation:event];
                if(movingObject){
                    moveHandleOffset = NSMakePoint(currentPoint.x - movingObject.frame.origin.x, currentPoint.y - movingObject.frame.origin.y);
                }
                break;
            case Rectangle:
                editingObject = [[CanvasObjectRectangle alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
                break;
            case Ellipse:
                editingObject = [[CanvasObjectEllipse alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
                break;
        }
        if(editingObject != nil){
            editingObject.FillColor = self.toolboxController.drawingFillColor;
            editingObject.StrokeColor = self.toolboxController.drawingStrokeColor;
            editingObject.StrokeWidth = self.toolboxController.drawingStrokeWidth;
            [self addSubview:editingObject];
            
            editingObject = [editingObject drawMouseDown:currentPoint];
        }
    } else{
        //図形描画の途中
        editingObject = [editingObject drawMouseDown:currentPoint];
    }
}

- (void)mouseDragged:(NSEvent*)event
{
    NSPoint currentPoint;
    
    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mDr:%@", NSStringFromPoint(currentPoint)]];
    
    editingObject = [editingObject drawMouseDragged:currentPoint];
    
    [movingObject setFrameOrigin:NSMakePoint(currentPoint.x - moveHandleOffset.x, currentPoint.y - moveHandleOffset.y)];
}

- (void)mouseUp:(NSEvent*)event
{
    NSPoint currentPoint;

    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mUp:%@", NSStringFromPoint(currentPoint)]];
 
    editingObject = [editingObject drawMouseUp:currentPoint];
    
    movingObject = nil;
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    self.focusedObject = [self getCanvasObjectAtCursorLocation:theEvent];
}

-(void)resetCursorRects
{
    [self discardCursorRects];
    [self addCursorRect:self.visibleRect cursor:canvasCursor];
}

- (NSRect)makeNSRectFromMouseMoving:(NSPoint)startPoint :(NSPoint)endPoint
{
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

- (CanvasObject *)getCanvasObjectAtCursorLocation:(NSEvent *)event
{
    NSPoint currentPoint;
    CanvasObject *aCanvasObject, *candidateCanvasObject;
    NSBitmapImageRep *bitmapImage;
    NSPoint currentPointInObject;
    NSColor *pointColor;
    
    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    
    candidateCanvasObject = nil;
    for(NSView *aSubview in [self.subviews reverseObjectEnumerator]){
        if([aSubview isKindOfClass:[CanvasObject class]]){
            //前面にあるオブジェクトから順番に、ポインタの指す座標が含まれているか調べる。
            aCanvasObject = (CanvasObject *)aSubview;
            if(NSPointInRect(currentPoint, aCanvasObject.frame)){
                currentPointInObject = [aCanvasObject getPointerLocationRelativeToSelfView:event];
                [self.label_indicator setStringValue:NSStringFromPoint(currentPointInObject)];
                bitmapImage = [aCanvasObject bitmapImageRepForCachingDisplayInRect:aCanvasObject.frame];
                [aCanvasObject cacheDisplayInRect:aCanvasObject.bounds toBitmapImageRep:bitmapImage];
                //bitmapimageは表示状態の倍率で保存されているので、座標にCanvasScaleを掛けなければならない。
                pointColor = [bitmapImage colorAtX:currentPointInObject.x * self.canvasScale y:currentPointInObject.y * self.canvasScale];
                if([pointColor alphaComponent] != 0 || [pointColor numberOfComponents] == 0){
                    //指定された座標が、完全に透明でないことを確認
                    candidateCanvasObject = aCanvasObject;
                    break;
                }
            }
        }
    }

    return candidateCanvasObject;
}

@end
