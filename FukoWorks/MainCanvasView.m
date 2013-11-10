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
    //ペイント枠だったら記憶しておく
    if([_focusedObject isKindOfClass:[CanvasObjectPaintFrame class]]){
        drawingPaintFrame = (CanvasObjectPaintFrame *)_focusedObject;
        NSLog(@"paintFrame!");
    } else{
        drawingPaintFrame = nil;
    }
}
- (NSSize)canvasSize{
    return baseFrame.size;
}
- (void)setCanvasSize:(NSSize)canvasSize
{
    baseFrame.size = canvasSize;
    [self setCanvasScale:self.canvasScale];
}

@synthesize canvasObjects = _canvasObjects;

//
// Function
//

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        undoManager = [[NSUndoManager alloc] init];
        
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
        _canvasObjects = [NSMutableArray array];
        
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
    
    //key取得のためにFirstResponderに設定
    [self.superview.window makeFirstResponder:self];
    //ドラッグしたらNOにする。
    clickOnly = YES;
    
    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mDw:%@", NSStringFromPoint(currentPoint)]];

    if(editingObject == nil){
        //作成中の図形はない
        //図形の新規作成or移動
        switch(self.toolboxController.drawingObjectType){
            case Undefined:
                //カーソルモード
                //図形移動を初期化
                movingObject = [self getCanvasObjectAtCursorLocation:event];
                if(movingObject){
                    moveHandleOffset = NSMakePoint(currentPoint.x - movingObject.frame.origin.x, currentPoint.y - movingObject.frame.origin.y);
                }
                //移動中はフォーカスを消す
                [_focusedObject setFocused:NO];
                break;
            case Rectangle:
                editingObject = [[CanvasObjectRectangle alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
                break;
            case Ellipse:
                editingObject = [[CanvasObjectEllipse alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
                break;
            case PaintFrame:
                editingObject = [[CanvasObjectPaintFrame alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
                break;
            case PaintRectangle:
            case PaintEllipse:
                NSLog(@"Draw in paint frame.\n");
                break;
            default:
                NSLog(@"Not implemented operation to make a new object.\n");
                break;
        }
        if(editingObject != nil){
            editingObject.FillColor = self.toolboxController.drawingFillColor;
            editingObject.StrokeColor = self.toolboxController.drawingStrokeColor;
            editingObject.StrokeWidth = self.toolboxController.drawingStrokeWidth;
            editingObject.undoManager = undoManager;
            [self appendCanvasObject:editingObject];
            
            editingObject = [editingObject drawMouseDown:currentPoint];
        }
    } else{
        //図形描画の途中
        editingObject = [editingObject drawMouseDown:currentPoint];
    }
    //ペイント枠に描くなら描く
    if(drawingPaintFrame){
        drawingPaintFrame.FillColor = self.toolboxController.drawingFillColor;
        drawingPaintFrame.StrokeColor = self.toolboxController.drawingStrokeColor;
        drawingPaintFrame.StrokeWidth = self.toolboxController.drawingStrokeWidth;
        [drawingPaintFrame drawPaintFrameMouseDown:currentPoint mode:self.toolboxController.drawingObjectType];
    }
}

- (void)mouseDragged:(NSEvent*)event
{
    NSPoint currentPoint;
    
    //ドラッグしたのでクリックのみではなかったと記録
    clickOnly = NO;
    
    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mDr:%@", NSStringFromPoint(currentPoint)]];
    
    //作成中の図形があるなら座標を送る
    editingObject = [editingObject drawMouseDragged:currentPoint];
    
    //図形移動するならする
    [movingObject setFrameOrigin:NSMakePoint(currentPoint.x - moveHandleOffset.x, currentPoint.y - moveHandleOffset.y)];

    //ペイント枠に描くなら描く
    [drawingPaintFrame drawPaintFrameMouseDragged:currentPoint mode:self.toolboxController.drawingObjectType];
}

- (void)mouseUp:(NSEvent*)event
{
    NSPoint currentPoint;

    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mUp:%@", NSStringFromPoint(currentPoint)]];
 
    editingObject = [editingObject drawMouseUp:currentPoint];
    
    //図形移動終了
    movingObject = nil;
    //フォーカスを戻す
    [_focusedObject setFocused:YES];
    
    //ペイント枠に描くなら描く
    [drawingPaintFrame drawPaintFrameMouseUp:currentPoint mode:self.toolboxController.drawingObjectType];
    
    if(clickOnly){
        //ドラッグしなかったので、クリックのみ。
        //フォーカスを与える。
        self.focusedObject = [self getCanvasObjectAtCursorLocation:event];
    }
    
    
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    NSPoint currentPointInScreen;
    currentPointInScreen = [self getPointerLocationInScreen:theEvent];
    
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
        [[anInspectorWindowController window]setFrameOrigin:currentPointInScreen];
    }
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    //self.focusedObject = [self getCanvasObjectAtCursorLocation:theEvent];
}
/*
- (void)keyDown:(NSEvent *)theEvent
{
    NSInteger keyCode;
    
    keyCode = [theEvent keyCode];
    NSLog(@"%ld", keyCode);
 
    switch(keyCode){
        case 51:
            //Backspace
        case 117:
            //Delete(Backspace+Fn)
            [self removeCanvasObject:_focusedObject];
            break;
    }
 
}
*/

-(void)resetCursorRects
{
    [self discardCursorRects];
    if(_toolboxController.drawingObjectType == Undefined){
        [self addCursorRect:self.visibleRect cursor:[NSCursor arrowCursor]];
    } else{
        [self addCursorRect:self.visibleRect cursor:[NSCursor crosshairCursor]];
    }
}

// add / remove CanvasObject

- (void)appendCanvasObject:(CanvasObject *)aCanvasObject
{
    [self addSubview:aCanvasObject];
    [_canvasObjects addObject:aCanvasObject];
    NSLog(@"Added CanvasObject to %@ \n%@\n", self.className, self.subviews.description);
    [[CanvasObjectListWindowController sharedCanvasObjectListWindowController] reloadData];
}

- (void)removeCanvasObject:(CanvasObject *)aCanvasObject
{
    if(_focusedObject == aCanvasObject){
        self.focusedObject = nil;
    }
    if(editingObject == aCanvasObject){
        editingObject = nil;
    }
    if(movingObject == aCanvasObject){
        movingObject = nil;
    }
    [aCanvasObject removeFromSuperview];
    [_canvasObjects removeObject:aCanvasObject];
    if(aCanvasObject != nil){
        NSLog(@"Removed CanvasObject. \n%@\n", self.subviews.description);
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
            [self appendCanvasObject:aCanvasObject];
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
// Printing
//

// https://developer.apple.com/library/mac/documentation/cocoa/conceptual/Printing/osxp_pagination/osxp_pagination.html
- (NSSize)calculatePrintPaperSize
{
    //用紙の大きさを取得
    NSPrintInfo *pinfo = [[NSPrintOperation currentOperation] printInfo];
    
    NSSize paperSize = [pinfo paperSize];
    
    float pageHeight = paperSize.height - [pinfo topMargin] - [pinfo bottomMargin];
    float pageWidth = paperSize.width - [pinfo leftMargin] - [pinfo rightMargin];

    float scale = [[[pinfo dictionary] objectForKey:NSPrintScalingFactor]
                   floatValue];
    
    return NSMakeSize(pageWidth / scale, pageHeight / scale);

}

- (BOOL)knowsPageRange:(NSRangePointer)range
{
    //必要なページ数をrangeに設定
    NSSize paperSize = [self calculatePrintPaperSize];
    CGFloat pages;
    pages = ceil(self.frame.size.width / paperSize.width) * ceil(self.frame.size.height / paperSize.height);
    *range = NSMakeRange(1, pages);
    NSLog(@"pages:%f", pages);
    
    return YES;
}

- (NSRect)rectForPage:(NSInteger)page
{
    //指定されたページ番号に該当するview上の範囲を返す。
    NSInteger xpages, ypages, x, y;
    NSSize paperSize = [self calculatePrintPaperSize];
    NSRect rect;
    xpages = ceil(self.frame.size.width / paperSize.width);
    ypages = ceil(self.frame.size.height / paperSize.height);
    if(page > xpages * ypages){
        //範囲外のページ番号だった
        NSLog(@"zerorect:");
        return NSZeroRect;
    }
    page--;
    y = (page / xpages);
    x = (page % xpages);
    
    rect = NSMakeRect(paperSize.width * x, paperSize.height * y,
                      paperSize.width, paperSize.height);
    NSLog(@"rect:%@", NSStringFromRect(rect));
    
    return rect;
}

//
// MenuItem
//

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if( [menuItem action] == @selector(cut:) ||
       [menuItem action] == @selector(copy:) ||
       [menuItem action] == @selector(delete:) ){
        return (_focusedObject != nil);
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
    if(_focusedObject){
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard declareTypes:[NSArray arrayWithObject:FWK_PASTEBOARD_TYPE] owner:nil];
        [pasteboard setData:[[self convertCanvasObjectsToString:[NSArray arrayWithObject:_focusedObject]] dataUsingEncoding:NSUTF8StringEncoding] forType:FWK_PASTEBOARD_TYPE];
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
    [self removeCanvasObject:_focusedObject];
}

//
// Undo / Redo
//

- (IBAction)undo:(id)sender
{
    [undoManager undo];
}
- (IBAction)redo:(id)sender
{
    [undoManager redo];
}

@end
