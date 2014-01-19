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
}
/*
@synthesize focusedObject = _focusedObject;
- (void)setFocusedObject:(CanvasObject *)focusedObject
{
    if(focusedObject != _focusedObject){
        [_focusedObject setFocused:NO];
        [focusedObject setFocused:YES];
    }
    _focusedObject = focusedObject;
    _toolboxController.editingObject = focusedObject;
    //ペイント枠だったら記憶しておく
    if([_focusedObject isKindOfClass:[CanvasObjectPaintFrame class]]){
        drawingPaintFrame = (CanvasObjectPaintFrame *)_focusedObject;
        NSLog(@"paintFrame!");
    } else{
        drawingPaintFrame = nil;
    }
    
    [overlayView setNeedsDisplay:YES];
}
 */
- (NSSize)canvasSize{
    return rootSubCanvas.frame.size;
}
- (void)setCanvasSize:(NSSize)canvasSize
{
    //[overlayView setFrameSize:baseFrame.size];
    [rootSubCanvas setFrameSize:canvasSize];
    [self setCanvasScale:self.canvasScale];
}

@synthesize canvasObjects = _canvasObjects;
@synthesize realSizeCanvas = rootSubCanvas;

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
        
        editingObject = nil;
        movingObject = nil;
        
        inspectorWindows = [NSMutableArray array];
        _canvasObjects = [NSMutableArray array];
        
        //overlayView = [[OverlayCanvasView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        //[self addSubview:overlayView];
        //overlayView.canvasObjectList = _canvasObjects;
        
        rootSubCanvas = [[SubCanvasView alloc] initWithFrame:frame];
        [self addSubview:rootSubCanvas];
        
        objectHandles = [[NSMutableDictionary alloc] init];
        
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
    [rootSubCanvas addSubview:aCanvasObject positioned:NSWindowAbove relativeTo:nil];
    [_canvasObjects addObject:aCanvasObject];
    NSLog(@"Added CanvasObject to %@ \n%@\n", rootSubCanvas.className, rootSubCanvas.subviews.description);
    [[CanvasObjectListWindowController sharedCanvasObjectListWindowController] reloadData];
}

- (void)removeCanvasObject:(CanvasObject *)aCanvasObject
{
    /*
    if(_focusedObject == aCanvasObject){
        self.focusedObject = nil;
    }
     */
    if(editingObject == aCanvasObject){
        editingObject = nil;
    }
    if(movingObject == aCanvasObject){
        movingObject = nil;
    }
    [aCanvasObject removeFromSuperview];
    [_canvasObjects removeObject:aCanvasObject];
    if(aCanvasObject != nil){
        NSLog(@"Removed CanvasObject. \n%@\n", rootSubCanvas.subviews.description);
    }
    [[CanvasObjectListWindowController sharedCanvasObjectListWindowController] reloadData];
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
    NSPoint currentPoint;
    CanvasObject *aCanvasObject, *candidateCanvasObject;
    NSBitmapImageRep *bitmapImage;
    NSPoint currentPointInObject;
    NSColor *pointColor;
    NSArray *subviews = [[rootSubCanvas.subviews reverseObjectEnumerator] allObjects];
    
    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    
    candidateCanvasObject = nil;
    for(NSView *aSubview in subviews){
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
    
    NSLog(@"%@", candidateCanvasObject);

    return candidateCanvasObject;
}


//
//TypeID:data1a,data1b,data1c|data2a,data2b,data2c\n
//
- (void)writeCanvasToURL:(NSURL *)url atomically:(BOOL)isAtomically
{
    NSString *saveData;
    NSError *error;
    
    saveData = [self convertCanvasObjectsToString:self.subviews];

    error = nil;
    if(![saveData writeToURL:url atomically:isAtomically encoding:NSUTF8StringEncoding error:&error]){
        NSRunAlertPanel(@"FukoWorks-Error-", [error localizedDescription], @"OK", nil, nil);
    }
}

- (NSString *)convertCanvasObjectsToString:(NSArray *)canvasObjects
{
    //渡されたNSArray中のCanvasObjectを示す文字列を生成し返す。
    CanvasObject *aCanvasObject;
    NSMutableString *stringRep;
    stringRep = [[NSMutableString alloc] initWithFormat:@"[FukoWorKs]:%ld\n", [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] integerValue]];
    
    for(NSView *aSubview in canvasObjects){
        if([aSubview isKindOfClass:[CanvasObject class]]){
            aCanvasObject = (CanvasObject *)aSubview;
            
            switch(aCanvasObject.ObjectType){
                case Rectangle:
                case Ellipse:
                case PaintFrame:
                    [stringRep appendFormat:@"%ld:", aCanvasObject.ObjectType];
                    [stringRep appendFormat:@"%@\n",[aCanvasObject encodedStringForCanvasObject]];
                    break;
                default:
                    NSLog(@"Not implemented operation to save object type %ld.\n", aCanvasObject.ObjectType);
                    break;
            }
        }
    }

    return [NSString stringWithString:stringRep];
}

- (void)appendCanvasObjectsFromString:(NSString *)stringRep
{
    //渡された文字列からCanvasObjectを生成し追加する。
    NSArray *dataList;
    NSArray *dataItem;
    NSString *aDataString;
    NSString *dataItemsString;
    NSUInteger i, i_max;
    CanvasObject *aCanvasObject;

    dataList = [stringRep componentsSeparatedByString:@"\n"];
    
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
        NSRunAlertPanel(@"FukoWorks-警告-", @"読み込もうとしているデータは、より新しいバージョンのFukoWorksで作成されたものであり、正常に読み込めない可能性があります。", @"OK", nil, nil);
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
                
            case PaintFrame:
                aCanvasObject = [[CanvasObjectPaintFrame alloc] initWithEncodedString:[dataItem objectAtIndex:1]];
                break;
                
            default:
                NSLog(@"Not implemented operation to load object type %ld.\n", aDataString.integerValue);
                break;
        }
        if(aCanvasObject != nil){
            [self addCanvasObject:aCanvasObject];
            NSLog(@"Added CanvasObject to %@ \n%@\n", self.className, self.subviews.description);
        }
    }
}

- (void)loadCanvasFromURL:(NSURL *)url
{
    NSString *dataString;
    NSError *error;
    
    error = nil;
    dataString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];

    [self appendCanvasObjectsFromString:dataString];
}

//
// MenuItem
//

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if( [menuItem action] == @selector(cut:) ||
       [menuItem action] == @selector(copy:) ||
       [menuItem action] == @selector(delete:) ){
        return /*(_focusedObject != nil)*/ NO;
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
    /*
    if(_focusedObject){
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard declareTypes:[NSArray arrayWithObject:FWK_PASTEBOARD_TYPE] owner:nil];
        [pasteboard setData:[[self convertCanvasObjectsToString:[NSArray arrayWithObject:_focusedObject]] dataUsingEncoding:NSUTF8StringEncoding] forType:FWK_PASTEBOARD_TYPE];
    }
     */
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
    //[self removeCanvasObject:_focusedObject];
}



@end
