//
//  MainCanvasView.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/16.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "MainCanvasView.h"
#import "CanvasObjectListWindowController.h"

@implementation MainCanvasView

//
// Property
//

@synthesize label_indicator = _label_indicator;
@synthesize toolboxController = _toolboxController;
@synthesize canvasScale = _canvasScale;
- (void)setCanvasScale:(CGFloat)canvasScale
{
    [self scaleUnitSquareToSize:NSMakeSize(1/_canvasScale, 1/_canvasScale)];
    _canvasScale = canvasScale;
    [self scaleUnitSquareToSize:NSMakeSize(canvasScale, canvasScale)];
    [self setFrameSize:NSMakeSize(rootSubCanvas.frame.size.width * canvasScale, rootSubCanvas.frame.size.height * canvasScale)];
    [self.superview setNeedsDisplay:YES];
    [self setNeedsDisplay:YES];
    [self resetAllCanvasObjectHandle];
}
- (NSSize)canvasSize{
    return rootSubCanvas.frame.size;
}
- (void)setCanvasSize:(NSSize)canvasSize
{
    [rootSubCanvas setFrameSize:canvasSize];
    [self setCanvasScale:self.canvasScale];
}

@synthesize canvasObjects = _canvasObjects;
@synthesize realSizeCanvas = rootSubCanvas;
@synthesize selectedObjectList = selectedObjects;

//
// Function
//

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        undoManager = [[NSUndoManager alloc] init];
        
        drawingStartPoint.x = 0;
        drawingStartPoint.y = 0;
        
        backgroundColor = CGColorCreateGenericRGB(1, 1, 1, 1);
        _canvasScale = 1;
        
        creatingObject = nil;
        movingObject = nil;
        
        inspectorWindows = [NSMutableArray array];
        _canvasObjects = [NSMutableArray array];
        
        rootSubCanvas = [[SubCanvasView alloc] initWithFrame:frame];
        [self addSubview:rootSubCanvas];
        
        objectHandles = [[NSMutableDictionary alloc] init];
        selectedObjects = [[NSMutableArray alloc] init];
        
        //NSLog(@"Init %@ \n%@\n", self.className, self.subviews.description);
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef mainContext;
    CGRect rect;
    
    mainContext = [[NSGraphicsContext currentContext] graphicsPort];
    
    rect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    CGContextSaveGState(mainContext);
    {
        CGContextSetFillColorWithColor(mainContext, backgroundColor);
        CGContextFillRect(mainContext, rect);
    }
    CGContextRestoreGState(mainContext);
}

-(void)resetCursorRects
{
    [self discardCursorRects];
    if(_toolboxController.drawingObjectType == Undefined){
        [self addCursorRect:self.visibleRect cursor:[NSCursor arrowCursor]];
    } else{
        [self addCursorRect:self.visibleRect cursor:[NSCursor crosshairCursor]];
    }
}

//
// add / remove CanvasObject
//

- (void)addCanvasObject:(CanvasObject *)aCanvasObject
{
    //最上面に追加
    aCanvasObject.ownerMainCanvasView = self;
    [rootSubCanvas addSubview:aCanvasObject positioned:NSWindowAbove relativeTo:nil];
    [_canvasObjects addObject:aCanvasObject];
    //NSLog(@"Added CanvasObject to %@ \n%@\n", rootSubCanvas.className, rootSubCanvas.subviews.description);
    [[CanvasObjectListWindowController sharedCanvasObjectListWindowController] reloadData];
}

- (void)removeCanvasObject:(CanvasObject *)aCanvasObject
{
    aCanvasObject.ownerMainCanvasView = self;
    if(creatingObject == aCanvasObject){
        creatingObject = nil;
    }
    if(movingObject == aCanvasObject){
        movingObject = nil;
    }
    [self deselectCanvasObject:aCanvasObject];
    [aCanvasObject removeFromSuperview];
    [_canvasObjects removeObject:aCanvasObject];
    if(aCanvasObject != nil){
        //NSLog(@"Removed CanvasObject. \n%@\n", rootSubCanvas.subviews.description);
    }
    [[CanvasObjectListWindowController sharedCanvasObjectListWindowController] reloadData];
}

- (void)removeCanvasObjects:(NSArray *)canvasObjectList
{
    NSArray *tmpList = [[NSArray alloc] initWithArray:canvasObjectList];
    for(CanvasObject *co in tmpList){
        [self removeCanvasObject:co];
    }
}



- (NSRect)getVisibleRectOnObjectLayer
{
    //最上位オブジェクト座標系(rootSubCanvas.subviews)における、現在キャンバスが表示している範囲の矩形を返す
    return [self.superview convertRect:self.superview.bounds toView:rootSubCanvas];
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

- (NSPoint)getPointerLocationInScreen:(NSEvent *)event
{
    NSPoint currentPoint;
    
    currentPoint = [event locationInWindow];
    currentPoint = [self.window convertBaseToScreen:currentPoint];
    return currentPoint;
}

- (CanvasObject *)getCanvasObjectAtCursorLocation:(NSEvent *)event
{
    CanvasObject *aCanvasObject, *candidateCanvasObject;
    NSBitmapImageRep *bitmapImage;
    NSPoint currentPointOnCanvas;
    NSPoint currentPointOnObject;
    NSPoint currentPointOnObjectOwner;
    NSColor *pointColor;
    NSArray *subviews = [[rootSubCanvas.subviews reverseObjectEnumerator] allObjects];
    NSRect subRect;
    NSRect visibleRectOnObject;
    currentPointOnCanvas = [self getPointerLocationRelativeToSelfView:event];
    
    candidateCanvasObject = nil;
    for(NSView *aSubview in subviews){
        if([aSubview isKindOfClass:[CanvasObject class]]){
            //前面にあるオブジェクトから順番に、ポインタの指す座標が含まれているか調べる。
            aCanvasObject = (CanvasObject *)aSubview;
            currentPointOnObjectOwner = [self convertPoint:currentPointOnCanvas toView:aCanvasObject.superview];
            if(NSPointInRect(currentPointOnObjectOwner, aCanvasObject.frame)){
                currentPointOnObject = [aCanvasObject convertPoint:currentPointOnCanvas fromView:self];
                visibleRectOnObject = [aCanvasObject convertRect:[self getVisibleRectOnObjectLayer] fromView:rootSubCanvas];
                subRect = NSIntersectionRect(aCanvasObject.bounds, visibleRectOnObject);
                //vvv 指定するRectはオブジェクト自身上での座標
                bitmapImage = [aCanvasObject bitmapImageRepForCachingDisplayInRect:subRect];
                //vvv 生成されるbitmapは、表示状態の倍率なので注意
                [aCanvasObject cacheDisplayInRect:subRect toBitmapImageRep:bitmapImage];
                pointColor = [bitmapImage
                              colorAtX: (currentPointOnObject.x - subRect.origin.x) * self.canvasScale
                              //vvv Y座標は逆方向
                              y:(subRect.size.height - (currentPointOnObject.y - subRect.origin.y)) * self.canvasScale];
                if([pointColor numberOfComponents] == 0 || [pointColor alphaComponent] != 0){
                    //指定された座標が、完全に透明でないことを確認
                    //NSLog(@"%@", [pointColor debugDescription]);
                    candidateCanvasObject = aCanvasObject;
                    break;
                }
            }
        }
    }
    return candidateCanvasObject;
}

//
// MenuItem
//

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if( [menuItem action] == @selector(cut:) ||
       [menuItem action] == @selector(copy:) ||
       [menuItem action] == @selector(delete:) ){
        return (selectedObjects.count > 0);
    } else if([menuItem action] == @selector(paste:)){
        return [self pasteboardHas:FWK_PASTEBOARD_TYPE];
    } else if([menuItem action] == @selector(undo:)){
        return [undoManager canUndo];
    } else if([menuItem action] == @selector(redo:)){
        return [undoManager canRedo];
    }
    return YES;
}

//
// Pasteboard
//

- (BOOL)pasteboardHas:(NSString *)theType
{
    NSPasteboard    *pasteboard = [NSPasteboard generalPasteboard];
    NSArray         *types = [NSArray arrayWithObject:theType];
    
    return  ([pasteboard availableTypeFromArray:types] != nil);
}

- (IBAction)copy:(id)sender
{
    if(selectedObjects.count > 0){
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard declareTypes:[NSArray arrayWithObject:FWK_PASTEBOARD_TYPE] owner:nil];
        [pasteboard setData:[[self convertCanvasObjectsToString:selectedObjects] dataUsingEncoding:NSUTF8StringEncoding] forType:FWK_PASTEBOARD_TYPE];
    }
}
- (IBAction)paste:(id)sender
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSData *data = [pasteboard dataForType:FWK_PASTEBOARD_TYPE];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self appendCanvasObjectsFromString:str];
}
- (IBAction)cut:(id)sender
{
    [self copy:sender];
    [self delete:sender];
}
- (IBAction)delete:(id)sender
{
    [self removeCanvasObjects:selectedObjects];
}



@end
