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
- (NSSize)canvasSize{
    return baseFrame.size;
}
- (void)setCanvasSize:(NSSize)canvasSize
{
    baseFrame.size = canvasSize;
    [self setCanvasScale:self.canvasScale];
}

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
    _toolboxController.editingObject = focusedObject;
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
        
        clickOnly = false;
                
        editingObject = nil;
        _focusedObject = nil;
        movingObject = nil;
        
        inspectorWindows = [NSMutableArray array];
        
        NSLog(@"Init %@ \n%@\n", self.className, self.subviews.description);
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

- (void)mouseDown:(NSEvent*)event
{
    NSPoint currentPoint;
    
    //ドラッグしたらNOにする。
    clickOnly = YES;
    
    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mDw:%@", NSStringFromPoint(currentPoint)]];

    if(editingObject == nil){
        //作成中の図形はない
        //図形の新規作成or移動
        switch(self.toolboxController.drawingObjectType){
            case Undefined:
                //図形移動初期化
                movingObject = [self getCanvasObjectAtCursorLocation:event];
                if(movingObject){
                    moveHandleOffset = NSMakePoint(currentPoint.x - movingObject.frame.origin.x, currentPoint.y - movingObject.frame.origin.y);
                }
                [_focusedObject setFocused:NO];
                break;
            case Rectangle:
                editingObject = [[CanvasObjectRectangle alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
                break;
            case Ellipse:
                editingObject = [[CanvasObjectEllipse alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
                break;
            default:
                NSLog(@"Not implemented operation to make a new object.\n");
                break;
        }
        if(editingObject != nil){
            editingObject.FillColor = self.toolboxController.drawingFillColor;
            editingObject.StrokeColor = self.toolboxController.drawingStrokeColor;
            editingObject.StrokeWidth = self.toolboxController.drawingStrokeWidth;
            [self addSubview:editingObject];
            NSLog(@"Added CanvasObject to %@ \n%@\n", self.className, self.subviews.description);
            
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
    
    clickOnly = NO;
    
    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mDr:%@", NSStringFromPoint(currentPoint)]];
    
    editingObject = [editingObject drawMouseDragged:currentPoint];
    
    //図形移動
    [movingObject setFrameOrigin:NSMakePoint(currentPoint.x - moveHandleOffset.x, currentPoint.y - moveHandleOffset.y)];
}

- (void)mouseUp:(NSEvent*)event
{
    NSPoint currentPoint;

    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mUp:%@", NSStringFromPoint(currentPoint)]];
 
    editingObject = [editingObject drawMouseUp:currentPoint];
    
    //図形移動終了
    movingObject = nil;
    [_focusedObject setFocused:YES];
    
    if(clickOnly){
        //ドラッグしなかったので、クリックのみ。
        //フォーカスを与える。
        self.focusedObject = [self getCanvasObjectAtCursorLocation:event];
    }
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    //編集終了or詳細設定
    CanvasObject *aCanvasObject;
    InspectorWindowController *anInspectorWindowController;
    
    if(editingObject == nil){
        //詳細設定を開く
        aCanvasObject = [self getCanvasObjectAtCursorLocation:theEvent];
        if(aCanvasObject == nil){
            //キャンバスの詳細設定
            anInspectorWindowController = [[InspectorWindowController alloc] initWithEditView:self];
        } else{
            //オブジェクトの詳細設定
            anInspectorWindowController = [[InspectorWindowController alloc] initWithEditView:aCanvasObject];
        }
        [inspectorWindows addObject:anInspectorWindowController];
        [anInspectorWindowController showWindow:self];
    }
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    //self.focusedObject = [self getCanvasObjectAtCursorLocation:theEvent];
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
                if([pointColor numberOfComponents] == 0 || [pointColor alphaComponent] != 0){
                    //指定された座標が、完全に透明でないことを確認
                    candidateCanvasObject = aCanvasObject;
                    break;
                }
            }
        }
    }

    return candidateCanvasObject;
}


//
//TypeID:data1a,data1b,data1c|data2a,data2b,data2c\n
//
- (void)writeCanvasToURL:(NSURL *)url atomically:(BOOL)isAtomically
{
    NSMutableString *saveData;
    NSInteger count;
    CanvasObject *aCanvasObject;
    NSError *error;
    
    saveData = [[NSMutableString alloc] initWithFormat:@"[FukoWorKs]:%ld\n", [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] integerValue]];
    
    count = 0;
    for(NSView *aSubview in self.subviews){
        if([aSubview isKindOfClass:[CanvasObject class]]){
            aCanvasObject = (CanvasObject *)aSubview;
            
            switch(aCanvasObject.ObjectType){
                case Undefined:
                    //Do nothing.
                    break;
                    
                case Rectangle:
                    [saveData appendFormat:@"%ld:", aCanvasObject.ObjectType];
                    [saveData appendFormat:@"%@\n",[aCanvasObject encodedStringForCanvasObject]];
                    break;
                case Ellipse:
                    [saveData appendFormat:@"%ld:", aCanvasObject.ObjectType];
                    [saveData appendFormat:@"%@\n",[aCanvasObject encodedStringForCanvasObject]];
                    break;
                
                default:
                    NSLog(@"Not implemented operation to save object type %ld.\n", aCanvasObject.ObjectType);
                    break;
            }
            
            count++;
        }
    }
    
    error = nil;
    if(![saveData writeToURL:url atomically:isAtomically encoding:NSUTF8StringEncoding error:&error]){
        NSRunAlertPanel(@"FukoWorks-Error-", [error localizedDescription], @"OK", nil, nil);
    }
}

- (void)loadCanvasFromURL:(NSURL *)url
{
    NSString *dataString;
    NSArray *dataList;
    NSArray *dataItem;
    NSError *error;
    NSString *aDataString;
    NSString *dataItemsString;
    NSUInteger i, i_max;
    CanvasObject *aCanvasObject;
    
    error = nil;
    dataString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    dataList = [dataString componentsSeparatedByString:@"\n"];
    
    //Validation data.
    dataItemsString = [dataList objectAtIndex:0];
    dataItem = [dataItemsString componentsSeparatedByString:@":"];
    aDataString = [dataItem objectAtIndex:0];
    if(![aDataString isEqualToString:@"[FukoWorKs]"]){
        NSRunAlertPanel(@"FukoWorks-データ読み込みエラー-", @"ヘッダが見つかりません", @"OK", nil, nil);
        return;
    }
    aDataString = [dataItem objectAtIndex:1];
    if(aDataString.integerValue > [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] integerValue]){
        //もし新たなバージョンで作成されたファイルであったら、警告を出す。
        NSRunAlertPanel(@"FukoWorks-警告-", @"読み込もうとしているファイルは、より新しいバージョンのFukoWorksで作成されたものであり、正常に読み込めない可能性があります。", @"OK", nil, nil);
    }
    
    //データ読み込み
    i_max = [dataList count];
    for(i = 1; i < i_max; i++){
        dataItemsString = [dataList objectAtIndex:i];
        dataItem = [dataItemsString componentsSeparatedByString:@":"];
        aDataString = [dataItem objectAtIndex:0];
        aCanvasObject = nil;
        switch ((CanvasObjectType)aDataString.integerValue) {
            case Undefined:
                //Do nothing.
                break;
            case Rectangle:
                aCanvasObject = [[CanvasObjectRectangle alloc] initWithEncodedString:[dataItem objectAtIndex:1]];
                break;
                
            case Ellipse:
                aCanvasObject = [[CanvasObjectEllipse alloc] initWithEncodedString:[dataItem objectAtIndex:1]];
                break;
                
            default:
                NSLog(@"Not implemented operation to load object type %ld.\n", aDataString.integerValue);
                break;
        }
        if(aCanvasObject != nil){
            [self addSubview:aCanvasObject];
            NSLog(@"Added CanvasObject to %@ \n%@\n", self.className, self.subviews.description);
        }
    }
}

@end
